//
//  REOperationMgr.swift
//  Remolet
//
//  Created by Liwei Zhang on 2014-11-30.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

import Foundation

/*
The goal of the app is to provide offline like UX while sync with server. So the priorities of the app's tasks from top to bottom are:
1. highly responsive to user's action: use like an offline app
2. push local db changes to server db: this is consistent with point 1
3. sync with server db: to get the latest db that user builds through all devices

There are three queues (by priority):
1. local db operations
2. UI snapshot transitions
3. sync cycle

Based on above, priorities for any operation are:
1. Always proceed local change to db instantly.
2. Send local changes to server
3. Send sync request

Each time a change is committed to local db, its state changes from A to B. Because local change to db is the top priority, the only top state change is local A to local B(we use lA and lB in the rest of this section).
The order with no interruption is:
local change made to db =>
analyze local changes has not successfully processed by server and push again till no one left =>
sync with server => done
Now, let's take db priorities into account. Local change is an instant interruption. requestID, which is the record in local db to mark is one request is successfully processed by server, is not an instant interruption but it has the same priority to be processed before others. since we want to send as few repetitive requests as possible. Sync cycle, which includes analyzing uncommitted local changes and sending requests(see comments in other files for details) is stopped instantly when any of previous two instant interruptions occurs. And a new sync cycle starts when necessary.
Because communication between client and server is async, not all feedbacks from server can be received before another ii(instant interruption) happens. Once an ii happens, all the unproccessed(including both received and not received) feedbacks are dismissed, except requestId, which's state update can only be made from server, in other words, user can not change it locally.

*senario with no interruption happens before everything is done*
lA => analyze local db and push each uncommitted change => lB, lC, lD... => all changes done => send sync request and successfully proccessed => lSynced
Local db transaction priority:
1. user activity / requestId operation
2. JSON in response
*senario B: interruption occurs before everything is done*
At least four possible ii points:
lA => analyze local db and push each uncommitted change (a)ii => lB, lC... (b)ii => all changes done (c)ii => send sync request and successfully proccessed (d)ii => lSynced

Except user-triggerd db/server operations, all the rest are composed of sync cycles. Ongoing cycles can be interrupted by user activities and new cycles start afterwards. Interrupted cycles need to be stopped immediatedly. Thus, the data/request operations derived from the interrupted cycle have to be stopped asap, too. Because new state will be taken care of by the new sync cycle. As for the parts already done for the stopped cycle, just leave them as is since new cycles will put new layers on them if necessary.
Based on above notion, the key is to stop any given cycle and its derived operations. A good way is to assign a DNA to the cycle and its operations so that we can easily identify them with their DNA. A DNA here in the context of digital world can simply be a UUID. We set checkpoint for operations before they run to stop them. It's like isCancelled for NSOperation, but with the DNA, we can specifically have a cycle stopped without extra steps.
There is also a need for something to record the order of the DNAs to let the app know which ones to stop and which ones to proceed. A NSMutableArray is ideal for this task. However, at any moment, there is only one sync cycle can be valid at most. And sometimes no sync cycle is valid. So we can use a NSMutableString to store the current valid dna and while no cycle is valid, simply set it as empty.
We also need to know when a cycle starts and ends. It starts when (a) user triggers create/update/delete/sync operations (b) some viewController launches: tableView for cards (c) client check with server regularly. It ends when (a) a cycle is completed (b) a new cycle starts before the previous one ends.
Sync request is generated and sent when the rest

We choose to use NSOperationQueue to manage above process. Meanwhile, use another array to store the NSOperation so that we could easily locate any given NSOperation to make further change after it is added to the queue, such as cancellation. Completed and cancelled ones are removed from the array right away.
The NSOperation in queue above contains a ctx serving as a channel to do data transaction in local db. The queue itself is actually a queue for local db transactions. So any given time, there is only one ctx working on local db transaction.

To prevent concurrent ctx operation (yes, we can use merge policy, but we don't want to add that layer to this app for now), we use a queue mentioned above to manage the process of all the ctxes so that each time only one ctx is processed. It's on the main thread. There is another queue, comWorker(NSOperationQueue, name abbreviated from communication worker). comWorker is on a background thread, all the operation does not block main thread. All communications with server are on comWorker.
*/


// MARK: - Snapshot UI
/*
OperationMgr is to manage all the operations in this app. It keeps the status of the app's current UI state and the next UI state and processes operations related between them.
The system is snapshots based. i operations happen after snapshot n and before snapshot n + 1 so that snapshot n + 1 shows the updated state of the app after i operations are done.
However, operations' timing of arrival and completion may not on a batch basis. A simple example is operationA for snapshot n may comes later than operatiopnB for snapshot n + 1. We are expecting a mix stream of operations. To solve this, we add a unique identifier for each snapshot. All operations for a given snapshot hold the id to link themselves to the snapshot. We call it snapshotId.
Each snapshot
*/

// MARK: - Operation Priorities
// To block lower priority operations.
// All operations on the record user is interacting with are disabled. User interaction includes editing/choosingToDeleting an existing record. During this period, (1) no request is allowed to be generated, (2) ongoing request does not commit to local db, (3) waiting-listed request is cancelled.

// MARK: - sync cycle
// First find undone records one by one, and after all are clear, send sync request. The process can be disrupted at any time when local db changes.

// The user in sync cycle is for deviceInfo
/*
We have to fulfill two goals:
A. push latest local content change to server.
B. get most updated content from server after all.

For A, we need:
(1) the specific type of crud operation to generate correct url.
(2) a way to find out which records to be pushed to server.
(3) something to record each request's completion status.
For (1) keep all the operations for a record in an array.
For (2) add a flag to each record.
For (3) create an obj for each request to record the completion status.

Regarding (2) above, due to the async nature of push operation, there could be new operation done to the local record after the request for previous change is sent. The 200 response can only indicates previous operation is pushed, not that there is nothing to push to server for this record now. So a straightforward flag may not be the simple answer to this. An easy way is to append the request info in the array as well. Because a request is specificly corresponding to a crud operation, it's better to have crud operation and request info in on objin the array. Thus, (3) is fulfilled,too.
Based on the reasons above, we create TVRequestIdCandidate as the element for the array. A TVRequestIdCandidate contains: (a) the info of crud operation type (b) a flag to mark a request is done if needed, which is marked done when 200 response is received. (c) the requestId to identify any potential request both on client and server (d) operationVersion to store the order number to indicate the sequence of each element to form the array. A non-nil requestId indicates it's an element having corresponding request sent.


When nil is returned, which indicates no requestId for next steps, we don't need to proceed further since the client has already got the message from server that the request has been successfully processed on server.
*/
// Get the number of uncommitted records every time. Each successful following request decrease it by one. When zero is reached, trigger syncCycle to check and send sync request accordingly.

// MARK: - communicate with server
/*
When communicate with server, only status matters.
A requestID is triggered to be generated when there is new status since last sync. It is subject to serverID's existence and specific operation. We try to generate requestID as less as possible. So each scan only go through the full cycle of request/response for one sellected record. No matter whether resonse is successfully received by client, after a cycle finishes, scan again to meet any one of selected records. Repeat this till a scan returns no record and run sync request afterwards.
RequestID for update operation is generated everytime record being updated in db. Use NSManagedObjectContextObjectsDidChangeNotification to do this before checking server availability. This is because we use RequestID to link each update with one unique requestID to setup a one to one relationship to make sure right content is submitted to server. For record with valid serverID, TVDocUpdated is set. For record with empty serverID, TVDocNew is used.
lastUnsyncAction == TVDocDeleted and last requestID is for deletion block all attempt to add new requestID to list since there is no way to create/update/delete a deleted record.

1. check server availability when:
a. user launches the app, check in background, user not disrupted
b. db changed locally, this can be monitored by NSManagedObjectContextObjectsDidChangeNotification, check in background, user not disrupted
c. user triggers the sync button/refresh control, check in main operation queue, user has to wait

2. scan local db to find out records uncommited to server
criteria: lastUnsyncAction != TVDocNoAction, this is set to TVDocNoAction everytime a successful process response received by client and to other values once change is committed to local db.

3. further analyze
a. if serverID is empty
In this case, only "TVDocNew" request has been sent since, without a serverID, there is no way to update/delete a record on sever. There could be multiple "TVDocNew" requests sent due to local update operation after the initial local create operation. Without the serverID, local update operation is treated as creating a new record to the server each time. When user delete it locally, the delete operation could not be able to trigger any request due to its lack of the serverID. So the record has different version of records on server as many as the requests it sends to the server since each time a new record is created on server. When syncing, those records are delivered back to client and the local record is deleted accordingly. User has to delete the redundant records after the sync process. User also may find the deleted local record show up again since it is not deleted on server. The one on server is copied back to the client as a new record. User has to delete it again.
i. no requestID in hasReqID
No request has been generated and sent for this record. Generate a "TVDocNew" request and send. Add one requestID to the list.
ii. requestID in hasReqID and last one done
Because we only care about the latest content of the record, only latest requestID needs to be checked. Last request has been handled by server successfully, which indicates there is an updated record for it on server already. Wait for the next sync to get that record.
iii. requestID in hasReqID and last one undone
Send request again.
b. serverID is not empty
This is the record that has synchronized with server successfully, from which it in turn gets a serverID, editAction "TVDocNew" is impossible to be here.
Locally deleted records and their related requestIDs have TVDocDeleted in their lastUnsyncAction fields and not deleted till corresponding requests being successfully processed.
i. no requestID in hasReqID
Generate a request based on lastUnsyncAction and send. Add one requestID to the list.
ii. requestID in hasReqID and last one is done
All current status is submitted to server successfully. Nothing to do.
iii. requestID in hasReqID and last one undone
Since we only care about the latest content, so:
a. lastUnsyncAction == TVDocUpdated, which is to update, and last requestID is undone, only send update request with the last requestIDs.
b. lastUnsyncAction == TVDocDeleted, which is to delete, if the last requestID is not for deletion, add one, then send delete request.

Local operation is not locked by communicating with server to ensure client is fully responsive almost any time.
So while local db is executing write task and user is editing existing records(create a new record not included here), the feedback from server to db should be blocked, which means not to commit change from server to local db. In this case, set corresponding requestID to done if successful without commit change to local db. Scan and communicate with server later. For sync response, ignore the result and sync next time. When user is in card editing section, stop sending any request and ignore all the responses (well, this can be optimized by only ignore the response of the related card, But let's leave it for now).

Merge response's result into local db:

1. serverID is empty
All the requests sent were to create new records on server. Only merge the result for the latest request to make sure all local following potential operations to this record is based on the last content in local db. Keep the unsynced record till it is updated with serverID.
In the case of sync process, which there is no easy way to match the one from server and the one in local, delete the local one and insert the one from server. Because sync process is not proceeded when any local change is not successfully committed to the server, so we can make sure the commited results from sync process are the most updated status for both server and local. Delete local records without serverId afterwards.

2. serverID is not empty
Only merge the response for the latest requestId since the result of previous request may conflict with the local record's content. So we only commint the last one the ensure there is absolutely no conflict.
*/
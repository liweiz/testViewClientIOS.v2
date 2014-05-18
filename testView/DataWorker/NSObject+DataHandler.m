//
//  NSObject+DataHandler.m
//  testView
//
//  Created by Liwei on 2014-05-14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "NSObject+DataHandler.h"
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestId.h"

@implementation NSObject (DataHandler)

/*
 When communicate with server, only status matters.
 A requestID is triggered to be generated when there is new status since last sync. It is subject to serverID's existence and specific operation. We try to generate requestID as less as possible. So each scan only go through the full cycle of request/response for one sellected record. No matter whether resonse is successfully received by client, after a cycle finishes, scan again to meet any one of selected records. Repeat this till a scan returns no record and run sync request afterwards.
 RequestID for update operation is generated everytime record being updated in db. Use NSManagedObjectContextObjectsDidChangeNotification to do this before checking server availability. This is because we use RequestID to link each update with one unique requestID to setup a one to one relationship to make sure right content is submitted to server. For record with valid serverID, TVDocUpdated is set. For record empty serverID, TVDocNew is used.
 lastUnsyncAction == TVDocDeleted and last requestID is for deletion block all attempt to add new requestID to list since there is no way to create/update/delete a deleted record.
 1. check server availability when:
 a. user launches the app, check in background, user not disrupted
 b. db changed locally, this can be monitored by NSManagedObjectContextObjectsDidChangeNotification, check in background, user not disrupted
 c. user triggers the sync button/refresh control, check in main operation queue, user has to wait
 2. scan local db to find out records uncommited to server
 criteria: lastUnsyncAction != TVDocNoAction, this is set to TVDocNoAction everytime a successful process response received by client and to other values once change is committed to local db.
 3. further analyze
 a. if serverID is empty
 In this case, only "TVDocNew" request has been sent since without a serverID, there is no way to update/delete a record on sever. There could be multiple "TVDocNew" requests sent due to local update operation after the initial local create operation. Without the serverID, local update operation is treated as creating a new record to the server each time. When user delete it locally, the delete operation could not be able to trigger any request due to its lack of the serverID. So the record has  different version of records on server as many as the requests it sends to the server since each time a new record is created on server. When syncing, those records are delivered back to client and the local record is deleted accordingly. User has to delete the redundant records after the sync process. User also may find the deleted local record show up again since it is not deleted on server. The one on server is copied back to the client as a new record. User has to delete it again.
 1. no requestID in hasReqID
 No request has been generated and sent for this record. Generate a "TVDocNew" request and send. Add one requestID to the list.
 2. requestID in hasReqID and last one done
 Because we only care about the latest content of the record, only latest requestID needs to be checked. Last request has been handled by server successfully, which indicates there is an updated record for it on server already. Wait for the next sync to get that record.
 3. requestID in hasReqID and last one undone
 Send request again.
 b. serverID is not empty
 This is the record that has synchronized with server successfully, from which it in turn gets a serverID, editAction "TVDocNew" is impossible to be here.
 Locally deleted records and their related requestIDs have TVDocDeleted in their lastUnsyncAction fields and not deleted till corresponding requests being successfully processed.
 1. no requestID in hasReqID
 Generate a request based on lastUnsyncAction and send. Add one requestID to the list.
 2. requestID in hasReqID and last one is done
 All current status is submitted to server successfully. Nothing to do.
 3. requestID in hasReqID and last one undone
 Since we only care about the latest content, so:
 a. lastUnsyncAction == TVDocUpdated, which is to update, and last requestID is undone, only send update request with the last requestIDs.
 b. lastUnsyncAction == TVDocDeleted, which is to delete, if the last requestID is not for deletion, add one, then send delete request.
 
 Local operation is not locked by communicating with server to ensure client is fully responsive almost any time.
 So while local db is executing write task and user is editing existing records(create a new record not included here), the feedback from server to db should be blocked, which means not to commit change from server to local db. In this case, set corresponding requestID to done if successful without commit change to local db. Scan and communicate with server later.
 */

- (TVBase *)scanDBForUndone:(NSSet *)objSet
{
    for (TVBase *x in objSet) {
        if (x.lastUnsyncAction.integerValue != TVDocNoAction) {
            return x;
        }
    }
    return nil;
}

- (void)setupNewDocBaseLocal:(TVBase *)doc
{
    doc.serverId = @"";
    doc.localId = [[NSUUID UUID] UUIDString];
    doc.lastUnsyncAction = [NSNumber numberWithInteger:TVDocNew];
    doc.lastModifiedAtLocal = [NSDate date];
}

- (void)setupNewDocBaseServer:(TVBase *)doc fromRequest:(NSMutableDictionary *)dic
{
    doc.serverId = [dic valueForKey:@"serverId"];
    doc.lastUnsyncAction = [NSNumber numberWithInteger:TVDocNoAction];
    doc.lastModifiedAtServer = [dic valueForKey:@"lastModifiedAtServer"];
    doc.versionNo = [dic valueForKey:@"versionNo"];
}

- (void)setupNewUser:(TVUser *)user withDic:(NSMutableDictionary *)dic
{
    user.activated = [dic valueForKey:@"activated"];
    user.deviceUUID = [dic valueForKey:@"deviceUUID"];
    user.email = [dic valueForKey:@"email"];
    user.isLoggedIn = [dic valueForKey:@"isLoggedIn"];
    user.rememberMe = [dic valueForKey:@"rememberMe"];
    user.sortOption = [dic valueForKey:@"sortOption"];
    user.sourceLang = [dic valueForKey:@"sourceLang"];
    user.targetLang = [dic valueForKey:@"targetLang"];
}

- (void)setupNewCard:(TVCard *)card withDic:(NSMutableDictionary *)dic
{
    card.belongTo = [dic valueForKey:@"belongTo"];
    card.collectedAt = [NSDate date];
    card.context = [dic valueForKey:@"context"];
    card.detail = [dic valueForKey:@"detail"];
    card.target = [dic valueForKey:@"target"];
    card.translation = [dic valueForKey:@"translation"];
    card.sourceLang = [dic valueForKey:@"sourceLang"];
    card.targetLang = [dic valueForKey:@"targetLang"];
}

- (void)setupNewRequestId:(TVRequestId *)doc action:(NSInteger)a for:(TVBase *)base
{
    doc.editAction = [NSNumber numberWithInteger:a];
    doc.requestId = [[NSUUID UUID] UUIDString];
    doc.done = NO;
    doc.createdAtLocal = [NSDate date];
    doc.lastModifiedAtLocal = [NSDate date];
    doc.operationVersion = [NSNumber numberWithInteger:[self getRequestIdOperationVersion:base]];
}

- (void)updateDocBaseLocal:(TVBase *)doc
{
    // requestID is not processed here
    doc.lastUnsyncAction = [NSNumber numberWithInteger:TVDocUpdated];
    doc.lastModifiedAtLocal = [NSDate date];
}

- (void)markRequestIdAsDone:(TVRequestId *)reqId
{
    // change in requestID does not change time modified
    reqId.done = [NSNumber numberWithBool:YES];
    reqId.lastModifiedAtLocal = [NSDate date];
}

- (void)updateDocBaseServer:(TVBase *)doc withDic:(NSMutableDictionary *)dic
{
    doc.lastModifiedAtServer = [NSDate date];
    doc.serverId = [dic valueForKey:@"serverId"];
    doc.versionNo = [dic valueForKey:@"versionNo"];
}

- (void)updateUser:(TVUser *)user withDic:(NSMutableDictionary *)dic
{
    user.activated = [dic valueForKey:@"activated"];
    user.deviceUUID = [dic valueForKey:@"deviceUUID"];
    user.sortOption = [dic valueForKey:@"sortOption"];
    user.sourceLang = [dic valueForKey:@"sourceLang"];
    user.targetLang = [dic valueForKey:@"targetLang"];
}

- (void)updateCard:(TVCard *)card withDic:(NSMutableDictionary *)dic
{
    card.belongTo = [dic valueForKey:@"belongTo"];
    if ([dic valueForKey:@"collectedAt"]) {
        card.collectedAt = [dic valueForKey:@"collectedAt"];
    }
    card.context = [dic valueForKey:@"context"];
    card.detail = [dic valueForKey:@"detail"];
    card.target = [dic valueForKey:@"target"];
    card.translation = [dic valueForKey:@"translation"];
    card.sourceLang = [dic valueForKey:@"sourceLang"];
    card.targetLang = [dic valueForKey:@"targetLang"];
}

#pragma mark - requestID related process
- (NSInteger)getRequestIdOperationVersion:(TVBase *)base
{
    if ([base.hasReqId count] == 0) {
        return 1;
    } else {
        NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:YES];
        return [[[base.hasReqId sortedArrayUsingDescriptors:@[s]].lastObject operationVersion] integerValue] + 1;
    }
}

- (BOOL)dismissChangeToDBRecord:(TVBase *)base requestIdObj:(TVRequestId *)d
{
    // For given record in local db base, check response for request identified by d if the change should be dismissed.
    NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:NO];
    NSArray *a = [base.hasReqId sortedArrayUsingDescriptors:@[s]];
    NSInteger i = [a indexOfObject:d];
    NSInteger j = [a indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(TVRequestId *)obj done] boolValue] == YES) {
            return YES;
        }
        return NO;
    }];
    if (i < j) {
        return NO;
    } else {
        return YES;
    }
}

@end

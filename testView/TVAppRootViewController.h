//
//  TVAppRootViewController.h
//  testView
//
//  Created by Liwei Zhang on 2013-10-18.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVBlockIndicator.h"
#import "TVNonBlockIndicator.h"
#import "TVLoginViewController.h"
#import "KeychainItemWrapper.h"
#import "TVLangPickViewController.h"
#import "TVActivationViewController.h"
#import "TVContentRootViewController.h"

@interface TVAppRootViewController : UIViewController

@property (strong, nonatomic) NSFetchRequest *userFetchRequest;

@property (strong, nonatomic) TVLoginViewController *loginViewController;
@property (strong, nonatomic) TVActivationViewController *activationViewController;
@property (strong, nonatomic) TVLangPickViewController *nativeViewController;
@property (strong, nonatomic) TVLangPickViewController *targetViewController;
@property (strong, nonatomic) TVContentRootViewController *contentViewController;

@property (assign, nonatomic) BOOL requestReceivedResponse;
@property (assign, nonatomic) BOOL willSendRequest;
@property (assign, nonatomic) BOOL internetIsAccessible;

@property (strong, nonatomic) KeychainItemWrapper *passItem;

@property (strong, nonatomic) TVBlockIndicator *bIndicator;
@property (strong, nonatomic) TVNonBlockIndicator *nbIndicator;
@property (strong, nonatomic) UILabel *sysMsg;

@property (strong, nonatomic) UILabel *warning;

- (void)showSysMsg:(NSString *)msg;
- (void)sendActivationEmail:(BOOL)isUserTriggered;

/*
 Local db faces the challenge that changes from both local user activities and server feedbacks(through http response).
 The priorities of the app's tasks from top to bottom are:
 1. highly responsive to user's action: use like an offline app
 2. push local db changes to server db: this is consistent with point 1
 3. sync with server db: to get the latest db that user builds through all devices
 
 Based on above, priorities are:
 1. Always proceed local change to db first.
 2. Send local changes to server
 3. Send sync request
 
 Each time a change is committed to local db, its state changes from A to B. Because local change to db is the top priority, the only top state change is local A to local B(we use lA and lB in the rest of this section).
 The order with no interruption is:
 local change made to db =>
 analyze local changes has not successfully processed by server and push again till no one left =>
 sync with server => done
 Now, let's take db priorities into account. Local change is an instant interruption. requestID, which is the record in local db to mark is one request is successfully processed by server, is not an instant interruption but it has the same priority to be processed before others. since we want to send as few repetitive requests as possible. Sync cycle, which includes analyzing uncommitted local changes and sending requests(see comments in other files for details) is stopped instantly when previous two instant interruptions occur. And a new sync cycle starts when necessary.
 Because communication between client and server is async, not all feedbacks from server can be received before another ii(instant interruption) happens. Once an ii happens, all the unproccessed(including both received and not received) feedbacks are dismissed, except requestId, which's state update can only be made from server, in other words, user can not change it locally.
 
 *senario A: no interruption happens before everything is done*
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

@end

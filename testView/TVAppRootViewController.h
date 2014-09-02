//
//  TVAppRootViewController.h
//  testView
//
//  Created by Liwei Zhang on 2013-10-18.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVUser.h"
#import "TVIndicator.h"
#import "TVLoginViewController.h"
#import "KeychainItemWrapper.h"
#import "TVLangPickViewController.h"
#import "TVActivationViewController.h"
#import "TVCommunicator.h"
#import "TVRootViewCtlBox.h"
#import "TVContentRootViewController.h"

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
 Because communication between client and server is async, not all feedbacks from server can be received before another ii(instant interruption) happens. Once an ii happens, all the unproccessed(including both received and not received) feedbacks are dismissed, except requestId.
 *senario A: no interruption happens before everything is done*
 lA => analyze local db and push uncommitted changes => all changes done => send sync request and successfully proccessed => lB
 Local db transaction priority:
 1. user activity / requestId operation
 2. JSON in response
 
 We choose to use NSOperationQueue to manage above process. Meanwhile, use another array to store the NSOperation so that we could easily locate any given NSOperation to make further change after it is added to the queue, such as cancelation. Completed and canceled ones are removed from the array right away.
 The NSOperation in queue above contains a ctx serving as a channel to do data transaction in local db. The queue itself is actually a queue for local db transactions. So any given time, there is only one ctx working on local db transaction.
 
 To prevent concurrent ctx operation (yes, we can use merge policy, but we don't want to add that layer to this app), we use a queue mentioned above to manage the process of all the ctxes so that each time only one ctx is processed. It's on the main thread. There is another queue, bWorker(NSOperationQueue). bWorker is on a background thread, all the operation does not block main thread. All communications with server are on bWork.
 */

extern NSString *const tvEnglishFontName;
extern NSString *const tvServerUrl;
extern CGFloat const goldenRatio;
extern CGFloat const tvRowHeight;
//extern UIColor *const tvBackgroundColor;
//extern UIColor *const tvBackgroundColorAlternative;
//extern UIColor *const tvFontColor;
extern CGFloat const tvFontSizeLarge;
extern CGFloat const tvFontSizeRegular;
extern NSString *const tvShowNative;
extern NSString *const tvShowTarget;
extern NSString *const tvShowActivation;
extern NSString *const tvShowContent;
extern NSString *const tvShowAfterActivated;
extern NSString *const tvPinchToShowAbove;
extern NSString *const tvAddAndCheckReqNo;
extern NSString *const tvMinusAndCheckReqNo;
extern NSString *const tvUserChangedLocalDb;
extern NSString *const tvUserSignUp;
extern NSString *const tvShowWarning;
extern NSString *const tvPinchToShowSave;
extern NSString *const tvSaveAsNew;
extern NSString *const tvSaveAsUpdate;
extern NSString *const tvDismissSaveViewOnly;
extern NSString *const tvHideExpandedCard;

extern NSString *const tvFetchOrSaveErr;

@interface TVAppRootViewController : UIViewController

@property (nonatomic, assign) CGRect appRect;

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

@property (strong, nonatomic) TVIndicator *indicator;
@property (strong, nonatomic) UILabel *sysMsg;



@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) UILabel *warning;

- (void)showSysMsg:(NSString *)msg;
- (void)sendActivationEmail:(BOOL)isUserTriggered;


@end

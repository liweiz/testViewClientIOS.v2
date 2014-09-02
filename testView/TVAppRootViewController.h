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
 
 So the priorities to handle changes to local db are:
 1. Always proceed local change first.
 2. Send local changes
 3. Send sync request
 
 
 To prevent concurrent ctx operation (yes, we can use merge policy, but we don't want to add that layer to this app), we use a queue to manage the process of all the ctxes so that each time only one ctx is processed. The queue is bWorker(NSOperationQueue). Since bWorker is on a background thread, all the data operation to local db does not block main thread. We also have a comminicator(call it com in the rest of this section). It is on another background thread to avoid blocking the main thread and bWorker.
 So we have three queues, one on main thread, one for data transaction, one for com.
 UserTriggered data transactions have higher priority.
 
 How these three parts interact with each other?
 1. main thread: user triggered data change
 2. thread for com: server triggered data change
 3. thread for data transaction
 There is only one queue for data transaction. Changes triggered by the other two gather in this queue. User triggered change has higher priority since waht user does at local client has to be very responsive. The later processed com triggered change may be dismissed if it conflicts with the previous user action.
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

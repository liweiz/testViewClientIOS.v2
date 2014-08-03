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

extern NSString *const tvDismissSaveViewOnly;

@interface TVAppRootViewController : UIViewController

@property (nonatomic, assign) CGRect appRect;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSFetchRequest *userFetchRequest;
@property (strong, nonatomic) TVUser *user;
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

@property (strong, nonatomic) NSOperationQueue *bWorker;
@property (strong, nonatomic) TVCommunicator *com;

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) UILabel *warning;

- (void)showSysMsg:(NSString *)msg;
- (void)sendActivationEmail:(BOOL)isUserTriggered;


@end

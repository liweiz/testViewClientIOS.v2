//
//  TVAppRootViewController.m
//  testView
//
//  Created by Liwei Zhang on 2013-10-18.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVAppRootViewController.h"
#import "TVRequester.h"
#import "NSObject+DataHandler.h"
#import "NSObject+NetworkHandler.h"
#import "TVTestViewController.h"
#import "UIViewController+InOutTransition.h"
#import "TVLangPickViewController.h"
#import "TVActivationViewController.h"
#import "TVLayerBaseViewController.h"
#import "TVCommunicator.h"
#import "TVRootViewCtlBox.h"

NSString *const tvEnglishFontName = @"TimesNewRomanPSMT";
NSString *const tvServerUrl = @"http://localhost:3000";
CGFloat const goldenRatio = 1.6180339887498948482f / 2.6180339887498948482f;
CGFloat const tvRowHeight = 50.0f;
//UIColor *const tvBackgroundColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:42/255.0f alpha:1.0f];
//UIColor *const tvBackgroundColorAlternative = [UIColor colorWithRed:148/255.0f green:180/255.0f blue:7/255.0f alpha:1.0f];
//UIColor *const tvFontColor = [UIColor colorWithRed:246/255.0f green:247/255.0f blue:242/255.0f alpha:1.0f];
CGFloat const tvFontSizeLarge = 23.0f;
CGFloat const tvFontSizeRegular = 17.0f;
NSString *const tvShowLogin = @"tvShowLogin";
NSString *const tvShowActivation = @"tvShowActivation";
NSString *const tvShowNative = @"tvShowLangPickNative";
NSString *const tvShowTarget = @"tvShowLangPickTarget";
NSString *const tvShowContent = @"tvShowContent";
NSString *const tvShowAfterActivated = @"tvShowAfterActivated";

NSString *const tvPinchToShowAbove = @"tvPinchToShowAbove";
NSString *const tvAddAndCheckReqNo = @"tvAddAndCheckReqNo";
NSString *const tvMinusAndCheckReqNo = @"tvMinusAndCheckReqNo";
NSString *const tvUserChangedLocalDb = @"tvUserChangedLocalDb";
NSString *const tvUserSignUp = @"tvUserSignUp";

NSString *const tvShowWarning = @"tvShowWarning";

NSString *const tvPinchToShowSave = @"tvPinchToShowSave";

NSString *const tvDismissSaveViewOnly = @"tvDismissSaveViewOnly";

@interface TVAppRootViewController ()

@end

@implementation TVAppRootViewController

@synthesize managedObjectContext, persistentStoreCoordinator, managedObjectModel, userFetchRequest, user, loginViewController, requestReceivedResponse, willSendRequest, passItem, appRect, internetIsAccessible;
@synthesize indicator;
@synthesize sysMsg;

@synthesize nativeViewController;
@synthesize targetViewController;
@synthesize activationViewController;

@synthesize com;
@synthesize bWorker;
@synthesize box;
@synthesize warning;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.bWorker = [[NSOperationQueue alloc] init];
        self.box = [[TVRootViewCtlBox alloc] init];
        self.com = [[TVCommunicator alloc] init];
        self.com.bWorker = self.bWorker;
        self.com.box = self.box;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:self.appRect];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.box.appRect = self.appRect;
    [self.box setupBox];
    
    self.requestReceivedResponse = YES;
    self.willSendRequest = YES;
    self.indicator = [[TVIndicator alloc] initWithFrame:self.appRect];
    [self.view addSubview:self.indicator];
    self.indicator.hidden = YES;
    // sysMsg width: 80 height: 44
    self.sysMsg = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150.0f) * 0.5f, (self.view.frame.size.height - 44.0f) * 0.5f, 150.0f, 44.0f)];
    [self.view addSubview:self.sysMsg];
    self.sysMsg.adjustsFontSizeToFitWidth = YES;
    self.sysMsg.numberOfLines = 2;
    self.sysMsg.textAlignment = NSTextAlignmentCenter;
    self.sysMsg.alpha = 0.0f;
    self.sysMsg.textColor = [UIColor whiteColor];
    self.sysMsg.backgroundColor = [UIColor greenColor];
    
//    [self loadController];
    [self loadContentCtl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivationBelow:) name:tvShowActivation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNativePickBelow:) name:tvShowNative object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTargetPickBelow:) name:tvShowTarget object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAndCheckReqNo) name:tvAddAndCheckReqNo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minusAndCheckReqNo) name:tvMinusAndCheckReqNo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarningWithText) name:tvShowWarning object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pinchToShowAbove:) name:tvPinchToShowAbove object:nil];
}

/*
 Data flow of login process:
 Start with sign up/in by getting "user" from server with sign up/in request. If everything's ok, show content and start sync cycle in background.
 This can be interrupted when:
 1. not activated according to local db: show activation view, user has to manually press a button to get the updated user to recheck through "GET" user response. This also indicates user does not have previous data on this device.
 2. no language pair set according to local db
 In both 1 and 2, launch a user triggered sync cycle, which leads to the indicator to show up and user has to wait.
 If no language pair returned from server, show lang pick view and use "POST" deivceInfo to create one on server.
 */
// 1. sign up/in: get from "POST" user response.  check activation status when updated user available.
// 2. before being activated:
// 3. after being activated: get user settings and cards through sync cycle.

- (void)showSysMsg:(NSString *)msg
{
    self.sysMsg.text = msg;
    if (self.sysMsg.alpha == 0.0f) {
        self.sysMsg.alpha = 0.6f;
    }
    [self.view bringSubviewToFront:self.sysMsg];
    [UIView animateWithDuration:4.0f animations:^{
        self.sysMsg.alpha = 0.0f;
    }];
}

- (void)sendActivationEmail:(BOOL)isUserTriggered
{
    if (!self.user) {
        [self refreshUser];
    }
    TVRequester *r = [[TVRequester alloc] init];
    r.box = self.box;
    r.requestType = TVEmailForActivation;
    if (isUserTriggered) {
        r.isUserTriggered = YES;
    }
    r.userId = self.user.serverId;
    r.isBearer = YES;
    r.method = @"GET";
    r.accessToken = [self getAccessTokenForAccount:self.user.serverId];
    [r checkServerAvailToProceed];
}

#pragma mark - indicator on/off

- (void)addAndCheckReqNo
{
    self.box.numberOfUserTriggeredRequests = self.box.numberOfUserTriggeredRequests + 1;
    if (self.indicator.hidden) {
        [self showIndicator];
    }
}

- (void)minusAndCheckReqNo
{
    self.box.numberOfUserTriggeredRequests = self.box.numberOfUserTriggeredRequests - 1;
    if (!self.indicator.hidden && self.box.numberOfUserTriggeredRequests == 0) {
        [self hideIndicator];
    }
}

- (void)showIndicator
{
    if (self.indicator.hidden) {
        self.indicator.hidden = NO;
        [self.indicator.superview bringSubviewToFront:self.indicator];
        [self.indicator.indicator startAnimating];
    }
}

- (void)hideIndicator
{
    if (!self.indicator.hidden) {
        self.indicator.hidden = YES;
        [self.indicator.indicator stopAnimating];
    }
}

# pragma mark - view layers in/out

// view layers from upper to bottom: login/activation/langPicker/content
// Compare main view layer index
- (UIView *)getCurrentView:(NSInteger)tag
{
    switch (tag) {
        case 1001:
            return self.loginViewController.view;
        case 1002:
            return self.activationViewController.view;
        case 1003:
            return self.nativeViewController.view;
        case 1004:
            return self.targetViewController.view;
//        case TVContentCtl:
//            return nil;
        default:
            return nil;
    }
}

- (void)showActivationBelow:(NSNotification *)note
{
    TVRequester *r = note.object;
    [self loadActivationCtl:NO];
    [self showViewBelow:self.activationViewController.view currentView:[self getCurrentView:r.fromVewTag] baseView:self.view pointInBaseView:self.box.transitionPointInRoot];
}

- (void)showAfterActivated:(NSNotification *)note
{
    TVRequester *r = note.object;
    // If user
}

- (void)showNativePickBelow:(NSNotification *)note
{
    TVLoginViewController *c = note.object;
    [self loadNativePickCtl];
    [self showViewBelow:self.nativeViewController.view currentView:[self getCurrentView:c.view.tag] baseView:self.view pointInBaseView:c.box.transitionPointInRoot];
}

- (void)showNativePickAbove:(NSNotification *)note
{
    TVLangPickViewController *c = note.object;
    [self loadNativePickCtl];
    [self showViewAbove:self.nativeViewController.view currentView:[self getCurrentView:c.view.tag] baseView:self.view pointInBaseView:c.box.transitionPointInRoot];
}

- (void)showTargetPickBelow:(NSNotification *)note
{
    TVLangPickViewController *c = note.object;
    [self loadTargetPickCtl];
    [self showViewBelow:self.targetViewController.view currentView:[self getCurrentView:c.view.tag] baseView:self.view pointInBaseView:c.box.transitionPointInRoot];
}

- (void)showContentBelow:(NSNotification *)note
{
    TVRequester *r = note.object;
}

- (void)pinchToShowAbove:(NSNotification *)note
{
    TVLayerBaseViewController *c = note.object;
    int n = c.view.tag;
    if (n == 1002 || n == 1003) {
        [self loadLoginCtl];
        [self showViewAbove:self.loginViewController.view currentView:c.view baseView:self.view pointInBaseView:self.box.transitionPointInRoot];
        if (n == 1002) {
            [self signOut];
        }
    } else if (n == 1004) {
        [self loadNativePickCtl];
        [self showViewAbove:self.nativeViewController.view currentView:c.view baseView:self.view pointInBaseView:self.box.transitionPointInRoot];
    }
}

// viewController hierarchy
// root/content/activation/login
// login: target/native/signInOrUp
// content 1 new card: compose/action
// content 2 card list: list/menu
// content 3 dic: context/contextList/detail/DetailList/translation/translationList/searchInput

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *name = [anim valueForKey:@"animationName"];
        if ([name isEqualToString:@"comeThrough"]) {
            switch ([self getCtlAbove]) {
                case TVLoginCtl:
                    self.loginViewController.view.hidden = YES;
                    [self.loginViewController.view.layer removeAllAnimations];
                    break;
                case TVNativePickCtl:
                    self.nativeViewController.view.hidden = YES;
                    [self.nativeViewController.view.layer removeAllAnimations];
                    break;
                default:
                    break;
            }
        }
        
    }
}

- (TVCtl)getCtlAbove
{
    switch (self.box.ctlOnDuty) {
        case TVNativePickCtl:
            return TVLoginCtl;
        case TVTargetPickCtl:
            return TVNativePickCtl;
        case TVActivationCtl:
            return TVLoginCtl;
        default:
            // Return a very big number to indicate not exists.
            return 100000;
    }
}

# pragma mark - content viewController

- (void)loadController
{
    // When sync with server, isLoggedIn is not processed on server. The response in turn is always true. So when user signs out, isLoggedIn is set to be false. Once user signs in it set to be the value in response, which is alwasy true.
    [self refreshUser];
    if (self.user) {
        self.box.user = self.user;
        if (self.user.activated.integerValue == 1) {
            
        } else {
            [self loadActivationCtl:YES];
        }
    } else {
        [self loadLoginCtl];
    }
}

- (void)actionAfterActivationDone
{
    if ([self.user.sourceLang isEqualToString:@""]) {
        // This indicates that there is no data on this device previously, the app is the first time to be installed here or it's a reinstall after previous deletion. Start a sync cycle to get all from server.
        // Show langPicker and indicator since a request is sent anyway to get the deviceInfo status from server and user has to wait for the response.
        // 1. If no response received, let user pick lang pair so that user can keep use the app.
        // 2. If server side error, let user pick lang pair so that user can keep use the app.
        // 3. If there is existing deviceInfo on server(either specific for this device or fetched as default, see more details in server files), sync data from server and show content right away.
        // 4. If there is no existing deviceInfo on server, let user pick lang pair so that user can keep use the app.
        // Show langPick first. At the mean time, send request show indicator accordingly.
        // Prepare request
        TVRequester *r = [[TVRequester alloc] init];
        r.box = self.box;
        // We need user wait for the result from server
        r.isUserTriggered = YES;
        r.requestType = TVSync;
        r.isBearer = YES;
        r.method = @"GET";
        r.urlBranch = [self getUrlBranchFor:TVOneDeviceInfo userId:self.user.serverId deviceInfoId:nil cardId:nil];
        NSMutableArray *m = [self getCardVerList:self.user.serverId withCtx:self.managedObjectContext];
        r.body = [self getJSONSyncWithCardVerList:m err:nil];
        [r checkServerAvailToProceed];
    } else {
        // Show content
    }
}

- (void)loadLoginCtl
{
    if (!self.loginViewController) {
        self.loginViewController = [[TVLoginViewController alloc] initWithNibName:nil bundle:nil];
        self.loginViewController.managedObjectContext = self.managedObjectContext;
        self.loginViewController.managedObjectModel = self.managedObjectModel;
        
        self.loginViewController.box = self.box;
        
        [self addChildViewController:self.loginViewController];
        [self.view addSubview:self.loginViewController.view];
        [self.loginViewController didMoveToParentViewController:self];
        self.loginViewController.view.tag = 1001;
    }
    self.loginViewController.view.hidden = NO;
    self.box.ctlOnDuty = TVLoginCtl;
}

- (void)loadNativePickCtl
{
    if (!self.nativeViewController) {
        self.nativeViewController = [[TVLangPickViewController alloc] initWithNibName:nil bundle:nil];
        self.nativeViewController.tableIsForSourceLang = YES;

        self.nativeViewController.managedObjectContext = self.managedObjectContext;
        self.nativeViewController.managedObjectModel = self.managedObjectModel;
        
        self.nativeViewController.box = self.box;
        [self addChildViewController:self.nativeViewController];
        [self.view addSubview:self.nativeViewController.view];
        [self.nativeViewController didMoveToParentViewController:self];
    }
    self.nativeViewController.view.hidden = NO;
    self.box.ctlOnDuty = TVNativePickCtl;
}

- (void)loadTargetPickCtl
{
    if (!self.targetViewController) {
        self.targetViewController = [[TVLangPickViewController alloc] initWithNibName:nil bundle:nil];
        self.targetViewController.tableIsForSourceLang = NO;
        self.targetViewController.managedObjectContext = self.managedObjectContext;
        self.targetViewController.managedObjectModel = self.managedObjectModel;
        
        self.targetViewController.box = self.box;
        
        [self addChildViewController:self.targetViewController];
        [self.view addSubview:self.targetViewController.view];
        [self.targetViewController didMoveToParentViewController:self];
    }
    self.targetViewController.view.hidden = NO;
    self.box.ctlOnDuty = TVTargetPickCtl;
}


- (void)loadActivationCtl:(BOOL)isOnTop
{
    if (!self.activationViewController) {
        self.activationViewController = [[TVActivationViewController alloc] initWithNibName:nil bundle:nil];
        self.activationViewController.managedObjectContext = self.managedObjectContext;
        self.activationViewController.managedObjectModel = self.managedObjectModel;
        
        [self addChildViewController:self.activationViewController];
        [self.activationViewController didMoveToParentViewController:self];
        self.activationViewController.view.tag = 1002;
    }
    if (isOnTop) {
        [self.view addSubview:self.activationViewController.view];
    }
    self.activationViewController.view.hidden = NO;
    self.box.ctlOnDuty = TVActivationCtl;
}

- (void)loadContentCtl
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSync:) name:NSManagedObjectContextDidSaveNotification object:nil];
    self.contentViewController = [[TVContentRootViewController alloc] initWithNibName:nil bundle:nil];
    
    self.contentViewController.managedObjectContext = self.managedObjectContext;
    self.contentViewController.managedObjectModel = self.managedObjectModel;

    self.contentViewController.box = self.box;
    
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
}

//- (void)startSync:(NSNotification *)didSaveNotification
//{
//    if (self.willSendRequest == YES) {
//        NSMutableSet *entitiesToSync = [NSMutableSet setWithCapacity:1];
//        [entitiesToSync addObject:@"TVCard"];
//        if ([self startSyncEntitySet:entitiesToSync
//               withNewCardController:self.contentViewController.myNewBaseViewController user:self.user]) {
//            // Successful
//            NSLog(@"connected");
//        } else {
//            // Failed, show indicator to let users know
//            NSLog(@"not connected");
//        }
//    }
//}

#pragma mark - warning display

- (void)showWarningWithText
{
    if (!self.warning) {
        self.warning = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 220.0f) * 0.5f, (self.view.frame.size.height - 90.0f) * 0.5f, 220.0f, 90.0f)];
        [self.view addSubview:self.warning];
        self.warning.textAlignment = NSTextAlignmentLeft;
    }
    self.warning.text = self.box.warning;
    if (self.warning.alpha == 0.0f) {
        self.warning.alpha = 1.0f;
        [self.view bringSubviewToFront:self.warning];
    }
    [UIView animateWithDuration:4 animations:^{
        self.warning.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.box.warning = @"";
    }];
}

- (void)hideWarning
{
    self.warning.text = @"";
    if (self.warning.alpha == 1.0f) {
        self.warning.alpha = 0.0f;
    }
}

#pragma mark - user management

- (TVUser *)getLoggedInUser
{
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSArray *users = [self.managedObjectContext executeFetchRequest:fRequest error:nil];
    if ([users count] != 0) {
        for (TVUser *u in users) {
            NSString *s = [self getRefreshTokenForAccount:u.serverId];
            if (![s isEqualToString:@""]) {
                return u;
            }
        }
    }
    return nil;
}

- (void)refreshUser
{
    if (!self.user) {
        self.user = [self getLoggedInUser];
    } else {
        self.userFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
        self.userFetchRequest.predicate = [NSPredicate predicateWithFormat:@"serverId == %@", self.user.serverId];
        self.user = [self.managedObjectContext executeFetchRequest:self.userFetchRequest error:nil][0];
    }
}

- (void)signOut
{
    if (!self.user) {
        [self refreshUser];
    }
    [self resetTokens:self.user.serverId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

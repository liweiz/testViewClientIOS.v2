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
#import "UIViewController+InOutTransition.h"
#import "TVLangPickViewController.h"
#import "TVLayerBaseViewController.h"
#import "TVCRUDChannel.h"
#import "TVRootViewCtlBox.h"
#import "TVUser.h"

@interface TVAppRootViewController ()

@end

@implementation TVAppRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[TVRootViewCtlBox sharedBox].appRect];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.requestReceivedResponse = YES;
    self.willSendRequest = YES;
    
    self.bIndicator = [[TVBlockIndicator alloc] initWithFrame:[TVRootViewCtlBox sharedBox].appRect];
    [self.view addSubview:self.bIndicator];
    self.bIndicator.hidden = YES;
    
    self.nbIndicator = [[TVNonBlockIndicator alloc] initWithFrame:CGRectMake([TVRootViewCtlBox sharedBox].appRect.origin.x, [TVRootViewCtlBox sharedBox].appRect.origin.y, [TVRootViewCtlBox sharedBox].appRect.size.width, 33.0f)];
    [self.view addSubview:self.nbIndicator];
    self.nbIndicator.hidden = YES;
    
    // sysMsg width: 80 height: 44
    self.sysMsg = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150.0f) * 0.5f, (self.view.frame.size.height - 44.0f) * 0.5f, 150.0f, 44.0f)];
    [self.view addSubview:self.sysMsg];
    self.sysMsg.adjustsFontSizeToFitWidth = YES;
    self.sysMsg.numberOfLines = 2;
    self.sysMsg.textAlignment = NSTextAlignmentCenter;
    self.sysMsg.alpha = 0.0f;
    self.sysMsg.textColor = [UIColor whiteColor];
    self.sysMsg.backgroundColor = [UIColor greenColor];
    
    [self loadController];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContentBelow) name:tvShowContent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivationBelow) name:tvShowActivation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNativePickBelow) name:tvShowNative object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTargetPickBelow) name:tvShowTarget object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAndCheckReqNo) name:tvAddAndCheckReqNo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minusAndCheckReqNo) name:tvMinusAndCheckReqNo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAndCheckReqNoNB) name:tvAddAndCheckReqNoNB object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minusAndCheckReqNoNB) name:tvMinusAndCheckReqNoNB object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarningWithText:) name:tvShowWarning object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pinchToShowAbove:) name:tvPinchToShowAbove object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarningWithText:) name:tvFetchOrSaveErr object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseUncommittedByOne:) name:tvMinusOneToUncommitted object:nil];
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
// 1. sign up/in: get from "POST" user response. check activation status when updated user available.
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
    TVRequester *r = [[TVRequester alloc] init];
    r.requestType = TVEmailForActivation;
    r.isUserTriggered = isUserTriggered;
    r.isBearer = YES;
    r.method = @"GET";
    r.accessToken = [self getAccessTokenForAccount:[TVRootViewCtlBox sharedBox].userServerId];
    [r setupAndLoadToQueue:[TVRootViewCtlBox sharedBox].comWorker withDna:NO];
}

#pragma mark - Indicator On/off

// Two indicators: one for blocking user interaction, which is user triggered, one not, which is client/system triggered.

// For blockIndicator
- (void)addAndCheckReqNo
{
    [TVRootViewCtlBox sharedBox].numberOfUserTriggeredRequests++;
    if (self.bIndicator.hidden) {
        [self showBIndicator];
    }
}

- (void)minusAndCheckReqNo
{
    [TVRootViewCtlBox sharedBox].numberOfUserTriggeredRequests--;
    if (!self.bIndicator.hidden && [TVRootViewCtlBox sharedBox].numberOfUserTriggeredRequests == 0) {
        [self hideBIndicator];
    }
}

- (void)showBIndicator
{
    if (self.bIndicator.hidden) {
        self.bIndicator.hidden = NO;
        [self.bIndicator.superview bringSubviewToFront:self.bIndicator];
        [self.bIndicator.indicator startAnimating];
    }
}

- (void)hideBIndicator
{
    if (!self.bIndicator.hidden) {
        self.bIndicator.hidden = YES;
        [self.bIndicator.indicator stopAnimating];
    }
}

// For nonBlockIndicator
- (void)addAndCheckReqNoNB
{
    [TVRootViewCtlBox sharedBox].numberOfNonUserTriggeredRequests++;
    if (self.nbIndicator.hidden) {
        [self showNBIndicator];
    }
}

- (void)minusAndCheckReqNoNB
{
    [TVRootViewCtlBox sharedBox].numberOfNonUserTriggeredRequests--;
    if (!self.nbIndicator.hidden && [TVRootViewCtlBox sharedBox].numberOfNonUserTriggeredRequests == 0) {
        [self hideNBIndicator];
    }
}

- (void)showNBIndicator
{
    if (self.nbIndicator.hidden) {
        NSLog(@"subview count: %lu", (unsigned long)[self.view.subviews count]);
        self.nbIndicator.hidden = NO;
        [self.nbIndicator startAni];
    }
}

- (void)hideNBIndicator
{
//    if (!self.nbIndicator.hidden) {
//        NSLog(@"subview count: %lu", (unsigned long)[self.view.subviews count]);
//        self.nbIndicator.hidden = YES;
//        NSLog(@"animationToStop");
//        [self.nbIndicator stopAni];
//    }
}

# pragma mark - View Layers In/out

// view layers from upper to bottom: login/activation/langPicker/content
// Compare main view layer index
- (UIView *)getCurrentView:(NSInteger)ctlOnDuty
{
    switch (ctlOnDuty) {
        case 1001:
            return self.loginViewController.view;
        case 1002:
            return self.activationViewController.view;
        case 1003:
            return self.nativeViewController.view;
        case 1004:
            return self.targetViewController.view;
        case 1009:
            return self.contentViewController.view;
        default:
            return nil;
    }
}

- (UIView *)getViewOnDuty
{
    switch ([TVRootViewCtlBox sharedBox].ctlOnDuty) {
        case TVLoginCtl:
            return self.loginViewController.view;
        case TVActivationCtl:
            return self.activationViewController.view;
        case TVNativePickCtl:
            return self.nativeViewController.view;
        case TVTargetPickCtl:
            return self.targetViewController.view;
        case TVContentCtl:
            return self.contentViewController.view;
        default:
            return nil;
    }
}

- (void)showActivationBelow
{
    [self loadActivationCtl];
    [self showViewBelow:self.activationViewController.view currentView:[self getViewOnDuty] baseView:self.view pointInBaseView:[TVRootViewCtlBox sharedBox].transitionPointInRoot];
    [TVRootViewCtlBox sharedBox].ctlOnDuty = TVActivationCtl;
}

- (void)showNativePickBelow
{
    [self loadNativePickCtl];
    [self showViewBelow:self.nativeViewController.view currentView:[self getViewOnDuty] baseView:self.view pointInBaseView:[TVRootViewCtlBox sharedBox].transitionPointInRoot];
    [TVRootViewCtlBox sharedBox].ctlOnDuty = TVNativePickCtl;
}

- (void)showNativePickAbove
{
    [self loadNativePickCtl];
    [self showViewAbove:self.nativeViewController.view currentView:[self getViewOnDuty] baseView:self.view pointInBaseView:[TVRootViewCtlBox sharedBox].transitionPointInRoot];
    [TVRootViewCtlBox sharedBox].ctlOnDuty = TVNativePickCtl;
}

- (void)showTargetPickBelow
{
    [self loadTargetPickCtl];
    [self showViewBelow:self.targetViewController.view currentView:[self getViewOnDuty] baseView:self.view pointInBaseView:[TVRootViewCtlBox sharedBox].transitionPointInRoot];
    [TVRootViewCtlBox sharedBox].ctlOnDuty = TVTargetPickCtl;
}

//
- (void)showContentBelow
{
    [self loadContentCtl];
    [self showViewBelow:self.contentViewController.view currentView:[self getViewOnDuty] baseView:self.view pointInBaseView:[TVRootViewCtlBox sharedBox].transitionPointInRoot];
    [TVRootViewCtlBox sharedBox].ctlOnDuty = TVContentCtl;
}

- (void)pinchToShowAbove:(NSNotification *)note
{
    TVLayerBaseViewController *c = note.object;
    NSInteger n = c.view.tag;
    if (n == 1002 || n == 1003) {
        [self loadLoginCtl];
        [self showViewAbove:self.loginViewController.view currentView:[self getViewOnDuty] baseView:self.view pointInBaseView:[TVRootViewCtlBox sharedBox].transitionPointInRoot];
        if (n == 1002) {
            [self signOut:[TVRootViewCtlBox sharedBox].userServerId];
        }
    } else if (n == 1004) {
        [self loadNativePickCtl];
        [self showViewAbove:self.nativeViewController.view currentView:[self getViewOnDuty] baseView:self.view pointInBaseView:[TVRootViewCtlBox sharedBox].transitionPointInRoot];
    }
}

/*
 viewController hierarchy
 root/content/activation/login
 login: target/native/signInOrUp
 content 1 new card: compose/action
 content 2 card list: list/menu
 content 3 dic: context/contextList/detail/DetailList/translation/translationList/searchInput
 
 view layers from upmost to the bottom:
 signInOrUp=>activation=>targetLang=>nativeLang
 ==>>
 content
 */

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
                case TVTargetPickCtl:
                    self.targetViewController.view.hidden = YES;
                    [self.targetViewController.view.layer removeAllAnimations];
                    break;
                default:
                    break;
            }
        }
        
    }
}

- (TVCtl)getCtlAbove
{
    switch ([TVRootViewCtlBox sharedBox].ctlOnDuty) {
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

# pragma mark - Child viewControllers

- (void)loadController
{
    // When sync with server, isLoggedIn is not processed on server. The response in turn is always true. So when user signs out, isLoggedIn is set to be false. Once user signs in it set to be the value in response, which is alwasy true.
    // Nerver cancel this operation, it's a fundamental one for the app.
    TVQueueElement *o = [TVQueueElement blockOperationWithBlock:^{
        TVCRUDChannel *crud = [[TVCRUDChannel alloc] init];
        TVUser *u = [crud getLoggedInUser];
        if (u) {
            [[TVRootViewCtlBox sharedBox].userServerId setString:u.serverId];
            if (u.activated.boolValue == YES) {
                [self loadContentCtl];
            } else {
                [self loadActivationCtl];
            }
        } else {
            [self loadLoginCtl];
        }
    }];
    // No need to set queuePriority here since it's a normal one.
    [[NSOperationQueue mainQueue] addOperation:o];
}

- (void)loadLoginCtl
{
    if (!self.loginViewController) {
        self.loginViewController = [[TVLoginViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:self.loginViewController];
        [self.view addSubview:self.loginViewController.view];
        [self.loginViewController didMoveToParentViewController:self];
        self.loginViewController.view.tag = 1001;
    }
    self.loginViewController.view.hidden = NO;
    [TVRootViewCtlBox sharedBox].ctlOnDuty = TVLoginCtl;
}

- (void)loadNativePickCtl
{
    if (!self.nativeViewController) {
        self.nativeViewController = [[TVLangPickViewController alloc] initWithNibName:nil bundle:nil];
        self.nativeViewController.tableIsForSourceLang = YES;
        [self addChildViewController:self.nativeViewController];
        [self.view addSubview:self.nativeViewController.view];
        [self.nativeViewController didMoveToParentViewController:self];
    }
    self.nativeViewController.view.hidden = NO;
}

- (void)loadTargetPickCtl
{
    if (!self.targetViewController) {
        self.targetViewController = [[TVLangPickViewController alloc] initWithNibName:nil bundle:nil];
        self.targetViewController.tableIsForSourceLang = NO;
        [self addChildViewController:self.targetViewController];
        [self.view addSubview:self.targetViewController.view];
        [self.targetViewController didMoveToParentViewController:self];
    }
    self.targetViewController.view.hidden = NO;
}

- (void)loadActivationCtl
{
    if (!self.activationViewController) {
        self.activationViewController = [[TVActivationViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:self.activationViewController];
        [self.view addSubview:self.activationViewController.view];
        [self.activationViewController didMoveToParentViewController:self];
        self.activationViewController.view.tag = 1002;
    }
    self.activationViewController.view.hidden = NO;
}

- (void)loadContentCtl
{
    if (!self.contentViewController) {
        self.contentViewController = [[TVContentRootViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:self.contentViewController];
        [self.view addSubview:self.contentViewController.view];
        [self.contentViewController didMoveToParentViewController:self];
        self.contentViewController.view.tag = 1009;
    }
    self.contentViewController.view.hidden = NO;
}

#pragma mark - warning display

- (void)showWarningWithText:(NSNotification *)note
{
    if (!self.warning) {
        self.warning = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 220.0f) * 0.5f, (self.view.frame.size.height - 90.0f) * 0.5f, 220.0f, 90.0f)];
        [self.view addSubview:self.warning];
        self.warning.textAlignment = NSTextAlignmentLeft;
    }
    if ([note.name isEqualToString:tvFetchOrSaveErr]) {
        self.warning.text = @"Something went wrong, please try later.";
    } else {
        self.warning.text = [TVRootViewCtlBox sharedBox].warning;
    }
    
    if (self.warning.alpha == 0.0f) {
        self.warning.alpha = 1.0f;
        [self.view bringSubviewToFront:self.warning];
    }
    [UIView animateWithDuration:4 animations:^{
        self.warning.alpha = 0.0f;
    } completion:^(BOOL finished){
        [[TVRootViewCtlBox sharedBox].warning setString:@""];
    }];
}

- (void)hideWarning
{
    self.warning.text = nil;
    if (self.warning.alpha == 1.0f) {
        self.warning.alpha = 0.0f;
    }
}

#pragma mark - mornitor sync cycle

- (void)decreaseUncommittedByOne:(NSNotification *)note
{
    TVCRUDChannel *crud = note.object;
    [TVRootViewCtlBox sharedBox].numberOfUncommittedRecord--;
    if ([TVRootViewCtlBox sharedBox].numberOfUncommittedRecord == 0) {
        [crud syncCycle:NO];
    }
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

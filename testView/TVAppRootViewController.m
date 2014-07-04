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

NSString *const tvEnglishFontName = @"TimesNewRomanPSMT";
NSString *const tvServerUrl = @"http://localhost:3000";
CGFloat const goldenRatio = 1.6180339887498948482f / 2.6180339887498948482f;
//UIColor *const tvBackgroundColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:42/255.0f alpha:1.0f];
//UIColor *const tvBackgroundColorAlternative = [UIColor colorWithRed:148/255.0f green:180/255.0f blue:7/255.0f alpha:1.0f];
//UIColor *const tvFontColor = [UIColor colorWithRed:246/255.0f green:247/255.0f blue:242/255.0f alpha:1.0f];
//CGFloat *const tvFontSizeHeader = 34.0f;
//CGFloat *const tvFontSizeContent = 28.0f;
NSString *const tvShowLogin = @"tvShowLogin";
NSString *const tvShowActivation = @"tvShowActivation";
NSString *const tvShowLangPick = @"tvShowLangPick";
NSString *const tvShowContent = @"tvShowContent";

@interface TVAppRootViewController ()

@end

@implementation TVAppRootViewController

@synthesize managedObjectContext, persistentStoreCoordinator, managedObjectModel, userFetchRequest, user, loginViewController, requestReceivedResponse, willSendRequest, passItem, appRect, internetIsAccessible;
@synthesize indicator;
@synthesize sysMsg;
@synthesize numberOfUserTriggeredRequests;
@synthesize langViewController;
@synthesize activationViewController;
@synthesize ctlOnDuty;
@synthesize transitionPointInRoot;

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
    self.view = [[UIView alloc] initWithFrame:self.appRect];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    [self loadController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginAbove:) name:tvShowLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivationBelow:) name:tvShowActivation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLangPick:) name:tvShowLangPick object:nil];
}

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
    r.coordinator = self.persistentStoreCoordinator;
    r.requestType = TVEmailForActivation;
    if (isUserTriggered) {
        r.isUserTriggered = YES;
    }
    r.userId = self.user.serverId;
    r.isBearer = YES;
    r.method = @"GET";
    r.accessToken = [self getAccessTokenForAccount:self.user.serverId];
    [r checkServerAvailabilityToProceed];
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
            return self.langViewController.view;
//        case TVContentCtl:
//            return nil;
        default:
            return nil;
    }
}


- (void)showLoginAbove:(NSNotification *)note
{
    TVRequester *r = note.object;
    [self loadLoginCtl:NO];
    [self showViewAbove:self.loginViewController.view currentView:[self getCurrentView:r.fromVewTag] baseView:self.view pointInBaseView:r.transitionPointInRoot];
}

- (void)showActivationBelow:(NSNotification *)note
{
    TVRequester *r = note.object;
    [self loadActivationCtl:NO];
    [self showViewBelow:self.activationViewController.view currentView:[self getCurrentView:r.fromVewTag] baseView:self.view pointInBaseView:r.transitionPointInRoot];
}

- (void)showLangPick:(NSNotification *)note
{
    TVRequester *r = note.object;
    if (r.fromVewTag < 1003) {
        [self showLangPickBelow:r];
    } else {
        [self showLangPickAbove:r];
    }
}

- (void)showLangPickBelow:(TVRequester *)r
{
    [self loadLangPickCtl:NO];
    [self showViewBelow:self.langViewController.view currentView:[self getCurrentView:r.fromVewTag] baseView:self.view pointInBaseView:r.transitionPointInRoot];
}

- (void)showLangPickAbove:(TVRequester *)r
{
    [self loadLangPickCtl:NO];
    [self showViewAbove:self.langViewController.view currentView:[self getCurrentView:r.fromVewTag] baseView:self.view pointInBaseView:r.transitionPointInRoot];
}

# pragma mark - content viewController

- (void)loadController
{
    self.userFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    // When sync with server, isLoggedIn is not processed on server. The response in turn is always true. So when user signs out, isLoggedIn is set to be false. Once user signs in it set to be the value in response, which is alwasy true.
    self.userFetchRequest.predicate = [NSPredicate predicateWithFormat:@"isLoggedIn == YES"];
    NSArray *userArray = [self.managedObjectContext executeFetchRequest:self.userFetchRequest error:nil];
    if ([userArray count] == 1) {
        self.user = userArray[0];
        if (self.user.activated.intValue == 1) {
//            [self loadContentController];
        } else {
            // Show activation view
        }
    } else {
        [self loadLoginCtl:YES];
//        need to clear each local users isLoggedIn flag
    }
}

// isOnTop is only set to be YES when the controller is loaded directly after the app is launched.
- (void)loadLoginCtl:(BOOL)isOnTop
{
    if (!self.loginViewController) {
        self.loginViewController = [[TVLoginViewController alloc] init];
        self.loginViewController.appRect = self.appRect;
        self.loginViewController.managedObjectContext = self.managedObjectContext;
        self.loginViewController.managedObjectModel = self.managedObjectModel;
        self.loginViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
        self.loginViewController.indicator = self.indicator;
        [self addChildViewController:self.loginViewController];
        [self.loginViewController didMoveToParentViewController:self];
        self.loginViewController.view.tag = 1001;
    }
    if (isOnTop) {
        // In other situations, subview is inserted by showView... method.
        [self.view addSubview:self.loginViewController.view];
    }
    self.ctlOnDuty = TVLoginCtl;
}

- (void)loadActivationCtl:(BOOL)isOnTop
{
    if (!self.activationViewController) {
        self.activationViewController = [[TVActivationViewController alloc] init];
        self.activationViewController.appRect = self.appRect;
        self.activationViewController.managedObjectContext = self.managedObjectContext;
        self.activationViewController.managedObjectModel = self.managedObjectModel;
        self.activationViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
        self.activationViewController.indicator = self.indicator;
        [self addChildViewController:self.activationViewController];
        [self.activationViewController didMoveToParentViewController:self];
        self.activationViewController.view.tag = 1002;
    }
    if (isOnTop) {
        [self.view addSubview:self.activationViewController.view];
    }
    self.ctlOnDuty = TVActivationCtl;
}

- (void)loadLangPickCtl:(BOOL)isOnTop
{
    if (!self.langViewController) {
        self.langViewController = [[TVLangPickViewController alloc] init];
        self.langViewController.appRect = self.appRect;
        self.langViewController.managedObjectContext = self.managedObjectContext;
        self.langViewController.managedObjectModel = self.managedObjectModel;
        self.langViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [self addChildViewController:self.langViewController];
        [self.langViewController didMoveToParentViewController:self];
        self.langViewController.view.tag = 1003;
    }
    if (isOnTop) {
        [self.view addSubview:self.langViewController.view];
    }
    self.ctlOnDuty = TVActivationCtl;
}

//- (void)loadContentController
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSync:) name:NSManagedObjectContextDidSaveNotification object:nil];
//    self.contentViewController = [[TVContentRootViewController alloc] init];
//    
//    self.contentViewController.managedObjectContext = self.managedObjectContext;
//    self.contentViewController.managedObjectModel = self.managedObjectModel;
//    self.contentViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
//    
//    self.contentViewController.user = self.user;
//    
//    [self addChildViewController:self.contentViewController];
//    [self.view addSubview:self.contentViewController.view];
//    [self.contentViewController didMoveToParentViewController:self];
//}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

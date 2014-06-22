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

NSString *const tvEnglishFontName = @"TimesNewRomanPSMT";
NSString *const tvServerUrl = @"http://localhost:3000";
CGFloat const goldenRatio = 1.6180339887498948482f / 2.6180339887498948482f;
//UIColor *const tvBackgroundColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:42/255.0f alpha:1.0f];
//UIColor *const tvBackgroundColorAlternative = [UIColor colorWithRed:148/255.0f green:180/255.0f blue:7/255.0f alpha:1.0f];
//UIColor *const tvFontColor = [UIColor colorWithRed:246/255.0f green:247/255.0f blue:242/255.0f alpha:1.0f];
//CGFloat *const tvFontSizeHeader = 34.0f;
//CGFloat *const tvFontSizeContent = 28.0f;


@interface TVAppRootViewController ()

@end

@implementation TVAppRootViewController

@synthesize managedObjectContext, persistentStoreCoordinator, managedObjectModel, userFetchRequest, user, loginViewController, requestReceivedResponse, willSendRequest, passItem, appRect, internetIsAccessible;
@synthesize indicator;
@synthesize sysMsg;
@synthesize numberOfUserTriggeredRequests;

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

# pragma mark - view layers in/out

- (void)tapInLangPicker
{
    if (self.) {
        <#statements#>
    }
}

- (void)loadController
{
    self.userFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    self.userFetchRequest.predicate = [NSPredicate predicateWithFormat:@"isLoggedIn == YES"];
    NSArray *userArray = [self.managedObjectContext executeFetchRequest:self.userFetchRequest error:nil];
    if ([userArray count] == 1) {
        self.user = [userArray objectAtIndex:0];
//        [self loadContentController];
    } else {
        [self loadLoginController];
//        need to clear each local users isLoggedIn flag
    }
}

- (void)loadLoginController
{
    self.loginViewController = [[TVLoginViewController alloc] init];
    self.loginViewController.appRect = self.appRect;
    self.loginViewController.managedObjectContext = self.managedObjectContext;
    self.loginViewController.managedObjectModel = self.managedObjectModel;
    self.loginViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
    self.loginViewController.indicator = self.indicator;
    
    [self addChildViewController:self.loginViewController];
    [self.view addSubview:self.loginViewController.view];
    [self.loginViewController didMoveToParentViewController:self];
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

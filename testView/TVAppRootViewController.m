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

NSString *const tvEnglishFontName = @"TimesNewRomanPSMT";
NSString *const tvServerUrl = @"http://localhost:3000";
//UIColor *const tvBackgroundColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:42/255.0f alpha:1.0f];
//UIColor *const tvBackgroundColorAlternative = [UIColor colorWithRed:148/255.0f green:180/255.0f blue:7/255.0f alpha:1.0f];
//UIColor *const tvFontColor = [UIColor colorWithRed:246/255.0f green:247/255.0f blue:242/255.0f alpha:1.0f];
//CGFloat *const tvFontSizeHeader = 34.0f;
//CGFloat *const tvFontSizeContent = 28.0f;


@interface TVAppRootViewController ()

@end

@implementation TVAppRootViewController

@synthesize managedObjectContext, persistentStoreCoordinator, managedObjectModel, userFetchRequest, user, loginViewController, requestReceivedResponse, willSendRequest, passItem, appRect, internetIsAccessible;

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
    [self loadController];
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

//- (void)loginAsTest
//{
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
//    request.predicate = [NSPredicate predicateWithFormat:@"isLoggedIn == YES"];
//    NSArray *userArray = [self.managedObjectContext executeFetchRequest:request error:nil];
//    if ([userArray isEqual: @[]]) {
//        //create a test user by faking a response
//        NSMutableDictionary *testResponse = [NSMutableDictionary dictionaryWithCapacity:1];
//        [testResponse setValue:@"test@test.com" forKey:@"email"];
//        NSNumber *isLoggedIn = [NSNumber numberWithBool:YES];
//        [testResponse setValue:@"collectedAtDAlphabetA" forKey:@"sortOption"];
//        [testResponse setValue:isLoggedIn forKey:@"isLoggedIn"];
//        [testResponse setValue:@"Chinese Simplified" forKey:@"sourceLang"];
//        [testResponse setValue:@"English" forKey:@"targetLang"];
//        [self createRecord:[TVUser class] recordInResponse:testResponse inContext:self.managedObjectContext withNewCardController:nil withNonCardController:nil user:nil];
//        [self proceedChangesInContext:self.managedObjectContext willSendRequest:NO];
//    }
//}

- (void)loadLoginController
{
    self.loginViewController = [[TVLoginViewController alloc] init];
    self.loginViewController.appRect = self.appRect;
    self.loginViewController.managedObjectContext = self.managedObjectContext;
    self.loginViewController.managedObjectModel = self.managedObjectModel;
    self.loginViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
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

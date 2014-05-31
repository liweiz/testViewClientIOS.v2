//
//  TVTestViewController.m
//  testView
//
//  Created by Liwei on 2014-05-29.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVTestViewController.h"
#import "TVRequester.h"
#import "NSObject+DataHandler.h"
#import "NSObject+NetworkHandler.h"

@interface TVTestViewController ()

@end

@implementation TVTestViewController {
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectContext *managedObjectContext;
    
    NSArray *reqTypeArray;
    
    NSString *email;
    NSString *password;
    NSMutableDictionary *card1;
    NSMutableDictionary *card2;
    NSMutableDictionary *card3;
    NSMutableDictionary *card4;
    NSMutableDictionary *card5;
    NSMutableDictionary *card6;
    NSMutableDictionary *card7;
    
    NSString *context;
    NSString *target;
    NSString *translation;
    NSString *detail1;
    NSString *detail2;
    NSString *detail3;
    NSString *detail4;
    NSString *detail5;
    NSString *detail6;
}

@synthesize managedObjectContext, persistentStoreCoordinator, managedObjectModel, user, requestReceivedResponse, willSendRequest, passItem, appRect, internetIsAccessible;

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
    reqTypeArray = @[[NSNumber numberWithInteger:TVSignUp], // 0
                     [NSNumber numberWithInteger:TVSignIn], // 1
                     [NSNumber numberWithInteger:TVForgotPassword], // 2
                     [NSNumber numberWithInteger:TVRenewTokens], // 3
                     [NSNumber numberWithInteger:TVNewDeviceInfo], // 4
                     [NSNumber numberWithInteger:TVOneDeviceInfo], // 5
                     [NSNumber numberWithInteger:TVEmailForActivation], // 6
                     [NSNumber numberWithInteger:TVEmailForPasswordResetting], // 7
                     [NSNumber numberWithInteger:TVSync], // 8
                     [NSNumber numberWithInteger:TVNewCard], // 9
                     [NSNumber numberWithInteger:TVOneCard]]; // 10
    
    
    email = @"matt.z.lw@gmail.com";
    password = @"1a2b!!";
    
    context = @"As designers, we must not forget that we design for the people. We must gain empathy and ride on the arc of modern design.";
    target = @"empathy";
    translation = @"感同身受";
    detail1 = @"直译为“移情作用”，在中文中不易理解。";
    detail2 = @"直译为“移情作用”。wiki中有详解，却不易理解。";
    detail3 = @"直译为“移情作用”。";
    detail4 = @"a直译为“移情作用”，在中文中不易理解。";
    detail5 = @"a直译为“移情作用”。wiki中有详解，却不易理解。";
    detail6 = @"a直译为“移情作用”。";
}

- (void)signUp
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[0] integerValue];
    reqster.email = email;
    reqster.password = password;
    reqster.body = [self getJSONSignUpOrInWithEmail:reqster.email password:reqster.password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.authNeeded = NO;
    [reqster proceedToRequest];
}

- (void)signIn
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[1] integerValue];
    reqster.email = email;
    reqster.password = password;
    reqster.body = [self getJSONSignUpOrInWithEmail:reqster.email password:reqster.password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.authNeeded = YES;
    [reqster proceedToRequest];
}

- (void)renewTokens
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[3] integerValue];
    NSString *a = [self getAccessTokenForAccount:self.user.serverId];
    NSString *r = [self getRefreshTokenForAccount:self.user.serverId];
    reqster.body = [self getJSONRenewTokensWithAccessToken:a refreshToken:r err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.authNeeded = YES;
    reqster.accessToken = a;
    [reqster proceedToRequest];
}

- (void)newDeviceInfo
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[4] integerValue];
    NSString *a = [self getAccessTokenForAccount:self.user.serverId];
    TVRequestId *rId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:reqster.ctx];
    self setupNewRequestId:rId action:TVDocNew for:<#(TVBase *)#>
    reqster.reqId =
    reqster.body = [self getJSONDeviceInfo:self.user requestId:reqster.reqId err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.authNeeded = YES;
    reqster.accessToken = a;
    [reqster proceedToRequest];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

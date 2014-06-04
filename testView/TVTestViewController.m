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
    
    NSString *sourceLang;
    NSString *targetLang;
    NSString *sortOption1;
    NSString *sortOption2;
    
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
    
    sourceLang = @"English";
    targetLang = @"简体中文";
    sortOption1 = @"collectedAtDescending";
    sortOption2 = @"collectedAtAscending";
    
    context = @"As designers, we must not forget that we design for the people. We must gain empathy and ride on the arc of modern design.";
    target = @"empathy";
    translation = @"感同身受";
    detail1 = @"直译为“移情作用”，在中文中不易理解。";
    detail2 = @"直译为“移情作用”。wiki中有详解，却不易理解。";
    detail3 = @"直译为“移情作用”。";
    detail4 = @"a直译为“移情作用”，在中文中不易理解。";
    detail5 = @"a直译为“移情作用”。wiki中有详解，却不易理解。";
    detail6 = @"a直译为“移情作用”。";
    
    UILabel *btn1 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 60.0f, 50.0f)];
    btn1.adjustsFontSizeToFitWidth = YES;
    btn1.userInteractionEnabled = YES;
    btn1.text = @"signUp";
    UITapGestureRecognizer *g1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signUp)];
    [btn1 addGestureRecognizer:g1];
    [self.view addSubview:btn1];
    
    UILabel *btn2 = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 10.0f, 60.0f, 50.0f)];
    btn2.adjustsFontSizeToFitWidth = YES;
    btn2.userInteractionEnabled = YES;
    btn2.text = @"signIn";
    UITapGestureRecognizer *g2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signIn)];
    [btn2 addGestureRecognizer:g2];
    [self.view addSubview:btn2];
    
    UILabel *btn3 = [[UILabel alloc] initWithFrame:CGRectMake(150.0f, 10.0f, 60.0f, 50.0f)];
    btn3.adjustsFontSizeToFitWidth = YES;
    btn3.userInteractionEnabled = YES;
    btn3.text = @"renewTokens";
    UITapGestureRecognizer *g3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(renewTokens)];
    [btn3 addGestureRecognizer:g3];
    [self.view addSubview:btn3];
    
    UILabel *btn4 = [[UILabel alloc] initWithFrame:CGRectMake(220.0f, 10.0f, 60.0f, 50.0f)];
    btn4.adjustsFontSizeToFitWidth = YES;
    btn4.userInteractionEnabled = YES;
    btn4.text = @"newDeviceInfo";
    UITapGestureRecognizer *g4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newDeviceInfo)];
    [btn4 addGestureRecognizer:g4];
    [self.view addSubview:btn4];
    
    UILabel *btn5 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 60.0f, 50.0f)];
    btn5.adjustsFontSizeToFitWidth = YES;
    btn5.userInteractionEnabled = YES;
    btn5.text = @"oneDeviceInfo";
    UITapGestureRecognizer *g5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneDeviceInfo)];
    [btn5 addGestureRecognizer:g5];
    [self.view addSubview:btn5];
    
    UILabel *btn6 = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 70.0f, 60.0f, 50.0f)];
    btn6.adjustsFontSizeToFitWidth = YES;
    btn6.userInteractionEnabled = YES;
    btn6.text = @"refreshUser";
    UITapGestureRecognizer *g6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshUser)];
    [btn6 addGestureRecognizer:g6];
    [self.view addSubview:btn6];
    
    UILabel *btn7 = [[UILabel alloc] initWithFrame:CGRectMake(150.0f, 70.0f, 60.0f, 50.0f)];
    btn7.adjustsFontSizeToFitWidth = YES;
    btn7.userInteractionEnabled = YES;
    btn7.text = @"emailForActivation";
    UITapGestureRecognizer *g7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailForActivation)];
    [btn7 addGestureRecognizer:g7];
    [self.view addSubview:btn7];
    
    UILabel *btn8 = [[UILabel alloc] initWithFrame:CGRectMake(220.0f, 70.0f, 60.0f, 50.0f)];
    btn8.adjustsFontSizeToFitWidth = YES;
    btn8.userInteractionEnabled = YES;
    btn8.text = @"createDeviceInfo";
    UITapGestureRecognizer *g8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createDeviceInfo)];
    [btn8 addGestureRecognizer:g8];
    [self.view addSubview:btn8];
    
    UILabel *btn9 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 130.0f, 60.0f, 50.0f)];
    btn9.adjustsFontSizeToFitWidth = YES;
    btn9.userInteractionEnabled = YES;
    btn9.text = @"changeDeviceInfo";
    UITapGestureRecognizer *g9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeDeviceInfo)];
    [btn9 addGestureRecognizer:g9];
    [self.view addSubview:btn9];
}

- (void)refreshUser
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSPredicate *pUser = [NSPredicate predicateWithFormat:@"email like %@", email];
    [fetchRequest setPredicate:pUser];
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    self.user = r[0];
    NSLog(@"self.user.serverId: %@, self.user.deviceInfoId: %@, self.user.sortOption: %@", self.user.serverId, self.user.deviceInfoId, self.user.sortOption);
}

- (void)createDeviceInfo
{
    self.user.sourceLang = sourceLang;
    self.user.targetLang = targetLang;
    self.user.sortOption = sortOption1;
    [self.managedObjectContext save:nil];
    [self refreshUser];
}

- (void)changeDeviceInfo
{
    self.user.sortOption = sortOption2;
    [self.managedObjectContext save:nil];
    [self refreshUser];
}

- (void)signUp
{
    NSLog(@"signUp");
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[0] integerValue];
    reqster.email = email;
    reqster.password = password;
    reqster.isBearer = NO;
    reqster.body = [self getJSONSignUpOrInWithEmail:reqster.email password:reqster.password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    [reqster proceedToRequest:nil];
}

- (void)signIn
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[1] integerValue];
    reqster.email = email;
    reqster.password = password;
    reqster.isBearer = NO;
    reqster.body = [self getJSONSignUpOrInWithEmail:reqster.email password:reqster.password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    [reqster proceedToRequest:nil];
}

- (void)renewTokens
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[3] integerValue];
    NSString *a = [self getAccessTokenForAccount:self.user.serverId];
    NSString *r = [self getRefreshTokenForAccount:self.user.serverId];
    reqster.isBearer = YES;
    reqster.body = [self getJSONRenewTokensWithAccessToken:a refreshToken:r err:nil];
    reqster.userId = self.user.serverId;
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.accessToken = a;
    [reqster proceedToRequest:nil];
}

- (void)emailForActivation
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.requestType = [reqTypeArray[6] integerValue];
    NSString *a = [self getAccessTokenForAccount:self.user.serverId];
    reqster.isBearer = YES;
    reqster.method = @"GET";
    reqster.accessToken = a;
    reqster.userId = self.user.serverId;
    [reqster proceedToRequest:nil];
}

- (void)newDeviceInfo
{
    TVRequestId *rId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:self.managedObjectContext];
    [self setupNewRequestId:rId action:TVDocNew for:(TVBase *)self.user];
    [self.managedObjectContext save:nil];
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[4] integerValue];
    NSString *a = [self getAccessTokenForAccount:self.user.serverId];
    reqster.reqId = rId;
    reqster.isBearer = YES;
    reqster.body = [self getJSONDeviceInfo:self.user requestId:reqster.reqId.requestId err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.accessToken = a;
    reqster.userId = self.user.serverId;
    [reqster proceedToRequest:nil];
}

- (void)oneDeviceInfo
{
    TVRequestId *rId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:self.managedObjectContext];
    [self setupNewRequestId:rId action:TVDocUpdated for:(TVBase *)self.user];
    [self.managedObjectContext save:nil];
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.ctx = self.managedObjectContext;
    reqster.requestType = [reqTypeArray[5] integerValue];
    NSString *a = [self getAccessTokenForAccount:self.user.serverId];
    reqster.reqId = rId;
    reqster.isBearer = YES;
    reqster.body = [self getJSONDeviceInfo:self.user requestId:reqster.reqId.requestId err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.accessToken = a;
    reqster.userId = self.user.serverId;
    reqster.deviceInfoId = self.user.deviceInfoId;
    reqster.objectIdArray = [NSMutableArray arrayWithCapacity:0];
    [reqster.objectIdArray addObject:self.user.deviceInfoId];
    [reqster proceedToRequest:nil];
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

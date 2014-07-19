//
//  TVActivationViewController.m
//  testView
//
//  Created by Liwei Zhang on 2014-06-25.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVActivationViewController.h"
#import "NSObject+NetworkHandler.h"
#import "NSObject+DataHandler.h"
#import "TVRequester.h"
#import "TVAppRootViewController.h"

@interface TVActivationViewController ()

@end

@implementation TVActivationViewController {
    CGFloat btnHeight;
    CGFloat gap;
    CGFloat topIntroHeight;
    CGFloat bottomIntroHeight;
}

@synthesize connectIntro;
@synthesize connectBtn;
@synthesize connectBtnTap;
@synthesize sendIntro;
@synthesize sendBtn;
@synthesize sendBtnTap;
@synthesize emailDisplay;
@synthesize signOutBtn;
@synthesize signOutBtnTap;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceed:) name:@"TVRequestOKOnly" object:nil];
    btnHeight = 44.0f;
    gap = 20.0f;
    topIntroHeight = (460.0f - btnHeight) * 0.5f - gap * 2.0f;
    bottomIntroHeight = (460.0f - btnHeight) * 0.5f - gap * 3.0f - btnHeight;
    
    self.connectBtn = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, (self.appRect.size.height - btnHeight) * 0.5f, self.appRect.size.width - 20.0f * 2.0f, btnHeight)];
    [self.view addSubview:self.connectBtn];
    self.connectBtn.backgroundColor = [UIColor greenColor];
    self.connectBtn.userInteractionEnabled = YES;
    self.connectBtn.textAlignment = NSTextAlignmentCenter;
    self.connectBtn.text = @"Continue";
    self.connectBtn.textColor = [UIColor whiteColor];
    self.connectBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkUserAgain)];
    [self.connectBtn addGestureRecognizer:self.connectBtnTap];
    
    self.connectIntro = [[UILabel alloc] initWithFrame:CGRectMake(self.connectBtn.frame.origin.x, self.connectBtn.frame.origin.y - gap - topIntroHeight, self.connectBtn.frame.size.width, topIntroHeight)];
    self.connectIntro.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.connectIntro];
    
    self.sendIntro = [[UILabel alloc] initWithFrame:CGRectMake(self.connectBtn.frame.origin.x, self.connectBtn.frame.origin.y + btnHeight + gap, self.connectBtn.frame.size.width, bottomIntroHeight)];
    self.sendIntro.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.sendIntro];
    
    self.sendBtn = [[UILabel alloc] initWithFrame:CGRectMake(self.connectBtn.frame.origin.x, self.sendIntro.frame.origin.y + bottomIntroHeight + gap, self.connectBtn.frame.size.width, btnHeight)];
    [self.view addSubview:self.connectBtn];
    self.sendBtn.backgroundColor = [UIColor greenColor];
    self.sendBtn.userInteractionEnabled = YES;
    self.sendBtn.textAlignment = NSTextAlignmentCenter;
    self.sendBtn.text = @"Send";
    self.sendBtn.textColor = [UIColor whiteColor];
    self.sendBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendEmail)];
    [self.sendBtn addGestureRecognizer:self.sendBtnTap];
    [self.view addSubview:self.sendBtn];
}

- (void)checkUserAgain
{
    self.transitionPointInRoot = [self.connectBtnTap locationInView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
    // Get user from server and check activation again
    TVRequester *r = [[TVRequester alloc] init];
    r.transitionPointInRoot = self.transitionPointInRoot;
    r.fromVewTag = self.view.tag;
    r.coordinator = self.persistentStoreCoordinator;
    r.requestType = TVOneUser;
    r.isUserTriggered = YES;
    r.userId = self.user.serverId;
    r.isBearer = YES;
    r.method = @"GET";
    r.accessToken = [self getAccessTokenForAccount:self.user.serverId];
    [r checkServerAvailabilityToProceed];
}

- (void)sendEmail
{
    self.transitionPointInRoot = [self.sendBtnTap locationInView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
    TVAppRootViewController *t = (TVAppRootViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    [t sendActivationEmail:YES];
}

- (void)proceed:(NSNotification *)note
{
    TVRequester *r = (TVRequester *)note;
    if (r.requestType == TVEmailForActivation) {
        // Show email sent msg to user
    } else if (r.requestType == TVOneUser) {
        // Check the user in local db to know the activation status
        [self.managedObjectContext refreshObject:self.user mergeChanges:NO];
        if (self.user.activated) {
            [[NSNotificationCenter defaultCenter] postNotificationName:tvShowLangPick object:r];
        }
    }
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

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
#import "TVLayerBaseViewController.h"

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
        self.actionNo = TVPinchRoot;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:self.box.appRect];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    btnHeight = 44.0f;
    gap = 20.0f;
    topIntroHeight = (460.0f - btnHeight) * 0.5f - gap * 2.0f;
    bottomIntroHeight = (460.0f - btnHeight) * 0.5f - gap * 3.0f - btnHeight;
    
    self.connectBtn = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, (self.box.appRect.size.height - btnHeight) * 0.5f, self.box.appRect.size.width - 20.0f * 2.0f, btnHeight)];
    [self.view addSubview:self.connectBtn];
    self.connectBtn.backgroundColor = [UIColor greenColor];
    self.connectBtn.userInteractionEnabled = YES;
    self.connectBtn.textAlignment = NSTextAlignmentCenter;
    self.connectBtn.text = @"Continue";
    self.connectBtn.textColor = [UIColor whiteColor];
    self.connectBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(proceed)];
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

- (void)proceed
{
    // Check server availability
    [self checkServerAvail:YES inQueue:self.box.comWorker flagToSet:self.box.serverIsAvailable];
    TVRequester *req = [[TVRequester alloc] init];
    req.box = self.box;
    req.isUserTriggered = YES;
    req.isBearer = YES;
    req.accessToken = [self getAccessTokenForAccount:self.box.userServerId];
    req.method = @"GET";
    req.requestType = TVOneUser;
    [req setupRequest];
    [req setupAndLoadToQueue:self.box.comWorker];
}

- (void)sendEmail
{
    self.box.transitionPointInRoot = [self.sendBtnTap locationInView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
    TVAppRootViewController *t = (TVAppRootViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    [t sendActivationEmail:YES];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  TVSaveViewController.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-31.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVSaveViewController.h"
#import "TVAppRootViewController.h"
#import "TVView.h"
#import "UIViewController+InOutTransition.h"

@interface TVSaveViewController ()

@end

@implementation TVSaveViewController

@synthesize box;
@synthesize saveAsNewBtn;
@synthesize saveAsNewTap;
@synthesize updateBtn;
@synthesize updateTap;
@synthesize createNewOnly;
@synthesize ctlInCharge;

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
    //self.myNewView.decelerationRate =  UIScrollViewDecelerationRateFast;
    TVView *theView = [[TVView alloc] initWithFrame:[TVRootViewCtlBox sharedBox].appRect];
    theView.touchToDismissKeyboardIsOn = NO;
    theView.touchToDismissViewIsOn = YES;
    theView.ctlInCharge = self.ctlInCharge;
    self.view = theView;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Add Create button.
    // The action will be added in rootViewController
    self.saveAsNewBtn = [[UILabel alloc] initWithFrame:CGRectMake([TVRootViewCtlBox sharedBox].originX, 10.0f, [TVRootViewCtlBox sharedBox].labelWidth, tvRowHeight)];
    self.saveAsNewBtn.userInteractionEnabled = YES;
    self.saveAsNewBtn.text = @"Create a new card";
    self.saveAsNewBtn.textAlignment = NSTextAlignmentCenter;
    self.saveAsNewBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.saveAsNewBtn];
    self.saveAsNewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveAsNew)];
    [self.saveAsNewBtn addGestureRecognizer:self.saveAsNewTap];
    
    [self checkIfUpdateBtnNeeded];
}

- (void)checkIfUpdateBtnNeeded
{
    if (self.createNewOnly == YES) {
        self.updateBtn.hidden = YES;
    } else {
        if (!self.updateBtn) {
            self.updateBtn = [[UILabel alloc] initWithFrame:CGRectMake([TVRootViewCtlBox sharedBox].originX, self.saveAsNewBtn.frame.origin.y + self.saveAsNewBtn.frame.size.height + 10.0f, [TVRootViewCtlBox sharedBox].labelWidth, tvRowHeight)];
            self.updateBtn.userInteractionEnabled = YES;
            self.updateBtn.text = @"Update";
            self.updateBtn.textAlignment = NSTextAlignmentCenter;
            self.updateBtn.backgroundColor = [UIColor greenColor];
            self.updateBtn.hidden = YES;
            [self.view addSubview:self.updateBtn];
            self.updateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveAsUpdate)];
            [self.updateBtn addGestureRecognizer:self.updateTap];
        }
        self.updateBtn.hidden = NO;
    }
}

- (void)saveAsNew
{
    [TVRootViewCtlBox sharedBox].transitionPointInRoot = [self pointBy:self.saveAsNewTap inView:self.parentViewController.view];
    [[NSNotificationCenter defaultCenter] postNotificationName:tvSaveAsNew object:self];
}

- (void)saveAsUpdate
{
    [TVRootViewCtlBox sharedBox].transitionPointInRoot = [self pointBy:self.updateTap inView:self.parentViewController.view];
    [[NSNotificationCenter defaultCenter] postNotificationName:tvSaveAsUpdate object:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

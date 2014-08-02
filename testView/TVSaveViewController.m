//
//  TVSaveViewController.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-31.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVSaveViewController.h"
#import "TVAppRootViewController.h"

@interface TVSaveViewController ()

@end

@implementation TVSaveViewController

@synthesize appRect;
@synthesize box;
@synthesize saveAsNewBtn;
@synthesize saveAsNewTap;
@synthesize updateBtn;
@synthesize updateTap;

- (void)loadView
{
    //self.myNewView.decelerationRate =  UIScrollViewDecelerationRateFast;
    self.view = [[UIView alloc] initWithFrame:self.appRect];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Add Create button.
    // The action will be added in rootViewController
    self.saveAsNewBtn = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, 10.0f, self.box.labelWidth, tvRowHeight)];
    self.saveAsNewBtn.userInteractionEnabled = YES;
    self.saveAsNewBtn.text = @"Create a new card";
    self.saveAsNewBtn.textAlignment = NSTextAlignmentCenter;
    self.saveAsNewBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.saveAsNewBtn];
    self.saveAsNewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveAsNew)];
    [self.saveAsNewBtn addGestureRecognizer:self.saveAsNewTap];
    
    self.updateBtn = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.saveAsNewBtn.frame.origin.y + self.saveAsNewBtn.frame.size.height + 10.0f, self.box.labelWidth, tvRowHeight)];
    self.updateBtn.userInteractionEnabled = YES;
    self.updateBtn.text = @"Update";
    self.updateBtn.textAlignment = NSTextAlignmentCenter;
    self.updateBtn.backgroundColor = [UIColor greenColor];
    self.updateBtn.hidden = YES;
    [self.view addSubview:self.updateBtn];
    self.updateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveAsUpdate)];
    [self.updateBtn addGestureRecognizer:self.updateTap];
    
    self.cancelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [self.view addGestureRecognizer:self.cancelTap];
}

- (void)saveAsNew
{
    [[NSNotificationCenter defaultCenter] postNotificationName:tvSaveAsNew object:self];
}

- (void)saveAsUpdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:tvSaveAsUpdate object:self];
}

- (void)dismissView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:tvDismissSaveViewOnly object:self];
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

//
//  TVCardsTopViewController.m
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVCardsTopViewController.h"


@interface TVCardsTopViewController ()

@end

@implementation TVCardsTopViewController

@synthesize topView, position, tempSize;

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
    CGRect firstRect = [[UIScreen mainScreen] applicationFrame];
    self.tempSize = firstRect.size;
    CGRect tempRect = CGRectMake(0.0, 0.0, tempSize.width, 44.0);
    self.topView = [[UIView alloc] initWithFrame:tempRect];
    self.view = self.topView;
    self.view.backgroundColor = [UIColor lightTextColor];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Add topBar    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TVLangPickViewController.m
//  testView
//
//  Created by Liwei on 10/23/2013.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVLangPickViewController.h"

@interface TVLangPickViewController ()

@end

@implementation TVLangPickViewController

@synthesize sourceLangViewIntro, sourceLangView, sourceLangTap, targetLangViewIntro, targetLangView, targetLangTap, tableIsForSourceLang, langPickController, originY;

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
    CGRect viewRect = CGRectMake(0.0f, self.originY, firstRect.size.width, 250.0f);
    self.view = [[UIView alloc] initWithFrame:viewRect];
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.sourceLangViewIntro = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 15.0f, (self.view.frame.size.width - 15.0f * 2.0f), 44.0f)];
    
    self.sourceLangView = [[UILabel alloc] initWithFrame:CGRectMake(self.sourceLangViewIntro.frame.origin.x, self.sourceLangViewIntro.frame.origin.y + self.sourceLangViewIntro.frame.size.height, self.sourceLangViewIntro.frame.size.width, self.sourceLangViewIntro.frame.size.height)];
    self.sourceLangView.userInteractionEnabled = YES;
    self.sourceLangTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getSourceLangTable)];
    [self.sourceLangView addGestureRecognizer:self.sourceLangTap];
    
    self.targetLangViewIntro = [[UILabel alloc] initWithFrame:CGRectMake(self.sourceLangView.frame.origin.x, self.sourceLangView.frame.origin.y + self.sourceLangView.frame.size.height, self.sourceLangView.frame.size.width, self.sourceLangView.frame.size.height)];
    
    self.targetLangView = [[UILabel alloc] initWithFrame:CGRectMake(self.targetLangViewIntro.frame.origin.x, self.targetLangViewIntro.frame.origin.y + self.targetLangViewIntro.frame.size.height, self.targetLangViewIntro.frame.size.width, self.targetLangViewIntro.frame.size.height)];
    self.targetLangView.userInteractionEnabled = YES;
    self.targetLangTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getTargetLangTable)];
    [self.targetLangView addGestureRecognizer:self.targetLangTap];
    
    self.sourceLangViewIntro.backgroundColor = [UIColor grayColor];
    self.sourceLangView.backgroundColor = [UIColor whiteColor];
    self.targetLangViewIntro.backgroundColor = [UIColor grayColor];
    self.targetLangView.backgroundColor = [UIColor whiteColor];
    self.sourceLangViewIntro.text = @"Source";
    self.targetLangViewIntro.text = @"Target";
    
    [self.view addSubview:self.sourceLangViewIntro];
    [self.view addSubview:self.sourceLangView];
    [self.view addSubview:self.targetLangViewIntro];
    [self.view addSubview:self.targetLangView];
}

- (void)getSourceLangTable
{
    self.tableIsForSourceLang = YES;
    [self getLangTable];
}

- (void)getTargetLangTable
{
    self.tableIsForSourceLang = NO;
    [self getLangTable];
}

- (void)getLangTable
{
    if (!self.langPickController) {
        self.langPickController = [[TVLangPickTableViewController alloc] init];
        self.langPickController.tableView.delegate = self;
    }
    [self presentViewController:self.langPickController animated:YES completion:nil];
//    [self addChildViewController:self.langPickController];
//    [self.view addSubview:self.langPickController.tableView];
//    [self.langPickController didMoveToParentViewController:self];
}

- (void)dismissLangTable
{
    [self.langPickController dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableIsForSourceLang == YES) {
        self.sourceLangView.text = [self.langPickController.langArray objectAtIndex:indexPath.row];
        self.user.sourceLang = self.sourceLangView.text;
    } else {
        self.targetLangView.text = [self.langPickController.langArray objectAtIndex:indexPath.row];
        self.user.targetLang = self.targetLangView.text;
    }
    [self dismissLangTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

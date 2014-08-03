//
//  TVLangPickViewController.m
//  testView
//
//  Created by Liwei on 10/23/2013.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVLangPickViewController.h"
#import "TVAppRootViewController.h"

@interface TVLangPickViewController ()

@end

@implementation TVLangPickViewController

@synthesize lang;
@synthesize button;
@synthesize buttonTap;
@synthesize tableIsForSourceLang;
@synthesize langPickController;
@synthesize originY;
@synthesize warning;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    CGRect firstRect = [[UIScreen mainScreen] applicationFrame];
    CGRect viewRect = CGRectMake(0.0f, self.originY, firstRect.size.width, firstRect.size.height);
    self.view = [[UIView alloc] initWithFrame:viewRect];
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.langPickController = [[TVLangPickTableViewController alloc] init];
    self.lang = [[UITextField alloc] initWithFrame:CGRectMake(15.0f, 15.0f, (self.view.frame.size.width - 15.0f * 2.0f), 44.0f)];
    self.lang.clearButtonMode = UITextFieldViewModeAlways;
    self.lang.delegate = self;
    [self.view addSubview:self.lang];
    self.langPickController.originY1 = self.lang.frame.origin.y + self.lang.frame.size.height;
    self.button = [[UILabel alloc] initWithFrame:CGRectMake(self.lang.frame.origin.x, self.view.frame.size.height - self.lang.frame.size.height, self.lang.frame.size.width, self.lang.frame.size.height)];
    [self.view addSubview:self.button];
    self.button.backgroundColor = [UIColor greenColor];
    self.button.userInteractionEnabled = YES;
    self.button.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.button];
    self.buttonTap = [[UITapGestureRecognizer alloc] init];
    [self.button addGestureRecognizer:self.buttonTap];
    self.langPickController.originY2 = self.button.frame.origin.y;
    if (self.tableIsForSourceLang) {
        self.lang.placeholder = @"Your native language is?";
        self.button.text = @"Next";
        [self.buttonTap addTarget:self action:@selector(validateToTargetLang)];
        self.view.tag = 1003;
    } else {
        self.lang.placeholder = @"Language to learn?";
        self.button.text = @"Sign Up";
        [self.buttonTap addTarget:self action:@selector(validateAndSignUp)];
        self.view.tag = 1004;
    }
    self.langPickController.tableView.delegate = self;
    [self addChildViewController:self.langPickController];
    [self.view addSubview:self.langPickController.view];
    [self.langPickController didMoveToParentViewController:self];
}

- (void)validateToTargetLang
{
    if ([self validateTextField]) {
        [self nextToTargetLang];
    }
}

- (void)nextToTargetLang
{
    self.box.transitionPointInRoot = [self.buttonTap locationInView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
    NSLog(@"text: %@", self.lang.text);
    [self.box.sourceLang setString:self.lang.text];
    NSLog(@"text1: %@", self.box.sourceLang);
    [[NSNotificationCenter defaultCenter] postNotificationName:tvShowTarget object:self];
}

- (void)validateAndSignUp
{
    if ([self validateTextField]) {
        [self signUp];
    }
}

- (void)signUp
{
    self.box.transitionPointInRoot = [self.buttonTap locationInView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
    NSLog(@"text: %@", self.lang.text);
    NSLog(@"text0: %@", self.box.targetLang);
    [self.box.targetLang setString:self.lang.text];
    NSLog(@"text1: %@", self.box.sourceLang);
    NSLog(@"text2: %@", self.box.targetLang);
    [[NSNotificationCenter defaultCenter] postNotificationName:tvUserSignUp object:self];
}

- (BOOL)validateTextField
{
    BOOL isMatched = NO;
    for (NSString *aLang in self.langPickController.langArray) {
        if ([aLang isEqualToString:self.lang.text]) {
            isMatched = YES;
            break;
        }
    }
    if (!isMatched) {
        [self.box.warning setString:@"Please select a language."];
        [[NSNotificationCenter defaultCenter] postNotificationName:tvShowWarning object:self];
        return NO;
    }
    return YES;
}

// User is not allowed to edit directly.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"text21: %@", self.box.sourceLang);
    NSLog(@"text22: %@", self.box.targetLang);
    self.lang.text = [self.langPickController.langArray objectAtIndex:indexPath.row];
    NSLog(@"text31: %@", self.box.sourceLang);
    NSLog(@"text32: %@", self.box.targetLang);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TVLoginViewController.m
//  testView
//
//  Created by Liwei Zhang on 2013-10-19.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVLoginViewController.h"
//#import "UIViewController+sharedMethods.h"

@interface TVLoginViewController ()

@end

@implementation TVLoginViewController

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

@synthesize emailInput, passwordInput, signUpButton, loginButton, termsBox, agreeToTermsTextBox, agreeToPrivacyTextBox, allContentIsOpenTextBox, forgotPassword, signUpButtonTap, loginButtonTap, isSigningUP, tapDetector, passItem, forgotPasswordTap, appRect;

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
    self.tapDetector = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:self.tapDetector];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isSigningUP = NO;
    self.emailInput = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 50.0, self.view.frame.size.width - 20.0 * 2, 50.0)];
    self.emailInput.backgroundColor = [UIColor whiteColor];
    self.emailInput.delegate = self;
    self.emailInput.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.emailInput];
    
    self.passwordInput = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 20.0 + self.emailInput.frame.origin.y + self.emailInput.frame.size.height, self.view.frame.size.width - 20.0 * 2, 50.0)];
    self.passwordInput.backgroundColor = [UIColor whiteColor];
    self.passwordInput.clearsOnBeginEditing = YES;
    [self.view addSubview:self.passwordInput];
    self.passwordInput.delegate = self;
    self.passwordInput.returnKeyType = UIReturnKeyDone;
    self.passwordInput.secureTextEntry = YES;
    
    self.signUpButton = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0 + self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height, ((self.view.frame.size.width - 20.0 * 2) - 20.0) / 2, 50.0)];
    [self.view addSubview:self.signUpButton];
    self.signUpButton.userInteractionEnabled = YES;
    self.signUpButton.text = @"Sign Up";
    self.signUpButton.textAlignment = NSTextAlignmentCenter;
    self.signUpButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToSignUp)];
    [self.signUpButton addGestureRecognizer:self.signUpButtonTap];
    
    self.loginButton = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + 20.0 + self.signUpButton.frame.size.width, 20.0 + self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height, ((self.view.frame.size.width - 20.0 * 2) - 20.0) / 2, 50.0)];
    [self.view addSubview:self.loginButton];
    self.loginButton.userInteractionEnabled = YES;
    self.loginButton.text = @"Login";
    self.loginButton.textAlignment = NSTextAlignmentCenter;
    self.loginButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToLogin)];
    [self.loginButton addGestureRecognizer:self.loginButtonTap];
    
    self.forgotPassword = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + 20.0 + self.loginButton.frame.size.width, 20.0 + self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height, ((self.view.frame.size.width - 20.0 * 2) - 20.0) / 2, 50.0)];
    [self.view addSubview:self.forgotPassword];
    self.forgotPassword.userInteractionEnabled = YES;
    self.forgotPassword.text = @"Forgot password?";
    self.forgotPassword.textAlignment = NSTextAlignmentCenter;
    self.forgotPasswordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToLogin)];
    [self.forgotPassword addGestureRecognizer:self.forgotPasswordTap];
    
    [self switchSignUpLogin];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)chooseToSignUp
{
    [self makeSwitchSignUpLogin];
}

- (void)chooseToLogin
{
    [self makeSwitchSignUpLogin];
}

- (void)makeSwitchSignUpLogin
{
    if (self.isSigningUP == YES) {
        self.isSigningUP = NO;
    } else {
        self.isSigningUP = YES;
    }
    [self switchSignUpLogin];
}

- (void)switchSignUpLogin
{
    if (self.isSigningUP == YES) {
        self.signUpButton.backgroundColor = [UIColor greenColor];
        self.loginButton.backgroundColor = [UIColor grayColor];
    } else {
        self.signUpButton.backgroundColor = [UIColor grayColor];
        self.loginButton.backgroundColor = [UIColor greenColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.passwordInput]) {
        NSString *URLToGo;
        if (self.isSigningUP == YES) {
            // Sign up for new user, generate a request for registeration, if successful, get pass
            URLToGo = @"";
        } else {
            // Login, generate a request to get pass
            URLToGo = @"";
        }
//        [self startRegistrationLoginWithEmail:self.emailInput.text password:self.passwordInput.text withURLString:URLToGo];
    } else {
        self.passwordInput.text = @"";
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

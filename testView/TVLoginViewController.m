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

@synthesize emailInput, passwordInput;
@synthesize signUpButton, signUpButtonTap;
@synthesize signInButton, signInButtonTap;
@synthesize switchToSignIn, switchToSignInTap;
@synthesize switchToSignUp, switchToSignUpTap;
@synthesize terms, termsTap;

@synthesize termsBox, agreeToTermsTextBox, agreeToPrivacyTextBox, introTextBox, forgotPassword, isSigningUP, tapDetector, passItem, forgotPasswordTap, appRect;

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
    
    self.emailInput = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 200.0f, self.view.frame.size.width - 20.0f * 2.0f, 50.0f)];
    self.emailInput.backgroundColor = [UIColor whiteColor];
    self.emailInput.delegate = self;
    self.emailInput.returnKeyType = UIReturnKeyNext;
    self.emailInput.placeholder = @"Email";
    [self.view addSubview:self.emailInput];
    
    self.forgotPassword = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f + self.emailInput.frame.origin.y + self.emailInput.frame.size.height, self.view.frame.size.width - 20.0f * 2.0f, 26.0f)];
    [self.view addSubview:self.forgotPassword];
    self.forgotPassword.userInteractionEnabled = YES;
    self.forgotPassword.text = @"Forgot password?";
    self.forgotPassword.textAlignment = NSTextAlignmentRight;
    self.forgotPasswordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToLogin)];
    [self.forgotPassword addGestureRecognizer:self.forgotPasswordTap];
    
    self.terms = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f + self.emailInput.frame.origin.y + self.emailInput.frame.size.height, self.view.frame.size.width - 20.0f * 2.0f, 26.0f)];
    [self.view addSubview:self.terms];
    self.terms.hidden = YES;
    self.terms.userInteractionEnabled = YES;
    self.terms.text = @"Forgot password?";
    self.terms.textAlignment = NSTextAlignmentRight;
    self.termsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToLogin)];
    [self.terms addGestureRecognizer:self.termsTap];
    
    self.passwordInput = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 20.0f + self.forgotPassword.frame.origin.y + self.forgotPassword.frame.size.height, self.view.frame.size.width - 20.0f * 2.0f, 50.0f)];
    self.passwordInput.backgroundColor = [UIColor whiteColor];
    self.passwordInput.clearsOnBeginEditing = YES;
    [self.view addSubview:self.passwordInput];
    self.passwordInput.delegate = self;
    self.passwordInput.returnKeyType = UIReturnKeyDone;
    self.passwordInput.placeholder = @"Password";
    self.passwordInput.secureTextEntry = YES;
    
    self.signUpButton = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f + self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height, self.view.frame.size.width - 20.0f * 2.0f, 50.0f)];
    [self.view addSubview:self.signUpButton];
    self.signUpButton.backgroundColor = [UIColor greenColor];
    self.signUpButton.hidden = YES;
    self.signUpButton.userInteractionEnabled = YES;
    self.signUpButton.text = @"Sign Up";
    self.signUpButton.textAlignment = NSTextAlignmentCenter;
    self.signUpButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToSignUp)];
    [self.signUpButton addGestureRecognizer:self.signUpButtonTap];
    
    self.signInButton = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f + self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height, self.view.frame.size.width - 20.0f * 2.0f, 50.0f)];
    [self.view addSubview:self.signInButton];
    self.signInButton.backgroundColor = [UIColor greenColor];
    self.signInButton.userInteractionEnabled = YES;
    self.signInButton.text = @"Sign In";
    self.signInButton.textAlignment = NSTextAlignmentCenter;
    self.signInButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToLogin)];
    [self.signInButton addGestureRecognizer:self.signInButtonTap];
    
    self.switchToSignIn = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f + self.signInButton.frame.origin.y + self.signInButton.frame.size.height, self.view.frame.size.width - 20.0f * 2.0f, 26.0f)];
    [self.view addSubview:self.switchToSignIn];
    self.switchToSignIn.userInteractionEnabled = YES;
    self.switchToSignIn.hidden = YES;
    self.switchToSignIn.text = @"Already a member? Sign in.";
    self.switchToSignIn.textAlignment = NSTextAlignmentCenter;
    self.switchToSignInTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToLogin)];
    [self.switchToSignIn addGestureRecognizer:self.switchToSignInTap];
    
    self.switchToSignUp = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f + self.signInButton.frame.origin.y + self.signInButton.frame.size.height, self.view.frame.size.width - 20.0f * 2.0f, 26.0f)];
    [self.view addSubview:self.switchToSignUp];
    self.switchToSignUp.userInteractionEnabled = YES;
    self.switchToSignUp.text = @"New member? Sign up.";
    self.switchToSignUp.textAlignment = NSTextAlignmentCenter;
    self.switchToSignUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseToLogin)];
    [self.switchToSignUp addGestureRecognizer:self.switchToSignUpTap];
    
//    [self switchSignUpLogin];
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

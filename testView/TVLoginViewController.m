//
//  TVLoginViewController.m
//  testView
//
//  Created by Liwei Zhang on 2013-10-19.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVLoginViewController.h"
#import "TVAppRootViewController.h"
#import "TVRequester.h"
#import "NSObject+NetworkHandler.h"
#import "MBProgressHUD.h"
#import "TVKeyboard.h"
#import "TVView.h"
//#import "UIViewController+sharedMethods.h"

@interface TVLoginViewController ()

@end

@implementation TVLoginViewController

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize introHeight;
@synthesize gapHeight;
@synthesize verticalPadding;
@synthesize horizontalPadding;
@synthesize inputX;
@synthesize inputWidth;
@synthesize inputHeight;
@synthesize smallFontSize;
@synthesize emailInput, passwordInput;
@synthesize signUpButton, signUpButtonTap;
@synthesize signInButton, signInButtonTap;
@synthesize switchToSignIn, switchToSignInTap;
@synthesize switchToSignUp, switchToSignUpTap;
@synthesize terms, termsTap;
@synthesize coverOnBaseView;

@synthesize appRect, animationSec;
@synthesize keyboard;

@synthesize termsBox, agreeToTermsTextBox, agreeToPrivacyTextBox, introTextBox, forgotPassword, isForSignUP, tapDetector, passItem, forgotPasswordTap;

// 5 parts: intro/email/info/password/submit and 5 gaps. gaps adjacent to info only have 1/2 gap. gap is 1/3 of text box height. Take 320 * 480 as the standard rectangle at the center of a screen, pad the rest of screen when the screen is bigger.
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
    self.animationSec = 0.1f;
    self.gapHeight = 460.0f * goldenRatio / (1.0f + 0.5f + 0.5f + 1.0f + 3.0f * 3.0f + 1.3f + 2.0f + 2.0f + 1.0f);
    self.introHeight = 460.0f * (1.0f - goldenRatio) - self.gapHeight * 1.5f;
    if (self.appRect.size.height > 460.0f) {
        self.verticalPadding = (self.appRect.size.height - 460.0f) / 2.0f;
    } else {
        self.verticalPadding = 0.0f;
    }
    if (self.appRect.size.width > 320.0f) {
        self.horizontalPadding = (self.appRect.size.width - 320.0f) / 2.0f;
    } else {
        self.horizontalPadding = 0.0f;
    }
    self.inputX = self.horizontalPadding + 20.0f;
    self.inputWidth = 320.0f - 20.0f * 2.0f;
    self.inputHeight = self.gapHeight * 3.0f;
    self.baseView = [[UIScrollView alloc] initWithFrame:self.appRect];
    self.baseView.contentSize = CGSizeMake(self.appRect.size.width, self.appRect.size.height * 2.0f);
    self.coverOnBaseView = [[TVView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.baseView.contentSize.width, self.baseView.contentSize.height)];
    [self.baseView addSubview:self.coverOnBaseView];
    self.baseView.scrollEnabled = NO;
    self.baseView.showsHorizontalScrollIndicator = NO;
    self.baseView.showsVerticalScrollIndicator = NO;
    self.view = self.baseView;
    self.view.backgroundColor = [UIColor redColor];
//    self.tapDetector = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    [self.view addGestureRecognizer:self.tapDetector];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isForSignUP = NO;
    
    self.introTextBox = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX, self.verticalPadding + self.gapHeight, self.inputWidth, self.introHeight)];
    self.introTextBox.backgroundColor = [UIColor greenColor];
    [self.coverOnBaseView addSubview:self.introTextBox];
    NSLog(@"self.introTextBox.frame.origin.y: %f", self.introTextBox.frame.origin.y);
    NSLog(@"self.gapHeight: %f", self.gapHeight);
    self.emailInput = [[UITextField alloc] initWithFrame:CGRectMake(self.inputX, self.verticalPadding + self.introHeight + self.gapHeight * 3.0f, self.inputWidth, self.inputHeight)];
    self.emailInput.backgroundColor = [UIColor whiteColor];
    self.emailInput.delegate = self;
    self.emailInput.returnKeyType = UIReturnKeyNext;
    self.emailInput.placeholder = @"Email";
    [self.coverOnBaseView addSubview:self.emailInput];
    
    self.passwordInput = [[UITextField alloc] initWithFrame:CGRectMake(self.inputX, self.emailInput.frame.origin.y + self.emailInput.frame.size.height + self.gapHeight * 0.5f, self.inputWidth, self.inputHeight)];
    self.passwordInput.backgroundColor = [UIColor whiteColor];
    self.passwordInput.clearsOnBeginEditing = YES;
    [self.coverOnBaseView addSubview:self.passwordInput];
    self.passwordInput.delegate = self;
    self.passwordInput.returnKeyType = UIReturnKeyDone;
    self.passwordInput.placeholder = @"Password";
    self.passwordInput.secureTextEntry = YES;
    
    [self showSignInButton];
    
    [self showForgotPassword];
    
    [self showSwitchToSignUp];
}


- (void)showSignUpButton
{
    if (self.signInButton) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.signInButton.alpha = 0.0f;
        }];
    }
    if (!self.signUpButton) {
        self.signUpButton = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX, self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height + self.gapHeight * 0.5f, self.inputWidth, self.inputHeight)];
        [self.coverOnBaseView addSubview:self.signUpButton];
        self.signUpButton.backgroundColor = [UIColor greenColor];
        self.signUpButton.userInteractionEnabled = YES;
        self.signUpButton.text = @"Sign Up";
        self.signUpButton.textAlignment = NSTextAlignmentCenter;
        self.signUpButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signUp)];
        [self.signUpButton addGestureRecognizer:self.signUpButtonTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.signUpButton];
    if (self.signUpButton.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.signUpButton.alpha = 1.0f;
        }];
    }
}

- (void)showSignInButton
{
    if (self.signUpButton.alpha == 1.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.signUpButton.alpha = 0.0f;
        }];
    }
    if (!self.signInButton) {
        self.signInButton = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX, self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height + self.gapHeight * 0.5f, self.inputWidth, self.inputHeight)];
        [self.coverOnBaseView addSubview:self.signInButton];
        self.signInButton.backgroundColor = [UIColor greenColor];
        self.signInButton.userInteractionEnabled = YES;
        self.signInButton.text = @"Sign In";
        self.signInButton.textAlignment = NSTextAlignmentCenter;
        self.signInButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signIn)];
        [self.signInButton addGestureRecognizer:self.signInButtonTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.signInButton];
    if (self.signInButton.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.signInButton.alpha = 1.0f;
        }];
    }
}

- (void)showForgotPassword
{
    if (self.terms) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.terms.alpha = 0.0f;
        }];
    }
    if (!self.forgotPassword) {
        self.forgotPassword = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX + self.inputWidth * 1.0f / 2.0f, self.signInButton.frame.origin.y + self.signInButton.frame.size.height + self.gapHeight, self.inputWidth * 1.0f / 2.0f, self.gapHeight * 1.3f)];
        [self.coverOnBaseView addSubview:self.forgotPassword];
        self.forgotPassword.font = [self.forgotPassword.font fontWithSize:self.emailInput.font.pointSize * 0.8f];
        self.forgotPassword.userInteractionEnabled = YES;
        self.forgotPassword.text = @"Forgot password?";
        self.forgotPassword.textAlignment = NSTextAlignmentRight;
        self.forgotPasswordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailToResettingPassword)];
        [self.forgotPassword addGestureRecognizer:self.forgotPasswordTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.forgotPassword];
    if (self.forgotPassword.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.forgotPassword.alpha = 1.0f;
        }];
    }
}

- (void)showTerms
{
    if (self.forgotPassword.alpha == 1.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.forgotPassword.alpha = 0.0f;
        }];
    }
    if (!self.terms) {
        self.terms = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX + self.inputWidth * 1.0f / 2.0f, self.signInButton.frame.origin.y + self.signInButton.frame.size.height + self.gapHeight, self.inputWidth * 1.0f / 2.0f, self.gapHeight * 1.3f)];
        [self.coverOnBaseView addSubview:self.terms];
        self.terms.font = [self.terms.font fontWithSize:self.emailInput.font.pointSize * 0.8f];
        self.terms.userInteractionEnabled = YES;
        self.terms.text = @"terms";
        self.terms.textAlignment = NSTextAlignmentRight;
        self.termsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(termsDetail)];
        [self.terms addGestureRecognizer:self.termsTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.terms];
    if (self.terms.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.terms.alpha = 1.0f;
        }];
    }
}

- (void)emailToResettingPassword
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.coordinator = self.persistentStoreCoordinator;
    reqster.requestType = TVEmailForPasswordResetting;
    reqster.email = self.emailInput.text;
    reqster.body = [self getJSONForgotPasswordWithEmail:reqster.email err:nil];
    
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.indicator = self.indicator;
    [reqster checkServerAvailabilityToProceed];
}

- (void)termsDetail
{
    
}

- (void)signUp
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.coordinator = self.persistentStoreCoordinator;
    reqster.requestType = TVSignUp;
    reqster.email = self.emailInput.text;
    reqster.password = self.passwordInput.text;
    reqster.isBearer = NO;
    reqster.body = [self getJSONSignUpOrInWithEmail:reqster.email password:reqster.password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.indicator = self.indicator;
    reqster.isUserTriggered = YES;
    [reqster checkServerAvailabilityToProceed];
}

- (void)signIn
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.coordinator = self.persistentStoreCoordinator;
    reqster.requestType = TVSignIn;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSPredicate *pUser = [NSPredicate predicateWithFormat:@"email like %@", self.emailInput.text];
    [fetchRequest setPredicate:pUser];
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if ([r count] > 0) {
        reqster.objectIdArray = [NSMutableArray arrayWithCapacity:0];
        [reqster.objectIdArray addObject:r[0]];
    }
    reqster.isUserTriggered = YES;
    reqster.email = self.emailInput.text;
    reqster.password = self.passwordInput.text;
    reqster.isBearer = NO;
    reqster.body = [self getJSONSignUpOrInWithEmail:reqster.email password:reqster.password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.indicator = self.indicator;
    [reqster checkServerAvailabilityToProceed];
}

- (void)showSwitchToSignIn
{
    if (self.switchToSignUp) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.switchToSignUp.alpha = 0.0f;
        }];
    }
    if (!self.switchToSignIn) {
        self.switchToSignIn = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX, self.forgotPassword.frame.origin.y + self.forgotPassword.frame.size.height + self.gapHeight * 2.0f, self.inputWidth, self.gapHeight * 2.0f)];
        [self.coverOnBaseView addSubview:self.switchToSignIn];
        self.switchToSignIn.userInteractionEnabled = YES;
        self.switchToSignIn.font = [self.switchToSignIn.font fontWithSize:self.emailInput.font.pointSize * 0.8f];
        self.switchToSignIn.text = @"Already a member? Sign in.";
        self.switchToSignIn.textAlignment = NSTextAlignmentCenter;
        self.switchToSignInTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSignIn)];
        [self.switchToSignIn addGestureRecognizer:self.switchToSignInTap];
    }
    if (self.switchToSignIn.alpha == 0.0f) {
        [self.coverOnBaseView bringSubviewToFront:self.switchToSignIn];
        [UIView animateWithDuration:self.animationSec animations:^{
            self.switchToSignIn.alpha = 1.0f;
        }];
    }
}

- (void)showSwitchToSignUp
{
    if (self.switchToSignIn) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.switchToSignIn.alpha = 0.0f;
        }];
    }
    if (!self.switchToSignUp) {
        self.switchToSignUp = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX, self.forgotPassword.frame.origin.y + self.forgotPassword.frame.size.height + self.gapHeight * 2.0f, self.inputWidth, self.gapHeight * 2.0f)];
        [self.coverOnBaseView addSubview:self.switchToSignUp];
        self.switchToSignUp.userInteractionEnabled = YES;
        self.switchToSignUp.font = [self.switchToSignUp.font fontWithSize:self.emailInput.font.pointSize * 0.8f];
        self.switchToSignUp.text = @"New member? Sign up.";
        self.switchToSignUp.textAlignment = NSTextAlignmentCenter;
        self.switchToSignUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSignUp)];
        [self.switchToSignUp addGestureRecognizer:self.switchToSignUpTap];
    }
    if (self.switchToSignUp.alpha == 0.0f) {
        [self.coverOnBaseView bringSubviewToFront:self.switchToSignUp];
        [UIView animateWithDuration:self.animationSec animations:^{
            self.switchToSignUp.alpha = 1.0f;
        }];
    }
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)goToSignUp
{
    [self showTerms];
    [self showSignUpButton];
    [self showSwitchToSignIn];
    self.isForSignUP = YES;
}

- (void)goToSignIn
{
    [self showForgotPassword];
    [self showSignInButton];
    [self showSwitchToSignUp];
    self.isForSignUP = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.passwordInput]) {
        NSString *URLToGo;
        if (self.isForSignUP == YES) {
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

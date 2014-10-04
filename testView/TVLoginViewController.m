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
#import "TVKeyboard.h"
#import "TVView.h"


@interface TVLoginViewController ()

@end

@implementation TVLoginViewController

@synthesize introHeight;
@synthesize gapHeight;
@synthesize verticalPadding;
@synthesize horizontalPadding;
@synthesize inputX;
@synthesize inputWidth;
@synthesize inputHeight;
@synthesize smallFontSize;

@synthesize emailInput, passwordInput;
@synthesize forgotPasswordButton, forgotPasswordButtonTap;
@synthesize signUpButton, signUpButtonTap;
@synthesize signInButton, signInButtonTap;
@synthesize switchToSignIn, switchToSignInTap;
@synthesize switchToSignUp, switchToSignUpTap;
@synthesize terms, termsTap;
@synthesize coverOnBaseView;
@synthesize animationSec;
@synthesize keyboard;

@synthesize forgotPassword, forgotPasswordTap;
@synthesize backToSignIn, backToSignInTap;

@synthesize termsBox, agreeToTermsTextBox, agreeToPrivacyTextBox, introTextBox, passItem;

// 5 parts: intro/email/info/password/submit and 5 gaps. gaps adjacent to info only have 1/2 gap. gap is 1/3 of text box height. Take 320 * 480 as the standard rectangle at the center of a screen, pad the rest of screen when the screen is bigger.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUp) name:tvUserSignUp object:nil];
        self.actionNo = TVPinchRoot;
    }
    return self;
}

- (void)loadView
{
    self.animationSec = 0.1f;
    self.gapHeight = 460.0f * goldenRatio / (1.0f + 0.5f + 0.5f + 1.0f + 3.0f * 3.0f + 1.3f + 2.0f + 2.0f + 1.0f);
    self.introHeight = 460.0f * (1.0f - goldenRatio) - self.gapHeight * 1.5f;
    if (self.box.appRect.size.height > 460.0f) {
        self.verticalPadding = (self.box.appRect.size.height - 460.0f) / 2.0f;
    } else {
        self.verticalPadding = 0.0f;
    }
    if (self.box.appRect.size.width > 320.0f) {
        self.horizontalPadding = (self.box.appRect.size.width - 320.0f) / 2.0f;
    } else {
        self.horizontalPadding = 0.0f;
    }
    self.inputX = self.horizontalPadding + 20.0f;
    self.inputWidth = 320.0f - 20.0f * 2.0f;
    self.inputHeight = self.gapHeight * 3.0f;
    self.baseView = [[UIScrollView alloc] initWithFrame:self.box.appRect];
    self.baseView.contentSize = CGSizeMake(self.box.appRect.size.width, self.box.appRect.size.height * 2.0f);
    self.coverOnBaseView = [[TVView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.baseView.contentSize.width, self.baseView.contentSize.height)];
    
    [self.baseView addSubview:self.coverOnBaseView];
    self.baseView.scrollEnabled = NO;
    self.baseView.showsHorizontalScrollIndicator = NO;
    self.baseView.showsVerticalScrollIndicator = NO;
    self.view = self.baseView;
    self.view.backgroundColor = [UIColor redColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    [self listenToKeyboardEvent];
}

#pragma mark - show signIn

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
        self.signInButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(validateAndSignIn)];
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
        self.forgotPassword = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX + (self.emailInput.frame.size.width - self.inputWidth * 1.0f / 2.0f) / 2.0f, self.signInButton.frame.origin.y + self.signInButton.frame.size.height + self.gapHeight, self.inputWidth * 1.0f / 2.0f, self.gapHeight * 1.3f)];
        [self.coverOnBaseView addSubview:self.forgotPassword];
        self.forgotPassword.font = [self.forgotPassword.font fontWithSize:self.emailInput.font.pointSize * 0.8f];
        self.forgotPassword.userInteractionEnabled = YES;
        self.forgotPassword.text = @"Forgot password?";
        self.forgotPassword.textAlignment = NSTextAlignmentCenter;
        self.forgotPasswordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showForgotPasswordButton)];
        [self.forgotPassword addGestureRecognizer:self.forgotPasswordTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.forgotPassword];
    if (self.forgotPassword.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.forgotPassword.alpha = 1.0f;
        }];
    }
}

- (void)validateAndSignIn
{
    if ([self validateTextField]) {
        [self signIn];
    }
}

- (void)signIn
{
    self.box.transitionPointInRoot = [self.signInButtonTap locationInView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.box = self.box;
    reqster.requestType = TVSignIn;
    
    reqster.isUserTriggered = YES;
    reqster.email = self.emailInput.text;
    reqster.password = self.passwordInput.text;
    reqster.isBearer = NO;
    //    reqster.body = [self getJSONSignUpOrInWithEmail:reqster.email password:reqster.password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    [reqster setupAndLoadToQueue:self.box.comWorker withDna:NO];
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

- (void)goToSignUp
{
    [self showTerms];
    [self showNextButton];
    [self showSwitchToSignIn];
}

#pragma mark - show signUp

- (void)showNextButton
{
    if (self.nextButton) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.nextButton.alpha = 0.0f;
        }];
    }
    if (!self.nextButton) {
        self.nextButton = [[UILabel alloc] initWithFrame:CGRectMake(self.inputX, self.passwordInput.frame.origin.y + self.passwordInput.frame.size.height + self.gapHeight * 0.5f, self.inputWidth, self.inputHeight)];
        [self.coverOnBaseView addSubview:self.nextButton];
        self.nextButton.backgroundColor = [UIColor greenColor];
        self.nextButton.userInteractionEnabled = YES;
        self.nextButton.text = @"Next";
        self.nextButton.textAlignment = NSTextAlignmentCenter;
        self.nextButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(validateToNativeLang)];
        [self.nextButton addGestureRecognizer:self.nextButtonTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.nextButton];
    if (self.nextButton.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.nextButton.alpha = 1.0f;
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

- (void)validateToNativeLang
{
    if ([self validateTextField]) {
        [self nextToNativeLang];
    };
}

- (void)nextToNativeLang
{
    self.box.transitionPointInRoot = [self.nextButtonTap locationInView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
    [[NSNotificationCenter defaultCenter] postNotificationName:tvShowNative object:self];
}

- (void)termsDetail
{
    
}

- (void)signUp
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.box = self.box;
    reqster.requestType = TVSignUp;
    reqster.email = self.emailInput.text;
    reqster.password = self.passwordInput.text;
    reqster.isBearer = NO;
    if (self.box) {
        NSLog(@"YES");
        if (self.box.sourceLang) {
            NSLog(@"YES");
        } else {
            NSLog(@"NO");
        }
    }
    NSLog(@"sLang: %@", self.box.sourceLang);
    NSLog(@"tLang: %@", self.box.targetLang);
    reqster.body = [self getJSONSignUpWithSource:self.box.sourceLang target:self.box.targetLang err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.isUserTriggered = YES;
    [reqster setupAndLoadToQueue:self.box.comWorker withDna:NO];
}

- (void)goToSignIn
{
    [self showForgotPassword];
    [self showSignInButton];
    [self showSwitchToSignUp];
}

#pragma mark - show forgotPassword

- (void)showForgotPasswordButton
{
    if (self.passwordInput) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.passwordInput.alpha = 0.0f;
        }];
    }
    if (self.signInButton) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.signInButton.alpha = 0.0f;
        }];
    }
    if (self.forgotPassword) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.forgotPassword.alpha = 0.0f;
        }];
    }
    if (self.switchToSignUp) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.switchToSignUp.alpha = 0.0f;
        }];
    }
    if (self.nextButton) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.nextButton.alpha = 0.0f;
        }];
    }
    if (!self.forgotPasswordButton) {
        self.forgotPasswordButton = [[UILabel alloc] initWithFrame:self.passwordInput.frame];
        [self.coverOnBaseView addSubview:self.forgotPasswordButton];
        self.forgotPasswordButton.backgroundColor = [UIColor greenColor];
        self.forgotPasswordButton.userInteractionEnabled = YES;
        self.forgotPasswordButton.text = @"Send Email To Reset Password";
        self.forgotPasswordButton.textAlignment = NSTextAlignmentCenter;
        self.forgotPasswordButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailToResettingPassword)];
        [self.forgotPasswordButton addGestureRecognizer:self.forgotPasswordButtonTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.forgotPasswordButton];
    if (self.forgotPasswordButton.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.forgotPasswordButton.alpha = 1.0f;
        }];
    }
    
    if (!self.backToSignIn) {
        self.backToSignIn = [[UILabel alloc] initWithFrame:self.forgotPassword.frame];
        [self.coverOnBaseView addSubview:self.backToSignIn];
        self.backToSignIn.font = [self.forgotPassword.font fontWithSize:self.emailInput.font.pointSize * 0.8f];
        self.backToSignIn.userInteractionEnabled = YES;
        self.backToSignIn.text = @"Return To Sign In";
        self.backToSignIn.textAlignment = NSTextAlignmentCenter;
        self.backToSignInTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnFromPasswordResetting)];
        [self.backToSignIn addGestureRecognizer:self.backToSignInTap];
    }
    [self.coverOnBaseView bringSubviewToFront:self.backToSignIn];
    if (self.backToSignIn.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.backToSignIn.alpha = 1.0f;
        }];
    }

}

- (void)returnFromPasswordResetting
{
    if (self.forgotPasswordButton) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.forgotPasswordButton.alpha = 0.0f;
        }];
    }
    if (self.backToSignIn) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.backToSignIn.alpha = 0.0f;
        }];
    }
    [self.coverOnBaseView bringSubviewToFront:self.passwordInput];
    if (self.passwordInput.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.passwordInput.alpha = 1.0f;
        }];
    }
    [self.signInButton bringSubviewToFront:self.signInButton];
    if (self.signInButton.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.signInButton.alpha = 1.0f;
        }];
    }
    [self.forgotPassword bringSubviewToFront:self.forgotPassword];
    if (self.forgotPassword.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.forgotPassword.alpha = 1.0f;
        }];
    }
    [self.coverOnBaseView bringSubviewToFront:self.switchToSignUp];
    if (self.switchToSignUp.alpha == 0.0f) {
        [UIView animateWithDuration:self.animationSec animations:^{
            self.switchToSignUp.alpha = 1.0f;
        }];
    }
}

- (void)emailToResettingPassword
{
    TVRequester *reqster = [[TVRequester alloc] init];
    reqster.box = self.box;
    reqster.requestType = TVEmailForPasswordResetting;
    reqster.email = self.emailInput.text;
    reqster.body = [self getJSONForgotPasswordWithEmail:reqster.email err:nil];
    
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    [reqster setupAndLoadToQueue:self.box.comWorker withDna:NO];
}

#pragma mark - keyboard

- (void)listenToKeyboardEvent
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToTop) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveBack) name:UIKeyboardWillHideNotification object:nil];
}

- (void)moveToTop
{
    self.coverOnBaseView.touchToDismissKeyboardIsOn = YES;
    [self.baseView setContentOffset:CGPointMake(0.0f, self.emailInput.frame.origin.y - self.gapHeight * 2.0f) animated:YES];
}

- (void)moveBack
{
    self.coverOnBaseView.touchToDismissKeyboardIsOn = NO;
    [self.baseView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - textField

- (BOOL)validateTextField
{
    // Validate email
    if (self.emailInput.text.length == 0) {
        [self.box.warning setString:@"Email should not be empty."];
        [[NSNotificationCenter defaultCenter] postNotificationName:tvShowWarning object:self];
        return NO;
    }
    // Validate password
    if (self.passwordInput.alpha == 1.0f) {
        if (self.passwordInput.text.length == 0) {
            [self.box.warning setString:@"Password should not be empty."];
            [[NSNotificationCenter defaultCenter] postNotificationName:tvShowWarning object:self];
            return NO;
        } else if (self.passwordInput.text.length < 6 || self.passwordInput.text.length > 20) {
            // Password's length has to be no less than 6 and no more than 20.
            [self.box.warning setString:@"Password's length has to be between 6 and 20."];
            [[NSNotificationCenter defaultCenter] postNotificationName:tvShowWarning object:self];
            return NO;
        }
    }
    return YES;
}



//- (void)dismissKeyboard
//{
//    [self.view endEditing:YES];
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.passwordInput]) {
        NSString *URLToGo;
        
//        [self startRegistrationLoginWithEmail:self.emailInput.text password:self.passwordInput.text withURLString:URLToGo];
    } else {
        self.passwordInput.text = @"";
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

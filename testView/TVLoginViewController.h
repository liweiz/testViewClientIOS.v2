//
//  TVLoginViewController.h
//  testView
//
//  Created by Liwei Zhang on 2013-10-19.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"
#import "TVKeyboard.h"
#import "TVView.h"
#import "TVLayerBaseViewController.h"
#import "TVRootViewCtlBox.h"

@interface TVLoginViewController : TVLayerBaseViewController <UITextFieldDelegate, UITextInputTraits>

@property (nonatomic, assign) CGFloat animationSec;
@property (nonatomic, assign) CGFloat introHeight;
@property (nonatomic, assign) CGFloat gapHeight;
@property (nonatomic, assign) CGFloat smallFontSize;
@property (nonatomic, assign) CGFloat verticalPadding;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat inputX;
@property (nonatomic, assign) CGFloat inputWidth;
@property (nonatomic, assign) CGFloat inputHeight;

@property (strong, nonatomic) TVKeyboard *keyboard;
@property (strong, nonatomic) UIScrollView *baseView;

@property (strong, nonatomic) TVView *coverOnBaseView;

@property (strong, nonatomic) UITextField *emailInput;
@property (strong, nonatomic) UITextField *passwordInput;

@property (strong, nonatomic) UILabel *forgotPasswordButton;
@property (strong, nonatomic) UITapGestureRecognizer *forgotPasswordButtonTap;

@property (strong, nonatomic) UILabel *signUpButton;
@property (strong, nonatomic) UITapGestureRecognizer *signUpButtonTap;

@property (strong, nonatomic) UILabel *nextButton;
@property (strong, nonatomic) UITapGestureRecognizer *nextButtonTap;

@property (strong, nonatomic) UILabel *signInButton;
@property (strong, nonatomic) UITapGestureRecognizer *signInButtonTap;

@property (strong, nonatomic) UILabel *switchToSignIn;
@property (strong, nonatomic) UITapGestureRecognizer *switchToSignInTap;

@property (strong, nonatomic) UILabel *switchToSignUp;
@property (strong, nonatomic) UITapGestureRecognizer *switchToSignUpTap;

@property (strong, nonatomic) UIView *termsBox;
@property (strong, nonatomic) UILabel *agreeToTermsTextBox;

@property (strong, nonatomic) UILabel *agreeToPrivacyTextBox;
@property (strong, nonatomic) UILabel *introTextBox;

@property (strong, nonatomic) UILabel *forgotPassword;
@property (strong, nonatomic) UITapGestureRecognizer *forgotPasswordTap;

@property (strong, nonatomic) UILabel *backToSignIn;
@property (strong, nonatomic) UITapGestureRecognizer *backToSignInTap;

@property (strong, nonatomic) UILabel *terms;
@property (strong, nonatomic) UITapGestureRecognizer *termsTap;

@property (strong, nonatomic) KeychainItemWrapper *passItem;
@property (strong, nonatomic) TVRootViewCtlBox *box;

@end

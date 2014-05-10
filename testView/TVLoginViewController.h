//
//  TVLoginViewController.h
//  testView
//
//  Created by Liwei Zhang on 2013-10-19.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@interface TVLoginViewController : UIViewController <UITextFieldDelegate, UITextInputTraits>

@property (nonatomic, assign) CGRect appRect;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIScrollView *baseView;
@property (strong, nonatomic) UITextField *emailInput;
@property (strong, nonatomic) UITextField *passwordInput;

@property (strong, nonatomic) UILabel *signUpButton;
@property (strong, nonatomic) UITapGestureRecognizer *signUpButtonTap;

@property (strong, nonatomic) UILabel *loginButton;
@property (strong, nonatomic) UITapGestureRecognizer *loginButtonTap;

@property (strong, nonatomic) UIView *termsBox;
@property (strong, nonatomic) UILabel *agreeToTermsTextBox;
@property (strong, nonatomic) UILabel *agreeToPrivacyTextBox;
@property (strong, nonatomic) UILabel *allContentIsOpenTextBox;

@property (strong, nonatomic) UILabel *forgotPassword;
@property (strong, nonatomic) UITapGestureRecognizer *forgotPasswordTap;
@property (assign, nonatomic) BOOL isSigningUP;

@property (strong, nonatomic) UITapGestureRecognizer *tapDetector;

@property (strong, nonatomic) KeychainItemWrapper *passItem;

@end

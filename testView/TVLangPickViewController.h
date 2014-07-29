//
//  TVLangPickViewController.h
//  testView
//
//  Created by Liwei on 10/23/2013.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVLangPickTableViewController.h"
#import "TVLayerBaseViewController.h"


@interface TVLangPickViewController : TVLayerBaseViewController <UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) TVLangPickTableViewController *langPickController;
@property (strong, nonatomic) UITextField *lang;
@property (strong, nonatomic) UILabel *button;
@property (strong, nonatomic) UITapGestureRecognizer *buttonTap;
@property (assign, nonatomic) BOOL tableIsForSourceLang;
@property (assign, nonatomic) CGFloat originY;

@property (strong, nonatomic) UILabel *warning;

@end

//
//  TVLangPickViewController.h
//  testView
//
//  Created by Liwei on 10/23/2013.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVLangPickTableViewController.h"
#import "TVUser.h"

@interface TVLangPickViewController : UIViewController <UITableViewDelegate>

@property (strong, nonatomic) TVLangPickTableViewController *langPickController;

@property (strong, nonatomic) UILabel *sourceLangViewIntro;
@property (strong, nonatomic) UILabel *targetLangViewIntro;
@property (strong, nonatomic) UILabel *sourceLangView;
@property (strong, nonatomic) UILabel *targetLangView;
@property (strong, nonatomic) UITapGestureRecognizer *sourceLangTap;
@property (strong, nonatomic) UITapGestureRecognizer *targetLangTap;
@property (assign, nonatomic) BOOL tableIsForSourceLang;
@property (assign, nonatomic) CGFloat originY;
@property (strong, nonatomic) TVUser *user;

@end

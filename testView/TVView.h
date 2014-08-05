//
//  TVView.h
//  testView
//
//  Created by Liwei on 2013-09-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVView : UIView

@property (assign, nonatomic) BOOL touchToDismissKeyboardIsOn;
@property (assign, nonatomic) BOOL touchToDismissViewIsOn;
@property (weak, nonatomic) UIViewController *ctlInCharge;

@end

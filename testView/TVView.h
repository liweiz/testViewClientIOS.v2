//
//  TVView.h
//  testView
//
//  Created by Liwei on 2013-09-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVView : UIView

@property (assign, nonatomic) BOOL keyboardIsShown;
@property (assign, nonatomic) BOOL keyboardIsForBottomInput;
@property (assign, nonatomic) BOOL touchToDismissKeyboardIsOff;
@property (assign, nonatomic) CGFloat keyboardAndExtraHeight;
@property (assign, nonatomic) CGFloat viewOffsetY;

@end

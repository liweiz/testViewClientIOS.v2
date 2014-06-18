//
//  TVKeyboard.h
//  testView
//
//  Created by Liwei Zhang on 2014-06-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVKeyboard : NSObject

// This is the view that has its bottom folating above the keyboard. This view's position may change when user switch input language, e.g., switch between English and Chinese input, in which Chinese input comes with a bar above the keyboard to show the characters to select while English input does not.
@property (strong, nonatomic) UIView *viewWithButtomFloating;

@property (strong, nonatomic) UIView *viewToDismissKeyboard;

@property (assign, nonatomic) CGFloat keyboardAndExtraHeight;
@property (assign, nonatomic) BOOL keyboardIsForBottomInput;
@property (assign, nonatomic) BOOL keyboardIsShown;
@property (assign, nonatomic) BOOL touchToDismissKeyboardIsOff;

@property (strong, nonatomic) UIScrollView *keyboardSlot;
// tempSize is the size of the view calls keyboard
@property (assign, nonatomic) CGSize tempSize;
@property (nonatomic, assign) id<UIScrollViewDelegate> delegate;

@end

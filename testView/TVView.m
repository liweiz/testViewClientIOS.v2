//
//  TVView.m
//  testView
//
//  Created by Liwei on 2013-09-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVView.h"

@implementation TVView

@synthesize keyboardIsShown, keyboardIsForBottomInput, keyboardAndExtraHeight, touchToDismissKeyboardIsOff;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.keyboardIsShown == YES && self.keyboardIsForBottomInput == YES && self.touchToDismissKeyboardIsOff == NO) {
        if (point.y < self.frame.size.height - self.keyboardAndExtraHeight) {
            [self endEditing:YES];
        }
    }
    return [super hitTest:point withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

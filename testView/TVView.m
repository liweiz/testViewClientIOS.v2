//
//  TVView.m
//  testView
//
//  Created by Liwei on 2013-09-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVView.h"

@implementation TVView

@synthesize keyboardIsShown;
@synthesize touchToDismissKeyboardIsOff;
@synthesize keyboardIsForBottomInput;
@synthesize keyboardAndExtraHeight;
// When the view is larger than the height of its parent view, e.g., used with uiscrollview, need to take offset into account as well.
@synthesize viewOffsetY;

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
        if (point.y < self.frame.size.height - self.keyboardAndExtraHeight && point.y > self.viewOffsetY) {
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

//
//  TVView.m
//  testView
//
//  Created by Liwei on 2013-09-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVView.h"

@implementation TVView

@synthesize touchToDismissKeyboardIsOn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Add all those views that are touched to dismiss keyboard to this view.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *x = [super hitTest:point withEvent:event];
    if (self.touchToDismissKeyboardIsOn == YES) {
        if (![x isKindOfClass:[UITextField class]]) {
            [self endEditing:YES];
        }
    }
    return x;
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

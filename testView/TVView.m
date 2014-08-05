//
//  TVView.m
//  testView
//
//  Created by Liwei on 2013-09-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVView.h"
#import "TVAppRootViewController.h"

@implementation TVView

@synthesize touchToDismissKeyboardIsOn;
@synthesize touchToDismissViewIsOn;
@synthesize ctlInCharge;

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
//    Attention: hitTest is called even view is hidden
    if (self.hidden == NO) {
        if (self.touchToDismissKeyboardIsOn == YES) {
            if (![x isKindOfClass:[UITextField class]]) {
                [self endEditing:YES];
            }
        } else if (self.touchToDismissViewIsOn == YES) {
            if (!([x isKindOfClass:[UILabel class]] && x.userInteractionEnabled == YES)) {
                // Dismiss view
                [[NSNotificationCenter defaultCenter] postNotificationName:tvDismissSaveViewOnly object:self];
            }
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

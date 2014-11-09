//
//  TVNonBlockIndicator.m
//  testView
//
//  Created by Liwei Zhang on 2014-09-21.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVNonBlockIndicator.h"

@implementation TVNonBlockIndicator

static CGFloat const aniDuration = 1;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        _isActive = YES;
//        self.alpha = 0.5f;
        if (!_goDark) {
            _goDark = [POPBasicAnimation easeInAnimation];
//            self.goDark = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            [_goDark setValue:@"goDark" forKey:@"animationName"];
            _goDark.delegate = self;
            _goDark.property = [POPAnimatableProperty propertyWithName:@"backgroundColor"];
            _goDark.fromValue = CFBridgingRelease([UIColor lightTextColor].CGColor);
            _goDark.toValue = CFBridgingRelease([UIColor greenColor].CGColor);
            _goDark.duration = aniDuration;
        }
        if (!_goLight) {
            _goLight = [POPBasicAnimation easeOutAnimation];
//            self.goLight = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            [_goLight setValue:@"goLight" forKey:@"animationName"];
            _goLight.property = [POPAnimatableProperty propertyWithName:@"backgroundColor"];
            _goLight.delegate = self;
            _goLight.fromValue = (id)[UIColor greenColor].CGColor;
            _goLight.toValue = (id)[UIColor lightTextColor].CGColor;
            _goLight.duration = aniDuration;
        }
    }
    return self;
}

- (void)startAni
{
    [self.superview bringSubviewToFront:self];
    self.isActive = YES;
    [self.layer pop_addAnimation:self.goDark forKey:@"goDark"];
}

- (void)stopAni
{
    self.isActive = NO;
    [self.layer removeAllAnimations];
}

- (void)pop_animationDidStart:(CAAnimation *)anim
{
    if (![self.superview.subviews.lastObject isEqual:self]) {
        [self.superview bringSubviewToFront:self];
    }
    NSLog(@"animationDidStart");
}

- (void)pop_animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (![self.superview.subviews.lastObject isEqual:self]) {
        [self.superview bringSubviewToFront:self];
    }
    if (flag) {
        if (self.isActive) {
            // Keep the animation on.
            if ([[anim valueForKey:@"animationName"] isEqualToString:@"goDark"]) {
                [self.layer pop_addAnimation:self.goLight forKey:nil];
            } else if ([[anim valueForKey:@"animationName"] isEqualToString:@"goLight"]) {
                [self.layer pop_addAnimation:self.goDark forKey:nil];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

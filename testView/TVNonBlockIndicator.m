//
//  TVNonBlockIndicator.m
//  testView
//
//  Created by Liwei Zhang on 2014-09-21.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVNonBlockIndicator.h"

@implementation TVNonBlockIndicator

@synthesize goDark, goLight;
@synthesize isActive;
@synthesize aniDuration;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        self.isActive = NO;
        self.aniDuration = 5.0;
//        self.alpha = 0.5f;
        if (!self.goDark) {
            self.goDark = [POPBasicAnimation easeInAnimation];
            self.goDark = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            [self.goDark setValue:@"goDark" forKey:@"animationName"];
            self.goDark.delegate = self;
            self.goDark.fromValue = (id)[UIColor lightTextColor].CGColor;
            self.goDark.toValue = (id)[UIColor greenColor].CGColor;
            self.goDark.duration = self.aniDuration;
        }
        if (!self.goLight) {
            self.goLight = [POPBasicAnimation easeOutAnimation];
            self.goLight = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            [self.goLight setValue:@"goLight" forKey:@"animationName"];
            self.goLight.delegate = self;
            self.goLight.fromValue = (id)[UIColor greenColor].CGColor;
            self.goLight.toValue = (id)[UIColor lightTextColor].CGColor;
            self.goLight.duration = self.aniDuration;
        }
    }
    return self;
}

- (void)startAni
{
    [self.superview bringSubviewToFront:self];
    self.isActive = YES;
    [self.layer addAnimation:self.goDark forKey:nil];
}

- (void)stopAni
{
    self.isActive = NO;
    [self.layer removeAllAnimations];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (![self.superview.subviews.lastObject isEqual:self]) {
        [self.superview bringSubviewToFront:self];
    }
    NSLog(@"animationDidStart");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (![self.superview.subviews.lastObject isEqual:self]) {
        [self.superview bringSubviewToFront:self];
    }
    if (flag) {
        if (self.isActive) {
            // Keep the animation on.
            if ([[anim valueForKey:@"animationName"] isEqualToString:@"goDark"]) {
                [self.layer addAnimation:self.goLight forKey:nil];
            } else if ([[anim valueForKey:@"animationName"] isEqualToString:@"goLight"]) {
                [self.layer addAnimation:self.goDark forKey:nil];
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

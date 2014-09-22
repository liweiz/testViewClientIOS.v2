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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightTextColor];
        self.alpha = 0.5f;
        if (self.goDark) {
            self.goDark = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            [self.goDark setValue:@"goDark" forKey:@"animationName"];
            self.goDark.delegate = self;
            self.goDark.fromValue = (id)[UIColor lightTextColor].CGColor;
            self.goDark.toValue = (id)[UIColor greenColor].CGColor;
            self.goDark.duration = 0.5f;
        }
        if (self.goLight) {
            self.goLight = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            [self.goLight setValue:@"goLight" forKey:@"animationName"];
            self.goLight.delegate = self;
            self.goLight.fromValue = (id)[UIColor greenColor].CGColor;
            self.goLight.toValue = (id)[UIColor lightTextColor].CGColor;
            self.goLight.duration = 0.5f;
        }
    }
    return self;
}

- (void)startAni
{
    [self.layer addAnimation:self.goDark forKey:nil];
}

- (void)stopAni
{
    [self.layer removeAllAnimations];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *name = [anim valueForKey:@"animationName"];
        if ([name isEqualToString:@"goDark"]) {
            [self.layer addAnimation:self.goLight forKey:nil];
        } else if ([name isEqualToString:@"goLight"]) {
            [self.layer addAnimation:self.goDark forKey:nil];
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

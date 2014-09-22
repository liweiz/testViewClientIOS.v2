//
//  TVIndicator.m
//  testView
//
//  Created by Liwei Zhang on 2014-06-21.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVBlockIndicator.h"

@implementation TVBlockIndicator

@synthesize indicator;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!self.indicator) {
            self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.indicator.frame = CGRectMake((self.frame.size.width - self.indicator.frame.size.width) * 0.5f, (self.frame.size.height - self.indicator.frame.size.height) * 0.5f, self.indicator.frame.size.width, self.indicator.frame.size.height);
            [self addSubview:self.indicator];
            self.backgroundColor = [UIColor lightGrayColor];
            self.alpha = 0.2f;
        }
    }
    return self;
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

//
//  TVSortCellView.m
//  testView
//
//  Created by Liwei Zhang on 2013-09-27.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVSortCellView.h"

@implementation TVSortCellView

@synthesize textView, rankView, switchView, tap, isSelected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isSelected = NO;
        if (!self.rankView) {
            self.rankView = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 44.0, 44.0)];
            [self addSubview:self.rankView];
        }
        if (!self.textView) {
            self.textView = [[UILabel alloc] initWithFrame:CGRectMake(10.0 + 44.0 + 10.0, 10.0, 150.0, 44.0)];
            [self addSubview:self.textView];
        }
        if (!self.switchView) {
            self.switchView = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 10.0 - 50.0, 10.0, 50.0, 44.0)];
            self.switchView.on = NO;
            [self addSubview:self.switchView];
        }
        if (!self.tap) {
            self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectionAction)];
            [self addGestureRecognizer:self.tap];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self hightlighted];
}

- (void)selectionAction
{
    if (self.isSelected == NO) {
        self.isSelected = YES;
    } else {
        self.isSelected = NO;
    }
    [self hightlighted];
}

- (void)hightlighted
{
    if (self.isSelected == YES) {
        self.backgroundColor = [UIColor greenColor];
    } else {
        self.backgroundColor = [UIColor lightGrayColor];
    }
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

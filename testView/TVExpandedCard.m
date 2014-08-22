//
//  TVExpandedCard.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-20.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVExpandedCard.h"

@implementation TVExpandedCard

@synthesize target;
@synthesize translation;
@synthesize detail;
@synthesize context;
@synthesize serverId;
@synthesize localId;
@synthesize versionNo;
@synthesize lastModifiedAtLocal;
@synthesize rowNo;
@synthesize blanks;
@synthesize baseView;
@synthesize labelTranslation;
@synthesize labelDetail;
@synthesize labelContext;
@synthesize originY;
@synthesize width;
@synthesize height;
@synthesize gap;
@synthesize numberOfRowsNeeded;

- (id)init
{
    self = [super init];
    if (self) {
        self.gap = 15.0f;
    }
    return self;
}

- (void)setup
{
    CGRect oRect = [self getOriginalRectOfFullCardView];
    self.numberOfRowsNeeded = [self getRowNoOfFullCardView:oRect.size.height];
    CGRect fRect = [self getFinalRectOfFullCardView:self.numberOfRowsNeeded];
    if (!self.baseView) {
        self.baseView = [[UIScrollView alloc] initWithFrame:fRect];
        self.baseView.contentSize = CGSizeMake(self.baseView.frame.size.width, self.baseView.frame.size.height * 2.0f);
        UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.baseView.frame.size.width, self.baseView.frame.size.height)];
        self.baseView.scrollEnabled = NO;
        
        [contentView addSubview:self.labelTranslation];
        [contentView addSubview:self.labelDetail];
        [contentView addSubview:self.labelContext];
        [self.baseView addSubview:contentView];
        contentView.backgroundColor = [UIColor grayColor];
        [self.baseView setContentOffset:CGPointMake(0.0f, self.baseView.frame.size.height) animated:NO];
        self.baseView.backgroundColor = [UIColor clearColor];
        
        [self.baseView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    } else {
        self.baseView.frame = fRect;
        [self.baseView setNeedsLayout];
    }
    // Adjust number of blanks to match the number needed
    if ([self.blanks count] > self.numberOfRowsNeeded) {
        for (NSInteger n = 1; [self.blanks count] - self.numberOfRowsNeeded; n++) {
            [self.blanks removeObject:[self.blanks lastObject]];
        }
    } else if ([self.blanks count] < self.numberOfRowsNeeded) {
        for (NSInteger n = 1; self.numberOfRowsNeeded - [self.blanks count]; n++) {
            NSDictionary *newBlank = [[NSDictionary alloc] init];
            [self.blanks addObject:newBlank];
        }
    }
}

#pragma mark - Card rect calculation

// Calculate all three labels, origin of each label is not important, let's just use (0.0, 0.0) here since what we need is only the heights.

- (CGFloat)labelContextHeight
{
    CGFloat contextHeight = 0.0f;
    self.labelContext = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width, 1000.0f)];
    self.labelContext.text = self.context;
    [self.labelContext sizeToFit];
    contextHeight = self.labelContext.frame.size.height;
    return contextHeight;
}

- (CGFloat)labelDetailHeight
{
    CGFloat detailHeight = 0.0f;
    self.labelDetail = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width, 1000.0f)];
    self.labelDetail.text = self.detail;
    [self.labelDetail sizeToFit];
    detailHeight = self.labelDetail.frame.size.height;
    return detailHeight;
}

- (CGFloat)labelTranslationHeight
{
    CGFloat translationHeight = 0.0f;
    self.labelTranslation = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width, 1000.0f)];
    self.labelTranslation.text = self.translation;
    [self.labelTranslation sizeToFit];
    translationHeight = self.labelTranslation.frame.size.height;
    return translationHeight;
}

- (CGRect)getFinalRectOfFullCardView:(NSInteger)noOfRowsNeeded
{
    return CGRectMake(0.0f, self.originY, self.width, self.cellHeight * noOfRowsNeeded);
}

- (NSInteger)getRowNoOfFullCardView:(CGFloat)originalHeight
{
    return ceil(originalHeight / self.cellHeight);
}

- (CGFloat)getHeightOfFullCardView:(CGFloat)originalHeight
{
    return ceil(originalHeight / self.cellHeight) * self.cellHeight;
}

- (CGRect)getOriginalRectOfFullCardView
{
    // LabelPoint is the origin of the cellLabel + its height in tableView's context, not the cell
    // From top to bottom: translation, detail, context
    CGFloat contextHeight = [self labelContextHeight];
    CGFloat detailHeight = [self labelDetailHeight];
    CGFloat translationHeight = [self labelTranslationHeight];
    // self.cellRect is assigned once a cell is selected.
    
    // Height of the scrollView's frame
    CGFloat myHeight = contextHeight + detailHeight + translationHeight + self.gap * 5;
    return CGRectMake(0.0f, self.originY, self.width, myHeight);
}

@end

//
//  TVTableViewCell0.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-07.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVTableViewCell0.h"

@implementation TVTableViewCell0

@synthesize selectionRect;
@synthesize selectionViewBase;
@synthesize selectionViewFull;
@synthesize selectionViewNone;
@synthesize selectionTap;
@synthesize deleteTap;
@synthesize currentIndexPath;
@synthesize deleteView;
@synthesize cellLabel;
@synthesize delay;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // In editing mode, contentView's x is 38.0, while in normal mode, it is 0.0. This can be calculated with NSLogging contentView and backgroundView. contentView's width changes to 282.0 as well, while backgroundView's width does not change.
    if (self.textLabel.hidden == NO) {
        self.textLabel.hidden = YES;
    }
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    }
    // BaseScrollView's origin.x is the same as self.separatorInset.left, since originally self.separatorInset.left equals to textLabel's origin.x
    
    if (!self.baseScrollView) {
        // self.textLabel's default origin.x is 15.0
        self.baseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15.0f, 0.0f, self.frame.size.width - 15.0f, self.contentView.frame.size.height)];
        self.baseScrollView.contentSize = CGSizeMake(self.baseScrollView.frame.size.width + self.baseScrollView.frame.size.height, self.baseScrollView.frame.size.height);
        self.baseScrollView.backgroundColor = [UIColor greenColor];
        self.baseScrollView.bounces = NO;
        self.baseScrollView.showsHorizontalScrollIndicator = NO;
        self.baseScrollView.showsVerticalScrollIndicator = NO;
        [self.contentView addSubview:self.baseScrollView];
    }
    CGFloat cellLabelWidth;
    if (self.editing == YES) {
        cellLabelWidth = self.frame.size.width - 15.0f * 2.0f - self.contentView.frame.origin.x;
    } else {
        cellLabelWidth = self.frame.size.width - 15.0f * 2.0f;
    }
    if (!self.cellLabel) {
        self.cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cellLabelWidth, self.contentView.frame.size.height)];
        self.cellLabel.backgroundColor = [UIColor whiteColor];
        [self.baseScrollView addSubview:self.cellLabel];
    }
    if (self.cellLabel.frame.size.width != cellLabelWidth) {
        self.cellLabel.frame = CGRectMake(0.0f, 0.0f, cellLabelWidth, self.contentView.frame.size.height);
    }
    if (!self.deleteView) {
        self.deleteView = [[UIView alloc] initWithFrame:CGRectMake(self.backgroundView.frame.size.width - self.contentView.frame.origin.x - 15.0f, 0.0f, self.baseScrollView.frame.size.height, self.baseScrollView.frame.size.height)];
        self.deleteView.backgroundColor = [UIColor redColor];
        if (!self.deleteTap) {
            self.deleteTap = [[UITapGestureRecognizer alloc] init];
            [self.deleteView addGestureRecognizer:self.deleteTap];
        }
    }
    // Remove deleteView while in normal mode
    if ([[self.deleteView superview] isEqual:self.baseScrollView]) {
        [self.deleteView removeFromSuperview];
    }
    
    if (self.editing == YES) {
        // Hide the default system control on background
        // Delay the process for a little bit
        if (self.delay) {
            self.delay = nil;
        }
        self.delay = [NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(addDeleteView) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.delay forMode:NSDefaultRunLoopMode];
    } else {
        self.baseScrollView.scrollEnabled = NO;
    }
    
    
    if (!self.selectionTap) {
        self.selectionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(multiselectionAction)];
        [self.contentView addGestureRecognizer:self.selectionTap];
    }
    
    [self.baseScrollView setContentOffset:CGPointZero animated:NO];
    self.contentView.backgroundColor = [UIColor yellowColor];
    self.textLabel.backgroundColor = [UIColor orangeColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Not able to access the system's default editControllView, so just make the backgroundView and contentView on top of it to hide it, otherwise, there is always a circle shown on left.
    [self bringSubviewToFront:self.backgroundView];
    [self bringSubviewToFront:self.contentView];
}

- (void)addDeleteView
{
    [self.baseScrollView addSubview:self.deleteView];
    self.baseScrollView.scrollEnabled = YES;
}

- (void)cancelDelay
{
    [self.delay invalidate];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    // This will not be called when - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath returns NO.
    [super willTransitionToState:state];
    if (state == UITableViewCellStateShowingEditControlMask) {
        
        self.selectionRect = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
        if (!self.backgroundView) {
            self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        }
        if (!self.selectionViewBase) {
            self.selectionViewBase = [[UIView alloc] initWithFrame:self.selectionRect];
            self.selectionViewBase.backgroundColor = [UIColor purpleColor];
        }
        [self.backgroundView addSubview:self.selectionViewBase];
        if (!self.selectionViewFull) {
            self.selectionViewFull = [[UIView alloc] initWithFrame:self.selectionRect];
            self.selectionViewFull.backgroundColor = [UIColor greenColor];
        }
        if (!self.selectionViewNone) {
            self.selectionViewNone = [[UIView alloc] initWithFrame:self.selectionRect];
            self.selectionViewNone.backgroundColor = [UIColor redColor];
        }
        [self updateEditView];
    }
    if (state == UITableViewCellStateDefaultMask) {
        [self cancelDelay];
        [self layoutIfNeeded];
    }
}

- (void)updateEditView
{
    if (self.selected == YES) {
        if ([self.selectionViewFull.superview isEqual:self.selectionViewBase]) {
            [self.selectionViewBase bringSubviewToFront:self.selectionViewFull];
        } else {
            [self.selectionViewBase addSubview:self.selectionViewFull];
        }
    } else {
        if ([self.selectionViewNone.superview isEqual:self.selectionViewBase]) {
            [self.selectionViewBase bringSubviewToFront:self.selectionViewNone];
        } else {
            [self.selectionViewBase addSubview:self.selectionViewNone];
        }
    }
}

// Used only in editing mode
- (void)multiselectionAction
{
    if (self.editing == YES) {
        // Update the editView accordingly
        [self updateEditView];
    }
}

@end

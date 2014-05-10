//
//  TVTableViewCell.m
//  testView
//
//  Created by Liwei on 2013-08-16.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVTableViewCell.h"

@implementation TVTableViewCell

@synthesize selectionViewFull, selectionViewNone, selectionViewPart, selectionRect, statusCode, partlySelectedIsOn, currentIndexPath, statusCodeOrigin, baseScrollView, deleteView, deleteTap, selectionViewBase, selectionTapMini, delay, selectionLongPressTap, selectionLongPressTapMini, cellLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

// tableViewCell has three statuses: 0: unselected, 1: fully selected, 2: partly selected

- (void)loadView
{
    
}

- (void)viewDidLoad
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // In editing mode, contentView's x is 38.0, while in normal mode, it is 0.0. This can be calculated with NSLogging contentView and backgroundView. contentView's width changes to 282.0 as well, while backgroundView's width does not change.
    if (self.textLabel.hidden == NO) {
        self.textLabel.hidden = YES;
    }
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    }
    // BaseScrollView's origin.x is the same as self.separatorInset.left, since originally self.separatorInset.left equals to textLabel's origin.x
//    NSLog(@"self.separatorInset.left: %f", self.separatorInset.left);
//    NSLog(@"self.textLabel.frame.origin.x: %f", self.textLabel.frame.origin.x);

    if (!self.baseScrollView) {
        // self.textLabel's default origin.x is 15.0
        self.baseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15.0, 0.0, 320.0 - 15.0, self.contentView.frame.size.height)];
        self.baseScrollView.contentSize = CGSizeMake(self.baseScrollView.frame.size.width + self.baseScrollView.frame.size.height, self.baseScrollView.frame.size.height);
        self.baseScrollView.backgroundColor = [UIColor greenColor];
        self.baseScrollView.bounces = NO;
        self.baseScrollView.showsHorizontalScrollIndicator = NO;
        self.baseScrollView.showsVerticalScrollIndicator = NO;
        [self.contentView addSubview:baseScrollView];
    }
    CGFloat cellLabelWidth;
    if (self.editing == YES) {
        cellLabelWidth = 320.0 - 15.0 * 2 - 38.0;
    } else {
        cellLabelWidth = 320.0 - 15.0 * 2;
    }
    if (!self.cellLabel) {
        self.cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cellLabelWidth, self.contentView.frame.size.height)];
        self.cellLabel.backgroundColor = [UIColor whiteColor];
        [self.baseScrollView addSubview:self.cellLabel];
    }
    if (self.cellLabel.frame.size.width != cellLabelWidth) {
        self.cellLabel.frame = CGRectMake(0.0, 0.0, cellLabelWidth, self.contentView.frame.size.height);
    }
    NSLog(@"self.cellLabel.frame.size.width: %f", self.cellLabel.frame.size.width);
    if (!self.deleteView) {
        
        self.deleteView = [[UIView alloc] initWithFrame:CGRectMake(self.backgroundView.frame.size.width - 38.0 - 15.0, 0.0, self.baseScrollView.frame.size.height, self.baseScrollView.frame.size.height)];
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
    if (!self.selectionTapMini) {
        self.selectionTapMini = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(multiselectionAction)];
    }
    if (!self.selectionLongPressTap) {
        self.selectionLongPressTap = [[UILongPressGestureRecognizer alloc] init];
        [self.contentView addGestureRecognizer:self.selectionLongPressTap];
    }
    if (!self.selectionLongPressTapMini) {
        self.selectionLongPressTapMini = [[UILongPressGestureRecognizer alloc] init];
    }
    [self.baseScrollView setContentOffset:CGPointZero animated:NO];
    self.contentView.backgroundColor = [UIColor yellowColor];
    self.textLabel.backgroundColor = [UIColor orangeColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    NSLog(@"self.contentView.frame.size.width: %f", self.contentView.frame.size.width);
//    NSLog(@"self.baseScrollView.frame.size.width: %f", self.baseScrollView.frame.size.width);
//    NSLog(@"self.baseScrollView.contentSize.width: %f", self.baseScrollView.contentSize.width);
//    NSLog(@"self.backgroundView.frame.size.width: %f", self.backgroundView.frame.size.width);
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
        if (!self.selectionTapMini) {
            self.selectionTapMini = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(multiselectionAction)];
        }
        [self.selectionViewBase addGestureRecognizer:self.selectionTapMini];
        [self.backgroundView addSubview:self.selectionViewBase];
        if (!self.selectionViewFull) {
            self.selectionViewFull = [[UIView alloc] initWithFrame:self.selectionRect];
            self.selectionViewFull.backgroundColor = [UIColor greenColor];
        }
        if (!self.selectionViewNone) {
            self.selectionViewNone = [[UIView alloc] initWithFrame:self.selectionRect];
            self.selectionViewNone.backgroundColor = [UIColor redColor];
        }
        
        // No need to process partly selection if it is not needed.
        if (self.partlySelectedIsOn) {
            if (!self.selectionViewPart) {
                self.selectionViewPart = [[UIView alloc] initWithFrame:self.selectionRect];
                self.selectionViewPart.backgroundColor = [UIColor orangeColor];
            }
        }
        [self updateEditView];
    }
    if (state == UITableViewCellStateDefaultMask) {
//        if (self.selectionViewFull) {
//            [self.selectionViewFull removeFromSuperview];
//            self.selectionViewFull = nil;
//        }
//        if (self.selectionViewNone) {
//            [self.selectionViewNone removeFromSuperview];
//            self.selectionViewNone = nil;
//        }
//        if (self.selectionViewPart) {
//            [self.selectionViewPart removeFromSuperview];
//            self.selectionViewPart = nil;
//        }
//        if (self.selectionTap) {
//            [self removeGestureRecognizer:self.selectionTap];
//            self.selectionTap = nil;
//        }
//        if (self.deleteView) {
//            [self.deleteView removeFromSuperview];
//            if (self.deleteTap) {
//                [self.deleteView removeGestureRecognizer:self.deleteTap];
//                self.deleteTap = nil;
//            }
//            self.deleteView = nil;
//        }
        [self cancelDelay];
        [self layoutIfNeeded];
    }
}

- (void)updateEditView
{
    switch (self.statusCode) {
        case 0:
            if ([self.selectionViewNone.superview isEqual:selectionViewBase]) {
                [self.selectionViewBase bringSubviewToFront:self.selectionViewNone];
            } else {
                [self.selectionViewBase addSubview:self.selectionViewNone];
            }
            break;
        case 1:
            if ([self.selectionViewFull.superview isEqual:selectionViewBase]) {
                [self.selectionViewBase bringSubviewToFront:self.selectionViewFull];
            } else {
                [self.selectionViewBase addSubview:self.selectionViewFull];
            }
            break;
        case 2:
            if ([self.selectionViewPart.superview isEqual:selectionViewBase]) {
                [self.selectionViewBase bringSubviewToFront:self.selectionViewPart];
            } else {
                [self.selectionViewBase addSubview:self.selectionViewPart];
            }
            break;
    }
}

// Used only in editing mode
- (void)multiselectionAction
{
    if (self.editing == YES) {
        // Update the statusCode
        [self tapOutcome];
        // Update the editView accordingly
        [self updateEditView];
    }
}

- (void)tapOutcome
{
    if (self.partlySelectedIsOn == YES) {
        // Three statuses
        switch (self.statusCode) {
            case 0:
                self.statusCode = 2;
                break;
            case 1:
                self.statusCode = 0;
                break;
            case 2:
                self.statusCode = 1;
                break;
        }
    } else {
        // Two statuses
        switch (self.statusCode) {
            case 0:
                self.statusCode = 1;
                break;
            case 1:
                self.statusCode = 0;
                break;
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end

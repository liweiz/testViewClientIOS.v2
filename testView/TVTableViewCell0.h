//
//  TVTableViewCell0.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-07.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVTableViewCell0 : UITableViewCell

@property (assign, nonatomic) CGRect selectionRect;
@property (strong, nonatomic) UIView *selectionViewBase;
@property (strong, nonatomic) UIView *selectionViewNone;
@property (strong, nonatomic) UIView *selectionViewFull;
@property (strong, nonatomic) UITapGestureRecognizer *selectionTap;
@property (strong, nonatomic) UITapGestureRecognizer *deleteTap;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) UIScrollView *baseScrollView;
@property (strong, nonatomic) UIView *deleteView;
@property (strong, nonatomic) UILabel *cellLabel;

@property (strong, nonatomic) NSTimer *delay;


- (void)updateEditView;

@end

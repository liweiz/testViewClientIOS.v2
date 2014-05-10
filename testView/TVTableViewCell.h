//
//  TVTableViewCell.h
//  testView
//
//  Created by Liwei on 2013-08-16.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (assign, nonatomic) CGRect selectionRect;

@property (strong, nonatomic) UIView *selectionViewBase;
@property (strong, nonatomic) UIView *selectionViewNone;
@property (strong, nonatomic) UIView *selectionViewFull;
@property (strong, nonatomic) UIView *selectionViewPart;
@property (strong, nonatomic) UITapGestureRecognizer *selectionTap;
@property (strong, nonatomic) UITapGestureRecognizer *selectionTapMini;
@property (strong, nonatomic) UILongPressGestureRecognizer *selectionLongPressTap;
@property (strong, nonatomic) UILongPressGestureRecognizer *selectionLongPressTapMini;
@property (strong, nonatomic) UITapGestureRecognizer *deleteTap;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
// This has to be configured asap
@property (assign, nonatomic) NSInteger statusCode;
@property (assign, nonatomic) NSInteger statusCodeOrigin;
@property (assign, nonatomic) BOOL partlySelectedIsOn;
@property (strong, nonatomic) UIScrollView *baseScrollView;
@property (strong, nonatomic) UIView *deleteView;
@property (strong, nonatomic) NSTimer *delay;
@property (strong, nonatomic) UILabel *cellLabel;

- (void)updateEditView;


@end

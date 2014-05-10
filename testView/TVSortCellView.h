//
//  TVSortCellView.h
//  testView
//
//  Created by Liwei Zhang on 2013-09-27.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVSortCellView : UIView


@property (strong, nonatomic) UILabel *textView;
@property (strong, nonatomic) UILabel *rankView;
@property (strong, nonatomic) UISwitch *switchView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (assign, nonatomic) BOOL isSelected;

- (void)selectionAction;

@end

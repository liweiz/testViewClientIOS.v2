//
//  TVScrollViewVertical.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-29.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVScrollViewVertical : UIScrollView <UIScrollViewDelegate>

// These two positions are for direction identification
@property (assign, nonatomic) CGFloat startPositionY;
@property (assign, nonatomic) CGFloat targetPositionY;

@property (assign, nonatomic) CGFloat dragStartPointY;
// We treat any area between each two stop points that are next to each other as a section. And sections are numbered from top to bottom from 0 to N. maxSectionNo = N, 0 <= sectionNo <= N
// sectionNo is the only indicator to decide which section user wants to go. So The rest such as stops are only the trigger.
/*
 Two ways to change sectionNo:
 1. User scrolls: through scrollViewDelegate
 2. User selects another UI element in the other section (in our case, textField)
 */
@property (assign, nonatomic) NSInteger sectionNo;
// This stores each stop point from top to bottom. So stops[0] is the top point.
@property (strong, nonatomic) NSArray *stops;
// This stores each textField from top to bottom. So textFields[0] is the top one.
@property (strong, nonatomic) NSArray *textFields;

- (CGFloat)getUpperStop:(NSInteger)aSectionNo;

@end

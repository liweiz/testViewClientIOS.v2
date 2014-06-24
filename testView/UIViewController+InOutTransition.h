//
//  UIViewController+InOutTransition.h
//  testView
//
//  Created by Liwei Zhang on 2014-06-19.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (InOutTransition)

#pragma mark - present another view back and forth

- (void)showViewBelow:(UIView *)viewBelow viewBelowController:(UIViewController *)controllerBelow currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture longPressGesture:(UILongPressGestureRecognizer *)longPressGesture point:(CGPoint)p;
- (void)showViewAbove:(UIView *)viewAbove viewAboveController:(UIViewController *)controllerAbove currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture pinchGesture:(UIPinchGestureRecognizer *)pinchGesture point:(CGPoint)p;
- (void)comeThrough:(UIView *)view anchorPoint:(CGPoint)point;
- (void)comeUp:(UIView *)view anchorPoint:(CGPoint)point;
- (void)goThrough:(UIView *)view anchorPoint:(CGPoint)point;
- (void)goDown:(UIView *)view anchorPoint:(CGPoint)point;

@end

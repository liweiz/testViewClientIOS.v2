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

- (CGPoint)pointBy:(UIGestureRecognizer *)recognizer inView:(UIView *)view;
- (void)showViewBelow:(UIView *)viewBelow currentView:(UIView *)currentView baseView:(UIView *)base pointInBaseView:(CGPoint)p;
- (void)showViewAbove:(UIView *)viewAbove currentView:(UIView *)currentView baseView:(UIView *)base pointInBaseView:(CGPoint)p;
- (void)comeThrough:(UIView *)view anchorPoint:(CGPoint)point;
- (void)comeUp:(UIView *)view anchorPoint:(CGPoint)point;
- (void)goThrough:(UIView *)view anchorPoint:(CGPoint)point;
- (void)goDown:(UIView *)view anchorPoint:(CGPoint)point;

@end

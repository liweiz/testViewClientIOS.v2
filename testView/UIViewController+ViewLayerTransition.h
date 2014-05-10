//
//  UIViewController+ViewLayerTransition.h
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ViewLayerTransition)

#pragma mark - present another view back and forth

- (void)showNewView:(UIView *)newView newViewController:(UIViewController *)newController currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture longPressGesture:(UILongPressGestureRecognizer *)longPressGesture;
- (void)hideNewView:(UIView *)newView currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture pinchGesture:(UIPinchGestureRecognizer *)pinchGesture;
- (void)comeThrough:(UIView *)view anchorPoint:(CGPoint)point;
- (void)comeUp:(UIView *)view anchorPoint:(CGPoint)point;
- (void)goThrough:(UIView *)view anchorPoint:(CGPoint)point;
- (void)goDown:(UIView *)view anchorPoint:(CGPoint)point;

@end

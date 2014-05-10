//
//  UIViewController+ViewLayerTransition.m
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "UIViewController+ViewLayerTransition.h"

@implementation UIViewController (ViewLayerTransition)

#pragma mark - present another view back and forth

// Tap could be the gesture for visiting or exiting a visual layer
// LongPress is only for visiting the visual layer below
// For visiting a visual layer below
- (void)showNewView:(UIView *)newView newViewController:(UIViewController *)newController currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture longPressGesture:(UILongPressGestureRecognizer *)longPressGesture
{
    [currentView endEditing:YES];
    // If the view is inited with a viewController, please get the controller ready before executing this method
    if (tapGesture) {
        if (newController) {
            [self addChildViewController:newController];
        }
        CGPoint positionPoint = [tapGesture locationInView:base];
        CGPoint anchorPoint = CGPointMake(positionPoint.x / base.frame.size.width, positionPoint.y / base.frame.size.height);
        [self comeThrough:currentView anchorPoint:anchorPoint];
        [base insertSubview:newView belowSubview:currentView];
        [self comeUp:newView anchorPoint:anchorPoint];
        if (newController) {
            [newController didMoveToParentViewController:self];
        }
    }
    if (longPressGesture && longPressGesture.state == UIGestureRecognizerStateBegan) {
        if (newController) {
            [self addChildViewController:newController];
        }
        CGPoint positionPoint = [longPressGesture locationInView:base];
        //        NSLog(@"location in base x: %f", positionPoint.x);
        //        NSLog(@"location in base y: %f", positionPoint.y);
        CGPoint anchorPoint = CGPointMake(positionPoint.x / base.frame.size.width, positionPoint.y / base.frame.size.height);
        //        NSLog(@"anchor x: %f", anchorPoint.x);
        //        NSLog(@"anchor y: %f", anchorPoint.y);
        [self comeThrough:currentView anchorPoint:anchorPoint];
        [base insertSubview:newView belowSubview:currentView];
        [self comeUp:newView anchorPoint:anchorPoint];
        if (newController) {
            [newController didMoveToParentViewController:self];
        }
    }
}

// Keep the newController in hierarchy, so no newController argument here
// No longPress here, either. However, pinchGesture could be here for exiting the new visual layer
- (void)hideNewView:(UIView *)newView currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture pinchGesture:(UIPinchGestureRecognizer *)pinchGesture
{
    [newView endEditing:YES];
    if (tapGesture) {
        CGPoint positionPoint = [tapGesture locationInView:base];
        CGPoint anchorPoint = CGPointMake(positionPoint.x / base.frame.size.width, positionPoint.y / base.frame.size.height);
        [self goThrough:currentView anchorPoint:anchorPoint];
        [base insertSubview:newView belowSubview:currentView];
        [self goDown:newView anchorPoint:anchorPoint];
    }
    if (pinchGesture && (pinchGesture.state == UIGestureRecognizerStateBegan)) {
        if (pinchGesture.scale < 1.0) {
            // The last locations
            CGPoint lastLocation0 = [pinchGesture locationOfTouch:0 inView:base];
            CGPoint lastLocation1 = [pinchGesture locationOfTouch:1 inView:base];
            CGPoint middlePoint = CGPointMake((lastLocation0.x + lastLocation1.x) / 2, (lastLocation0.y + lastLocation1.y) / 2);
            CGPoint anchorPoint = CGPointMake(middlePoint.x / base.frame.size.width, middlePoint.y / base.frame.size.height);
            [self goThrough:currentView anchorPoint:anchorPoint];
            [base insertSubview:newView belowSubview:currentView];
            [self goDown:newView anchorPoint:anchorPoint];
        }
    }
}

- (void)comeThrough:(UIView *)view anchorPoint:(CGPoint)point
{
    CABasicAnimation *becomeTransparent = [CABasicAnimation animationWithKeyPath:@"opacity"];
    becomeTransparent.fromValue = [NSNumber numberWithFloat:1.0];
    becomeTransparent.toValue = [NSNumber numberWithFloat:0.0];
    becomeTransparent.duration = 0.5;
    
    CABasicAnimation *becomeLarge = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeLarge.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    becomeLarge.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];;
    becomeLarge.duration = 0.5;
    
    CAAnimationGroup *comeThrough = [CAAnimationGroup animation];
    comeThrough.animations = [NSArray arrayWithObjects:becomeLarge, becomeTransparent, nil];
    comeThrough.duration = 0.5;
    comeThrough.delegate = self;
    // Keep the animation before hidden is set to avoid flashing back after the completion of the animiation while hidden is not set.
    comeThrough.fillMode = kCAFillModeForwards;
    comeThrough.removedOnCompletion = NO;
    
    // Get the anchorPoint and positionPoint before animating
    CGPoint lastAnchorPoint = view.layer.anchorPoint;
    CGPoint lastPositionPoint = view.layer.position;
    // Reset the anchorPoint and positionPoint by user's touch
    view.layer.anchorPoint = point;
    view.layer.position = CGPointMake(view.bounds.size.width * (point.x - lastAnchorPoint.x) + lastPositionPoint.x,view.bounds.size.height * (point.y - lastAnchorPoint.y) + lastPositionPoint.y);
    
    [comeThrough setValue:@"comeThrough" forKey:@"animationName"];
    
    [view.layer addAnimation:comeThrough forKey:@"comeThrough"];
    
}

- (void)comeUp:(UIView *)view anchorPoint:(CGPoint)point
{
    CABasicAnimation *becomeOpaque = [CABasicAnimation animationWithKeyPath:@"opacity"];
    becomeOpaque.fromValue = [NSNumber numberWithFloat:0.0];
    becomeOpaque.toValue = [NSNumber numberWithFloat:1.0];
    becomeOpaque.duration = 0.5;
    
    CABasicAnimation *becomeLarger = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeLarger.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.4, 0.4, 1)];
    becomeLarger.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];;
    becomeLarger.duration = 0.5;
    
    CAAnimationGroup *comeUp = [CAAnimationGroup animation];
    comeUp.animations = [NSArray arrayWithObjects:becomeLarger, becomeOpaque, nil];
    comeUp.duration = 0.5;
    comeUp.delegate = self;
    
    // Get the anchorPoint and positionPoint before animating
    CGPoint lastAnchorPoint = view.layer.anchorPoint;
    CGPoint lastPositionPoint = view.layer.position;
    // Reset the anchorPoint and positionPoint by user's touch
    view.layer.anchorPoint = point;
    view.layer.position = CGPointMake(view.bounds.size.width * (point.x - lastAnchorPoint.x) + lastPositionPoint.x,view.bounds.size.height * (point.y - lastAnchorPoint.y) + lastPositionPoint.y);
    
    [comeUp setValue:@"comeUp" forKey:@"animationName"];
    
    [view.layer addAnimation:comeUp forKey:@"comeUp"];
    
}

- (void)goThrough:(UIView *)view anchorPoint:(CGPoint)point
{
    CABasicAnimation *becomeOpaque = [CABasicAnimation animationWithKeyPath:@"opacity"];
    becomeOpaque.fromValue = [NSNumber numberWithFloat:0.0];
    becomeOpaque.toValue = [NSNumber numberWithFloat:1.0];
    becomeOpaque.duration = 0.5;
    
    CABasicAnimation *becomeSmall = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeSmall.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    becomeSmall.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];;
    becomeSmall.duration = 0.5;
    
    CAAnimationGroup *goThrough = [CAAnimationGroup animation];
    goThrough.animations = [NSArray arrayWithObjects:becomeSmall, becomeOpaque, nil];
    goThrough.duration = 0.5;
    goThrough.delegate = self;
    goThrough.fillMode = kCAFillModeForwards;
    goThrough.removedOnCompletion = NO;
    
    // Get the anchorPoint and positionPoint before animating
    CGPoint lastAnchorPoint = view.layer.anchorPoint;
    CGPoint lastPositionPoint = view.layer.position;
    // Reset the anchorPoint and positionPoint by user's touch
    view.layer.anchorPoint = point;
    view.layer.position = CGPointMake(view.bounds.size.width * (point.x - lastAnchorPoint.x) + lastPositionPoint.x,view.bounds.size.height * (point.y - lastAnchorPoint.y) + lastPositionPoint.y);
    
    [goThrough setValue:@"goThrough" forKey:@"animationName"];
    
    [view.layer addAnimation:goThrough forKey:@"goThrough"];
    
}

- (void)goDown:(UIView *)view anchorPoint:(CGPoint)point
{
    CABasicAnimation *becomeTransparent = [CABasicAnimation animationWithKeyPath:@"opacity"];
    becomeTransparent.fromValue = [NSNumber numberWithFloat:1.0];
    becomeTransparent.toValue = [NSNumber numberWithFloat:0.0];
    becomeTransparent.duration = 0.5;
    //self.becomeTransparent.removedOnCompletion = NO;
    
    CABasicAnimation *becomeSmaller = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeSmaller.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    becomeSmaller.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.4, 0.4, 1)];;
    becomeSmaller.duration = 0.5;
    //self.becomeSmaller.removedOnCompletion = NO;
    
    CAAnimationGroup *goDown = [CAAnimationGroup animation];
    goDown.animations = [NSArray arrayWithObjects:becomeSmaller, becomeTransparent, nil];
    goDown.duration = 0.5;
    goDown.delegate = self;
    
    // Get the anchorPoint and positionPoint before animating
    CGPoint lastAnchorPoint = view.layer.anchorPoint;
    CGPoint lastPositionPoint = view.layer.position;
    // Reset the anchorPoint and positionPoint by user's touch
    view.layer.anchorPoint = point;
    view.layer.position = CGPointMake(view.bounds.size.width * (point.x - lastAnchorPoint.x) + lastPositionPoint.x,view.bounds.size.height * (point.y - lastAnchorPoint.y) + lastPositionPoint.y);
    
    [goDown setValue:@"goDown" forKey:@"animationName"];
    
    [view.layer addAnimation:goDown forKey:@"goDown"];
    
}

@end

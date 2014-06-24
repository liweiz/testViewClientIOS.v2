//
//  UIViewController+InOutTransition.m
//  testView
//
//  Created by Liwei Zhang on 2014-06-19.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "UIViewController+InOutTransition.h"

CGFloat const animationDuration = 3.0f;

@implementation UIViewController (InOutTransition)

#pragma mark - present another view back and forth

// Tap could be the gesture for visiting or exiting a visual layer
// LongPress is only for visiting the visual layer below
// For visiting a visual layer below
- (void)showViewBelow:(UIView *)viewBelow viewBelowController:(UIViewController *)controllerBelow currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture longPressGesture:(UILongPressGestureRecognizer *)longPressGesture point:(CGPoint)p
{
    BOOL proceed;
    // If the view is inited with a viewController, please get the controller ready before executing this method
    CGPoint positionPoint;
    if (controllerBelow) {
        [self addChildViewController:controllerBelow];
        [controllerBelow didMoveToParentViewController:self];
    }
    if (tapGesture) {
        positionPoint = [tapGesture locationInView:base];
        proceed = YES;
    }
    if (longPressGesture && longPressGesture.state == UIGestureRecognizerStateBegan) {
        positionPoint = [longPressGesture locationInView:base];
        proceed = YES;
    }
    if (!tapGesture && !longPressGesture) {
        // This is used when tap location can not be got by gestureRecognizer, such as aysnc process. In this case, we store the touch point when the touch happens and assign to the parameter p here.
        positionPoint = p;
        proceed = YES;
    }
    if (proceed) {
        [currentView endEditing:YES];
        
        CGPoint anchorPoint = CGPointMake(positionPoint.x / base.frame.size.width, positionPoint.y / base.frame.size.height);
        [self comeThrough:currentView anchorPoint:anchorPoint];
        [base insertSubview:viewBelow belowSubview:currentView];
        [self comeUp:viewBelow anchorPoint:anchorPoint];
        currentView.userInteractionEnabled = NO;
        viewBelow.userInteractionEnabled = YES;
    }
}

// No longPress here. However, pinchGesture could be here for exiting the new visual layer
- (void)showViewAbove:(UIView *)viewAbove viewAboveController:(UIViewController *)controllerAbove currentView:(UIView *)currentView baseView:(UIView *)base tapGesture:(UITapGestureRecognizer *)tapGesture pinchGesture:(UIPinchGestureRecognizer *)pinchGesture point:(CGPoint)p
{
    BOOL proceed;
    CGPoint positionPoint;
    if (tapGesture) {
        positionPoint = [tapGesture locationInView:base];
        proceed = YES;
    }
    if (pinchGesture && (pinchGesture.state == UIGestureRecognizerStateBegan)) {
        if (pinchGesture.scale < 1.0) {
            // The last locations
            CGPoint lastLocation0 = [pinchGesture locationOfTouch:0 inView:base];
            CGPoint lastLocation1 = [pinchGesture locationOfTouch:1 inView:base];
            positionPoint = CGPointMake((lastLocation0.x + lastLocation1.x) / 2, (lastLocation0.y + lastLocation1.y) / 2);
            proceed = YES;
        }
    }
    if (!tapGesture && !pinchGesture) {
        positionPoint = p;
        proceed = YES;
    }
    if (proceed) {
        if (controllerAbove) {
            [self addChildViewController:controllerAbove];
            [controllerAbove didMoveToParentViewController:self];
        }
        [currentView endEditing:YES];
        CGPoint anchorPoint = CGPointMake(positionPoint.x / base.frame.size.width, positionPoint.y / base.frame.size.height);
        [self goThrough:viewAbove anchorPoint:anchorPoint];
        [base insertSubview:currentView belowSubview:viewAbove];
        [self goDown:currentView anchorPoint:anchorPoint];
        currentView.userInteractionEnabled = NO;
        viewAbove.userInteractionEnabled = YES;
    }
}

- (void)comeThrough:(UIView *)view anchorPoint:(CGPoint)point
{
    CABasicAnimation *becomeTransparent = [CABasicAnimation animationWithKeyPath:@"opacity"];
    becomeTransparent.fromValue = [NSNumber numberWithFloat:1.0];
    becomeTransparent.toValue = [NSNumber numberWithFloat:0.0];
    becomeTransparent.duration = animationDuration;
    
    CABasicAnimation *becomeLarge = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeLarge.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    becomeLarge.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];;
    becomeLarge.duration = animationDuration;
    
    CAAnimationGroup *comeThrough = [CAAnimationGroup animation];
    comeThrough.animations = [NSArray arrayWithObjects:becomeLarge, becomeTransparent, nil];
    comeThrough.duration = animationDuration;
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
    becomeOpaque.duration = animationDuration;
    
    CABasicAnimation *becomeLarger = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeLarger.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.4, 0.4, 1)];
    becomeLarger.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];;
    becomeLarger.duration = animationDuration;
    
    CAAnimationGroup *comeUp = [CAAnimationGroup animation];
    comeUp.animations = [NSArray arrayWithObjects:becomeLarger, becomeOpaque, nil];
    comeUp.duration = animationDuration;
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
    becomeOpaque.duration = animationDuration;
    
    CABasicAnimation *becomeSmall = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeSmall.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    becomeSmall.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];;
    becomeSmall.duration = animationDuration;
    
    CAAnimationGroup *goThrough = [CAAnimationGroup animation];
    goThrough.animations = [NSArray arrayWithObjects:becomeSmall, becomeOpaque, nil];
    goThrough.duration = animationDuration;
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
    becomeTransparent.duration = animationDuration;
    //self.becomeTransparent.removedOnCompletion = NO;
    
    CABasicAnimation *becomeSmaller = [CABasicAnimation animationWithKeyPath:@"transform"];
    becomeSmaller.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    becomeSmaller.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.4, 0.4, 1)];;
    becomeSmaller.duration = animationDuration;
    //self.becomeSmaller.removedOnCompletion = NO;
    
    CAAnimationGroup *goDown = [CAAnimationGroup animation];
    goDown.animations = [NSArray arrayWithObjects:becomeSmaller, becomeTransparent, nil];
    goDown.duration = animationDuration;
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
//
//  TVScrollViewVertical.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-29.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVScrollViewVertical.h"

@implementation TVScrollViewVertical

@synthesize startPositionY;
@synthesize targetPositionY;
@synthesize dragStartPointY;
@synthesize sectionNo;
@synthesize stops;
@synthesize textFields;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

# pragma mark - Pagination-like vertical scrolling

/*
 two senarioes:
 1. drag and stop at a precise point: the moving direction is just the stop point from the start point, and just to determine if the position is beyond 1/2 of the distance. If yes, go to the next stop. If no, bo back to the starting point.
 2. drag and stop with momentum, such as swipe: we could take the deceleration distance into account. Then the dragging distance with part of deceleration distance will be the best metric to determine which stop to go, starting one or the next one.
 */


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragStartPointY = scrollView.contentOffset.y;
}
/*
 // Senario 1
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
 {
 // if here is to avoid setting up target position twice, since two different senarios get processed in two stages
 if (decelerate) {
 // do nothing
 } else {
 // reset target position here
 // direction is determined by drag start and end points
 self.startPosition = self.dragStartPoint;
 self.targetPosition = scrollView.contentOffset.y;
 CGPoint newOffset;
 if (self.sectionNo == 0) {
 // Only possible to move to the section below
 // Target up section is the section itself
 newOffset = CGPointMake(0, [self stopChoiceUp:0 down:self.stopCamContext dragStart:self.start Position dragEnd:self.targetPosition startSection:0]);
 } else if (self.sectionNo == 1) {
 newOffset = CGPointMake(0, [self stopChoiceUp:0 down:self.stopContextTarget dragStart:self.startPosition dragEnd:self.targetPosition startSection:self.stopCamContext]);
 } else if (self.sectionNo == 2) {
 newOffset = CGPointMake(0, [self stopChoiceUp:self.stopCamContext down:self.stopTargetTranslation dragStart:self.startPosition dragEnd:self.targetPosition startSection:self.stopContextTarget]);
 
 } else if (self.sectionNo == 3) {
 newOffset = CGPointMake(0, [self stopChoiceUp:self.stopContextTarget down:self.stopTranslationDetail dragStart:self.startPosition dragEnd:self.targetPosition startSection:self.stopTargetTranslation]);
 } else if (self.sectionNo == 4) {
 // the only option is move up
 newOffset = CGPointMake(0, [self stopChoiceUp:self.stopTargetTranslation down:self.stopTranslationDetail dragStart:self.startPosition dragEnd:self.targetPosition startSection:self.stopTranslationDetail]);
 }
 [self.myNewView setContentOffset:newOffset animated:YES];
 }
 }
 */

// Senario 2
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Two initial points needed:
    // 1. initial "page" position for determining the two potential adjacent pages
    // 2. point to determine which direction to go
    
    // the 2nd point
    // direction is determined by drag end point and initial target deceleration point
    self.startPositionY = scrollView.contentOffset.y;
    self.targetPositionY = (*targetContentOffset).y;
    
    (*targetContentOffset).y = [self stopChoiceUp:[self getNextUpperStop:self.sectionNo] down:[self getNextLowerStop:self.sectionNo] dragStart:self.dragStartPointY dragEnd:self.startPositionY startSectionPointY:[self getUpperStop:self.sectionNo]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self switchCorrespondingTextView];
}

/*
 Section switch mechanism: each valid scroll will change the sectionNo.
 So no matter which section the user is at or while srolling, the scroll action will bring the user to the right section.
 A valid scroll is the scroll that will pass the direction check.
 */

- (CGFloat)stopChoiceUp:(CGFloat)upStop down:(CGFloat)downStop dragStart:(CGFloat)start dragEnd:(CGFloat)end startSectionPointY:(CGFloat)originalStart
{
    // CGFloat decelerationDistance = fabsf(end - finalTargetPosition);
    // Proceed to the target section
    // Figure out the direction
    /*
     if targetPosition == startPosition, which means no decelaration, set start as the startPositoin
     Below is just the same whole process above running with start
     */
    CGFloat x;
    if (self.startPositionY == self.targetPositionY) {
        x = self.dragStartPointY;
    } else {
        x = self.startPositionY;
    }
    return [self getStopChoiceUp:upStop down:downStop dragStart:start dragEnd:end startSectionPointY:originalStart directionDetectionStartPointY:x];
}

- (CGFloat)getStopChoiceUp:(CGFloat)upStop down:(CGFloat)downStop dragStart:(CGFloat)start dragEnd:(CGFloat)end startSectionPointY:(CGFloat)originalStart directionDetectionStartPointY:(CGFloat)detectionStart
{
    // startPoint here means the point for direction detection, see two senarios' comments
    CGFloat dragDistance = fabsf(end - start);
    if (self.targetPositionY < detectionStart) {
        // section 0 will not able to move up further
        if (originalStart >= [(NSNumber *)self.stops[0] floatValue]) {
            // move upwards, content view moves down
            CGFloat differenceUp = fabsf(originalStart - upStop);
            // Figure out if proceeding to the direction
            if (dragDistance < differenceUp / 6) {
                // Move back to the start section
                return originalStart;
            } else if (differenceUp == 0) {
                return originalStart;
            } else {
                // Reduce the section no by one
                self.sectionNo --;
                return upStop;
            }
        } else {
            // move back
            return originalStart;
        }
    } else if (self.targetPositionY > detectionStart) {
        // Last section will not able to move down further
        NSInteger n = [self.stops count];
        if (originalStart < [(NSNumber *)self.stops[n - 1] floatValue]) {
            // move downwards, content view moves up
            CGFloat differenceDown = fabsf(originalStart - downStop);
            // Figure out if proceeding to the direction
            if (dragDistance < differenceDown / 6) {
                // Move back to the start section
                return originalStart;
            } else if (differenceDown == 0) {
                return originalStart;
            } else {
                // Increase the section no by one
                self.sectionNo ++;
                return downStop;
            }
        } else {
            return originalStart;
        }
    } else {
        return originalStart;
    }
}

- (CGFloat)getNextUpperStop:(NSInteger)aSectionNo
{
    if (aSectionNo == 0 || aSectionNo == 1) {
        return 0.0f;
    } else {
        NSInteger n = aSectionNo - 2;
        NSNumber *x = self.stops[n];
        return x.floatValue;
    }
}

- (CGFloat)getNextLowerStop:(NSInteger)aSectionNo
{
    // Lower stop for last section is not needed since only scrolling stops only at upper stop.
    NSInteger n = [self.stops count];
    NSNumber *x;
    if (aSectionNo + 1 <= n) {
        x = self.stops[aSectionNo];
    } else {
        x = self.stops[n -1];
    }
    return x.floatValue;
}

- (CGFloat)getUpperStop:(NSInteger)aSectionNo
{
    if (aSectionNo == 0) {
        return 0.0f;
    } else {
        NSInteger n = aSectionNo - 1;
        NSNumber *x = self.stops[n];
        return x.floatValue;
    }
}

- (CGFloat)getLowerStop:(NSInteger)aSectionNo
{
    // Lower stop for last section is not needed since only scrolling stops only at upper stop.
    NSNumber *x = self.stops[aSectionNo];
    return x.floatValue;
}

# pragma mark - Keyboard management

- (void)switchCorrespondingTextView
{
    // Assume each section is corresponding to a textField.
    for (UITextField *t in self.textFields) {
        if ([t isFirstResponder]) {
            if (![self.textFields[self.sectionNo] isFirstResponder]) {
                [self.textFields[self.sectionNo] becomeFirstResponder];
            }
            break;
        }
    }
}

@end

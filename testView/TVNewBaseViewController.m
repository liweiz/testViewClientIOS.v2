//
//  TVNewBaseViewController.m
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVNewBaseViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "UIViewController+sharedMethods.h"


@interface TVNewBaseViewController ()

@end

@implementation TVNewBaseViewController

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

@synthesize myContextView, myDetailView, myNewView, myTargetView, myTranslationView, editOn, sectionList, contextEditOn, targetEditOn, translationEditOn, detailEditOn;

@synthesize tempSize, stopCamContext, stopContextTarget, stopTargetTranslation, stopTranslationDetail, startPosition, targetPosition, sectionNo, dragStartPoint, pinchToSaveGesture;

@synthesize tempContext, tempTarget, tempTranslation, tempDetail, myCreate, myUpdate, tapDetector, toTagSelectionGesture, textBefore, cancelView, cancelSaveTap;

@synthesize beginTime, timeOffset, repeatCount, repeatDuration, duration, speed, autoreverses, fillMode, currentLayer, bitLeft, myConfirmationView, toCreateTap, toUpdateTap, cardToUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    CGRect firstRect = [[UIScreen mainScreen] applicationFrame];
    self.tempSize = firstRect.size;
    CGRect viewRect = CGRectMake(tempSize.width * 0, 0.0, tempSize.width, tempSize.height);
    self.myNewView = [[UIScrollView alloc] initWithFrame:viewRect];
    self.myNewView.contentSize = CGSizeMake(self.tempSize.width, self.tempSize.height * 2 + 960.0);
     self.stopCamContext = self.tempSize.height;
    // Set the initial section
    self.myNewView.contentOffset = CGPointMake(0.0, self.stopCamContext);
    // sectionNo: 0=>OCR, 1=>Context, 2=>Target, 3=>Translation, 4=>Detail
    self.sectionNo = 1;
    self.myNewView.delegate = self;
    self.myNewView.bounces = NO;
    self.myNewView.backgroundColor = [UIColor greenColor];
    self.myNewView.alwaysBounceVertical = NO;

    //self.myNewView.decelerationRate =  UIScrollViewDecelerationRateFast;
    self.view = [[UIView alloc] initWithFrame:viewRect];
    self.view.backgroundColor = [UIColor yellowColor];
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.myNewView];
//    NSLog(@"self.view.frame.size.width: %f", self.view.frame.size.width);
//    NSLog(@"self.view.frame.size.height: %f", self.view.frame.size.height);
    
//    self.toTagSelectionGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showTagSelection:)];
//    [self.view addGestureRecognizer:self.toTagSelectionGesture];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Add context label
    UILabel *contextLabel =[[UILabel alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 15 + self.stopCamContext, self.tempSize.width * 9 / 10, 30)];
    contextLabel.text = @"Context";
    [self.myNewView addSubview:contextLabel];
    
    // Add context view
    self.myContextView = [[UITextView alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 5 + contextLabel.frame.origin.y + contextLabel.frame.size.height, self.tempSize.width * 9 / 10, 100)];
    [self.myNewView addSubview:self.myContextView];
    self.myContextView.delegate = self;
    
    self.stopContextTarget = self.myContextView.frame.origin.y + self.myContextView.frame.size.height;
    
    
    // Add target label
    UILabel *targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 15 + self.myContextView.frame.origin.y + self.myContextView.frame.size.height, self.tempSize.width * 9 / 10, 30)];
    targetLabel.text = @"Target";
    [self.myNewView addSubview:targetLabel];
    
    
    // Add target view, 15 is the space between two views
    self.myTargetView = [[UITextView alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 5 + targetLabel.frame.origin.y + targetLabel.frame.size.height, self.tempSize.width * 9 / 10, 30)];
    [self.myNewView addSubview:self.myTargetView];
    self.myTargetView.backgroundColor = [UIColor whiteColor];
    self.myTargetView.delegate = self;
    
    self.stopTargetTranslation = self.myTargetView.frame.origin.y + self.myTargetView.frame.size.height;
    
    // Add translation label
    UILabel *translationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 15 + self.myTargetView.frame.origin.y + self.myTargetView.frame.size.height, self.tempSize.width * 9 / 10, 30)];
    translationLabel.text = @"Translation";
    [self.myNewView addSubview:translationLabel];
    
    // Add translation view
    self.myTranslationView = [[UITextView alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 5 + translationLabel.frame.origin.y + translationLabel.frame.size.height, self.tempSize.width * 9 / 10, 30)];
    [self.myNewView addSubview:self.myTranslationView];
    self.myTranslationView.backgroundColor = [UIColor whiteColor];
    self.myTranslationView.delegate = self;
    
    self.stopTranslationDetail = self.myTranslationView.frame.origin.y + self.myTranslationView.frame.size.height;
    
    // Add detail label
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 15 + self.myTranslationView.frame.origin.y + self.myTranslationView.frame.size.height, self.tempSize.width * 9 / 10, 30)];
    detailLabel.text = @"Detail";
    [self.myNewView addSubview:detailLabel];
    
    // Add detail view
    self.myDetailView = [[UITextView alloc] initWithFrame:CGRectMake(self.tempSize.width / 20, 5 + detailLabel.frame.origin.y + detailLabel.frame.size.height, self.tempSize.width * 9 / 10, 100)];
    [self.myNewView addSubview:self.myDetailView];
    self.myDetailView.delegate = self;
    
//    NSLog(@"stopTranslationDetail: %f", self.stopTranslationDetail);
//    NSLog(@"stopTargetTranslation: %f", self.stopTargetTranslation);
//    NSLog(@"stopContextTarget: %f", self.stopContextTarget);
//    NSLog(@"stopCamContext: %f", self.stopCamContext);
    
    // config setionNo, stop and view array
    NSNumber *aNumber = [NSNumber numberWithFloat:self.stopCamContext];
    NSNumber *bNumber = [NSNumber numberWithFloat:self.stopContextTarget];
    NSNumber *cNumber = [NSNumber numberWithFloat:self.stopTargetTranslation];
    NSNumber *dNumber = [NSNumber numberWithFloat:self.stopTranslationDetail];
    NSNumber *zNumber = [NSNumber numberWithFloat:0];

    NSArray *zArray = [NSArray arrayWithObjects:nil, zNumber, nil];;
    NSArray *aArray = [NSArray arrayWithObjects:self.myContextView, aNumber, nil];
    NSArray *bArray = [NSArray arrayWithObjects:self.myTargetView, bNumber, nil];
    NSArray *cArray = [NSArray arrayWithObjects:self.myTranslationView, cNumber, nil];
    NSArray *dArray = [NSArray arrayWithObjects:self.myDetailView, dNumber, nil];
    // sectionNo: 0=>OCR, 1=>Context, 2=>Target, 3=>Translation, 4=>Detail
    // the first is left to be zArray to wait for change for OCR in the future
    self.sectionList = [NSArray arrayWithObjects:zArray, aArray, bArray, cArray, dArray, nil];
    
    if (!self.bitLeft) {
        self.bitLeft = [[UILabel alloc] initWithFrame:CGRectMake(250.0, contextLabel.frame.origin.y - self.myNewView.contentOffset.y, 55.0, contextLabel.frame.size.height)];
        [self updateBitLeft];
        self.bitLeft.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.bitLeft];
    }
    
    self.myConfirmationView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tempSize.width, tempSize.height)];
    self.myConfirmationView.backgroundColor = [UIColor whiteColor];
    self.myConfirmationView.hidden = YES;
    [self.view addSubview:self.myConfirmationView];
    self.pinchToSaveGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(showSave)];
    [self.myNewView addGestureRecognizer:self.pinchToSaveGesture];
    
    // Add Create button.
    // The action will be added in rootViewController
    self.myCreate = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 100.0)];
    self.myCreate.userInteractionEnabled = YES;
    self.myCreate.text = @"Save as new";
    self.myCreate.textAlignment = NSTextAlignmentCenter;
    self.myCreate.backgroundColor = [UIColor greenColor];
    [self.myConfirmationView addSubview:self.myCreate];
    self.toCreateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitSave)];
    [self.myCreate addGestureRecognizer:self.toCreateTap];
    
    self.myUpdate = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 100.0)];
    self.myUpdate.userInteractionEnabled = YES;
    self.myUpdate.text = @"Save";
    self.myUpdate.textAlignment = NSTextAlignmentCenter;
    self.myUpdate.backgroundColor = [UIColor greenColor];
    self.myUpdate.hidden = YES;
    [self.myConfirmationView addSubview:self.myUpdate];
    self.toUpdateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitSave)];
    [self.myUpdate addGestureRecognizer:self.toUpdateTap];
    
    self.cancelView = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.view.frame.size.height - 10.0 - 100.0, 300.0, 100.0)];
    self.cancelView.userInteractionEnabled = YES;
    self.cancelView.text = @"Cancel";
    self.cancelView.textAlignment = NSTextAlignmentCenter;
    self.cancelView.backgroundColor = [UIColor redColor];
    [self.myConfirmationView addSubview:self.cancelView];
    self.cancelSaveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitSave)];
    [self.cancelView addGestureRecognizer:self.cancelSaveTap];
    
    self.tapDetector = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:self.tapDetector];
    
    self.currentLayer = 1;
    
    self.cardToUpdate = nil;
}


- (BOOL)checkIfTargetIsInContext
{
    // Add target language locale
    NSRange range = [self.myContextView.text rangeOfString:self.myTargetView.text options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.myContextView.text.length) locale:nil];
    // Returns {NSNotFound, 0} if aString is not found or is empty (@"").
    if (range.location == NSNotFound) {
        // Send system alert
        return NO;
    }
    return  YES;
}

- (void)updateBitLeft
{
    NSString *string = [NSString stringWithFormat:@"%i", [self lengthLeft]];
    self.bitLeft.text = string;
}

- (NSInteger)lengthLeft
{
    NSInteger length;
    NSInteger left;
    switch (self.sectionNo) {
        case 1:
            // For context
            length = [self.myContextView.text length];
            left = 300 - length;
            return left;
        case 2:
            // For target
            length = [self.myTargetView.text length];
            left = 30 - length;
            return left;
        case 3:
            // For translation
            length = [self.myTranslationView.text length];
            left = 30 - length;
            return left;
        case 4:
            // For detail
            length = [self.myDetailView.text length];
            left = 600 - length;
            return left;
    }
    left = 10000;
    return left;
}

- (void)showSave
{
    if (self.cardToUpdate) {
        // Update is visiable
        self.myUpdate.hidden = NO;
        self.myCreate.frame = CGRectMake(10.0, 10.0 + 100.0 + 25.0, 300.0, 100.0);
    } else {
        self.myCreate.frame = CGRectMake(10.0, 10.0, 300.0, 100.0);
        self.myUpdate.hidden = YES;
    }
    self.currentLayer = 2;
    if (self.myConfirmationView.hidden == YES) {
        self.myConfirmationView.hidden = NO;
    }
    [self hideNewView:self.myNewView currentView:self.myConfirmationView baseView:self.view tapGesture:nil pinchGesture:self.pinchToSaveGesture];
    [self freezeRootView];
}

- (void)exitSave
{
    self.currentLayer = 1;
    if (self.myNewView.hidden == YES) {
        self.myNewView.hidden = NO;
    }
    [self showNewView:self.myNewView newViewController:nil currentView:self.myConfirmationView baseView:self.view tapGesture:self.cancelSaveTap longPressGesture:nil];
    [self defreezeRootView];
}

# pragma mark - Show & exit another layer beneath

//- (void)showTagSelection:(id)sender
//{
//    self.currentLayer = 0;
//    UILongPressGestureRecognizer *longPress = sender;
//    if (longPress.state == UIGestureRecognizerStateBegan) {
//        // Get tagViewController ready
//        if (!self.tagsMultiBaseViewController) {
//            // Add pinchToExit gesture
//            self.tagsMultiBaseViewController = [[TVTagsMultiBaseViewController alloc] init];
//            self.tagsMultiBaseViewController.tempAddedRowsIsOn = YES;
//            self.tagsMultiBaseViewController.startWithEditMode = YES;
//            self.tagsMultiBaseViewController.positionY = 0.0f;
//            self.tagsMultiBaseViewController.forTab = NO;
//            // Pass the Core Data settings
//            self.tagsMultiBaseViewController.managedObjectContext = self.managedObjectContext;
//            self.tagsMultiBaseViewController.managedObjectModel = self.managedObjectModel;
//            self.tagsMultiBaseViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
//            self.tagsMultiBaseViewController.pinchToExitGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(exitTagSelection)];
//        }
//        self.tagsMultiBaseViewController.tagsSelected = self.tagsSelected;
//        // Hide keyboard if there is one
//        [self.myNewView endEditing:YES];
//        // Freeze
//        [self freezeRootView];
//        
//        // Get tagView visiable
//        if (self.tagsMultiBaseViewController.view.hidden == YES) {
//            self.tagsMultiBaseViewController.view.hidden = NO;
//        }
//        // Animate
//        [self showNewView:self.tagsMultiBaseViewController.view newViewController:self.tagsMultiBaseViewController currentView:self.myNewView baseView:self.view tapGesture:nil longPressGesture:self.toTagSelectionGesture];
//        [self.tagsMultiBaseViewController.view addSubview:self.tagsMultiBaseViewController.keyboardSlot];
//        [self.tagsMultiBaseViewController.view addGestureRecognizer:self.tagsMultiBaseViewController.pinchToExitGesture];
//    }
//}

- (void)exitTagSelection
{
    self.currentLayer = 1;
    if (self.myNewView.hidden == YES) {
        self.myNewView.hidden = NO;
    }
    [self hideNewView:self.tagsMultiBaseViewController.view currentView:self.myNewView baseView:self.view tapGesture:nil pinchGesture:self.tagsMultiBaseViewController.pinchToExitGesture];
    [self defreezeRootView];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self viewHide];
    
    NSString *animName = [anim valueForKey:@"animationName"];
    
    if ([animName isEqualToString:@"comeThrough"]) {
        // Remove the animation
        [self.myNewView.layer removeAllAnimations];
        [self.myConfirmationView.layer removeAllAnimations];
    }
    if ([animName isEqualToString:@"comeUp"]) {
        
    }
    if ([animName isEqualToString:@"goThrough"]) {

    }
    if ([animName isEqualToString:@"goDown"]) {
        
    }
    [self viewShow];
}

- (void)viewHide
{
    switch (self.currentLayer) {
        case 0:
            self.myConfirmationView.hidden = YES;
            self.myNewView.hidden = YES;
            break;
        case 1:
            self.myConfirmationView.hidden = YES;
            self.tagsMultiBaseViewController.view.hidden = YES;
            break;
        case 2:
            self.tagsMultiBaseViewController.view.hidden = YES;
            self.myNewView.hidden = YES;
            break;
    }
}

- (void)viewShow
{
    switch (self.currentLayer) {
        case 0:
            self.tagsMultiBaseViewController.view.hidden = NO;
            break;
        case 1:
            self.myNewView.hidden = NO;
            break;
        case 2:
            self.myConfirmationView.hidden = NO;
            break;
    }
}

# pragma mark - Keyboard management

- (void)keepKeyboard
{
    Boolean contextFirst = [self.myContextView isFirstResponder];
    Boolean targetFirst = [self.myTargetView isFirstResponder];
    Boolean translationFirst = [self.myTranslationView isFirstResponder];
    Boolean detailFirst = [self.myDetailView isFirstResponder];
    if (contextFirst || targetFirst || translationFirst || detailFirst) {
        if (self.sectionNo == 1 && ![self.myContextView isFirstResponder]) {
            [self.myContextView becomeFirstResponder];
        }
        if (self.sectionNo == 2 && ![self.myTargetView isFirstResponder]) {
            [self.myTargetView becomeFirstResponder];
        }
        if (self.sectionNo == 3 && ![self.myTranslationView isFirstResponder]) {
            [self.myTranslationView becomeFirstResponder];
        }
        if (self.sectionNo == 4 && ![self.myDetailView isFirstResponder]) {
            [self.myDetailView becomeFirstResponder];
        }
    }
}

- (void)firstResponderMustAtTop
{
    // This senario only happens when user tap in a non current top input box.
    if ([self.myContextView isFirstResponder]) {
        if (self.sectionNo != 1) {
            [self.myNewView setContentOffset:CGPointMake(0, self.stopCamContext) animated:YES];
            self.sectionNo = 1;
        }
    }
    if ([self.myTargetView isFirstResponder]) {
        if (self.sectionNo != 2) {
            [self.myNewView setContentOffset:CGPointMake(0, self.stopContextTarget) animated:YES];
            self.sectionNo = 2;
        }
    }
    if ([self.myTranslationView isFirstResponder]) {
        if (self.sectionNo != 3) {
            [self.myNewView setContentOffset:CGPointMake(0, self.stopTargetTranslation) animated:YES];
            self.sectionNo = 3;
        }
    }
    if ([self.myDetailView isFirstResponder]) {
        if (self.sectionNo != 4) {
            [self.myNewView setContentOffset:CGPointMake(0, self.stopTranslationDetail) animated:YES];
            self.sectionNo = 4;
        }
    }
    [self updateBitLeft];
    if (self.bitLeft.hidden == YES) {
        self.bitLeft.hidden = NO;
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger maxLength;
    switch (self.sectionNo) {
        case 1:
            maxLength = 300;
            break;
        case 2:
            maxLength = 30;
            break;
        case 3:
            maxLength = 30;
            break;
        case 4:
            maxLength = 600;
            break;
    }
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= maxLength)
    {
        return YES;
    } else {
        NSUInteger emptySpace = maxLength - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.editOn = YES;
    if ([textView isEqual:self.myContextView]) {
        self.contextEditOn = YES;
    }
    if ([textView isEqual:self.myDetailView]) {
        self.detailEditOn = YES;
    }
    [self firstResponderMustAtTop];
    if ([textView isEqual:self.myTargetView] || [textView isEqual:self.myTranslationView]) {
        self.textBefore = textView.text;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.editOn = NO;
    if ([textView isEqual:self.myContextView]) {
        self.contextEditOn = NO;
    }
    if ([textView isEqual:self.myDetailView]) {
        self.detailEditOn = NO;
    }
    self.bitLeft.hidden = YES;
    // Trim text first
    NSString *trimmedText = [self trimInput:textView.text];
    if ([trimmedText isEqual:self.myTargetView] || [textView isEqual:self.myTranslationView]) {
        if ([textView.text isEqualToString:self.textBefore]) {
            // No change
        } else {
            [self.tagsSelected removeAllObjects];
        }
        self.textBefore = nil;
    }
    textView.text = trimmedText;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateBitLeft];
}

# pragma mark - Obsever for tag changing
// Any change made in target and translation leads to reset of tags selected


# pragma mark - Paging-like vertical scrolling

/*
 two senarioes:
 1. drag and stop at a precise point: the moving direction is just the stop point from the start point, and just to determine if the position is beyond 1/2 of the distance. If yes, go to the next stop. If no, bo back to the starting point.
 2. drag and stop with momentum, such as swipe: we could take the deceleration distance into account. Then the dragging distance with part of deceleration distance will be the best metric to determine which stop to go, starting one or the next one.
 */


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragStartPoint = scrollView.contentOffset.y;
//    NSLog(@"drag start at: %f", self.dragStartPoint);
}
/*
// Senario 1
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // if here is to avoid setting up target position twice, since two different senarios get processed in two stages
    NSLog(@"Called");
    if (decelerate) {
        // do nothing
        NSLog(@"fast");
    } else {
        NSLog(@"slow");
        // reset target position here
        // direction is determined by drag start and end points
        self.startPosition = self.dragStartPoint;
        self.targetPosition = scrollView.contentOffset.y;
        NSLog(@"startPosition: %f", self.startPosition);
        NSLog(@"targetPosition: %f", self.targetPosition);
        CGPoint newOffset;
        if (self.sectionNo == 0) {
            // Only possible to move to the section below
            // Target up section is the section itself
            newOffset = CGPointMake(0, [self stopChoiceUp:0 down:self.stopCamContext dragStart:self.startPosition dragEnd:self.targetPosition startSection:0]);
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
//    NSLog(@"section1: %i" ,self.sectionNo);
    // Two initial points needed:
    // 1. initial "page" position for determining the two potential adjacent pages
    // 2. point to determine which direction to go
    
    // the 2nd point
    // direction is determined by drag end point and initial target deceleration point
    self.startPosition = scrollView.contentOffset.y;
    self.targetPosition = (*targetContentOffset).y;
//    NSLog(@"startPosition: %f", self.startPosition);
//    NSLog(@"targetPosition: %f", self.targetPosition);

    if (self.sectionNo == 0) {
        // Only possible to move to the section below
        // Target up section is the section itself
        // (*targetContentOffset).y = [self stopChoiceUp:0 down:self.stopCamContext dragStart:self.dragStartPoint dragEnd:self.startPosition startSection:0];
    } else if (self.sectionNo == 1) {
        (*targetContentOffset).y = [self stopChoiceUp:0 down:self.stopContextTarget dragStart:self.dragStartPoint dragEnd:self.startPosition startSection:self.stopCamContext];
        if (targetContentOffset->y == 0.0) {
            targetContentOffset->y = self.stopCamContext;
            self.sectionNo = 1;
        }
    } else if (self.sectionNo == 2) {
        (*targetContentOffset).y = [self stopChoiceUp:self.stopCamContext down:self.stopTargetTranslation dragStart:self.dragStartPoint dragEnd:self.startPosition startSection:self.stopContextTarget];
    } else if (self.sectionNo == 3) {
        (*targetContentOffset).y = [self stopChoiceUp:self.stopContextTarget down:self.stopTranslationDetail dragStart:self.dragStartPoint dragEnd:self.startPosition startSection:self.stopTargetTranslation];
    } else if (self.sectionNo == 4) {
        // the only option is move up
        (*targetContentOffset).y = [self stopChoiceUp:self.stopTargetTranslation down:self.stopTranslationDetail dragStart:self.dragStartPoint dragEnd:self.startPosition startSection:self.stopTranslationDetail];
    }
}

/*
 Section switch mechanism: each valid scroll will change the sectionNo.
 So no matter which section the user is at or while srolling, the scroll action will bring the user to the right section.
 A valid scroll is the scroll that will pass the direction check.
 */

- (CGFloat)stopChoiceUp:(CGFloat)upStop down:(CGFloat)downStop dragStart:(CGFloat)start dragEnd:(CGFloat)end startSection:(CGFloat)stopXxx
{
    //CGFloat decelerationDistance = fabsf(end - finalTargetPosition);
    // Proceed to the target section
    // Figure out the direction

    /*
     if targetPosition == startPosition, which means no decelaration, set start as the startPositoin
     Below is just the same whole process above running with start
     */
    if (self.startPosition == self.targetPosition) {
        return [self stopChoiceCoreUp:upStop down:downStop dragStart:start dragEnd:end startSection:stopXxx startPoint:self.dragStartPoint];
    } else {
        return [self stopChoiceCoreUp:upStop down:downStop dragStart:start dragEnd:end startSection:stopXxx startPoint:self.startPosition];
    }
    
}

- (CGFloat)stopChoiceCoreUp:(CGFloat)upStop down:(CGFloat)downStop dragStart:(CGFloat)start dragEnd:(CGFloat)end startSection:(CGFloat)stopXxx startPoint:(CGFloat)myStart
{
    // startPoint here means the point for direction detection, see two senarios comments
    CGFloat dragDistance = fabsf(end - start);
    if (self.targetPosition < myStart) {
        // section 0 will not able to move up further
        if (stopXxx >= self.stopCamContext) {
            // move upwards, content view moves down
            CGFloat differenceUp = fabsf(stopXxx - upStop);
            // Figure out if proceeding to the direction
            if (dragDistance < differenceUp / 6) {
                // Move back to the start section
                return stopXxx;
            } else if (differenceUp == 0) {
                return stopXxx;
            } else {
                // Reduce the section no by one
                self.sectionNo --;
                return upStop;
            }
        } else {
            // move back
            return stopXxx;
        }
    } else if (self.targetPosition > myStart) {
        if (stopXxx <= self.stopTranslationDetail) {
            // move downwards, content view moves up
            CGFloat differenceDown = fabsf(stopXxx - downStop);
            // Figure out if proceeding to the direction
            if (dragDistance < differenceDown / 6) {
                // Move back to the start section
                return stopXxx;
            } else if (differenceDown == 0) {
                return stopXxx;
            } else {
                // Increase the section no by one
                self.sectionNo ++;
                return downStop;
            }
        } else {
            return stopXxx;
        }
    } else {
        return stopXxx;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self keepKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

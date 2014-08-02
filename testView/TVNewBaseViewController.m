//
//  TVNewBaseViewController.m
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVNewBaseViewController.h"
#import "TVAppRootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+sharedMethods.h"


@interface TVNewBaseViewController ()

@end

@implementation TVNewBaseViewController

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

@synthesize myContextView, myDetailView, myNewView, myTargetView, myTranslationView, editOn, sectionList, contextEditOn, targetEditOn, translationEditOn, detailEditOn;

@synthesize box;

@synthesize stopContextTarget, stopTargetTranslation, stopTranslationDetail, startPosition, targetPosition, sectionNo, dragStartPoint;

@synthesize tempContext, tempTarget, tempTranslation, tempDetail, textBefore;

@synthesize beginTime, timeOffset, repeatCount, repeatDuration, duration, speed, autoreverses, fillMode, bitLeft, cardToUpdate;

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
    CGRect viewRect = CGRectMake(self.box.appRect.size.width * 0.0f, 0.0f, self.box.appRect.size.width, self.box.appRect.size.height);
    self.myNewView = [[TVScrollViewVertical alloc] initWithFrame:self.box.appRect];
    self.myNewView.contentSize = CGSizeMake(self.box.appRect.size.width, self.box.appRect.size.height * 2.0f + 500.0f);
    // Set the initial section
    self.myNewView.contentOffset = CGPointMake(0.0f, 0.0f);
    // sectionNo: 0=>Context, 1=>Target, 2=>Translation, 3=>Detail
    self.myNewView.sectionNo = 0;
    self.myNewView.delegate = self.myNewView;
    self.myNewView.bounces = NO;
    self.myNewView.backgroundColor = [UIColor greenColor];
    self.myNewView.alwaysBounceVertical = NO;

    //self.myNewView.decelerationRate =  UIScrollViewDecelerationRateFast;
    self.view = [[UIView alloc] initWithFrame:viewRect];
    self.view.backgroundColor = [UIColor yellowColor];
    self.view.clipsToBounds = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:self.myNewView];
    // Add context label
    UILabel *contextLabel =[[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY, self.box.labelWidth, tvRowHeight)];
    contextLabel.text = @"Example";
    [self.myNewView addSubview:contextLabel];
    
    // Add context view
    self.myContextView = [[UITextView alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY + contextLabel.frame.origin.y + contextLabel.frame.size.height, self.box.labelWidth, tvRowHeight * 5.0f)];
    [self.myNewView addSubview:self.myContextView];
    self.myContextView.delegate = self;
    
    self.stopContextTarget = self.myContextView.frame.origin.y + self.myContextView.frame.size.height;
    
    // Add target label
    UILabel *targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY + self.myContextView.frame.origin.y + self.myContextView.frame.size.height, self.box.labelWidth, tvRowHeight)];
    targetLabel.text = @"Target";
    [self.myNewView addSubview:targetLabel];
    
    // Add target view, 15 is the space between two views
    self.myTargetView = [[UITextView alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY + targetLabel.frame.origin.y + targetLabel.frame.size.height, self.box.labelWidth, tvRowHeight * 2.0f)];
    [self.myNewView addSubview:self.myTargetView];
    self.myTargetView.backgroundColor = [UIColor whiteColor];
    self.myTargetView.delegate = self;
    
    self.stopTargetTranslation = self.myTargetView.frame.origin.y + self.myTargetView.frame.size.height;
    
    // Add translation label
    UILabel *translationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY + self.myTargetView.frame.origin.y + self.myTargetView.frame.size.height, self.box.labelWidth, tvRowHeight)];
    translationLabel.text = @"Translation";
    [self.myNewView addSubview:translationLabel];
    
    // Add translation view
    self.myTranslationView = [[UITextView alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY + translationLabel.frame.origin.y + translationLabel.frame.size.height, self.box.labelWidth, tvRowHeight * 2.0f)];
    [self.myNewView addSubview:self.myTranslationView];
    self.myTranslationView.backgroundColor = [UIColor whiteColor];
    self.myTranslationView.delegate = self;
    
    self.stopTranslationDetail = self.myTranslationView.frame.origin.y + self.myTranslationView.frame.size.height;
    
    // Add detail label
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY + self.myTranslationView.frame.origin.y + self.myTranslationView.frame.size.height, self.box.labelWidth, tvRowHeight)];
    detailLabel.text = @"Note";
    [self.myNewView addSubview:detailLabel];
    
    // Add detail view
    self.myDetailView = [[UITextView alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gapY + detailLabel.frame.origin.y + detailLabel.frame.size.height, self.box.labelWidth, tvRowHeight * 5.0f)];
    [self.myNewView addSubview:self.myDetailView];
    self.myDetailView.delegate = self;
    
    // config setionNo, stop and view array
    NSNumber *aNumber = [NSNumber numberWithFloat:self.stopContextTarget];
    NSNumber *bNumber = [NSNumber numberWithFloat:self.stopTargetTranslation];
    NSNumber *cNumber = [NSNumber numberWithFloat:self.stopTranslationDetail];

    self.myNewView.stops = [NSArray arrayWithObjects:aNumber, bNumber, cNumber, nil];
    self.myNewView.textFields = @[self.myContextView, self.myTargetView, self.myTranslationView, self.myDetailView];
    
    if (!self.bitLeft) {
        self.bitLeft = [[UILabel alloc] initWithFrame:CGRectMake(250.0, contextLabel.frame.origin.y - self.myNewView.contentOffset.y, 55.0, contextLabel.frame.size.height)];
        [self updateBitLeft];
        self.bitLeft.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.bitLeft];
    }
    
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

- (void)firstResponderMustAtTop
{
    // This senario only happens when user tap in a non current top input box.
    if ([self.myContextView isFirstResponder]) {
        if (self.sectionNo != 0) {
            [self.myNewView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
            self.sectionNo = 0;
        }
    }
    if ([self.myTargetView isFirstResponder]) {
        if (self.sectionNo != 1) {
            [self.myNewView setContentOffset:CGPointMake(0.0f, self.stopContextTarget) animated:YES];
            self.sectionNo = 1;
        }
    }
    if ([self.myTranslationView isFirstResponder]) {
        if (self.sectionNo != 2) {
            [self.myNewView setContentOffset:CGPointMake(0.0f, self.stopTargetTranslation) animated:YES];
            self.sectionNo = 2;
        }
    }
    if ([self.myDetailView isFirstResponder]) {
        if (self.sectionNo != 3) {
            [self.myNewView setContentOffset:CGPointMake(0.0f, self.stopTranslationDetail) animated:YES];
            self.sectionNo = 3;
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
        case 0:
            maxLength = 300;
            break;
        case 1:
            maxLength = 30;
            break;
        case 2:
            maxLength = 30;
            break;
        case 3:
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
        [self.textBefore setString:textView.text];
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
            
        }
        self.textBefore = nil;
    }
    textView.text = trimmedText;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateBitLeft];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

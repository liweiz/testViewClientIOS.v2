//
//  TVNewViewController.m
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVNewViewController.h"
#import "TVAppRootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+InOutTransition.h"
#import "TVView.h"
#import "TVSaveViewController.h"
#import "TVLayerBaseViewController.h"

@interface TVNewViewController ()

@end

@implementation TVNewViewController

@synthesize myContextView, myDetailView, myNewView, myTargetView, myTranslationView;
@synthesize createNewOnly;

@synthesize stopContextTarget, stopTargetTranslation, stopTranslationDetail, startPosition, targetPosition, dragStartPoint;

@synthesize tempContext, tempTarget, tempTranslation, tempDetail, textBefore;

@synthesize beginTime, timeOffset, repeatCount, repeatDuration, duration, speed, autoreverses, fillMode, bitLeft, cardToUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.actionNo = TVPinchToSave;
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
    TVView *theView = [[TVView alloc] initWithFrame:viewRect];
    theView.touchToDismissKeyboardIsOn = YES;
    theView.touchToDismissViewIsOn = NO;
    self.view = theView;
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


#pragma mark - Bit left

- (void)updateBitLeft
{
    NSString *string = [NSString stringWithFormat:@"%i", [self lengthLeft]];
    self.bitLeft.text = string;
}

- (NSInteger)lengthLeft
{
    NSInteger length;
    NSInteger left;
    switch (self.myNewView.sectionNo) {
        case 0:
            // For context
            length = [self.myContextView.text length];
            left = 300 - length;
            return left;
        case 1:
            // For target
            length = [self.myTargetView.text length];
            left = 30 - length;
            return left;
        case 2:
            // For translation
            length = [self.myTranslationView.text length];
            left = 30 - length;
            return left;
        case 3:
            // For detail
            length = [self.myDetailView.text length];
            left = 600 - length;
            return left;
    }
    // Return a large number to indicate an error.
    left = 10000;
    return left;
}

#pragma mark - textViewDelegate

- (NSInteger)getSectionNo:(UITextView *)textView
{
    return [self.myNewView.textFields indexOfObject:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // Make sure textView in editing is on top of the screen.
    // This senario only happens when user taps in a non current top input box.
    NSInteger n = [self getSectionNo:textView];
    if (self.myNewView.sectionNo != n) {
        self.myNewView.sectionNo = n;
    }
    if (self.myNewView.contentOffset.y != [self.myNewView getUpperStop:[self getSectionNo:textView]]) {
        [self.myNewView setContentOffset:CGPointMake(0.0f, [self.myNewView getUpperStop:n]) animated:YES];
    }
    [self.textBefore setString:textView.text];
    [self updateBitLeft];
    if (self.bitLeft.hidden == YES) {
        self.bitLeft.hidden = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger maxLength;
    switch (self.myNewView.sectionNo) {
        case 0:
            maxLength = 300;
            break;
        case 1:
            maxLength = 60;
            break;
        case 2:
            maxLength = 60;
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

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateBitLeft];
}

#pragma mark - remove blank spaces at the beginning and end of any input
- (NSString *)trimInput:(NSString *)text
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [text stringByTrimmingCharactersInSet:whitespace];
    return trimmed;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TVKeyboard.m
//  testView
//
//  Created by Liwei Zhang on 2014-06-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVKeyboard.h"
#import "TVView.h"

@implementation TVKeyboard

// This is the base view to put the floating views on.
@synthesize keyboardSlot;

@synthesize tempSize;
@synthesize delegate;
@synthesize viewWithButtomFloating;
@synthesize keyboardAndExtraHeight;
@synthesize keyboardIsForBottomInput;
@synthesize keyboardIsShown;
@synthesize touchToDismissKeyboardIsOff;
@synthesize viewToDismissKeyboard;

- (void)setup
{
    // Add keyboardSlot
    self.keyboardSlot = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, self.tempSize.height - 44.0f, self.tempSize.width, 44.0f)];
    // Make the contentSize large enough for different keyboard size, such as English or Chinese. Chinese input has an extra row above the basic keyboard to show the word candidates.
    self.keyboardSlot.contentSize = CGSizeMake(self.tempSize.width, self.tempSize.height * 2.0f);
    self.keyboardSlot.scrollEnabled = NO;
    self.keyboardSlot.delegate = self.delegate;
}

#pragma mark - Keyboard & inputField movement sync

// Register for keyboard notification
- (void)registerForKeyboardNotifications
{
    
    //     [[NSNotificationCenter defaultCenter] addObserver:self
    //     selector:@selector(willShow:)
    //     name:UIKeyboardWillShowNotification object:nil];
    //
    //     [[NSNotificationCenter defaultCenter] addObserver:self
    //     selector:@selector(didShow:)
    //     name:UIKeyboardDidShowNotification object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    //
    //     [[NSNotificationCenter defaultCenter] addObserver:self
    //     selector:@selector(didHide:)
    //     name:UIKeyboardDidHideNotification object:nil];
    //
    //
    //     [[NSNotificationCenter defaultCenter] addObserver:self
    //     selector:@selector(didChange:)
    //     name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Increase the contentSize bottom to make the view able to scroll down
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.viewToDismissKeyboard endEditing:YES];
    // Trim text first
    NSString *trimmedText = [self trimInput:textField.text];
    textField.text = trimmedText;
}

// Remove blank spaces at the beginning and end of any input
- (NSString *)trimInput:(NSString *)text
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [text stringByTrimmingCharactersInSet:whitespace];
    return trimmed;
}

- (void)keyboardWillChange:(NSNotification *)aNotification
{
    // Change event will be called very time
    NSDictionary* info = [aNotification userInfo];
    // Target at the end value instead of the begin value, end value is the one the keyboard is targeting on. keyboard's size won't change, so use the origin to track the movement of the keyboard
    CGPoint kbOrigin = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    // Use screen size instead of the application's, coz keyboard is on UIScreen which covers the status bar as well
    // Change keyboardSlot's height when keyboard is triggered first time
    if (self.keyboardSlot.frame.size.height == 44.0f) {
        // KeyboardSlot should move up from the bottom
        CGFloat newKeyboardSlotHeight = [UIScreen mainScreen].bounds.size.height - (kbOrigin.y - self.viewWithButtomFloating.frame.size.height);
        TVView *view = (TVView *)[UIApplication sharedApplication].keyWindow.rootViewController.view;
//        view.keyboardAndExtraHeight = newKeyboardSlotHeight;
//        view.keyboardIsForBottomInput = YES;
//        view.keyboardIsShown = YES;
//        view.touchToDismissKeyboardIsOff = NO;
        self.keyboardSlot.frame = CGRectMake(0.0f, self.tempSize.height - newKeyboardSlotHeight, self.tempSize.width, self.tempSize.height - kbOrigin.y + 44.0f);
        self.viewWithButtomFloating.frame = CGRectMake(0.0f, self.keyboardSlot.frame.size.height - 44.0f, self.keyboardSlot.frame.size.width, 44.0f);
        [self.keyboardSlot.superview bringSubviewToFront:self.keyboardSlot];
        [self.keyboardSlot setContentOffset:CGPointMake(0.0f, self.keyboardSlot.frame.size.height - 44.0f) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self.keyboardSlot setContentOffset:CGPointZero animated:YES];
    TVView *view = (TVView *)[UIApplication sharedApplication].keyWindow.rootViewController.view;
//    view.keyboardIsForBottomInput = NO;
//    view.keyboardIsShown = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.keyboardSlot]) {
        
        if (self.keyboardSlot.contentOffset.y == 0.0f) {
            // Just moved to bottom
            // Shrink keyboardSlot after the scrolling animation finished
            self.keyboardSlot.frame = CGRectMake(0.0f, self.tempSize.height - 44.0f, self.tempSize.width, 44.0f);
            self.viewWithButtomFloating.frame = CGRectMake(0.0f, 0.0f, self.tempSize.width, 44.0f);
        } else {
            // Just moved to top
        }
    }
}

- (void)dismissKeyboard
{
    [self.viewToDismissKeyboard endEditing:YES];
    [self.keyboardSlot setContentOffset:CGPointZero animated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Keyboard position test:
// - (void)willShow:(NSNotification*)aNotification
// {
// NSDictionary* info = [aNotification userInfo];
//
// CGSize bkbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
// NSLog(@"bwillShowY %f", [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y);
//
//
// CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
// NSLog(@"willShowY %f", [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y);
// NSLog(@"bwillShow %f", bkbSize.height);
// NSLog(@"willShow %f", kbSize.height);
// }
//
// - (void)didShow:(NSNotification*)aNotification
// {
// NSDictionary* info = [aNotification userInfo];
//
// CGSize bkbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
// NSLog(@"bdidShowY %f", [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y);
//
//
// CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
// NSLog(@"didShowY %f", [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y);
// NSLog(@"bdidShow %f", bkbSize.height);
// NSLog(@"didShow %f", kbSize.height);
// }
//
// - (void)willHide:(NSNotification*)aNotification
// {
// NSDictionary* info = [aNotification userInfo];
//
// CGSize bkbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
// NSLog(@"bwillHideY %f", [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y);
//
//
// CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
// NSLog(@"willHideY %f", [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y);
// NSLog(@"bwillHide %f", bkbSize.height);
// NSLog(@"willHide %f", kbSize.height);
// }
//
// - (void)didHide:(NSNotification*)aNotification
// {
// NSDictionary* info = [aNotification userInfo];
//
// CGSize bkbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
// NSLog(@"bdidHideY %f", [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y);
//
//
// CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
// NSLog(@"didHideY %f", [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y);
// NSLog(@"bdidHide %f", bkbSize.height);
// NSLog(@"didHide %f", kbSize.height);
// }

// - (void)willChange:(NSNotification*)aNotification
// {
// NSDictionary* info = [aNotification userInfo];
//
// CGSize bkbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
// NSLog(@"bwwillChangeY %f", [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y);
//
//
// CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
// NSLog(@"willChangeY %f", [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y);
// NSLog(@"bwillChange %f", bkbSize.height);
// NSLog(@"willChange %f", kbSize.height);
// }
//
// - (void)didChange:(NSNotification*)aNotification
// {
// NSDictionary* info = [aNotification userInfo];
//
// CGSize bkbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
// NSLog(@"bdidChangeY %f", [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y);
//
//
// CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
// NSLog(@"didChangeY %f", [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y);
// NSLog(@"bdidChange %f", bkbSize.height);
// NSLog(@"didChange %f", kbSize.height);
// }

@end

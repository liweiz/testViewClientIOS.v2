//
//  TVNewBaseViewController.h
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVCard.h"
#import "TVScrollViewVertical.h"
#import "TVRootViewCtlBox.h"

@interface TVNewBaseViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, CAMediaTiming>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) TVScrollViewVertical *myNewView;
@property (strong, nonatomic) UITextView *myContextView;
@property (strong, nonatomic) UITextView *myTargetView;
@property (strong, nonatomic) UITextView *myTranslationView;
@property (strong, nonatomic) UITextView *myDetailView;

@property (strong, nonatomic) TVRootViewCtlBox *box;

// stop points for vertical scrolling
//@property (assign, nonatomic) CGFloat stopCamContext;
@property (assign, nonatomic) CGFloat stopContextTarget;
@property (assign, nonatomic) CGFloat stopTargetTranslation;
@property (assign, nonatomic) CGFloat stopTranslationDetail;

// these two positions are for direction identification
@property (assign, nonatomic) CGFloat startPosition;
@property (assign, nonatomic) CGFloat targetPosition;

@property (assign, nonatomic) CGFloat dragStartPoint;

// temp pre-filled fields' content
@property (strong, nonatomic) NSMutableString *tempContext;
@property (strong, nonatomic) NSMutableString *tempTarget;
@property (strong, nonatomic) NSMutableString *tempTranslation;
@property (strong, nonatomic) NSMutableString *tempDetail;

@property (strong, nonatomic) TVCard *cardToUpdate;

// This is for showing the left characters available for inputting 
@property (strong, nonatomic) UILabel *bitLeft;
// To compare if the result of an input action is diferent from the content before
@property (strong, nonatomic) NSMutableString *textBefore;

- (BOOL)checkIfTargetIsInContext;

@end

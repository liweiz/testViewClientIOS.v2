//
//  TVNewBaseViewController.h
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVCard.h"


@interface TVNewBaseViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, CAMediaTiming>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIScrollView *myNewView;
@property (strong, nonatomic) UITextView *myContextView;
@property (strong, nonatomic) UITextView *myTargetView;
@property (strong, nonatomic) UITextView *myTranslationView;
@property (strong, nonatomic) UITextView *myDetailView;
@property (assign, nonatomic) CGSize tempSize;
@property (strong, nonatomic) UIView *myConfirmationView;

// stop points for vertical scrolling
@property (assign, nonatomic) CGFloat stopCamContext;
@property (assign, nonatomic) CGFloat stopContextTarget;
@property (assign, nonatomic) CGFloat stopTargetTranslation;
@property (assign, nonatomic) CGFloat stopTranslationDetail;

// these two position is for direction identification
@property (assign, nonatomic) CGFloat startPosition;
@property (assign, nonatomic) CGFloat targetPosition;

@property (assign, nonatomic) NSInteger sectionNo;
@property (assign, nonatomic) Boolean editOn;
@property (assign, nonatomic) Boolean contextEditOn;
@property (assign, nonatomic) Boolean targetEditOn;
@property (assign, nonatomic) Boolean translationEditOn;
@property (assign, nonatomic) Boolean detailEditOn;
@property (assign, nonatomic) CGFloat dragStartPoint;

// temp pre-filled fields' content
@property (strong, nonatomic) NSMutableString *tempContext;
@property (strong, nonatomic) NSMutableString *tempTarget;
@property (strong, nonatomic) NSMutableString *tempTranslation;
@property (strong, nonatomic) NSMutableString *tempDetail;

@property (strong, nonatomic) TVCard *cardToUpdate;

@property (strong, nonatomic) UILabel *myCreate;
@property (strong, nonatomic) UITapGestureRecognizer *toCreateTap;
@property (strong, nonatomic) UILabel *myUpdate;
@property (strong, nonatomic) UITapGestureRecognizer *toUpdateTap;

@property (strong, nonatomic) UILabel *cancelView;
@property (strong, nonatomic) UITapGestureRecognizer *cancelSaveTap;
@property (strong, nonatomic) UITapGestureRecognizer *tapDetector;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchToSaveGesture;
@property (strong, nonatomic) NSArray *sectionList;


@property (strong, nonatomic) UILongPressGestureRecognizer *toTagSelectionGesture;

// 0: tagsSelection 1: new 2: confirmation
@property (assign, nonatomic) NSInteger currentLayer;
// This is for showing the left characters available for inputting 
@property (strong, nonatomic) UILabel *bitLeft;
// To compare if the result of an input action is diferent from the content before
@property (strong, nonatomic) NSString *textBefore;


- (BOOL)checkIfTargetIsInContext;

@end

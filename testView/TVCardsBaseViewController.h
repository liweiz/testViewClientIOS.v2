//
//  TVCardsBaseViewController.h
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVCardsViewController.h"
#import "TVCardsTopViewController.h"
#import "TVCellLabelContext.h"
#import "TVCellLabelTarget.h"
#import "TVCellLabelTranslation.h"
#import "TVCellLabelDetail.h"
#import "TVCard.h"
#import "TVSortCellView.h"
#import "TVLangPickViewController.h"

@interface TVCardsBaseViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) TVCardsViewController *tvCardsViewController;
@property (strong, nonatomic) TVUser *user;

@property (strong, nonatomic) UIView *tvCardsMenuBaseSupportView;
@property (strong, nonatomic) UIView *tvCardsMenuBaseView;
@property (strong, nonatomic) UIScrollView *tvCardsSlotView;
@property (assign, nonatomic) CGSize tempSize;
@property (strong, nonatomic) TVCardsTopViewController *tvCardsTopViewController;
@property (strong, nonatomic) TVLangPickViewController *langPickViewController;

@property (assign, nonatomic) BOOL sortTabAtFront;
@property (assign, nonatomic) BOOL tagTabAtFront;
@property (assign, nonatomic) BOOL othersTabAtFront;
@property (assign, nonatomic) BOOL targetTop;
@property (assign, nonatomic) BOOL targetBottom;
@property (assign, nonatomic) BOOL scrollSyncOn;

// Cell expand/collapse management
@property (assign, nonatomic) CGRect cellRect;
@property (assign, nonatomic) TVCard *cardSelected;
@property (assign, nonatomic) CGFloat shouldIncreaseHeightBy;
@property (strong, nonatomic) UIScrollView *extraCardIn;
@property (strong, nonatomic) UIScrollView *extraCardOut;

@property (strong, nonatomic) TVCellLabelTarget *labelTarget;
@property (strong, nonatomic) TVCellLabelTranslation *labelTranslation;
@property (strong, nonatomic) TVCellLabelDetail *labelDetail;
@property (strong, nonatomic) TVCellLabelContext *labelContext;

@property (strong, nonatomic) UIView *multiTab;
@property (strong, nonatomic) UIView *contactTab;
@property (strong, nonatomic) UIView *tagTab;
@property (strong, nonatomic) UIView *othersTab;
@property (strong, nonatomic) UIView *cardTab;
@property (strong, nonatomic) UIView *changeTagTab;
@property (strong, nonatomic) UIView *shareTab;
@property (strong, nonatomic) UIView *allTab;
@property (strong, nonatomic) UIView *singleTab;
@property (strong, nonatomic) UIView *singleTagTab;
@property (strong, nonatomic) UIView *multiTagTab;

@property (strong, nonatomic) UIScrollView *leftOneBaseScrollView;
@property (strong, nonatomic) UIScrollView *leftTwoBaseScrollView;
@property (strong, nonatomic) UIScrollView *leftThreeBaseScrollView;
@property (strong, nonatomic) UIScrollView *leftFourBaseScrollView;

@property (strong, nonatomic) UITapGestureRecognizer *multiTap;
@property (strong, nonatomic) UITapGestureRecognizer *contactTap;
@property (strong, nonatomic) UITapGestureRecognizer *tagTap;
@property (strong, nonatomic) UITapGestureRecognizer *othersTap;
@property (strong, nonatomic) UITapGestureRecognizer *cardTap;
@property (strong, nonatomic) UITapGestureRecognizer *changeTagTap;
@property (strong, nonatomic) UITapGestureRecognizer *shareTap;
@property (strong, nonatomic) UITapGestureRecognizer *allTap;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (strong, nonatomic) UITapGestureRecognizer *singleTagTap;
@property (strong, nonatomic) UITapGestureRecognizer *multiTagTap;

@property (strong, nonatomic) UIView *contactView;
@property (strong, nonatomic) UIView *othersView;
// Here: 0: no alphabet sorting 1: alphabet ascending 2: alphabet descending
@property (assign, nonatomic) NSInteger byCellTitleAlphabetCode;
// Here: 0: no timeCollected sorting 1: timeCollected ascending 2: timeCollected descending
@property (assign, nonatomic) NSInteger byTimeCollectedCode;

// tagView triggered by tagTab is managedObject sourced while in multiCards mode, it is array sourced.

@property (strong, nonatomic) UIView *tagTableBar;
@property (strong, nonatomic) UITextField *createTagInput;
@property (strong, nonatomic) UIView *multiTagButton;
@property (strong, nonatomic) NSFetchRequest *fetchRequestTags;


@property (assign, nonatomic) BOOL horizontalLockOn;

@property (strong, nonatomic) NSArray *sortOptions;
@property (strong, nonatomic) NSMutableArray *tagOptions;
@property (strong, nonatomic) NSArray *othersOptions;
@property (strong, nonatomic) NSDictionary *frontToView;
@property (strong, nonatomic) NSTimer *hideCancelTimer;

@property (assign, nonatomic) CGFloat nowY;
@property (assign, nonatomic) CGFloat lastY;

@property (strong, nonatomic) TVSortCellView *byAlphabet;
@property (strong, nonatomic) TVSortCellView *byTimeCollected;
@property (strong, nonatomic) UIView *sortBaseView;
@property (strong, nonatomic) NSArray *cardSortDescriptors;


@property (assign, nonatomic) NSInteger tabNoAccordingToSharingFunction;

@end

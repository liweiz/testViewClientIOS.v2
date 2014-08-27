//
//  TVRootViewController.h
//  testView
//
//  Created by Liwei on 2013-07-22.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "TVCardsViewController.h"
#import "TVCard.h"
//#import "TVView.h"
#import "TVUser.h"
#import "TVRootViewCtlBox.h"
//#import "TVSearchBaseViewController.h"
//#import "TVCardsBaseViewController.h"
#import "TVNewBaseViewController.h"
#import "TVTableViewController.h"

@interface TVContentRootViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) TVTableViewController *myCardsViewController;
@property (nonatomic, strong) TVNewBaseViewController *myNewBaseViewController;
//@property (nonatomic, strong) TVSearchBaseViewController *mySearchViewController;

@property (strong, nonatomic) NSString *draftDirectory;
@property (strong, nonatomic) NSString *draftPath;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSDictionary *lastSavedDraft;
@property (assign, nonatomic) BOOL newDraftThisTime;
@property (assign, nonatomic) BOOL searchViewIncluded;
@property (strong, nonatomic) NSTimer *draftAutoSaveTimer;

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (assign, nonatomic) CGFloat centerOffsetX;
@property (strong, nonatomic) UIScrollView *myRootView;

@property (assign, nonatomic) NSInteger newViewPosition;
@property (assign, nonatomic) NSInteger cardsViewPosition;
@property (assign, nonatomic) NSInteger searchViewPosition;

@property (strong, nonatomic) TVCard *cardToUpdate;

@property (strong, nonatomic) NSTimer *scanForNew;
@property (strong, nonatomic) NSTimer *scanForChange;

@property (strong, nonatomic) NSFetchRequest *userFetchRequest;
@property (strong, nonatomic) NSFetchedResultsController *userFetchedResultsController;

@end

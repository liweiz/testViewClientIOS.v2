//
//  TVRootViewController.m
//  testView
//
//  Created by Liwei on 2013-07-22.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVContentRootViewController.h"
#import "TVCard.h"

#import <Foundation/Foundation.h>
//#import "TVCardsViewController.h"
#import "TVView.h"
//#import "TVSearchBaseViewController.h"
#import "TVAppDelegate.h"
//#import "TVCardsBaseViewController.h"
//#import "TVNewBaseViewController.h"


@interface TVContentRootViewController ()

@end

@implementation TVContentRootViewController

//@synthesize myCardsBaseViewController, myNewBaseViewController, mySearchViewController;
@synthesize box, cardToUpdate;
@synthesize centerOffsetX, myRootView, newViewPosition, cardsViewPosition, searchViewPosition;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize myNewBaseViewController;
@synthesize scanForNew, scanForChange, draftDirectory, draftPath, fileManager, lastSavedDraft, newDraftThisTime, draftAutoSaveTimer, userFetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.newViewPosition = 0;
        self.cardsViewPosition = 1;
        self.searchViewPosition = 2;
    }
    return self;
}

- (void)loadView
{
    self.myRootView = [[UIScrollView alloc] initWithFrame:self.box.appRect];
    CGSize theContentSize = CGSizeMake(self.box.appRect.size.width * 3, self.box.appRect.size.height);
    self.myRootView.contentSize = theContentSize;
    self.myRootView.bounces = NO;
    self.myRootView.showsHorizontalScrollIndicator = YES;
    self.myRootView.delegate = self;
    self.myRootView.pagingEnabled = YES;
    self.myRootView.tag = 555;

    self.view = [[TVView alloc] initWithFrame:self.box.appRect];
    [self.view addSubview:self.myRootView];
    self.centerOffsetX = self.myRootView.contentSize.width / 2 - self.box.appRect.size.width / 2;

    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Add cards view
    
    // Get user's settings
    
//    self.myCardsBaseViewController = [[TVCardsBaseViewController alloc] init];
//    self.myCardsBaseViewController.managedObjectContext = self.managedObjectContext;
//    self.myCardsBaseViewController.managedObjectModel = self.managedObjectModel;
//    self.myCardsBaseViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
//    self.myCardsBaseViewController.user = self.user;
//    self.myCardsBaseViewController.tabNoAccordingToSharingFunction = 2;
//    
//    [self addChildViewController:myCardsBaseViewController];
//    [self.myRootView addSubview:self.myCardsBaseViewController.view];
//    [self.myCardsBaseViewController didMoveToParentViewController:self];
    
    // Add new view
    self.myNewBaseViewController = [[TVNewBaseViewController alloc] initWithNibName:nil bundle:nil];
    self.myNewBaseViewController.managedObjectContext = self.managedObjectContext;
    self.myNewBaseViewController.managedObjectModel = self.managedObjectModel;
    self.myNewBaseViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
    self.myNewBaseViewController.box = self.box;
    [self addChildViewController:myNewBaseViewController];
    [self.myRootView addSubview:self.myNewBaseViewController.view];
    [self.myNewBaseViewController didMoveToParentViewController:self];
    
    // Add search view
//    self.mySearchViewController = [[TVSearchBaseViewController alloc] init];
//    [self addChildViewController:mySearchViewController];
//    [self.myRootView addSubview:self.mySearchViewController.view];
//    [self.mySearchViewController didMoveToParentViewController:self];
    
    [self.myRootView setContentOffset:CGPointMake(self.centerOffsetX, 0) animated:NO];
    
    // Config draft file info
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO);
    self.draftDirectory = [pathArray objectAtIndex:0];
    NSString *fileName = @"cardDraftWithTagSelection.plist";
    self.draftPath = [[self.draftDirectory stringByAppendingPathComponent:fileName] stringByExpandingTildeInPath];
    self.fileManager = [NSFileManager defaultManager];
    
    // Make sure the file exists and there is a dictionary in memory for quick comparison.
    if (![self.fileManager fileExistsAtPath:self.draftPath]) {
        // Initiate empty draft in memory and create the empty file
        self.lastSavedDraft = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"context", @"", @"target", @"", @"translation", @"", @"detail", nil];
        [self.lastSavedDraft writeToFile:self.draftPath atomically:YES];
    } else {
        // Load the last daft into memory to stand for a place for future quick comparison
        self.lastSavedDraft = [NSDictionary dictionaryWithContentsOfFile:self.draftPath];
        // Fill the info of lastSavedDraft to the corresponding fields
        for (NSString *key in self.lastSavedDraft) {
            NSString *text = [self.lastSavedDraft valueForKey:key];
            if ([key isEqualToString:@"context"]) {
                self.myNewBaseViewController.myContextView.text = text;
            }
            if ([key isEqualToString:@"target"]) {
                self.myNewBaseViewController.myTargetView.text = text;
            }
            if ([key isEqualToString:@"translation"]) {
                self.myNewBaseViewController.myTranslationView.text = text;
            }
            if ([key isEqualToString:@"detail"]) {
                self.myNewBaseViewController.myDetailView.text = text;
            }
        }
    }
}

// When user coming from card edit mode, there should be two done buttons. One for save to the existing card and another for save as a new card.

/*
 There are two edit scenes:
 1. Card with tag
 2. Tag only
 A save action in either one will trigger performFetch immediately. It will refresh and sync the lastest information from the persistentStore.
 Prior to the save action, all the edited information is stayed on its corresponding managedObjjectContext for draft.
 */

# pragma mark - Draft autosave
/*
 Draft autosave. Card only.
 Only one or no draft exists at any given time. So a newly created draft means the old one will be deleted if there is any. We don't need to actually delete the file but to reset all the values to empty.
 How to trigger new draft:
 1. Coming from SearchView with at least translation selected, which should be on deail layer to suggest a translation is selected.
 2. Coming from listView with a card expanded. This leads to card edit mode.
 3. If context/target/translation/detail are all empty and anyone of those are in edit mode and any of those field is not empty anymore, the first autosave after 4 seconds will create a new draft. So the new draft detector will check all four fields every 10 seconds as long as any of them is in edit mode till new draft is created.
 Once new draft is triggered, all 4 fields will be updated immediately to cardDraft. Once being triggered, the draft will be saved every 10 seconds. A successful save will start a new draft right away.
 */

// When new draft is triggered, create a NSDictionary obj and save it as a local file
- (void)updateDraft
{
    // All the info read from textField/textView directly.
    if ([self.lastSavedDraft valueForKey:@"context"] == self.myNewBaseViewController.myContextView.text &&
        [self.lastSavedDraft valueForKey:@"target"] == self.myNewBaseViewController.myTargetView.text &&
        [self.lastSavedDraft valueForKey:@"translation"] == self.myNewBaseViewController.myTranslationView.text &&
        [self.lastSavedDraft valueForKey:@"detail"] == self.myNewBaseViewController.myDetailView.text) {
        // Don't save to file since no change occurs.
    } else {
        // Destory the current one, create an updated one and write to the plist.
        self.lastSavedDraft = nil;
        self.lastSavedDraft = [NSDictionary dictionaryWithObjectsAndKeys:self.myNewBaseViewController.myContextView.text, @"context", self.myNewBaseViewController.myTargetView.text, @"target", self.myNewBaseViewController.myTranslationView.text, @"translation", self.myNewBaseViewController.myDetailView.text, @"detail", nil];
        [self.lastSavedDraft writeToFile:self.draftPath atomically:YES];
    }
}


- (void)dismissNewKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - swipe loop behavior

- (CGFloat)viewStackLoopAdd:(CGFloat)position
{
    // At any given moment, 0 => the left view, 1 => the middle one, 2 => the right one
    // The initial position is 0, 1, 2, see loadView
    if (position >= 2) {
        position = 0;
    } else {
        position ++;
    }
    return position;
}

- (CGFloat)viewStackLoopMinus:(CGFloat)position
{
    // The initial position is 0, 1, 2, see loadView
    if (position <= 0) {
        position = 2;
    } else {
        position --;
    }
    return position;
}

// Once newView is reached, a new managed object will be used.
// First check if there is a new one already. If not, generate one.
// Secondly, check if autofilled fields need to be updated. If yes, update it.
/*
- (void)getNewReady
{
    if (self.newViewPosition == 1) {
        if () {
 
        }
    }
}
 */

- (CGRect)updateFrame:(CGFloat)position
{
    CGRect updatedFrame = CGRectMake(self.box.appRect.size.width * position, 0, self.box.appRect.size.width, self.box.appRect.size.height);
    return updatedFrame;
}

- (void)recenter:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == self.box.appRect.size.width * 2) {
        // Get the new position before recentering contentview since contentOffset will change after recentering
        // Dismiss keyboard after leaving New
        if (self.newViewPosition == 1) {
            [self.myNewBaseViewController.view endEditing:YES];
        }
        
        if (scrollView.contentOffset.x == 0) {
            self.newViewPosition = [self viewStackLoopAdd:self.newViewPosition];
            self.cardsViewPosition = [self viewStackLoopAdd:self.cardsViewPosition];
            self.searchViewPosition = [self viewStackLoopAdd:self.searchViewPosition];
        } else if (scrollView.contentOffset.x == self.box.appRect.size.width * 2) {
            self.newViewPosition = [self viewStackLoopMinus:self.newViewPosition];
            self.cardsViewPosition = [self viewStackLoopMinus:self.cardsViewPosition];
            self.searchViewPosition = [self viewStackLoopMinus:self.searchViewPosition];
        }
        
        // Recenter the contentview
        [scrollView setContentOffset:CGPointMake(self.centerOffsetX, 0.0f) animated:NO];
        
        // Update the frame
        self.myNewBaseViewController.view.frame = [self updateFrame:self.newViewPosition];
//        self.myCardsBaseViewController.view.frame = [self updateFrame:self.cardsViewPosition];
//        self.mySearchViewController.view.frame = [self updateFrame:self.searchViewPosition];
        
        // Reset sectionNo to 1
        // Show context at top with keyboard when arriving at New
        self.myNewBaseViewController.myNewView.contentOffset = CGPointMake(0.0f, 0.0f);
        self.myNewBaseViewController.myNewView.sectionNo = 0;
        if (self.newViewPosition == 1) {
            [self.myNewBaseViewController.myContextView becomeFirstResponder];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self recenter:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (targetContentOffset->x == self.myRootView.contentSize.width / 3) {
        // Current page will not change

    }
    else if (self.newViewPosition == 0 && targetContentOffset->x == 0.0) {
        // CardsView is shown and will show newView
//        if ([[self.myCardsBaseViewController.tvCardsViewController.tableView indexPathsForSelectedRows] count] > 0) {
//            NSIndexPath *cardSelectionIndexPath = [self.myCardsBaseViewController.tvCardsViewController.tableView indexPathForSelectedRow];
//            self.myNewBaseViewController.cardToUpdate = [self.myCardsBaseViewController.tvCardsViewController.arrayDataSource objectAtIndex:cardSelectionIndexPath.row];
//            [self refillNewContentFromCard:self.myNewBaseViewController.cardToUpdate];
//            [self updateDraft];
//        }
        // Timer is triggered from entering the newView. At that point, updateDraft right away and fire timer every 6 secs. If user leave the newView, timer will be invalidated immediately and updateDraft will be executed at the same time.
        if (!self.draftAutoSaveTimer) {
            self.draftAutoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(updateDraft) userInfo:nil repeats:YES];
        }
        if (!self.draftAutoSaveTimer.isValid) {
            [[NSRunLoop currentRunLoop] addTimer:self.draftAutoSaveTimer forMode:NSDefaultRunLoopMode];
        }
    }
    else if (self.newViewPosition == 2 && targetContentOffset->x == self.myRootView.contentSize.width * 2 / 3) {
        // searchView is shown and will show newView
        
    }
    else {
        // Will leave newView
        self.myNewBaseViewController.cardToUpdate = nil;
        [self.draftAutoSaveTimer invalidate];
        [self updateDraft];
    }
}

- (void)refillNewContentFromCard:(TVCard *)card
{
    self.myNewBaseViewController.myContextView.text = nil;
    self.myNewBaseViewController.myTargetView.text = nil;
    self.myNewBaseViewController.myTranslationView.text = nil;
    self.myNewBaseViewController.myDetailView.text = nil;
    self.myNewBaseViewController.myContextView.text = card.context;
    self.myNewBaseViewController.myTargetView.text = card.target;
    self.myNewBaseViewController.myTranslationView.text = card.translation;
    self.myNewBaseViewController.myDetailView.text = card.detail;
}

- (void)emptyContentInNewCard
{
    self.myNewBaseViewController.myContextView.text = nil;
    self.myNewBaseViewController.myTargetView.text = nil;
    self.myNewBaseViewController.myTranslationView.text = nil;
    self.myNewBaseViewController.myDetailView.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

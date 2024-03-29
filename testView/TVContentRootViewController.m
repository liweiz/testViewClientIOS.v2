//
//  TVRootViewController.m
//  testView
//
//  Created by Liwei on 2013-07-22.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVContentRootViewController.h"
#import "NSObject+DataHandler.h"
#import "TVCard.h"
#import "TVQueueElement.h"
#import "TVCRUDChannel.h"
#import <Foundation/Foundation.h>
//#import "TVCardsViewController.h"
//#import "TVSearchBaseViewController.h"
#import "TVAppDelegate.h"
//#import "TVCardsBaseViewController.h"
//#import "TVNewBaseViewController.h"


@interface TVContentRootViewController ()

@end

@implementation TVContentRootViewController

//@synthesize mySearchViewController;
@synthesize box, cardToUpdate;
@synthesize centerOffsetX, myRootView, newViewPosition, cardsViewPosition, searchViewPosition;
@synthesize myCardsViewController;
@synthesize myNewBaseViewController;
@synthesize searchViewIncluded;
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
    self.view = [[UIView alloc] initWithFrame:[TVRootViewCtlBox sharedBox].appRect];
    self.myRootView = [[UIScrollView alloc] initWithFrame:[TVRootViewCtlBox sharedBox].appRect];
    NSInteger i;
    if (self.searchViewIncluded) {
        i = 3;
        self.centerOffsetX = self.myRootView.contentSize.width / 2 - [TVRootViewCtlBox sharedBox].appRect.size.width / 2;
        self.myRootView.delegate = self;
    } else {
        i = 2;
    }
    CGSize theContentSize = CGSizeMake([TVRootViewCtlBox sharedBox].appRect.size.width * i, [TVRootViewCtlBox sharedBox].appRect.size.height);
    self.myRootView.contentSize = theContentSize;
    self.myRootView.bounces = NO;
    self.myRootView.showsVerticalScrollIndicator = NO;
    self.myRootView.showsHorizontalScrollIndicator = NO;
    self.myRootView.pagingEnabled = YES;
    self.myRootView.tag = 555;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.myRootView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Start a new sync cycle everytime content controller launches.
    [self startNewSyncCycle:[TVRootViewCtlBox sharedBox] byUser:NO];
    // Add cards view
    
    // Get user's settings
    
    self.myCardsViewController = [[TVTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.myCardsViewController.tableEntityName = @"TVCard";
    [self addChildViewController:self.myCardsViewController];
    [self.myRootView addSubview:self.myCardsViewController.view];
    [self.myCardsViewController didMoveToParentViewController:self];
    
    // Add new view
    self.myNewBaseViewController = [[TVNewBaseViewController alloc] initWithNibName:nil bundle:nil];
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
                self.myNewBaseViewController.myNewViewCtl.myContextView.text = text;
            }
            if ([key isEqualToString:@"target"]) {
                self.myNewBaseViewController.myNewViewCtl.myTargetView.text = text;
            }
            if ([key isEqualToString:@"translation"]) {
                self.myNewBaseViewController.myNewViewCtl.myTranslationView.text = text;
            }
            if ([key isEqualToString:@"detail"]) {
                self.myNewBaseViewController.myNewViewCtl.myDetailView.text = text;
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
    if ([self.lastSavedDraft valueForKey:@"context"] == self.myNewBaseViewController.myNewViewCtl.myContextView.text &&
        [self.lastSavedDraft valueForKey:@"target"] == self.myNewBaseViewController.myNewViewCtl.myTargetView.text &&
        [self.lastSavedDraft valueForKey:@"translation"] == self.myNewBaseViewController.myNewViewCtl.myTranslationView.text &&
        [self.lastSavedDraft valueForKey:@"detail"] == self.myNewBaseViewController.myNewViewCtl.myDetailView.text) {
        // Don't save to file since no change occurs.
    } else {
        // Destory the current one, create an updated one and write to the plist.
        self.lastSavedDraft = nil;
        self.lastSavedDraft = [NSDictionary dictionaryWithObjectsAndKeys:self.myNewBaseViewController.myNewViewCtl.myContextView.text, @"context", self.myNewBaseViewController.myNewViewCtl.myTargetView.text, @"target", self.myNewBaseViewController.myNewViewCtl.myTranslationView.text, @"translation", self.myNewBaseViewController.myNewViewCtl.myDetailView.text, @"detail", nil];
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
    CGRect updatedFrame = CGRectMake([TVRootViewCtlBox sharedBox].appRect.size.width * position, 0, [TVRootViewCtlBox sharedBox].appRect.size.width, [TVRootViewCtlBox sharedBox].appRect.size.height);
    return updatedFrame;
}

- (void)recenter:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == [TVRootViewCtlBox sharedBox].appRect.size.width * 2) {
        // Get the new position before recentering contentview since contentOffset will change after recentering
        // Dismiss keyboard after leaving New
        if (self.newViewPosition == 1) {
            [self.myNewBaseViewController.view endEditing:YES];
        }
        
        if (scrollView.contentOffset.x == 0) {
            self.newViewPosition = [self viewStackLoopAdd:self.newViewPosition];
            self.cardsViewPosition = [self viewStackLoopAdd:self.cardsViewPosition];
            self.searchViewPosition = [self viewStackLoopAdd:self.searchViewPosition];
        } else if (scrollView.contentOffset.x == [TVRootViewCtlBox sharedBox].appRect.size.width * 2) {
            self.newViewPosition = [self viewStackLoopMinus:self.newViewPosition];
            self.cardsViewPosition = [self viewStackLoopMinus:self.cardsViewPosition];
            self.searchViewPosition = [self viewStackLoopMinus:self.searchViewPosition];
        }
        
        // Recenter the contentview
        [scrollView setContentOffset:CGPointMake(self.centerOffsetX, 0.0f) animated:NO];
        
        // Update the frame
        self.myNewBaseViewController.view.frame = [self updateFrame:self.newViewPosition];
        self.myCardsViewController.view.frame = [self updateFrame:self.cardsViewPosition];
//        self.mySearchViewController.view.frame = [self updateFrame:self.searchViewPosition];
        
        // Reset sectionNo to 1
        // Show context at top with keyboard when arriving at New
        self.myNewBaseViewController.myNewViewCtl.myNewView.contentOffset = CGPointMake(0.0f, 0.0f);
        self.myNewBaseViewController.myNewViewCtl.myNewView.sectionNo = 0;
        if (self.newViewPosition == 1) {
            [self.myNewBaseViewController.myNewViewCtl.myContextView becomeFirstResponder];
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
        self.myNewBaseViewController.myNewViewCtl.cardToUpdate = nil;
        [self.draftAutoSaveTimer invalidate];
        [self updateDraft];
    }
}

- (void)refillNewContentFromCard:(TVCard *)card
{
    self.myNewBaseViewController.myNewViewCtl.myContextView.text = nil;
    self.myNewBaseViewController.myNewViewCtl.myTargetView.text = nil;
    self.myNewBaseViewController.myNewViewCtl.myTranslationView.text = nil;
    self.myNewBaseViewController.myNewViewCtl.myDetailView.text = nil;
    self.myNewBaseViewController.myNewViewCtl.myContextView.text = card.context;
    self.myNewBaseViewController.myNewViewCtl.myTargetView.text = card.target;
    self.myNewBaseViewController.myNewViewCtl.myTranslationView.text = card.translation;
    self.myNewBaseViewController.myNewViewCtl.myDetailView.text = card.detail;
}

- (void)emptyContentInNewCard
{
    self.myNewBaseViewController.myNewViewCtl.myContextView.text = nil;
    self.myNewBaseViewController.myNewViewCtl.myTargetView.text = nil;
    self.myNewBaseViewController.myNewViewCtl.myTranslationView.text = nil;
    self.myNewBaseViewController.myNewViewCtl.myDetailView.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

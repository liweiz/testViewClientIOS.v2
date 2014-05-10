//
//  TVCardsBaseViewController.m
//  testView
//
//  Created by Liwei on 2013-07-25.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVCardsBaseViewController.h"
#import "TVCardsViewController.h"
#import "TVCardsTopViewController.h"
#import "UIViewController+sharedMethods.h"
#import "TVCardsViewController.h"
#import "TVTableViewCell.h"
#import "TVSortCellView.h"
#import "TVUser.h"


@interface TVCardsBaseViewController ()

@end

@implementation TVCardsBaseViewController

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

@synthesize tvCardsViewController, tempSize, tvCardsMenuBaseSupportView, tvCardsMenuBaseView, tvCardsSlotView, tvCardsTopViewController, nowY, lastY;
@synthesize multiTab, contactTab, tagTab, othersTab, shareTab, singleTab, changeTagTab, cardTab, allTab, targetTop, targetBottom;
@synthesize tagTap, cardTap, contactTap, othersTap, singleTap, changeTagTap, shareTap, allTap, multiTap;
@synthesize sortOptions, tagOptions, othersOptions, horizontalLockOn, scrollSyncOn;
@synthesize frontToView, tagTableBar, createTagInput, shouldIncreaseHeightBy, extraCardIn, extraCardOut;
@synthesize labelTarget, labelTranslation, labelDetail, labelContext, cardSelected, cellRect;
@synthesize leftOneBaseScrollView, leftTwoBaseScrollView, leftThreeBaseScrollView, leftFourBaseScrollView, singleTagTab, multiTagTab, singleTagTap, multiTagTap, byCellTitleAlphabetCode, byTimeCollectedCode, cardSortDescriptors, tabNoAccordingToSharingFunction, user, langPickViewController;


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
    CGRect tempRect = CGRectMake(tempSize.width, 0.0, tempSize.width, tempSize.height);
    self.tvCardsMenuBaseSupportView = [[UIView alloc] initWithFrame:tempRect];
    self.tvCardsMenuBaseSupportView.backgroundColor = [UIColor greenColor];
    self.view = self.tvCardsMenuBaseSupportView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Add cardsMenuBaseView for potential animation of the whole page
    self.tvCardsMenuBaseView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tempSize.width, tempSize.height)];
    self.tvCardsMenuBaseView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.tvCardsMenuBaseView];
    
    // Add slotView
    self.tvCardsSlotView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, tempSize.width, tempSize.height)];
    self.tvCardsSlotView.contentSize = CGSizeMake(tempSize.width, tempSize.height + 44.0 * 1);
    self.tvCardsSlotView.backgroundColor = [UIColor orangeColor];
    self.tvCardsSlotView.delegate = self;
    self.tvCardsSlotView.bounces = NO;
    self.tvCardsSlotView.scrollEnabled = NO;
    [self.view addSubview:self.tvCardsSlotView];
    
    // Add topView
    self.tvCardsTopViewController = [[TVCardsTopViewController alloc] init];
    [self addChildViewController:self.tvCardsTopViewController];
    [self.tvCardsSlotView addSubview:self.tvCardsTopViewController.view];
    [self.tvCardsTopViewController didMoveToParentViewController:self];
    
    self.tvCardsTopViewController.topView.backgroundColor = [UIColor grayColor];
    
    // Add leftOneBaseScrollView
    self.leftOneBaseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
    self.leftOneBaseScrollView.contentSize = CGSizeMake(self.leftOneBaseScrollView.frame.size.width * 2, self.leftOneBaseScrollView.frame.size.height);
    self.leftOneBaseScrollView.scrollEnabled = NO;
    [self.tvCardsTopViewController.topView addSubview:self.leftOneBaseScrollView];
    [self.leftOneBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:NO];
    
    // Add multiTab
    self.multiTab = [[UIView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
    self.multiTab.backgroundColor = [UIColor orangeColor];
    self.multiTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMultiCards)];
    [self.multiTab addGestureRecognizer:self.multiTap];
    [self.leftOneBaseScrollView addSubview:self.multiTab];
    
    // Add singleTab
    self.singleTab = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
    self.singleTab.backgroundColor = [UIColor whiteColor];
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToSingle)];
    [self.singleTab addGestureRecognizer:self.singleTap];
    [self.leftOneBaseScrollView addSubview:self.singleTab];
    
    // Add leftTwoBaseScrollView
    self.leftTwoBaseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
    self.leftTwoBaseScrollView.contentSize = CGSizeMake(self.leftTwoBaseScrollView.frame.size.width * 2, self.leftTwoBaseScrollView.frame.size.height);
    self.leftTwoBaseScrollView.scrollEnabled = NO;
    [self.tvCardsTopViewController.topView addSubview:self.leftTwoBaseScrollView];
    [self.leftTwoBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:NO];
    
    if (self.tabNoAccordingToSharingFunction >= 3) {
        // Add tagTab
        self.tagTab = [[UIView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
        self.tagTab.backgroundColor = [UIColor blackColor];
        self.tagTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTags)];
        [self.tagTab addGestureRecognizer:self.tagTap];
        [self.leftTwoBaseScrollView addSubview:self.tagTab];
        
        // Add changeTagTab
        self.changeTagTab = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
        self.changeTagTab.backgroundColor = [UIColor grayColor];
        self.changeTagTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showChangeTag)];
        [self.changeTagTab addGestureRecognizer:self.changeTagTap];
        [self.leftTwoBaseScrollView addSubview:self.changeTagTab];
        
        // Add leftThreeBaseScrollView
        self.leftThreeBaseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tempSize.width * 2 / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
        self.leftThreeBaseScrollView.contentSize = CGSizeMake(self.leftThreeBaseScrollView.frame.size.width * 2, self.leftThreeBaseScrollView.frame.size.height);
        self.leftThreeBaseScrollView.scrollEnabled = NO;
        [self.tvCardsTopViewController.topView addSubview:self.leftThreeBaseScrollView];
        [self.leftThreeBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:NO];
    }
    
    if (self.tabNoAccordingToSharingFunction == 4) {
        // Add contactTab
        self.contactTab = [[UIView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
        self.contactTab.backgroundColor = [UIColor greenColor];
        self.contactTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSort)];
        [self.contactTab addGestureRecognizer:self.contactTap];
        [self.leftThreeBaseScrollView addSubview:self.contactTab];
        
        // Add shareTab
        self.shareTab = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
        self.shareTab.backgroundColor = [UIColor blueColor];
        self.shareTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showShare)];
        [self.shareTab addGestureRecognizer:self.shareTap];
        [self.leftThreeBaseScrollView addSubview:self.shareTab];
    }
    
    // Add leftFourBaseScrollView
    if (self.tabNoAccordingToSharingFunction == 4) {
        self.leftFourBaseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tempSize.width * 3 / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
        self.leftFourBaseScrollView.contentSize = CGSizeMake(self.leftFourBaseScrollView.frame.size.width * 2, self.leftFourBaseScrollView.frame.size.height);
        self.leftFourBaseScrollView.scrollEnabled = NO;
        [self.tvCardsTopViewController.topView addSubview:self.leftFourBaseScrollView];
        [self.leftFourBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:NO];
    }
    
    // Add othersTab
    self.othersTab = [[UIView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width * 2 / self.tabNoAccordingToSharingFunction, 44.0)];
    self.othersTab.backgroundColor = [UIColor whiteColor];
    self.othersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOthers)];
    [self.othersTab addGestureRecognizer:self.othersTap];
    
    // Add allTab
    self.allTab = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44.0)];
    self.allTab.backgroundColor = [UIColor yellowColor];
    self.allTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showShare)];
    [self.allTab addGestureRecognizer:self.allTap];
    
    if (self.tabNoAccordingToSharingFunction == 2) {
        [self.leftTwoBaseScrollView addSubview:self.othersTab];
        [self.leftTwoBaseScrollView addSubview:self.allTab];
    }
    else if (self.tabNoAccordingToSharingFunction == 3) {
        [self.leftThreeBaseScrollView addSubview:self.othersTab];
        [self.leftThreeBaseScrollView addSubview:self.allTab];
    }
    else if (self.tabNoAccordingToSharingFunction == 4) {
        [self.leftFourBaseScrollView addSubview:self.othersTab];
        [self.leftFourBaseScrollView addSubview:self.allTab];
    }
    
    
    
    // Add cardsView
    self.tvCardsViewController = [[TVCardsViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.tvCardsViewController.managedObjectContext = self.managedObjectContext;
    self.tvCardsViewController.managedObjectModel = self.managedObjectModel;
    self.tvCardsViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
    self.tvCardsViewController.user = self.user;
    
    
    [self addChildViewController:self.tvCardsViewController];
    [self.tvCardsSlotView addSubview:self.tvCardsViewController.view];
    [self.tvCardsViewController didMoveToParentViewController:self];
    self.tvCardsViewController.tableView.bounces = YES;
    
    // Override tableView's delegate to detect scrolling
    self.tvCardsViewController.tableView.delegate = self;
    
    self.lastY = 0.0;
    
}

- (void)syncSortSettingsFromTableToMenu
{
    if ([self.tvCardsViewController.sortDescriptors count] > 0) {
        if ([self.tvCardsViewController.sortDescriptors containsObject:self.tvCardsViewController.byCellTitleAlphabetA]) {
            self.byCellTitleAlphabetCode = 1;
        }
        else if ([self.tvCardsViewController.sortDescriptors containsObject:self.tvCardsViewController.byCellTitleAlphabetD]) {
            self.byCellTitleAlphabetCode = 2;
        } else {
            self.byCellTitleAlphabetCode = 0;
        }
        
        if ([self.tvCardsViewController.sortDescriptors containsObject:self.tvCardsViewController.byTimeCollectedA]) {
            self.byTimeCollectedCode = 1;
        }
        else if ([self.tvCardsViewController.sortDescriptors containsObject:self.tvCardsViewController.byTimeCollectedD]) {
            self.byTimeCollectedCode = 2;
        } else {
            self.byTimeCollectedCode = 0;
        }
    } else {
        self.byCellTitleAlphabetCode = 0;
        self.byTimeCollectedCode = 0;
    }
}

- (void)syncSortSettingsFromMenuToTable
{
    
}

# pragma mark - Show & exit another tab

- (void)showFullTopView
{
    if (self.tvCardsSlotView.contentOffset.y != 0.0f) {
        [self.tvCardsSlotView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)showMultiCards
{
    // Change topView tabs
    [self.leftOneBaseScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [self.leftTwoBaseScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [self.leftThreeBaseScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [self.leftFourBaseScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    
    [self.tvCardsViewController.tableView setEditing:YES animated:YES];
    // Freeze the horizontal swipe to search/edit.
    [self freezeRootView];
}

- (void)backToSingle
{
    [self.leftOneBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:YES];
    [self.leftTwoBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:YES];
    [self.leftThreeBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:YES];
    [self.leftFourBaseScrollView setContentOffset:CGPointMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0) animated:YES];
    [self.tvCardsViewController.tableView setEditing:NO animated:YES];
    [self defreezeRootView];
}

- (void)showChangeTag
{
    //
}

- (void)showShare
{
    
}

- (void)allSelection
{
    
}

- (void)changeToCardTab
{
    if (!self.cardTab) {
        self.cardTab = [[UIView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44)];
        self.cardTab.backgroundColor = [UIColor yellowColor];
        [self.leftOneBaseScrollView addSubview:self.cardTab];
        self.cardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCards)];
        [self.cardTab addGestureRecognizer:self.cardTap];
    }
    if (self.multiTab.hidden == NO) {
        self.multiTab.hidden = YES;
    }
    if (self.cardTab.hidden == YES) {
        self.cardTab.hidden = NO;
    }
}

- (void)changeTagTabSingleMulti
{
    if (!self.multiTagTab) {
        self.multiTagTab = [[UIView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44)];
        self.multiTagTab.backgroundColor = [UIColor greenColor];
        [self.leftTwoBaseScrollView addSubview:self.multiTagTab];
        self.multiTagTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMultiTags)];
        [self.multiTagTab addGestureRecognizer:self.multiTagTap];
    }
    if (!self.singleTagTab) {
        self.singleTagTab = [[UIView alloc] initWithFrame:CGRectMake(self.tempSize.width / self.tabNoAccordingToSharingFunction, 0.0, self.tempSize.width / self.tabNoAccordingToSharingFunction, 44)];
        self.singleTagTab.backgroundColor = [UIColor blueColor];
        [self.leftTwoBaseScrollView addSubview:self.singleTagTab];
        self.singleTagTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSingleTag)];
        [self.singleTagTab addGestureRecognizer:self.singleTagTap];
    }
    if (self.multiTagTab.hidden == YES) {
        self.multiTagTab.hidden = NO;
    }
    if (self.singleTagTab.hidden == NO) {
        self.singleTagTab.hidden = YES;
    }
    
    if (self.tagTab.hidden == NO) {
        self.tagTab.hidden = YES;
    }
}


- (void)showCards
{
    // Get tagView visiable and hide other tabViews if available
    if (self.tvCardsViewController.view.hidden == YES) {
        self.tvCardsViewController.view.hidden = NO;
    }
    if (self.contactView.hidden == NO) {
        self.contactView.hidden = YES;
    }
    if (self.othersView.hidden == NO) {
        self.othersView.hidden = YES;
    }
    if (self.multiTab.hidden == YES) {
        self.multiTab.hidden = NO;
    }
    self.cardTab.hidden = YES;
    if (self.tagTab.hidden == YES) {
        self.tagTab.hidden = NO;
    }
    if (self.singleTagTab.hidden == NO) {
        self.singleTagTab.hidden = YES;
    }
    if (self.multiTagTab.hidden == NO) {
        self.multiTagTab.hidden = YES;
    }
}

- (void)showContact
{
    // Get tagViewController ready
    if (!self.contactView) {
        self.contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0, self.tempSize.width, self.tempSize.height)];
        self.contactView.backgroundColor = [UIColor whiteColor];
        [self.tvCardsSlotView addSubview:self.contactView];
        
    }
    // Get sortView visiable and hide other tabViews if available
    if (self.tvCardsViewController.view.hidden == NO) {
        self.tvCardsViewController.view.hidden = YES;
    }
    if (self.contactView.hidden == YES) {
        self.contactView.hidden = NO;
    }
    if (self.othersView.hidden == NO) {
        self.othersView.hidden = YES;
    }
}

- (void)exitSortView
{
    
}

- (void)showOthers
{
    if (!self.othersView) {
        self.othersView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.tempSize.width, self.tempSize.height - 44.0)];
        self.othersView.backgroundColor = [UIColor purpleColor];
        [self.tvCardsSlotView addSubview:self.othersView];
        
        if (!self.sortBaseView) {
            self.byAlphabet = [[TVSortCellView alloc]initWithFrame:CGRectMake(10.0, 10.0, self.view.frame.size.width - 20.0, 64)];
            [self.byAlphabet.tap addTarget:self action:@selector(disableTheRest:)];
            self.byAlphabet.textView.text = @"Alphabet Ascending";
            self.byTimeCollected = [[TVSortCellView alloc]initWithFrame:CGRectMake(10.0, 10.0 + self.byAlphabet.frame.origin.y + self.byAlphabet.frame.size.height, self.view.frame.size.width - 20.0, 64)];
            [self.byTimeCollected.tap addTarget:self action:@selector(disableTheRest:)];
            self.byTimeCollected.textView.text = @"Time Collected Ascending";
            
            self.sortBaseView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tempSize.width, self.byAlphabet.frame.size.height * 2 + 10.0 + 10.0 + 10.0)];
            self.sortBaseView.backgroundColor = [UIColor whiteColor];
            [self.othersView addSubview:self.sortBaseView];
            
            [self.sortBaseView addSubview:self.byAlphabet];
            [self.sortBaseView addSubview:self.byTimeCollected];
            
            if ([self.user.sortOption isEqualToString:@"collectedAtAAlphabetA"] || [self.user.sortOption isEqualToString:@"collectedAtDAlphabetA"]) {
                [self.byTimeCollected selectionAction];
            }
            if ([self.user.sortOption isEqualToString:@"AlphabetAcollectedAtD"] || [self.user.sortOption isEqualToString:@"AlphabetDcollectedAtD"]) {
                [self.byAlphabet selectionAction];
            }
        }
        
        if (!self.langPickViewController) {
            self.langPickViewController = [[TVLangPickViewController alloc] init];
            self.langPickViewController.originY = self.sortBaseView.frame.origin.y + self.sortBaseView.frame.size.height;
            self.langPickViewController.user =self.user;
            [self addChildViewController:self.langPickViewController];
            [self.othersView addSubview:self.langPickViewController.view];
            [self.langPickViewController didMoveToParentViewController:self];
        }
        
    }

    if (self.tvCardsViewController.view.hidden == NO) {
        self.tvCardsViewController.view.hidden = YES;
    }
    if (self.contactView.hidden == NO) {
        self.contactView.hidden = YES;
    }
    if (self.othersView.hidden == YES) {
        self.othersView.hidden = NO;
    }
    [self changeToCardTab];
}

- (void)disableTheRest:(id)sender
{
    UITapGestureRecognizer *aSender = sender;
    UIView *view = aSender.view;
    if ([view isEqual:self.byAlphabet]) {
        [self.byTimeCollected selectionAction];
    }
    if ([view isEqual:self.byTimeCollected]) {
        [self.byAlphabet selectionAction];
    }
}

// Change topLeft icon


// While cardsView in multiseleciton mode, tagSelectionView will be different. It will be like the tagSelectionView in New. So there will be two methods to trigger different tagSelectionViews. And the other one demands to complete tag info collection before the tagSelectionView is shown.



//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    NSString *animName = [anim valueForKey:@"animationName"];
//    
//    if ([animName isEqualToString:@"comeThrough"]) {
//        // Hide newView first to avoid flashing back before being hidden.
//        self.tvCardsSlotView.hidden = YES;
//        // Remove the animation
//        [self.tvCardsSlotView.layer removeAllAnimations];
//    }
//    if ([animName isEqualToString:@"comeUp"]) {
//        // Bring tagView to front
//        //[self.view bringSubviewToFront:self.tagSelectionBaseViewController.view];
//        
//    }
//    if ([animName isEqualToString:@"goThrough"]) {
//        // Show newView
//        //[self.view bringSubviewToFront:self.myNewView];
//        
//    }
//    if ([animName isEqualToString:@"goDown"]) {
//        // Hide tagView to front
//        self.tvTagsViewController.view.hidden = YES;
//    }
//}



//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
    //if ([textField isEqual:self.createTagInput]) {
        
    //}
    //return YES;
//}

#pragma mark - select to expand and collapse

// Get the labelPoint
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tvCardsViewController.tableView]) {
        if (tableView.editing == NO) {
            if (self.cellRect.size.width == 0.0) {
                TVTableViewCell *cell = (TVTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                self.cellRect = CGRectMake(cell.cellLabel.frame.origin.x, cell.cellLabel.frame.origin.y, cell.cellLabel.frame.size.width, cell.cellLabel.frame.size.height);
            }
            /*
             Makingg a row to expand/collapse is a chain of actions. 1. So when the scrolling triggering the display of a row, the cell is configured before it is ready for use. 2. If triggering by selecting/deselecting a row, the cell shoould be manually refreshed immediately.
             1. Only setting a flag will do
             2. We have to refresh the row ourselves
             
             There is some kind of animation glitch for reducing contentSize operation since reducing the contentSize leads to change of contentOffset, which even with setContetOffset animation:NO still can not resolve it very well. So I decided to abandon the reducing operatoin. Just increase to provide enough space for extraCard.
             */
            if (!self.cardSelected) {
                // No card is selected, only expand the current card
                self.cardSelected = [self.tvCardsViewController.arrayDataSource objectAtIndex:indexPath.row];
                [self expandCard:tableView card:self.cardSelected];
            } else if ([self.cardSelected isEqual:[self.tvCardsViewController.arrayDataSource objectAtIndex:indexPath.row]]) {
                // The selected card is selected again, collapse card
            } else {
                // A different new card is selected, the old selected card should be collapsed
                // Cells not able to be selected from here till the extraCardOut's animation is done.
                self.tvCardsViewController.tableView.allowsSelection = NO;
                [self hideCard];
                self.cardSelected = nil;
                self.cardSelected = [self.tvCardsViewController.arrayDataSource objectAtIndex:indexPath.row];
                self.extraCardIn = nil;
                [self expandCard:tableView card:self.cardSelected];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing == NO) {
        if ([tableView isEqual:self.tvCardsViewController.tableView]) {
            
            if (!self.cardSelected) {

            } else if ([self.cardSelected isEqual:[self.tvCardsViewController.arrayDataSource objectAtIndex:indexPath.row]]) {
                // The selected card is selected again, collapse card
                [self hideCard];
                self.cardSelected = nil;
                self.extraCardIn = nil;
            }
        }
    }
}

- (void)expandCard:(UITableView *)tableView card:(TVCard *)card
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:[self.tvCardsViewController.arrayDataSource indexOfObject:card] inSection:0];
    TVTableViewCell *tempCell = (TVTableViewCell *)[tableView cellForRowAtIndexPath:path];
    CGFloat tempLabelY = tempCell.frame.origin.y + (tempCell.frame.size.height - tempCell.cellLabel.frame.size.height) / 2 + tempCell.cellLabel.frame.size.height;
    // Firstly exam if default setting can fit
    CGFloat gap = 15.0;
    
    if (([self threeLabelsHeight:gap] + tempLabelY) > MAX(self.tvCardsViewController.tableView.contentSize.height, (tableView.rowHeight * [tableView numberOfRowsInSection:0]))) {
        // TableView's contentSize is not tall enough to have room for a full card display. Increase it.
        self.shouldIncreaseHeightBy = [self threeLabelsHeight:gap] + tempLabelY - tableView.contentSize.height;
        tableView.contentSize = CGSizeMake(tableView.contentSize.width, tableView.rowHeight * [tableView numberOfRowsInSection:0] + self.shouldIncreaseHeightBy);
    }
    [self showFullCardDownAtAtPoint:CGPointMake(tempCell.frame.origin.x, tempLabelY) forCell:tempCell gap:gap];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.extraCardIn]) {
        UITapGestureRecognizer *tapToHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCard)];
        [self.extraCardIn addGestureRecognizer:tapToHide];
    }
    if ([scrollView isEqual:self.extraCardOut]) {
        [self.extraCardOut removeFromSuperview];
        self.extraCardOut = nil;
        
        // Cells should be back to be able to be selected
        self.tvCardsViewController.tableView.allowsSelection = YES;
    }
    
}

// Calculate all three labels, origin of each label is not important, let's just use (0.0, 0.0) here since what we need is only the heights.

- (CGFloat)labelContextHeight
{
    CGFloat contextHeight = 0.0;
    self.labelContext = [[TVCellLabelContext alloc] initWithFrame:CGRectMake(0.0, 0.0, self.cellRect.size.width, 1000.0)];
    self.labelContext.text = [self.cardSelected valueForKey:@"context"];
    [self.labelContext sizeToFit];
    contextHeight = self.labelContext.frame.size.height;
    return contextHeight;
}

- (CGFloat)labelDetailHeight
{
    CGFloat detailHeight = 0.0;
    self.labelDetail = [[TVCellLabelDetail alloc] initWithFrame:CGRectMake(0.0, 0.0, self.cellRect.size.width, 1000.0)];
    self.labelDetail.text = [self.cardSelected valueForKey:@"detail"];
    [self.labelDetail sizeToFit];
    detailHeight = self.labelDetail.frame.size.height;
    return detailHeight;
}

- (CGFloat)labelTranslationHeight
{
    CGFloat translationHeight = 0.0;
    self.labelTranslation = [[TVCellLabelTranslation alloc] initWithFrame:CGRectMake(0.0, 0.0, self.cellRect.size.width, 1000.0)];
    self.labelTranslation.text = [self.cardSelected valueForKey:@"translation"];
    [self.labelTranslation sizeToFit];
    translationHeight = self.labelTranslation.frame.size.height;
    return translationHeight;
}

// This means the max room needed
- (CGFloat)threeLabelsHeight:(CGFloat)gap
{
    return (gap * 5 + [self labelContextHeight] + [self labelDetailHeight] + [self labelTranslationHeight]);
}

- (void)showFullCardDownAtAtPoint:(CGPoint)labelPoint forCell:(UITableViewCell *)cell gap:(CGFloat)gap
{
    // LabelPoint is the origin of the cellLabel + its height in tableView's context, not the cell
    CGFloat contextHeight = 0.0;
    CGFloat detailHeight = 0.0;
    CGFloat translationHeight = 0.0;
    
    // From top to bottom: translation, detail, context
    self.labelTranslation = [[TVCellLabelTranslation alloc] initWithFrame:CGRectMake(self.cellRect.origin.x, gap, self.cellRect.size.width, 1000.0)];
    self.labelTranslation.text = [self.cardSelected valueForKey:@"translation"];
    [self.labelTranslation sizeToFit];
    translationHeight = self.labelTranslation.frame.size.height;
    
    self.labelDetail = [[TVCellLabelDetail alloc] initWithFrame:CGRectMake(self.cellRect.origin.x, self.labelTranslation.frame.origin.y + self.labelTranslation.frame.size.height + gap, self.cellRect.size.width, 1000.0)];
    self.labelDetail.text = [self.cardSelected valueForKey:@"detail"];
    [self.labelDetail sizeToFit];
    detailHeight = self.labelDetail.frame.size.height;
    
    self.labelContext = [[TVCellLabelContext alloc] initWithFrame:CGRectMake(self.cellRect.origin.x, self.labelDetail.frame.origin.y + self.labelDetail.frame.size.height + gap, self.cellRect.size.width, 1000.0)];
    self.labelContext.text = [self.cardSelected valueForKey:@"context"];
    [self.labelContext sizeToFit];
    contextHeight = self.labelContext.frame.size.height;
    
    // Height of the scrollView's frame
    CGFloat myHeight = contextHeight + detailHeight + translationHeight + gap * 5;
    
    self.extraCardIn = [[UIScrollView alloc] initWithFrame:CGRectMake(labelPoint.x, labelPoint.y, cell.frame.size.width, myHeight)];
    self.extraCardIn.contentSize = CGSizeMake(self.extraCardIn.frame.size.width, self.extraCardIn.frame.size.height * 2);
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.extraCardIn.frame.size.width, myHeight)];
    self.extraCardIn.scrollEnabled = NO;
    
    [contentView addSubview:self.labelTranslation];
    [contentView addSubview:self.labelDetail];
    [contentView addSubview:self.labelContext];
    [self.extraCardIn addSubview:contentView];
    contentView.backgroundColor = [UIColor grayColor];
    [self.extraCardIn setContentOffset:CGPointMake(0.0, myHeight) animated:NO];
    [self.tvCardsViewController.tableView addSubview:self.extraCardIn];
    self.extraCardIn.backgroundColor = [UIColor clearColor];
    self.extraCardIn.delegate = self;
    [self.extraCardIn setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    
}

- (void)hideCard
{
    self.extraCardOut = nil;
    self.extraCardOut = self.extraCardIn;
    self.extraCardOut.delegate = self;
    [self.extraCardOut setContentOffset:CGPointMake(0.0, self.extraCardOut.frame.size.height) animated:YES];
}

//- (void)rebalanceTableView
//{
//    if (self.extraCardOut.frame.origin.y + self.extraCardOut.frame.size.height > MAX(self.tvCardsViewController.tableView.rowHeight * [self.tvCardsViewController.tableView numberOfRowsInSection:0], self.extraCardIn.frame.origin.y + self.extraCardIn.frame.size.height)) {
//        // Only if there is some reduction area shown currently, the animation will run. Otherwise, no need to run the animation.
//        // Coz reducing the tableView's height leads to unnecessarily move, reduce the height only when tableView reaches its bottom. But keep tracing the what the height is supposed to be to get prepared for the change.
//        if (self.tvCardsViewController.tableView.contentOffset.y > MAX(self.tvCardsViewController.tableView.rowHeight * [self.tvCardsViewController.tableView numberOfRowsInSection:0] - self.tvCardsViewController.tableView.frame.size.height, self.extraCardIn.frame.origin.y + self.extraCardIn.frame.size.height) - self.tvCardsViewController.tableView.frame.size.height) {
//            
//            [self.tvCardsViewController.tableView setContentOffset:CGPointMake(self.tvCardsViewController.tableView.contentOffset.x, MAX(self.tvCardsViewController.tableView.rowHeight * [self.tvCardsViewController.tableView numberOfRowsInSection:0] - self.tvCardsViewController.tableView.frame.size.height, self.extraCardIn.frame.origin.y + self.extraCardIn.frame.size.height) - self.tvCardsViewController.tableView.frame.size.height) animated:YES];
//        }
//    }
//}

//- (void)reduceTableViewHeight
//{
//    // Two places to make this decision: 1. the moment a card is selected/deselected 2. the moment the tableView scrolling pass the line
//    NSLog(@"00000: %f", self.tvCardsViewController.tableView.contentOffset.y);
//    NSLog(@"11111: %f", self.tvCardsViewController.tableView.rowHeight * [self.tvCardsViewController.tableView numberOfRowsInSection:0]);
//    NSLog(@"22222: %f", self.extraCardIn.frame.origin.y + self.extraCardIn.frame.size.height);
//    if (self.tvCardsViewController.tableView.contentSize.height > MAX(self.tvCardsViewController.tableView.rowHeight * [self.tvCardsViewController.tableView numberOfRowsInSection:0], self.extraCardIn.frame.origin.y + self.extraCardIn.frame.size.height)
//        && self.tvCardsViewController.tableView.contentOffset.y >= MAX(self.tvCardsViewController.tableView.rowHeight * [self.tvCardsViewController.tableView numberOfRowsInSection:0] - self.tvCardsViewController.tableView.frame.size.height, self.extraCardIn.frame.origin.y + self.extraCardIn.frame.size.height - self.tvCardsViewController.tableView.frame.size.height)) {
//        
//        CGPoint currentOffset = CGPointMake(self.tvCardsViewController.tableView.contentOffset.x, self.tvCardsViewController.tableView.contentOffset.y);
//        [self.tvCardsViewController.tableView setContentOffset:currentOffset animated:YES];
//        self.tvCardsViewController.tableView.contentSize = CGSizeMake(self.tvCardsViewController.tableView.contentSize.width, MAX(self.tvCardsViewController.tableView.rowHeight * [self.tvCardsViewController.tableView numberOfRowsInSection:0], self.extraCardIn.frame.origin.y + self.extraCardIn.frame.size.height));
//    }
//}


#pragma mark - slotView mechanism

/*
 tableView is the operation interface. topView and slotView will make corresponding move at the same velocity as the tableView based on:
 1. The velocity is synchronized by setting the difference between start point of each single move and the end point of the single move as the content offset change amount of the two corresponding subviews. A single move means the meta move in one direction.
 2. When approaching top, make both tableView's top and topView fully visiable before refreshControl can be triggered.
 a. tableView reachs top first, set the bounces to NO to disable refreshControl. Bring topView fully visible and, after that, set bounces back to YES to enable the refreshControl
 b. topView become fully visible, nothing to worry about then
 c. topView and tableView reach at the same time, nothing to worry about
 3. When approaching bottom, the increased contentInset will help.
 
 */

// Sync mode triggered by dragging, stopped by reaching an end, such as top or bottom. And one special case is if setContentOffset animation is in progress, sync mode will be off and must be retriggered by new dragging.
// Stop sync while bouncing. Bounce happens only after user's dragging ends and when either end is reached.

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tvCardsViewController.tableView]) {
        // Start to sync
        self.scrollSyncOn = YES;
        
    }
}

// When sync flag is on, sync.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tvCardsViewController.tableView]) {
        // Hide the deleteView shown while scrolling
        [self.tvCardsViewController hideDeleteViewIn];
        
        
        // For sync
        self.nowY = self.tvCardsViewController.tableView.contentOffset.y;
        // RefreshControl is available when topView is fully visible
        if (self.tvCardsSlotView.contentOffset.y <= 0.0) {
            self.tvCardsViewController.tableView.bounces = YES;
        }
        if (self.scrollSyncOn == YES) {
            
            if (self.tvCardsViewController.tableView.contentSize.height + self.tvCardsTopViewController.view.frame.size.height < self.tvCardsSlotView.frame.size.height) {
                // No need to sync when the rect of the whole content is less than the display rect
                // No need to worry about bounces since the sync is off anyway
                // slotView does not take any touch event,either.
                // Set tableView's contentInset to zero
                if (self.tvCardsViewController.tableView.contentInset.bottom != 0.0) {
                    self.tvCardsViewController.tableView.contentInset = UIEdgeInsetsZero;
                }
            } else if (self.tvCardsViewController.tableView.contentSize.height + self.tvCardsTopViewController.view.frame.size.height >= self.tvCardsSlotView.frame.size.height) {
                // Visiable area is bigger than slotView's frame, mechanism needed to best fit user's gesture
                // Add contentInset to tableView to let last row fully visible at any time scrolling to bottom
                if (self.tvCardsViewController.tableView.contentInset.bottom == 0.0) {
                    self.tvCardsViewController.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.tvCardsTopViewController.view.frame.size.height, 0.0);
                }
                /*
                 When tableView scrolled toward top:
                 A. Dragging ends before top is reached, use target as the reference
                 B. Passing the top while dragging, trigger the animation right after the top is reached
                */
                if (self.nowY < self.lastY && self.nowY <= 0.0) {
                    // offset reduced
                    self.scrollSyncOn = NO;
                    [self.tvCardsSlotView setContentOffset:CGPointZero animated:YES];
                } else if (self.nowY > self.lastY && self.nowY >= self.tvCardsViewController.tableView.contentSize.height - self.tvCardsSlotView.frame.size.height) {
                    // offset increased
                    self.scrollSyncOn = NO;
                } else {
                    [self synchronizeMove];
                }
            }
        }
        self.lastY = self.nowY;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Target at top or bottom will make the topView or the tableView fully visible accordingly
    if ([scrollView isEqual:self.tvCardsViewController.tableView]) {
        if (targetContentOffset->y <= 0.0) {
            // Disable the sync mode and take topView fully visible
            self.scrollSyncOn = NO;
            [self.tvCardsSlotView setContentOffset:CGPointZero animated:YES];
        }
    }
}

- (void)synchronizeMove
{
    CGFloat myY = self.tvCardsSlotView.contentOffset.y;
    CGFloat maxOffset = self.tvCardsTopViewController.topView.frame.size.height;
    CGFloat differenceNowLast = fabsf(self.nowY - self.lastY);
    
    CGFloat tempY;
    if (0 <= self.nowY && self.nowY < self.lastY) {
        // offset reduced
        CGFloat minReduce = MIN(myY, differenceNowLast);
        // posisble target offset of two subviews
        tempY = myY - minReduce;
        if (maxOffset >= myY && myY > 0) {
            [self.tvCardsSlotView setContentOffset:CGPointMake(0, tempY) animated:NO];
        }
    }
    if (self.nowY > self.lastY && self.lastY >= 0) {
        // offset increased

        CGFloat minIncrease = MIN(maxOffset - myY, differenceNowLast);

        // posisble target offset of two subviews
        tempY = myY + minIncrease;

        if (maxOffset > myY && myY >= 0) {
            [self.tvCardsSlotView setContentOffset:CGPointMake(0, tempY) animated:NO];
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

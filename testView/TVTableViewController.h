//
//  TVTableViewController.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-05.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVRootViewCtlBox.h"
#import "TVTableViewCell0.h"

@interface TVTableViewController : UITableViewController

@property (assign, nonatomic) BOOL changeIsUserDriven;

@property (strong, nonatomic) TVRootViewCtlBox *box;

@property (strong, nonatomic) NSFetchRequest *fetchRequest;

@property (strong, nonatomic) NSString *tableEntityName;

@property (assign, nonatomic) NSIndexPath *pathOfRowReadyToDelete;
@property (strong, nonatomic) UIView *deleteViewIn;
@property (strong, nonatomic) UIView *deleteViewOut;
/*
 An expandedCellSuite is a set of parts needed for cell expanding display.
 Each expandedCellSuite has following parts:
 card: the card info
 
 */
@property (strong, nonatomic) NSMutableSet *expandedCards;

// Sort
@property (strong, nonatomic) NSSortDescriptor *byCellTitleAlphabetA;
@property (strong, nonatomic) NSSortDescriptor *byTimeCollectedA;
@property (strong, nonatomic) NSSortDescriptor *byTimeCreatedA;
@property (strong, nonatomic) NSSortDescriptor *byCreatorA;
@property (strong, nonatomic) NSSortDescriptor *byCellTitleAlphabetD;
@property (strong, nonatomic) NSSortDescriptor *byTimeCollectedD;
@property (strong, nonatomic) NSSortDescriptor *byTimeCreatedD;
@property (strong, nonatomic) NSSortDescriptor *byCreatorD;
@property (strong, nonatomic) NSMutableDictionary *sortOptions;
@property (strong, nonatomic) NSArray *cardSortDescriptorsAlphabetAFirst;
@property (strong, nonatomic) NSArray *cardSortDescriptorsTimeCollectedDFirst;
@property (strong, nonatomic) NSArray *sortDescriptors;

@property (strong, nonatomic) NSMutableArray *rawDataSource;
/* tableViewDataSources is an array with different versions of dataSources.
 index = 0 indicates the dataSource is the current one in use, while index = 1 means the next version to update to. The last dataSource in the tableViewDataSources is the most recent one tableView needs to present.
 The reason we need a mechanism like this is that we want tableView to update automatically while user use it, during which time server side sync could also affect the presentation of the tableView. We could show some animation simutanously, but for a tableView that could constantly change. The best way to do that is to process those changes in a queue. The array of tableViewDataSource is a kind of queue to support this kind of operation. It keeps running till only one dataSource, the mostly updated one, left in the array.
 */
@property (strong, nonatomic) NSMutableArray *tableDataSources;
@property (strong, nonatomic) NSMutableArray *snapshots;

@property (strong, nonatomic) NSString *toDeleteServerId;
@property (strong, nonatomic) NSString *toDeleteLocalId;

@end

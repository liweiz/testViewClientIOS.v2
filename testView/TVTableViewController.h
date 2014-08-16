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

@interface TVTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (assign, nonatomic) BOOL changeIsUserDriven;

@property (strong, nonatomic) NSManagedObjectContext *ctx;
@property (strong, nonatomic) NSManagedObjectModel *model;

@property (strong, nonatomic) TVRootViewCtlBox *box;

@property (strong, nonatomic) NSFetchRequest *fetchRequest;

// Use lastRowSelected = 100000 as a very large number to indicate no row selected previously
@property (strong, nonatomic) NSInteger lastRowSelected;

@property (strong, nonatomic) NSString *tableEntityName;
@property (strong, nonatomic) NSString *cellTitle;
@property (strong, nonatomic) NSString *cellDetail;

@property (assign, nonatomic) NSIndexPath *pathOfRowReadyToDelete;
@property (strong, nonatomic) UIView *deleteViewIn;
@property (strong, nonatomic) UIView *deleteViewOut;
// A cell's rect
@property (assign, nonatomic) CGRect cellRect;
@property (strong, nonatomic) TVCard *cardSelected;
@property (strong, nonatomic) UILabel *labelTranslation;
@property (strong, nonatomic) UILabel *labelDetail;
@property (strong, nonatomic) UILabel *labelContext;

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

@property (strong, nonatomic) NSArray *rawDataSource;
@property (strong, nonatomic) NSMutableArray *tableDataSource;
// This is used to carry the insertion/deletion/update data set for tableView. Each of the keys is an array.
@property (strong, nonatomic) NSMutableDictionary *dicObjChangeToTable;
@property (strong, nonatomic) NSMutableDictionary *dicPathChangeToTable;

- (void)hideDeleteViewIn;
- (void)selectionActionAtPath:(NSIndexPath *)path;
- (void)configureStatusCodeForCell:(TVTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

//
//  TVTableViewController.h
//  testView
//
//  Created by Liwei on 2013-08-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVTableViewCell.h"
#import "TVUser.h"
#import "TVSortBox.h"

@interface TVTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

// flags
@property (assign, nonatomic) BOOL changeIsUserDriven;
@property (assign, nonatomic) BOOL startWithEditMode;
@property (assign, nonatomic) BOOL isThreeStatusCell;

// core data basics
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSPredicate *predicate;

// rows' data
@property (strong, nonatomic) NSMutableArray *dataSourceArray;
// Need to reset after leaving the tableView
@property (strong, nonatomic) NSMutableSet *objectsForInsertion;
@property (strong, nonatomic) NSMutableSet *objectsForInsertionThisTime;

@property (assign, nonatomic) CGSize tempSize;

// To yeild some space for other views. Must be configged before viewDidLoad
@property (assign, nonatomic) CGFloat positionY;

// Control table view's height
@property (assign, nonatomic) CGFloat heightToReduce;

@property (strong, nonatomic) NSString *myEntityName;
@property (strong, nonatomic) NSString *cellTitle;
@property (strong, nonatomic) NSString *cellDetail;

@property (assign, nonatomic) NSIndexPath *pathOfRowReadyToDelete;
@property (strong, nonatomic) UIView *deleteViewIn;
@property (strong, nonatomic) UIView *deleteViewOut;

@end

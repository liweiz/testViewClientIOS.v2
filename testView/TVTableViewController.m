//
//  TVTableViewController.m
//  testView
//
//  Created by Liwei on 2013-08-09.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVTableViewController.h"
#import "TVTableViewCell.h"
#import "TVView.h"

@interface TVTableViewController ()

@end

@implementation TVTableViewController

@synthesize tempSize, positionY, heightToReduce;
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;
@synthesize fetchedResultsController, fetchRequest, myEntityName;
@synthesize dataSourceArray;
@synthesize cellTitle, cellDetail, deleteViewIn, deleteViewOut;
@synthesize changeIsUserDriven, startWithEditMode;
@synthesize pathOfRowReadyToDelete, objectsForInsertion,objectsForInsertionThisTime;
@synthesize sortDescriptors;

@synthesize isThreeStatusCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    // Config tableView
    CGRect firstRect = [[UIScreen mainScreen] applicationFrame];
    self.tempSize = firstRect.size;
    // Notice the extraHeightReduce for height adjustment
    CGRect tempRect = CGRectMake(0.0, self.positionY, self.tempSize.width, self.tempSize.height - self.heightToReduce);
    
    self.tableView = [[UITableView alloc] initWithFrame:tempRect style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.tableView.backgroundColor = [UIColor grayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.changeIsUserDriven = NO;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // This will refresh data manually and both cardsTable and tagTable will be refreshed
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    // Config fetch request
    self.fetchRequest = [[NSFetchRequest alloc] init];
    self.fetchRequest.entity = [NSEntityDescription entityForName:self.myEntityName inManagedObjectContext:self.managedObjectContext];
    
//    predicate = [NSPredicate predicateWithFormat:@"not (editAction like 'delete')"];
    
    self.fetchRequest.sortDescriptors = self.sortDescriptors;
    if (self.predicate) {
        self.fetchRequest.predicate = self.predicate;
    }
    // Config fetchResultController
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    // Populate table with data
    NSError *err;
    [self refreshTable:&err];
    if (err) {
        // handle err
    }
}

- (void)refreshTable:(NSError **)err
{
    [self refreshData:err];
    if (err) {
        return;
    }
    // This will be changed, since communication with back-end will take time
    // Before testing with back-end, keep it this way for standalone app test
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    if (self.startWithEditMode == YES) {
        [self.tableView setEditing:YES animated:NO];
    }
}

- (void)refreshData:(NSError **)err
{
    [self.fetchedResultsController performFetch:err];
    if (err) {
        return;
    } else if (self.fetchedResultsController.fetchedObjects == nil) {
        // Handle the error.
        //        UIAlertView *emptyDataNotice = [[UIAlertView alloc] initWithTitle:@"No record found" message:@"Add new one or retry later" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
        //        [emptyDataNotice show];
    }
    self.dataSourceArray = nil;
    self.dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    [self.dataSourceArray addObjectsFromArray:[self getDataArray]];
}

- (NSIndexPath *)convertControllerResultsObject:(NSManagedObject *)object toNewArray:(NSArray *)array
{
    // Before this step, it might be necessary to refresh the dataSourceArray
    return [NSIndexPath indexPathForRow:[array indexOfObject:object] inSection:0];
}

- (NSArray *)getDataArray
{
    return [self.fetchedResultsController.fetchedObjects sortedArrayUsingDescriptors:self.sortDescriptors];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // This part is not effected by wether dataSouce is array
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [self.tableView registerClass:[TVTableViewCell class] forCellReuseIdentifier:@"Cell"];
    TVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSManagedObject *managedObject = [self.dataSourceArray objectAtIndex:indexPath.row];;
    [self configureCell:cell cellForRowAtIndexPath:indexPath];
    cell.cellLabel.text = [managedObject valueForKey:self.cellTitle];
    return cell;
}

- (void)configureCell:(TVTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // tableViewCell has three statuses: 0: unselected, 1: fully selected, 2: partly selected
    
    // Configure statusCode if needed
    [self configureStatusCodeForCell:cell atIndexPath:indexPath];
    // Mark the origin statusCode for change observation.
    cell.statusCodeOrigin = cell.statusCode;
    // Get subviews ready to attach related tapGesture
    [cell layoutIfNeeded];
    [cell.selectionTap addTarget:self action:@selector(triggerSelection:)];
    [cell.selectionTapMini addTarget:self action:@selector(triggerSelection:)];
    [cell.deleteTap addTarget:self action:@selector(deleteRow:)];
    cell.baseScrollView.delegate = self;
    [cell updateEditView];
}

- (void)configureStatusCodeForCell:(TVTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isThreeStatusCell) {
        // Two statuses are on. Disable the tapSelection of cell and use the default cell selectoin management. Start with no selection in both normal and edit mode. No need to configure the statusCode since selection management goes through system default.
        cell.partlySelectedIsOn = NO;
        if (self.tableView.editing == YES) {
            if ([self.tableView.indexPathsForSelectedRows containsObject:indexPath]) {
                cell.statusCode = 1;
            } else {
                cell.statusCode = 0;
            }
        } else {
            if ([self.tableView.indexPathsForSelectedRows count] > 0 && self.tableView.indexPathForSelectedRow.row == indexPath.row) {
                // Configure cell
                cell.statusCode = 1;
            } else {
                cell.statusCode = 0;
            }
        }
    }
}

// Actions after tapping on a cell
- (void)triggerSelection:(UITapGestureRecognizer *)sender
{
    UITapGestureRecognizer *tempSender = sender;
    // Two tapGestureRecognizers have different views attached, so the cell is at different levels.
    // For selectionTap
    if ([tempSender.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell *)tempSender.view.superview.superview];
        [self selectionActionAtPath:path];
    } else {
        // Handle error
    }
    // For selectionTapMini
    if ([tempSender.view.superview.superview.superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell *)tempSender.view.superview.superview.superview];
        [self selectionActionAtPath:path];
    } else {
        // Handle error
    }
}

- (void)selectionActionAtPath:(NSIndexPath *)path
{
    // Use statusCode to identify and switch among statuses on cell level.
    if (!self.isThreeStatusCell) {
        BOOL alreadySelected = NO;
        if ([self.tableView.indexPathsForSelectedRows containsObject:path]) {
            // Already selected, deselect this one
            alreadySelected = YES;
            [self.tableView deselectRowAtIndexPath:path animated:YES];
            [self.tableView.delegate tableView:self.tableView didDeselectRowAtIndexPath:path];
        }
        if (alreadySelected == NO) {
            [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:path];
        }
    }
}

- (void)deleteRow:(id)sender
{
    UITapGestureRecognizer *tempSender = sender;
    if ([tempSender.view.superview.superview.superview.superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell *)tempSender.view.superview.superview.superview.superview];
        TVBase *objToDelete = [self.dataSourceArray objectAtIndex:path.row];
        [self.managedObjectContext deleteObject:objToDelete];
        NSError *err;
        [self.managedObjectContext save:&err];
        if (!err && ![self.managedObjectContext.parentContext isKindOfClass:[NSPersistentStoreCoordinator class]]) {
            [self.managedObjectContext.parentContext save:&err];
        }
        if (err) {
            // handle saving err
        }
    }
}

#pragma mark - deleteView show/hide management
// Call this method when uncover a new row's deleteView
- (void)deleteViewWillShownAtIndexPath:(NSIndexPath *)path deleteView:(UIView *)view
{
    self.deleteViewOut = self.deleteViewIn;
    self.deleteViewIn = nil;
    self.pathOfRowReadyToDelete = nil;
    self.pathOfRowReadyToDelete = path;
    self.deleteViewIn = view;
    // deleteViewIn isEqual:self.deleteViewOut at this moment means no new deleteView is touched. Follow user's gesture
    if (![self.deleteViewIn isEqual:self.deleteViewOut]) {
        [(UIScrollView *)[self.deleteViewOut superview] setContentOffset:CGPointZero animated:YES];
    }
    self.deleteViewOut = nil;
}

// Call this method when a uncovered deleteView is closing manually
- (void)deleteViewWillHide
{
    self.pathOfRowReadyToDelete = nil;
    self.deleteViewIn = nil;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([scrollView.superview.superview.superview isKindOfClass:[UITableViewCell class]]) {
        // Change deleteView's width accordingly. Now use scrollView's height as deleteView's width.
        if (targetContentOffset->x >= scrollView.frame.size.height / 2) {
            targetContentOffset->x = scrollView.frame.size.height;
        }
        else if (targetContentOffset->x < scrollView.frame.size.height / 2) {
            targetContentOffset->x = 0.0;
        }
        if (targetContentOffset->x == 0.0) {
            // Moving to hide deleteView
            if ([scrollView isEqual:self.deleteViewIn.superview]) {
                [self deleteViewWillHide];
            }
        }
        else if (targetContentOffset->x == scrollView.frame.size.height) {
            // Moving to show deleteView
            NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell *)scrollView.superview.superview.superview];
            TVTableViewCell *cell = (TVTableViewCell *)scrollView.superview.superview.superview;
            [self deleteViewWillShownAtIndexPath:path deleteView:cell.deleteView];
        }
    }
}

// Hide deleteView programmatically
- (void)hideDeleteViewIn
{
    if (self.deleteViewIn) {
        UIScrollView *view = (UIScrollView *)self.deleteViewIn.superview;
        [view setContentOffset:CGPointZero animated:YES];
        self.deleteViewIn = nil;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Selected555555Path: %i", indexPath.row);
//    NSLog(@"tableView.indexPathsForSelectedRows count55555555: %i", [tableView.indexPathsForSelectedRows count]);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - fetchedResultsController delegate callbacks

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // Refresh the dataSourceArray to form a new array for insertion while keep the old one for reloading and deletion
    self.objectsForInsertion = nil;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (!self.changeIsUserDriven) {
        
        UITableView *tableView = self.tableView;
        NSIndexPath *pathNeeded;
        if (indexPath) {
            pathNeeded = [self convertControllerResultsObject:anObject toNewArray:self.dataSourceArray];
        }
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                // Insertion needs to find the indexPath in the new dataSource
                if (!self.objectsForInsertion) {
                    self.objectsForInsertion = [NSMutableSet setWithCapacity:0];
                }
                [self.objectsForInsertion addObject:anObject];
                if (!self.objectsForInsertionThisTime) {
                    self.objectsForInsertionThisTime = [NSMutableSet setWithCapacity:0];
                }
                [self.objectsForInsertionThisTime addObject:anObject];
                break;
                
            case NSFetchedResultsChangeDelete:
                // Removing and updating use the indexPath for existing dataSource
                // Updating and insertion do not happen at the same loop in this app. So no need to update the dataSource here.
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathNeeded]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                // this is from http://oleb.net/blog/2013/02/nsfetchedresultscontroller-documentation-bug/
                [tableView reloadRowsAtIndexPaths:@[pathNeeded] withRowAnimation:UITableViewRowAnimationAutomatic];
                //[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                //atIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
//                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                                 withRowAnimation:UITableViewRowAnimationFade];
//                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Configure new indexPath for instersion use
    NSArray *arrayForInsertion = [self getDataArray];
    if ([self.objectsForInsertion count] > 0) {
        for (NSManagedObject *obj in self.objectsForInsertion) {
            NSIndexPath *newPathNeeded = [self convertControllerResultsObject:obj toNewArray:arrayForInsertion];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPathNeeded] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    NSError *err;
    [self refreshData:&err];
    if (err) {
        // handle err
    }
    [self.tableView endUpdates];
}

@end

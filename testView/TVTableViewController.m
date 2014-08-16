//
//  TVTableViewController.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-05.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVTableViewController.h"
#import "NSObject+DataHandler.h"

@interface TVTableViewController ()

@end

@implementation TVTableViewController

@synthesize changeIsUserDriven;
@synthesize ctx;
@synthesize model;
@synthesize box;

@synthesize lastRowSelected;

@synthesize tableEntityName;
@synthesize cellTitle;
@synthesize cellDetail;
@synthesize pathOfRowReadyToDelete;
@synthesize deleteViewIn;
@synthesize deleteViewOut;
@synthesize labelTranslation;
@synthesize labelDetail;
@synthesize labelContext;

@synthesize fetchRequest;
@synthesize sortDescriptors;
@synthesize rawDataSource;
@synthesize tableDataSource;

@synthesize cellRect;
@synthesize cardSelected;
@synthesize dicObjChangeToTable;
@synthesize dicPathChangeToTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastRowSelected = 100000;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data source generation

/*
 rawDataSource and tableDataSource are two independent arrays. Instead of refreshing managedObjects one by one, We dealloc ctx and establish a new ctx to execute fetchRequest for the most recently data in local db.
 */

- (NSMutableArray *)getTableDataSource
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    for (NSManagedObject *o in self.rawDataSource) {
        [newArray addObject:[self convertObjToDic:o]];
    }
    self.rawDataSource = nil;
    [newArray sortUsingDescriptors:self.sortDescriptors];
    return newArray;
}

- (NSDictionary *)convertObjToDic:(NSManagedObject *)obj
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setValue:[obj valueForKey:@"localId"] forKey:@"localId"];
    [d setValue:[obj valueForKey:@"serverId"] forKey:@"serverId"];
    [d setValue:[obj valueForKey:@"versionNo"] forKey:@"versionNo"];
    [d setValue:[obj valueForKey:@"lastModifiedAtLocal"] forKey:@"lastModifiedAtLocal"];
    [d setValue:[obj valueForKey:@"context"] forKey:@"context"];
    [d setValue:[obj valueForKey:@"detail"] forKey:@"detail"];
    [d setValue:[obj valueForKey:@"target"] forKey:@"target"];
    [d setValue:[obj valueForKey:@"translation"] forKey:@"translation"];
    return d;
}

- (NSArray *)getRawDataSource:(NSString *)userServerId
{
    if (!self.fetchRequest) {
        self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.tableEntityName];
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(belongToUser like %@) && !(lastUnsyncAction like TVDocDeleted)", userServerId];
    [self.fetchRequest setPredicate:p];
    return [self.ctx executeFetchRequest:self.fetchRequest error:nil];
}

#pragma mark - Sync with local db
/*
 1.     For any row in tableDataSource, search for the counterpart in refreshed rawDataSource.
 1.1    Search for same serverId
 1.1.1    Match by versionNo to ensure the latest version is shown
 1.1.2    Match by lastModifiedAtLocal to ensure local made changes are shown
 1.1.3    For those with no match in tableDataSource, delete them.
 1.2    Search for same localId in case that serverId is not available. versionNo is not able to be used here since it's from server and no serverId means it has not successfully communicated with server.
 1.2.1    Match by lastModifiedAtLocal to ensure local made changes are shown
 2. For those in rawDataSource without a match in tableDataSource, add them to tableDataSource anyway.
 To easily achieve above steps, we create a new array based on rawDataSource. Add a flag to each of it's object to mark if it is matched during the search.
 */
- (NSDictionary *)syncWithLocalDb:(NSString *)userServerId
{
    self.rawDataSource = [self getRawDataSource:userServerId];
    NSArray *a = [self getArrayWithFlag];
    for (NSDictionary *d in self.tableDataSource) {
        NSString *localId = [d valueForKey:@"localId"];
        NSString *serverId = [d valueForKey:@"serverId"];
        NSNumber *versionNo = [d valueForKey:@"versionNo"];
        NSInteger versionNo0 = versionNo.integerValue;
        NSDate *lastModifiedAtLocal = [d valueForKey:@"lastModifiedAtLocal"];
        BOOL isMatched = NO;
        for (NSDictionary *x in a) {
            NSInteger rowNo = [self.tableDataSource indexOfObject:d];
            NSManagedObject *mo = [x valueForKey:@"obj"];
            if (serverId.length > 0) {
                if ([[mo valueForKey:@"serverId"] isEqualToString:serverId]) {
                    isMatched = YES;
                    NSNumber *nn = [NSNumber numberWithBool:YES];
                    [x setValue:nn forKey:@"isMatched"];
                    NSNumber *versionNo1 = [mo valueForKey:@"versionNo"];
                    NSInteger versionNo2 = versionNo1.integerValue;
                    if ([self isNeededToBeUpdatedByVerNo:versionNo0 criteria:versionNo2]) {
                        NSDictionary *newD = [self convertObjToDic:mo];
                        [self.tableDataSource replaceObjectAtIndex:rowNo withObject:newD];
                    } else {
                        NSDate *lastModifiedAtLocal0 = [mo valueForKey:@"lastModifiedAtLocal"];
                        if ([self isNeededToBeUpdatedByLastModified:lastModifiedAtLocal criteria:lastModifiedAtLocal0]) {
                            NSDictionary *newD = [self convertObjToDic:mo];
                            [self.tableDataSource replaceObjectAtIndex:rowNo withObject:newD];
                        }
                    }
                    break;
                }
            } else if (localId.length > 0) {
                if ([[mo valueForKey:@"localId"] isEqualToString:localId]) {
                    isMatched = YES;
                    NSNumber *nn = [NSNumber numberWithBool:YES];
                    [x setValue:nn forKey:@"isMatched"];
                    NSDate *lastModifiedAtLocal0 = [mo valueForKey:@"lastModifiedAtLocal"];
                    if ([self isNeededToBeUpdatedByLastModified:lastModifiedAtLocal criteria:lastModifiedAtLocal0]) {
                        NSDictionary *newD = [self convertObjToDic:mo];
                        [self.tableDataSource replaceObjectAtIndex:rowNo withObject:newD];
                    }
                    break;
                }
            }
        }
        if (!isMatched) {
            [self.tableDataSource removeObject:d];
        }
    }
    for (NSMutableDictionary *y in a) {
        NSNumber *i = [y valueForKey:@"isMatched"];
        if (!i.boolValue) {
            NSManagedObject *mo = [y valueForKey:@"obj"];
            NSDictionary *newD = [self convertObjToDic:mo];
            [self.tableDataSource addObject:newD];
        }
    }
    [self.tableDataSource sortUsingDescriptors:self.sortDescriptors];
}

- (NSArray *)getArrayWithFlag
{
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (id obj in self.rawDataSource) {
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
        [d setObject:obj forKey:@"obj"];
        NSNumber *n = [NSNumber numberWithBool:NO];
        [d setObject:n forKey:@"isMatched"];
        [a addObject:d];
    }
    return a;
}

- (BOOL)isNeededToBeUpdatedByVerNo:(NSInteger)verNoToExe criteria:(NSInteger)verNo
{
    if (verNoToExe >= verNo) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isNeededToBeUpdatedByLastModified:(NSDate *)timeToExe criteria:(NSDate *)time
{
    if ([timeToExe compare:time] == NSOrderedAscending) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Selection

- (NSMutableArray *)getBlankInsertedTableDataSource
{
    
}

// Get the labelPoint
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing == NO) {
        /*
         Makingg a row to expand/collapse is a chain of actions. 1. So when the scrolling triggering the display of a row, the cell is configured before it is ready for use. 2. If triggering by selecting/deselecting a row, the cell should be manually refreshed immediately.
         1. Only setting a flag will do
         2. We have to refresh the row ourselves
         
         There is some kind of animation glitch for reducing contentSize operation since reducing the contentSize leads to change of contentOffset, which even with setContetOffset animation:NO still can not resolve it very well. So I decided to abandon the reducing operatoin. Just increase to provide enough space for extraCard.
         */
        NSInteger rowSelected = indexPath.row;
        if (self.lastRowSelected == 100000) {
            // No card is selected, only expand the current card
            self.cardSelected = [self.tableDataSource objectAtIndex:rowSelected];
            [self expandCard:tableView card:self.cardSelected];
            self.lastRowSelected = rowSelected;
        } else if (self.lastRowSelected == rowSelected) {
            // The selected card is selected again, collapse card
            self.cardSelected = nil;
            self.lastRowSelected = 100000;
        } else {
            // A different new card is selected, the old selected card should be collapsed
            // Cells not able to be selected from here till the extraCardOut's animation is done.
            self.tableView.allowsSelection = NO;
            [self hideCard];
            self.lastRowSelected = rowSelected;
            self.cardSelected = [self.tableDataSource objectAtIndex:indexPath.row];
            self.extraCardIn = nil;
            [self expandCard:tableView card:self.cardSelected];
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

#pragma mark - Table view data source

/*
 Data flow structure:
 1. NSArray got from fetchRequest
 2. NSArray from 1 with sortDescriptors. Blank objects may be inserted to provide extra space for expanded card.
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // This part is not effected by wether dataSouce is array
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [self.tableView registerClass:[TVTableViewCell0 class] forCellReuseIdentifier:@"Cell"];
    TVTableViewCell0 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSManagedObject *managedObject;
    managedObject = [self.dataSource objectAtIndex:indexPath.row];
    
    [self configureCell:cell cellForRowAtIndexPath:indexPath];
    cell.cellLabel.text = [managedObject valueForKey:self.cellTitle];
    if (self.cellRect.size.width == 0.0f) {
        self.cellRect = cell.frame;
    }
    return cell;
}

- (void)configureCell:(TVTableViewCell0 *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get subviews ready to attach related tapGesture
    [cell layoutIfNeeded];
    [cell.selectionTap addTarget:self action:@selector(triggerSelection:)];
    [cell.deleteTap addTarget:self action:@selector(deleteRow:)];
    cell.baseScrollView.delegate = self;
    [cell updateEditView];
}

// Actions after tapping on a cell
- (void)triggerSelection:(UITapGestureRecognizer *)sender
{
    UITapGestureRecognizer *tempSender = sender;
    // For selectionTap
    if ([tempSender.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell *)tempSender.view.superview.superview];
        [self selectionActionAtPath:path];
    } else {
        // Handle error
    }
}

- (void)deleteRow:(id)sender
{
    UITapGestureRecognizer *tempSender = sender;
    if ([tempSender.view.superview.superview.superview.superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell *)tempSender.view.superview.superview.superview.superview];
        TVBase *objToDelete = [self.dataSource objectAtIndex:path.row];
        [self deleteDocBaseLocal:objToDelete];
        [self.ctx save:nil];
    } else {
        // Handle error
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
            TVTableViewCell0 *cell = (TVTableViewCell0 *)scrollView.superview.superview.superview;
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

#pragma mark - Tableview insertion/deletion/update

/*
 The process is always from rawDataSource to tableDataSource, no matter whether it's triggered by user or system, except inserting/deleting blank rows for expanding/collapsing a row.
 Steps:
 1. rawDataSource change (expanding/collapsing a row is not related to this)
 2. tableDataSource change
 3. use animation to present the changes on the table accordingly
 Scenarios:
 1.     Client side operation
 1.1    User creates a new card
 1.2    User updated a card
 1.3    User deletes card(s)
 2.     Server side operation leads to client side change
 2.1    For newCard response, if the new card is in response body, which indicates local db's corresponding record will be updated accordingly, refresh it in managedObjectContext.
 2.2    For oneCard response, same as 2.1.
 2.3    For sync response, use the module for a full sync between refreshed rawDataSource and tableDataSource, get difference and proceed to updating tableView.
 */
- (NSSet *)getDicChangeToTable
{
    NSMutableSet *s = [[NSMutableSet alloc] init];
    
}

// Convert objArray for rowEditing to pathArray
- (NSArray *)objToPath:(NSArray *)objArray inDataSouce:(NSArray *)sourceArray
{
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (id obj in objArray) {
        NSIndexPath *p = [NSIndexPath indexPathWithIndex:[sourceArray indexOfObject:obj]];
        [a addObject:p];
    }
    return a;
}

- (void)objToPathExe
{
    NSArray *i = [self.dicObjChangeToTable valueForKey:@"insert"];
    NSArray *d = [self.dicObjChangeToTable valueForKey:@"delete"];
    NSArray *u = [self.dicObjChangeToTable valueForKey:@"update"];
    if (!self.dicPathChangeToTable) {
        self.dicPathChangeToTable = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    [self.dicPathChangeToTable removeAllObjects];
    if ([i count] > 0) {
        [self.dicPathChangeToTable setObject:[self objToPath:i inDataSouce:self.tableDataSource] forKey:@"insert"];
    }
    if ([d count] > 0) {
        [self.dicPathChangeToTable setObject:[self objToPath:d inDataSouce:self.tableDataSource] forKey:@"delete"];
    }
    if ([u count] > 0) {
        [self.dicPathChangeToTable setObject:[self objToPath:u inDataSouce:self.tableDataSource] forKey:@"update"];
    }
}

- (void)tableChangeAnimation
{
    [self.tableView beginUpdates];
    NSArray *toInsert = [self.dicPathChangeToTable valueForKey:@"insert"];
    NSArray *toDelete = [self.dicPathChangeToTable valueForKey:@"delete"];
    NSArray *toUpdate = [self.dicPathChangeToTable valueForKey:@"update"];
    if ([toInsert count] > 0) {
        [self.tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationFade];
    }
    if ([toDelete count] > 0) {
        // Removing and updating use the indexPath for existing dataSource
        // Updating and insertion do not happen at the same loop in this app. So no need to update the dataSource here.
        [self.tableView deleteRowsAtIndexPaths:toDelete
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    if ([toUpdate count] > 0) {
        // Removing and updating use the indexPath for existing dataSource
        // Updating and insertion do not happen at the same loop in this app. So no need to update the dataSource here.
        // This is from http://oleb.net/blog/2013/02/nsfetchedresultscontroller-documentation-bug/
        [self.tableView reloadRowsAtIndexPaths:toUpdate withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
        //atIndexPath:indexPath];
    }
    [self.tableView endUpdates];
}

#pragma mark - select to expand and collapse



- (void)expandCard:(UITableView *)tableView card:(TVCard *)card
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:[self.tvCardsViewController.arrayDataSource indexOfObject:card] inSection:0];
    TVTableViewCell *tempCell = (TVTableViewCell *)[tableView cellForRowAtIndexPath:path];
    CGFloat tempLabelY = tempCell.frame.origin.y + (tempCell.frame.size.height - tempCell.cellLabel.frame.size.height) / 2 + tempCell.cellLabel.frame.size.height;
    // Firstly exam if default setting can fit
    CGFloat gap = 15.0;
    CGFloat h = [self threeLabelsHeight:gap];
    // Rows needed to be inserted
    CGFloat h1 = ceil(h / tempCell.frame.size.height);
    
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
    
    CGFloat myHeightFit = ;
    self.extraCardIn = [[UIScrollView alloc] initWithFrame:CGRectMake(labelPoint.x, labelPoint.y, cell.frame.size.width, myHeightFit)];
    self.extraCardIn.contentSize = CGSizeMake(self.extraCardIn.frame.size.width, self.extraCardIn.frame.size.height * 2.0f);
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.extraCardIn.frame.size.width, myHeightFit)];
    self.extraCardIn.scrollEnabled = NO;
    
    [contentView addSubview:self.labelTranslation];
    [contentView addSubview:self.labelDetail];
    [contentView addSubview:self.labelContext];
    [self.extraCardIn addSubview:contentView];
    contentView.backgroundColor = [UIColor grayColor];
    [self.extraCardIn setContentOffset:CGPointMake(0.0f, myHeightFit) animated:NO];
    [self.tvCardsViewController.tableView addSubview:self.extraCardIn];
    self.extraCardIn.backgroundColor = [UIColor clearColor];
    self.extraCardIn.delegate = self;
    [self.extraCardIn setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    
}

- (NSInteger)getRowNoOfFullCardView:(CGFloat)originalHeight cellHeight:(CGFloat)height
{
    return ceil(originalHeight / cell.frame.size.height);
}

- (CGFloat)getHeightOfFullCardView:(CGFloat)originalHeight cellHeight:(CGFloat)height
{
    return ceil(originalHeight / cell.frame.size.height) * cell.frame.size.height;
}

- (CGRect)getOriginalRectOfFullCardView cell:(UITableViewCell *)cell
{
    // LabelPoint is the origin of the cellLabel + its height in tableView's context, not the cell
    CGFloat contextHeight = 0.0f;
    CGFloat detailHeight = 0.0f;
    CGFloat translationHeight = 0.0f;
    
    // From top to bottom: translation, detail, context
    self.labelTranslation = [[TVLabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x, gap, cell.frame.size.width, 1000.0f)];
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
}

- (void)hideCard
{
    self.extraCardOut = nil;
    self.extraCardOut = self.extraCardIn;
    self.extraCardOut.delegate = self;
    [self.extraCardOut setContentOffset:CGPointMake(0.0f, self.extraCardOut.frame.size.height) animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

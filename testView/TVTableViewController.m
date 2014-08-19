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
@synthesize tableDataSources;

@synthesize expandedCellSuites;
@synthesize cellRect;
@synthesize gap;
@synthesize cardToShowRect;
@synthesize cardWillShow;
@synthesize cardShown;

@synthesize dicObjChangeToTable;
@synthesize dicPathChangeToTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastRowSelected = 1000000;
    self.gap = 15.0f;
    self.dicPathChangeToTable = [NSMutableDictionary dictionaryWithCapacity:0];
    self.expandedCellSuites = [NSMutableSet setWithCapacity:0];
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

- (void)updateTableView
{
    if ([self.tableDataSources count] > 1) {
        NSArray *dsNow = self.tableDataSources[0];
        NSArray *dsNext = self.tableDataSources[1];
        
    }
    
    
}

- (void)addBlankRows:(NSSet *)expandedCardSet toTableViewDataSource:(NSMutableArray *)dataSource
{
    for (NSDictionary *obj in expandedCardSet) {
        NSDictionary *card = [obj valueForKey:@"card"];
        NSString *serverId = [card valueForKey:@"serverId"];
        NSString *localId = [card valueForKey:@"localId"];
        NSDictionary *cardTailingBlank = [self findCard:serverId localId:localId inArray:dataSource];
        NSSet *blanks = [obj valueForKey:@"blankObjs"];
        NSInteger i = [dataSource indexOfObject:cardTailingBlank];
        for (NSDictionary *b in blanks) {
            [dataSource insertObject:b atIndex:(i + 1)];
        }
    }
}

- (NSMutableArray *)getAllBlankPath:(NSArray *)dataSource
{
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *d in dataSource) {
        if ([d count] > 0) {
            [a addObject:d];
        }
    }
    return a;
}

- (NSMutableArray *)getTableDataSource
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    for (NSManagedObject *obj in self.rawDataSource) {
        if ([self.tableDataSources count] == 0) {
            [newArray addObject:[self convertObjToDic:obj]];
        } else {
            // Reuse the obj from existing current dataSource to reduce memory usage. Otherwise, there could be too many objs duplicatedly generated.
            NSString *serverId = [obj valueForKey:@"serverId"];
            NSString *localId = [obj valueForKey:@"localId"];
            NSDictionary *d = [self findCard:serverId localId:localId inArray:self.tableDataSources[0]];
            if ([d count] > 0) {
                [newArray addObject:d];
            } else {
                [newArray addObject:[self convertObjToDic:obj]];
            }
        }
    }
    self.rawDataSource = nil;
    self.ctx = nil;
    [newArray sortUsingDescriptors:self.sortDescriptors];
    return newArray;
}

- (NSDictionary *)findCard:(NSString *)serverId localId:(NSString *)localId inArray:(NSArray *)array
{
    if (serverId.length == 0) {
        for (NSDictionary *c in array) {
            NSString *lId = [c valueForKey:@"localId"];
            if ([localId isEqualToString:lId]) {
                // Same card located
                return c;
            }
        }
    } else {
        for (NSDictionary *c in array) {
            NSString *sId = [c valueForKey:@"serverId"];
            if ([serverId isEqualToString:sId]) {
                // Same card located
                return c;
            }
        }
    }
    return nil;
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
- (void)syncWithLocalDb:(NSString *)userServerId
{
    [self.dicPathChangeToTable removeAllObjects];
    NSMutableArray *toInsert = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *toUpdate = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *toDelete = [NSMutableArray arrayWithCapacity:0];
    self.rawDataSource = [self getRawDataSource:userServerId];
    NSArray *a = [self getArrayWithFlag];
    for (NSDictionary *d in self.tableDataSource) {
        NSString *localId = [d valueForKey:@"localId"];
        NSString *serverId = [d valueForKey:@"serverId"];
        NSNumber *versionNo = [d valueForKey:@"versionNo"];
        NSInteger versionNo0 = versionNo.integerValue;
        NSDate *lastModifiedAtLocal = [d valueForKey:@"lastModifiedAtLocal"];
        BOOL isMatched = NO;
        NSInteger rowNo = [self.tableDataSource indexOfObject:d];
        NSIndexPath *path = [NSIndexPath indexPathWithIndex:rowNo];
        for (NSDictionary *x in a) {
            NSManagedObject *mo = [x valueForKey:@"obj"];
            if (serverId.length > 0) {
                if ([[mo valueForKey:@"serverId"] isEqualToString:serverId]) {
                    isMatched = YES;
                    NSNumber *nn = [NSNumber numberWithBool:YES];
                    [x setValue:nn forKey:@"isMatched"];
                    NSNumber *versionNo1 = [mo valueForKey:@"versionNo"];
                    NSInteger versionNo2 = versionNo1.integerValue;
                    if ([self isNeededToBeUpdatedByVerNo:versionNo0 criteria:versionNo2]) {
                        // Update row
                        NSDictionary *newD = [self convertObjToDic:mo];
                        [self.tableDataSource replaceObjectAtIndex:rowNo withObject:newD];
                        [toUpdate addObject:path];
                    } else {
                        NSDate *lastModifiedAtLocal0 = [mo valueForKey:@"lastModifiedAtLocal"];
                        if ([self isNeededToBeUpdatedByLastModified:lastModifiedAtLocal criteria:lastModifiedAtLocal0]) {
                            NSDictionary *newD = [self convertObjToDic:mo];
                            // Update row
                            [self.tableDataSource replaceObjectAtIndex:rowNo withObject:newD];
                            [toUpdate addObject:path];
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
                        // Update row
                        [self.tableDataSource replaceObjectAtIndex:rowNo withObject:newD];
                        [toUpdate addObject:path];
                    }
                    break;
                }
            }
        }
        if (!isMatched) {
            // Delete row
            [self.tableDataSource removeObject:d];
            [toDelete addObject:path];
        }
    }
    for (NSMutableDictionary *y in a) {
        NSNumber *i = [y valueForKey:@"isMatched"];
        if (!i.boolValue) {
            NSManagedObject *mo = [y valueForKey:@"obj"];
            NSDictionary *newD = [self convertObjToDic:mo];
            // Insert row
            [self.tableDataSource addObject:newD];
            NSInteger rowNo = [self.tableDataSource indexOfObject:newD];
            NSIndexPath *path = [NSIndexPath indexPathWithIndex:rowNo];
            [toInsert addObject:path];
        }
    }
    [self.dicPathChangeToTable setObject:toUpdate forKey:@"update"];
    [self.dicPathChangeToTable setObject:toDelete forKey:@"delete"];
    [self.dicPathChangeToTable setObject:toInsert forKey:@"insert"];
//    [self.tableDataSource sortUsingDescriptors:self.sortDescriptors];
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

- (void)tableChangeAnimation
{
    // To form a new array for insertion while keep the old one for reloading and deletion
    [self.tableView beginUpdates];
    NSArray *toInsert = [self.dicPathChangeToTable valueForKey:@"insert"];
    NSArray *toDelete = [self.dicPathChangeToTable valueForKey:@"delete"];
    NSArray *toUpdate = [self.dicPathChangeToTable valueForKey:@"update"];
    if ([toInsert count] > 0) {
        // Insertion needs to find the indexPath in the new dataSource
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
    return [self.tableDataSources[0] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [self.tableView registerClass:[TVTableViewCell0 class] forCellReuseIdentifier:@"Cell"];
    TVTableViewCell0 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSManagedObject *managedObject;
    managedObject = [self.tableDataSources[0] objectAtIndex:indexPath.row];
    
    [self configureCell:cell cellForRowAtIndexPath:indexPath];
    cell.cellLabel.text = [managedObject valueForKey:self.cellTitle];
    
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
        TVBase *objToDelete = [self.tableDataSources[0] objectAtIndex:path.row];
        [self deleteDocBaseLocal:objToDelete];
        [self.ctx save:nil];
    } else {
        // Handle error
    }
}

#pragma mark - Selection

// Get the labelPoint
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.cellRect = CGRectZero;
    self.cellRect = cell.frame;
    if (tableView.editing == NO) {
        /*
         Makingg a row to expand/collapse is a chain of actions. 1. So when the scrolling triggering the display of a row, the cell is configured before it is ready for use. 2. If triggering by selecting/deselecting a row, the cell should be manually refreshed immediately.
         1. Only setting a flag will do
         2. We have to refresh the row ourselves
         
         There is some kind of animation glitch for reducing contentSize operation since reducing the contentSize leads to change of contentOffset, which even with setContetOffset animation:NO still can not resolve it very well. So I decided to abandon the reducing operatoin. Just increase to provide enough space for extraCard.
         */
        NSInteger rowSelected = indexPath.row;
        if (self.lastRowSelected == 1000000) {
            // No card is selected, only expand the current card
            [self expandCard:rowSelected];
            self.lastRowSelected = rowSelected;
        } else if (self.lastRowSelected == rowSelected) {
            // The selected card is selected again, collapse card
            self.cardSelected = nil;
            self.lastRowSelected = 1000000;
        } else {
            // A different new card is selected, the old selected card should be collapsed
            // Cells not able to be selected from here till the extraCardOut's animation is done.
            self.tableView.allowsSelection = NO;
            [self hideCard];
            self.lastRowSelected = rowSelected;
            [self expandCard:rowSelected];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing == NO) {
        if ([self.cardSelected isEqual:[self.tableDataSource objectAtIndex:indexPath.row]]) {
            // The selected card is selected again, collapse card
            [self hideCard];
            self.cardSelected = nil;
        }
    }
}

#pragma mark - ExpandedCellSuite generation

- (void)generateExpandedCellSuite:(NSInteger)rowSelected
{
    NSMutableDictionary *s = [NSMutableDictionary dictionaryWithCapacity:0];
    [self.expandedCellSuites addObject:s];
    NSDictionary *cardSelected = [self.tableDataSource objectAtIndex:rowSelected];
    [s setObject:cardSelected forKey:@"card"];
    CGRect cardRect = [self getOriginalRectOfFullCardView];
    NSInteger rowsNeeded = [self getRowNoOfFullCardView:cardRect.size.height];
    NSNumber *rowsNeededN = [NSNumber numberWithInteger:rowsNeeded];
    [s setObject:rowsNeededN forKey:@"rowsNeeded"];
    cardRect = [self getFinalRectOfFullCardView:rowsNeeded];
    NSValue *cardRectValue = [NSValue valueWithCGRect:cardRect];
    [s setObject:cardRectValue forKey:@"cardRect"];
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *b = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger n = 1; n <= rowsNeeded; n++) {
        NSDictionary *x = [[NSDictionary alloc] init];
        [self.tableDataSource insertObject:x atIndex:(rowSelected + n)];
        [a addObject:x];
        NSIndexPath *p = [NSIndexPath indexPathWithIndex:(rowSelected + n)];
        [b addObject:p];
    }
    [s setObject:a forKey:@"blankObjs"];
    [s setObject:b forKey:@"blankObjPaths"];
}

#pragma mark - Select to expand/collapse

- (void)expandCard:(NSInteger)rowSelected
{
    
    [self.dicPathChangeToTable removeAllObjects];
    [self.dicPathChangeToTable setObject:a forKey:@"insert"];
    self.tableView.allowsSelection = NO;
    [self tableChangeAnimation];
    [self showFullCardDown:self.cardToShowRect];
}

- (void)showFullCardDown:(CGRect)cardRect
{
    self.cardWillShow = [[UIScrollView alloc] initWithFrame:cardRect];
    self.cardWillShow.contentSize = CGSizeMake(self.cardWillShow.frame.size.width, self.cardWillShow.frame.size.height * 2.0f);
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.cardWillShow.frame.size.width, self.cardWillShow.frame.size.height)];
    self.cardWillShow.scrollEnabled = NO;
    [contentView addSubview:self.labelTranslation];
    [contentView addSubview:self.labelDetail];
    [contentView addSubview:self.labelContext];
    [self.cardWillShow addSubview:contentView];
    contentView.backgroundColor = [UIColor grayColor];
    [self.cardWillShow setContentOffset:CGPointMake(0.0f, cardRect.size.height) animated:NO];
    [self.tableView addSubview:self.cardWillShow];
    self.cardWillShow.backgroundColor = [UIColor clearColor];
    self.cardWillShow.delegate = self;
    [self.cardWillShow setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.cardWillShow]) {
        UITapGestureRecognizer *tapToHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCard)];
        [self.cardWillShow addGestureRecognizer:tapToHide];
        self.cardShown = self.cardWillShow;
        self.cardWillShow = nil;
    }
    if ([scrollView isEqual:self.cardShown]) {
        [self.cardShown removeFromSuperview];
        self.cardShown = nil;
        // Cells should resume to be able to be selected
        self.tableView.allowsSelection = YES;
    }
}

- (void)hideCard
{
    [self.cardShown setContentOffset:CGPointMake(0.0f, self.cardShown.frame.size.height) animated:YES];
    self
}

#pragma mark - Card rect calculation

// Calculate all three labels, origin of each label is not important, let's just use (0.0, 0.0) here since what we need is only the heights.

- (CGFloat)labelContextHeight
{
    CGFloat contextHeight = 0.0;
    self.labelContext = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.cellRect.size.width, 1000.0)];
    self.labelContext.text = [self.cardSelected valueForKey:@"context"];
    [self.labelContext sizeToFit];
    contextHeight = self.labelContext.frame.size.height;
    return contextHeight;
}

- (CGFloat)labelDetailHeight
{
    CGFloat detailHeight = 0.0;
    self.labelDetail = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.cellRect.size.width, 1000.0)];
    self.labelDetail.text = [self.cardSelected valueForKey:@"detail"];
    [self.labelDetail sizeToFit];
    detailHeight = self.labelDetail.frame.size.height;
    return detailHeight;
}

- (CGFloat)labelTranslationHeight
{
    CGFloat translationHeight = 0.0;
    self.labelTranslation = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.cellRect.size.width, 1000.0)];
    self.labelTranslation.text = [self.cardSelected valueForKey:@"translation"];
    [self.labelTranslation sizeToFit];
    translationHeight = self.labelTranslation.frame.size.height;
    return translationHeight;
}

- (CGRect)getFinalRectOfFullCardView:(NSInteger)noOfRowsNeeded
{
    return CGRectMake(self.cardToShowRect.origin.x, self.cardToShowRect.origin.y, self.cardToShowRect.size.width, self.cellRect.size.height * noOfRowsNeeded);
}

- (NSInteger)getRowNoOfFullCardView:(CGFloat)originalHeight
{
    return ceil(originalHeight / self.cellRect.size.height);
}

- (CGFloat)getHeightOfFullCardView:(CGFloat)originalHeight
{
    return ceil(originalHeight / self.cellRect.size.height) * self.cellRect.size.height;
}

- (CGRect)getOriginalRectOfFullCardView
{
    // LabelPoint is the origin of the cellLabel + its height in tableView's context, not the cell
    CGFloat contextHeight = 0.0f;
    CGFloat detailHeight = 0.0f;
    CGFloat translationHeight = 0.0f;
    // self.cellRect is assigned once a cell is selected.
    // From top to bottom: translation, detail, context
    self.labelTranslation = [[UILabel alloc] initWithFrame:CGRectMake(self.cellRect.origin.x, self.gap, self.cellRect.size.width, 1000.0f)];
    self.labelTranslation.text = [self.cardSelected valueForKey:@"translation"];
    [self.labelTranslation sizeToFit];
    translationHeight = self.labelTranslation.frame.size.height;
    
    self.labelDetail = [[UILabel alloc] initWithFrame:CGRectMake(self.cellRect.origin.x, self.labelTranslation.frame.origin.y + self.labelTranslation.frame.size.height + self.gap, self.cellRect.size.width, 1000.0)];
    self.labelDetail.text = [self.cardSelected valueForKey:@"detail"];
    [self.labelDetail sizeToFit];
    detailHeight = self.labelDetail.frame.size.height;
    
    self.labelContext = [[UILabel alloc] initWithFrame:CGRectMake(self.cellRect.origin.x, self.labelDetail.frame.origin.y + self.labelDetail.frame.size.height + self.gap, self.cellRect.size.width, 1000.0)];
    self.labelContext.text = [self.cardSelected valueForKey:@"context"];
    [self.labelContext sizeToFit];
    contextHeight = self.labelContext.frame.size.height;
    
    // Height of the scrollView's frame
    CGFloat myHeight = contextHeight + detailHeight + translationHeight + self.gap * 5;
    return CGRectMake(self.cellRect.origin.x, self.cellRect.origin.y, self.cellRect.size.width, myHeight);
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

@end

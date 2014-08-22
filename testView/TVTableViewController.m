//
//  TVTableViewController.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-05.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVTableViewController.h"
#import "NSObject+DataHandler.h"
#import "TVExpandedCard.h"

@interface TVTableViewController ()

@end

@implementation TVTableViewController

@synthesize changeIsUserDriven;
@synthesize ctx;
@synthesize model;
@synthesize box;

@synthesize tableEntityName;

@synthesize pathOfRowReadyToDelete;
@synthesize deleteViewIn;
@synthesize deleteViewOut;

@synthesize fetchRequest;
@synthesize sortDescriptors;
@synthesize rawDataSource;
@synthesize tableDataSources;
@synthesize snapShots;
@synthesize expandedCards;

@synthesize cardWillShow;
@synthesize cardShown;

@synthesize userServerId;

/*
 Each snapShot includes two things:
 1. tableDataSource
 2. its corresponding expandedCards
 They are wrapped in a dictionary and the dictionary form an array to indicate its time-based order.
 We get the tableDataSource snapShot alone to self.tableDataSources for tableView change process.
 Modules here:
 1. tableDataSources generator: take snapShot and form a queue
 2. snapShots transition animator: find out difference between two adjacent snapShots and animate the change
 3. selection management: self.expandedCards has the latest selection while the snapShot is saved in self.snapShots
 4. expandedCard frame management: 
 5. cellDeleteView management:
 */

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.expandedCards = [NSMutableSet setWithCapacity:0];
        self.rawDataSource = [NSMutableArray arrayWithCapacity:0];
        self.tableDataSources = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



#pragma mark - Process tableDataSource snapShot queue

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

// Only process current to next version of snapShot
- (void)processOneStepSnapShotQueue
{
    [self tableChangeAnimation:[self getTableViewPathsToChange]];
}

// tableview insertion/deletion/update
- (void)tableChangeAnimation:(NSDictionary *)paths
{
    // The way to have method call after the animation completed is from here: http://stackoverflow.com/questions/7623771/how-to-detect-that-animation-has-ended-on-uitableview-beginupdates-endupdates?answertab=votes#tab-top
    // To form a new array for insertion while keep the old one for reloading and deletion
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if ([self.tableDataSources count] > 1) {
            // Proceed to next version of dataSource till no newer version remains.
            [self processOneStepSnapShotQueue];
        }
    }];
    [self.tableView beginUpdates];
    NSArray *toInsert = [paths valueForKey:@"insert"];
    NSArray *toDelete = [paths valueForKey:@"delete"];
    NSArray *toUpdate = [paths valueForKey:@"update"];
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
    if ([self.tableDataSources count] > 1) {
        [self.tableDataSources removeObjectAtIndex:0];
        [self.snapShots removeObjectAtIndex:0];
    }
    [self.tableView endUpdates];
    [CATransaction commit];
}

// This change is animated since it presents the difference between current version and next version.
- (NSDictionary *)getTableViewPathsToChange
{
    NSMutableDictionary *r = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([self.tableDataSources count] > 1) {
        NSMutableArray *dsNow = self.tableDataSources[0];
        NSMutableArray *dsNext = self.tableDataSources[1];
        NSMutableArray *toInsert = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *toUpdate = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *toDelete = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *d in dsNow) {
            NSInteger rowNo = [dsNow indexOfObject:d];
            NSIndexPath *path = [NSIndexPath indexPathWithIndex:rowNo];
            if ([d count] == 0) {
                // Blank row
                // blanks property of TVExpandedCard is not used here since it is reevaluated every time tableDataSource changes(in other words, take a new snapShot). So the blank obj may be removed from blanks here but still exists in that snapShot. In other cases, an added blank obj may not exist in previous snapShot.
                if (![dsNext containsObject:d]) {
                    // Delete blank row
                    [toDelete addObject:path];
                }
            } else {
                NSString *localId = [d valueForKey:@"localId"];
                NSString *serverId = [d valueForKey:@"serverId"];
                NSNumber *versionNo = [d valueForKey:@"versionNo"];
                NSInteger versionNo0 = versionNo.integerValue;
                NSDate *lastModifiedAtLocal = [d valueForKey:@"lastModifiedAtLocal"];
                NSDictionary *cardInNext = [self findCard:serverId localId:localId inArray:dsNext];
                if ([cardInNext count] > 0) {
                    // Corresponding card found
                    NSNumber *versionNo1 = [cardInNext valueForKey:@"versionNo"];
                    NSInteger versionNo2 = versionNo1.integerValue;
                    if ([self isNeededToBeUpdatedByVerNo:versionNo0 criteria:versionNo2]) {
                        // Update row, path is for its location in current dataSource. And d and cardInNext may not be the same object, though they present the same card in local db.
                        [toUpdate addObject:path];
                        // Update the data for this row in current dataSource as well since tableView probably loads data from this instead of the one in the new dataSource. It can be tested to find the answer later.
                        [dsNow replaceObjectAtIndex:rowNo withObject:cardInNext];
                    } else {
                        NSDate *lastModifiedAtLocal0 = [cardInNext valueForKey:@"lastModifiedAtLocal"];
                        if ([self isNeededToBeUpdatedByLastModified:lastModifiedAtLocal criteria:lastModifiedAtLocal0]) {
                            // Update row
                            [toUpdate addObject:path];
                            [dsNow replaceObjectAtIndex:rowNo withObject:cardInNext];
                        }
                    }
                } else {
                    // No such card found in new dataSource. Delete row.
                    [toDelete addObject:path];
                }
            }
            
        }
        for (NSDictionary *dd in dsNext) {
            NSInteger rowNo = [dsNext indexOfObject:dd];
            NSIndexPath *path = [NSIndexPath indexPathWithIndex:rowNo];
            if ([dd count] == 0) {
                // Blank row
                if (![dsNow containsObject:dd]) {
                    // Insert blank row
                    [toInsert addObject:path];
                }
            } else {
                NSString *localId = [dd valueForKey:@"localId"];
                NSString *serverId = [dd valueForKey:@"serverId"];
                NSDictionary *cardInNow = [self findCard:serverId localId:localId inArray:dsNow];
                if ([cardInNow count] == 0) {
                    // No such card found in current dataSource. Insert row.
                    [toInsert addObject:path];
                }
            }
        }
        [r setObject:toUpdate forKey:@"update"];
        [r setObject:toDelete forKey:@"delete"];
        [r setObject:toInsert forKey:@"insert"];
    }
    return r;
}

#pragma mark - tableDataSource snapShot queue generation

/*
 The whole concept of tableDataSources(yes, it's an array of dataSource here) is to keep the snapShots of dataSource in a time based queue so that even there is constant changes occur, such as multiple changes synced from server side, we still could use the system-provided animations to let user see the change of tableView with only a little disturbance. No need to remind user with icon. no need for the user to manually refresh table all the time.
 
 Blanks are checked by the card owns them.
 */

- (void)getFinalizedSnapShot:(NSMutableArray *)dataSource
{
    [self.rawDataSource setArray:[self getRawDataSource]];
    NSMutableArray *snapShot = [self takeSnapShotOfTableDataSource];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setObject:snapShot forKey:@"dataSource"];
    NSSet *cardsSelected =  self.expandedCards;
    [d setObject:cardsSelected forKey:@"expandedCards"];
    [self.snapShots addObject:d];
    [self addBlankRowsToSnapShot:snapShot];
    [self.tableDataSources addObject:snapShot];
}

- (void)addBlankRowsToSnapShot:(NSMutableArray *)dataSource
{
    NSSet *cards;
    for (NSDictionary *d in self.snapShots) {
        NSArray *ds = [d valueForKey:@"dataSource"];
        if ([ds isEqual:dataSource]) {
            cards = [d valueForKey:@"expandedCards"];
            break;
        }
    }
    for (TVExpandedCard *obj in cards) {
        [self addBlankRows:obj ToTableViewDataSource:dataSource];
    }
}

// Animated blank row insertion is always triggered by expanding card, which should be the only difference between current and next versions of dataSource. So no need to seperate the animated and non-animated blanks here since they are not able to exist in the same tableView update.
- (void)addBlankRows:(TVExpandedCard *)card ToTableViewDataSource:(NSMutableArray *)dataSource
{
    NSString *serverId = card.serverId;
    NSString *localId = card.localId;
    NSDictionary *cardWithBlank = [self findCard:serverId localId:localId inArray:dataSource];
    NSInteger i = [dataSource indexOfObject:cardWithBlank];
    for (NSDictionary *b in card.blanks) {
        [dataSource insertObject:b atIndex:(i + 1)];
    }
}

- (NSMutableArray *)getBlankPath:(NSArray *)dataSource forExpandedCard:(TVExpandedCard *)card
{
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *d in card.blanks) {
        NSIndexPath *p = [NSIndexPath indexPathWithIndex:[dataSource indexOfObject:d]];
        [a addObject:p];
    }
    return a;
}

- (NSMutableArray *)takeSnapShotOfTableDataSource
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


#pragma mark - Data source generation

/*
 rawDataSource and tableDataSource are two independent arrays. Instead of refreshing managedObjects one by one, We dealloc ctx and establish a new ctx to execute fetchRequest for the most recently data in local db.
 */

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

- (NSArray *)getRawDataSource
{
    if (!self.fetchRequest) {
        self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.tableEntityName];
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(belongToUser like %@) && !(lastUnsyncAction like TVDocDeleted)", self.userServerId];
    [self.fetchRequest setPredicate:p];
    return [self.ctx executeFetchRequest:self.fetchRequest error:nil];
}

#pragma mark - Check new version of card

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
        
        if ([self.expandedCards count] == 0) {
            // No card is selected, only expand the current card
            [self expandCard:rowSelected];
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

#pragma mark - ExpandedCard management
/*
 An expandedCard is created when user selects a card. It is ended by deselecting the same card/refreshing tableView/exiting app.
 All blanks are only in use for one version of dataSource, they are destoried with the dataSource they attached to. A new version of dataSource comes with its own blanks.
 The blanks in use for each expandedCard is stored in its corresponding expandedCard for easy locating.
 1. When created/deselected, it calculates the blank rows needed to be inserted/deleted and form a new version of dataSource. Only the newly selected/deselected card has the silde-out/in animation and blank rows inserted/deleted animation.
 2. When other reasons trigger the generation of a new version of dataSource, it firstly generates the dataSource without any blanks. After the initial array is generated, it checks self.expandedCards for blanks needed for each selected card. In this process, the number of blank rows for every expandedCard is recalculated in case that there is content change leading to size change. Blank rows are generated and inserted accordingly.
 */
- (void)initExpandedCard:(NSInteger)rowSelected
{
    TVExpandedCard *t = [[TVExpandedCard alloc] init];
    [self.expandedCards addObject:t];
    NSDictionary *cardSelected = [self.tableDataSources[0] objectAtIndex:rowSelected];
    [self configExpandedCard:t withSelectedCard:cardSelected];
}

- (void)refreshExpandedCard:(TVExpandedCard *)card
{
    NSDictionary *updatedCard = [self findCard:card.serverId localId:card.localId inArray:self.tableDataSources[0]];
    if ([updatedCard count] != 0) {
        [self configExpandedCard:card withSelectedCard:updatedCard];
    }
}

- (void)configExpandedCard:(TVExpandedCard *)expandedCard withSelectedCard:(NSDictionary *)card
{
    // Updating to existing card happens in current version of dataSource. The obj in the dataSource is replaced by the new one.
    [self save:card ToExpandedCard:expandedCard];
    // After setup, blanks for t updated.
    [expandedCard setup];
}

- (void)save:(NSDictionary *)cardDic ToExpandedCard:(TVExpandedCard *)card
{
    [card.target setString:[cardDic valueForKey:@"target"]];
    [card.translation setString:[cardDic valueForKey:@"translation"]];
    [card.detail setString:[cardDic valueForKey:@"detail"]];
    [card.context setString:[cardDic valueForKey:@"context"]];
    card.lastModifiedAtLocal = [cardDic valueForKey:@"lastModifiedAtLocal"];
    card.versionNo = [cardDic valueForKey:@"versionNo"];
    [card.serverId setString:[cardDic valueForKey:@"serverId"]];
    [card.localId setString:[cardDic valueForKey:@"localId"]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

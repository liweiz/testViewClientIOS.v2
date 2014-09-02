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
#import "TVAppRootViewController.h"
#import "NSObject+CoreDataStack.h"
#import "TVCRUDChannel.h"

@interface TVTableViewController ()

@end

@implementation TVTableViewController

@synthesize changeIsUserDriven;
@synthesize ctx;
@synthesize box;

@synthesize tableEntityName;

@synthesize pathOfRowReadyToDelete;
@synthesize deleteViewIn;
@synthesize deleteViewOut;

@synthesize fetchRequest;
@synthesize sortDescriptors;
@synthesize rawDataSource;
@synthesize tableDataSources;
@synthesize snapshots;
@synthesize expandedCards;
@synthesize toDeleteLocalId;
@synthesize toDeleteServerId;

/*
 Each snapshot includes two things:
 1. tableDataSource
 2. its corresponding expandedCards
 They are wrapped in a dictionary and the dictionary form an array to indicate its time-based order.
 We get the tableDataSource snapshot alone to self.tableDataSources for tableView change process.
 
 Modules here:
 1. tableDataSources generator: take snapshot and form a queue
 2. snapshots transition animator: find out difference between two adjacent snapshots and animate the change
 3. selection management: self.expandedCards has the latest selection while the snapshot is saved in self.snapshots
 4. expandedCard frame management: 
 5. cellDeleteView management:
 */

#pragma mark - init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.expandedCards = [NSMutableSet setWithCapacity:0];
        self.rawDataSource = [NSMutableArray arrayWithCapacity:0];
        self.tableDataSources = [NSMutableArray arrayWithCapacity:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCard:) name:tvHideExpandedCard object:nil];
    }
    return self;
}

- (void)loadView
{
    if ([self.tableDataSources count] == 0) {
        [self finalizeTableDataSource];
    }
    CGRect r = CGRectMake(self.box.appRect.size.width, 0.0f, self.box.appRect.size.width, self.box.appRect.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Process tableDataSource snapshot queue

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

// Only process current to next version of snapshot
- (void)processOneStepSnapshotQueue
{
    if ([self.tableDataSources count] > 1) {
        // This has to happen before the tableDataSource completes update, otherwise, current tableDataSource and snapshot will be removed in the process of animation.
        NSDictionary *d = [self getExpandedCardsFromState:[self findCorrespondingExpandedCards:self.tableDataSources[0]] toState:[self findCorrespondingExpandedCards:self.tableDataSources[1]]];
        // Proceed to next version of dataSource till no newer version remains.
        [self tableChangeAnimation:[self getTableViewPathsToChange]];
        // This has to happen after the tableDataSource completes update since it uses tableDataSource[0] as the base to refresh expandedCard.
        [self processExpandedCards:d];
    }
}

// tableview insertion/deletion/update
- (void)tableChangeAnimation:(NSDictionary *)paths
{
    // The way to have method call after the animation completed is from here: http://stackoverflow.com/questions/7623771/how-to-detect-that-animation-has-ended-on-uitableview-beginupdates-endupdates?answertab=votes#tab-top
    // To form a new array for insertion while keep the old one for reloading and deletion
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self processOneStepSnapshotQueue];
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
        [self.snapshots removeObjectAtIndex:0];
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
                // blanks property of TVExpandedCard is not used here since it is reevaluated every time tableDataSource changes(in other words, take a new snapshot). So the blank obj may be removed from blanks here but still exists in that snapshot. In other cases, an added blank obj may not exist in previous snapshot.
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

- (NSMutableSet *)findCorrespondingExpandedCards:(NSArray *)tableDataSource
{
    for (NSDictionary *snapshot in self.snapshots) {
        if ([[snapshot valueForKey:@"dataSource"] isEqual:tableDataSource]) {
            return [snapshot valueForKey:@"expandedCards"];
        }
    }
    return nil;
}

#pragma mark - tableDataSource snapshot queue generation

/*
 The whole concept of tableDataSources(yes, it's an array of dataSource here) is to keep the snapshots of dataSource in a time based queue so that even there is constant changes occur, such as multiple changes synced from server side, we still could use the system-provided animations to let user see the change of tableView with only a little disturbance. No need to remind user with icon. no need for the user to manually refresh table all the time.
 
 Blanks are checked by the card owns them.
 */

- (void)takeSnapshotAndRunQueue
{
    [self finalizeTableDataSource];
    [self processOneStepSnapshotQueue];
}

- (void)finalizeTableDataSource
{
    [self.rawDataSource setArray:[self getRawDataSource]];
    NSMutableArray *snapshot = [self takeSnapshotOfTableDataSource];
    [self addBlankRowsToTableDataSource:snapshot];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setObject:snapshot forKey:@"dataSource"];
    [d setObject:self.expandedCards forKey:@"expandedCards"];
    [self.snapshots addObject:d];
    [self.tableDataSources addObject:snapshot];
}

- (void)addBlankRowsToTableDataSource:(NSMutableArray *)dataSource
{
    NSSet *cards;
    for (NSDictionary *d in self.snapshots) {
        NSArray *ds = [d valueForKey:@"dataSource"];
        if ([ds isEqual:dataSource]) {
            cards = [d valueForKey:@"expandedCards"];
            break;
        }
    }
    for (TVExpandedCard *obj in cards) {
        [self addBlankRows:obj ToTableDataSource:dataSource];
    }
}

// Animated blank row insertion is always triggered by expanding card, which should be the only difference between current and next versions of dataSource. So no need to seperate the animated and non-animated blanks here since they are not able to exist in the same tableView update.
- (void)addBlankRows:(TVExpandedCard *)card ToTableDataSource:(NSMutableArray *)dataSource
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

- (NSMutableArray *)takeSnapshotOfTableDataSource
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    for (NSManagedObject *obj in self.rawDataSource) {
        if ([self.tableDataSources count] == 0) {
            [newArray addObject:[self convertCardObjToDic:obj]];
        } else {
            // Reuse the obj from existing current dataSources to reduce memory usage. Otherwise, there could be too many objs duplicatedly generated.
            NSString *serverId = [obj valueForKey:@"serverId"];
            NSString *localId = [obj valueForKey:@"localId"];
            BOOL found = NO;
            for (NSArray *a in self.tableDataSources) {
                NSDictionary *d = [self findCard:serverId localId:localId inArray:a];
                if ([d count] > 0) {
                    [newArray addObject:d];
                    break;
                }
            }
            if (!found) {
                [newArray addObject:[self convertCardObjToDic:obj]];
            }
        }
    }
    self.rawDataSource = nil;
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



- (NSArray *)getRawDataSource
{
    if (!self.fetchRequest) {
        self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.tableEntityName];
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(belongToUser like %@) && !(lastUnsyncAction like TVDocDeleted)", self.box.user.serverId];
    [self.fetchRequest setPredicate:p];
    [self refreshCtx];
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
    NSDictionary *d = [self.tableDataSources[0] objectAtIndex:indexPath.row];
    [self configureCell:cell cellForRowAtIndexPath:indexPath];
    cell.cellLabel.text = [d valueForKey:@"target"];
    return cell;
}

- (void)configureCell:(TVTableViewCell0 *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get subviews ready to attach related tapGesture
    [cell layoutIfNeeded];
    [cell.selectionTap addTarget:self action:@selector(tapped:)];
    [cell.deleteTap addTarget:self action:@selector(deleteRow:)];
    cell.baseScrollView.delegate = self;
    [cell updateEditView];
}

// Actions after tapping on a cell
- (void)tapped:(UITapGestureRecognizer *)sender
{
    // For selectionTap
    if ([sender.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell *)sender.view.superview.superview];
        [self tableView:self.tableView didSelectRowAtIndexPath:path];
    } else {
        // Handle error
    }
}

- (void)deleteRow:(id)sender
{
    UITapGestureRecognizer *tempSender = sender;
    if ([tempSender.view.superview.superview.superview.superview isKindOfClass:[UITableViewCell class]]) {
        NSBlockOperation *o = [NSBlockOperation blockOperationWithBlock:^{
            TVCRUDChannel *crud = [[TVCRUDChannel alloc] init];
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
            [d setObject:self.toDeleteServerId forKey:@"serverId"];
            [d setObject:self.toDeleteLocalId forKey:@"localId"];
            NSArray *a = [crud getObjs:[NSSet setWithObject:d] name:@"TVCard"];
            [crud deleteOneCard:a[0] fromServer:NO];
            if ([crud saveWithCtx:crud.ctx]) {
                // action after deletion
            }
        }];
        [o setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [self.box.dbWorker addOperation:o];
    } else {
        // Handle error
    }
}

#pragma mark - Selection

// Get the labelPoint
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect cellRect = cell.frame;
    if (tableView.editing == NO) {
        /*
         Makingg a row to expand/collapse is a chain of actions. 1. So when the scrolling triggering the display of a row, the cell is configured before it is ready for use. 2. If triggering by selecting/deselecting a row, the cell should be manually refreshed immediately.
         1. Only setting a flag will do
         2. We have to refresh the row ourselves
         
         There is some kind of animation glitch for reducing contentSize operation since reducing the contentSize leads to change of contentOffset, which even with setContetOffset animation:NO still can not resolve it very well. So I decided to abandon the reducing operatoin. Just increase to provide enough space for extraCard.
         */
        NSInteger rowSelected = indexPath.row;
        NSDictionary *card = [self.tableDataSources[0] objectAtIndex:rowSelected];
        NSMutableSet *aSet;
        for (NSDictionary *s in self.snapshots) {
            NSArray *ss = [s valueForKey:@"dataSource"];
            if ([ss isEqual:self.tableDataSources[0]]) {
                aSet = [s valueForKey:@"expandedCards"];
                break;
            }
        }
        TVExpandedCard *c = [self getTappedCard:card inExpandedCards:aSet];
        TVExpandedCard *cc = [self getTappedCard:card inExpandedCards:self.expandedCards];
        // Identify whether it's a selection or deselection
        if (c) {
            // Selected, should be set to deselected next
            if ([c isEqual:cc]) {
                // Still seletcted now, remove and deselect
                [self.expandedCards removeObject:c];
                
            } else {
                if (cc) {
                    // Selected, but have different objs
                    [self.expandedCards removeObject:cc];
                } else {
                    // Already deselected now, nothing to do
                }
            }
        } else {
            // Not selected, should be set to selected next
            if (cc) {
                // Already selected now, nothing to do
            } else {
                // Not selected, select and add
                [self launchExpandedCard:card];
            }
        }
        
    }
}

// Get the card user selects/deselects, in other words, taps. In a finished expandedCards snapshot, duplicates have been removed already.
- (TVExpandedCard *)getTappedCard:(NSDictionary *)cardTapped inExpandedCards:(NSMutableSet *)aSet
{
    NSString *serverId = [cardTapped valueForKey:@"serverId"];
    NSString *localId = [cardTapped valueForKey:@"localId"];
    return [[self findExpandedCard:serverId localId:localId inSet:aSet] anyObject];
}

// This is to make sure only one TVExpandedCard exists in a set. It returns the one left.
- (TVExpandedCard *)removeDuplicateCards:(NSString *)serverId localId:(NSString *)localId inSet:(NSMutableSet *)aSet
{
    NSMutableSet *s = [self findExpandedCard:serverId localId:localId inSet:aSet];
    if ([s count] > 0) {
        TVExpandedCard *x = [s anyObject];
        for (TVExpandedCard *xx in s) {
            if (![xx isEqual:x]) {
                [aSet removeObject:xx];
            }
        }
        return x;
    }
    return nil;
}

// Tapping occurs on snapshot, so it is the expandedCards for that snapshot used to exam if  it's a seleciton or deselection.
- (NSMutableSet *)findExpandedCard:(NSString *)serverId localId:(NSString *)localId inSet:(NSSet *)aSet
{
    NSMutableSet *r = [NSMutableSet setWithCapacity:0];
    for (TVExpandedCard *c in aSet) {
        if (serverId.length == 0) {
            if ([localId isEqualToString:c.localId]) {
                // Same card located
                [r addObject:c];
            }
        } else {
            if ([serverId isEqualToString:c.serverId]) {
                // Same card located
                [r addObject:c];
            }
        }
    }
    return r;
}

#pragma mark - Process expandedCard snapshot queue

// The states are from self.tableDataSources' corresponding parts, so we don't use array to get the states here.

- (NSDictionary *)getExpandedCardsFromState:(NSMutableSet *)stateOrigin toState:(NSMutableSet *)stateNext
{
    // These two sets need animations.
    NSMutableSet *toExpand = [NSMutableSet setWithCapacity:0];
    NSMutableSet *toCollapse = [NSMutableSet setWithCapacity:0];
    NSMutableSet *toKeep = [NSMutableSet setWithCapacity:0];
    for (TVExpandedCard *o in stateOrigin) {
        // The blanks to collapse are not in the next tableDataSource, so no need to update height and rowsNeeded for them.
        NSMutableSet *s = [self findExpandedCard:o.serverId localId:o.localId inSet:stateNext];
        if ([s count] == 0) {
            // To collapse
            [toCollapse addObject:o];
        } else if ([s count] == 1) {
            // To keep showing
            [toKeep addObject:[s anyObject]];
        }
    }
    for (TVExpandedCard *n in stateNext) {
        NSMutableSet *s = [self findExpandedCard:n.serverId localId:n.localId inSet:stateOrigin];
        if ([s count] == 0) {
            // To expand
            [toExpand addObject:n];
        }
    }
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setObject:toKeep forKey:@"toKeep"];
    [d setObject:toExpand forKey:@"toExpand"];
    [d setObject:toCollapse forKey:@"toCollapse"];
    return d;
}

- (void)processExpandedCards:(NSDictionary *)stateChangeDic
{
    NSMutableSet *toCollapse = [stateChangeDic valueForKey:@"toCollapse"];
    NSMutableSet *toKeep = [stateChangeDic valueForKey:@"toKeep"];
    NSMutableSet *toExpand = [stateChangeDic valueForKey:@"toExpand"];
    [self collapseCardWithAnimation:toCollapse];
    for (TVExpandedCard *c in toKeep) {
        [self refreshExpandedCard:c];
    }
    [self expandCardsWithAnimation:toExpand];
}

#pragma mark - ExpandedCard management
/*
 An expandedCard is created when user selects a card. It is ended by deselecting the same card/refreshing tableView/exiting app.
 All blanks are only in use for one version of dataSource, they are destoried with the dataSource they attached to. A new version of dataSource comes with its own blanks.
 The blanks in use for each expandedCard is stored in its corresponding expandedCard for easy locating.
 1. When created/deselected, it calculates the blank rows needed to be inserted/deleted and form a new version of dataSource. Only the newly selected/deselected card has the silde-out/in animation and blank rows inserted/deleted animation.
 2. When other reasons trigger the generation of a new version of dataSource, it firstly generates the dataSource without any blanks. After the initial array is generated, it checks self.expandedCards for blanks needed for each selected card. In this process, the number of blank rows for every expandedCard is recalculated in case that there is content change leading to size change. Blank rows are generated and inserted accordingly.
 */
- (TVExpandedCard *)launchExpandedCard:(NSDictionary *)card
{
    TVExpandedCard *t;
    // Reuse existing obj
    for (NSDictionary *snapshot in self.snapshots) {
        NSMutableSet *cards = [snapshot valueForKey:@"expandedCards"];
        t = [self getTappedCard:card inExpandedCards:cards];
        if (t) {
            break;
        }
    }
    if (!t) {
        // Create a new obj when nothing to reuse.
        t = [[TVExpandedCard alloc] init];
        [self configExpandedCard:t withSelectedCard:card];
    }
    [self.expandedCards addObject:t];
    return [self removeDuplicateCards:t.serverId localId:t.localId inSet:self.expandedCards];
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
    card.versionNo = ((NSNumber *)[cardDic valueForKey:@"versionNo"]).integerValue;
    [card.serverId setString:[cardDic valueForKey:@"serverId"]];
    [card.localId setString:[cardDic valueForKey:@"localId"]];
}

#pragma mark - Expand/collapse card

- (void)expandCardsWithAnimation:(NSSet *)cardsToExpand
{
    // Expand card
    for (TVExpandedCard *c in cardsToExpand) {
        [c setup];
        [c show:YES];
        c.baseView.delegate = self;
        [self.view addSubview:c.baseView];
    }
}

- (void)collapseCardWithAnimation:(NSSet *)cardToCollapse
{
    for (TVExpandedCard *c in cardToCollapse) {
        [c setup];
        [c show:NO];
        [c.baseView setContentOffset:CGPointMake(0.0f, c.baseView.frame.size.height) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Use contentOffset and tag of uiview to identify if it's the view for expandedCard.
    if (scrollView.contentOffset.y == scrollView.frame.size.height && scrollView.tag == 20140824) {
        [scrollView removeFromSuperview];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

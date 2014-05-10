//
//  UIViewController+DataExchange.m
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "UIViewController+DataExchange.h"

@implementation UIViewController (DataExchange)

#pragma mark - pre-selection action
- (void)preselectFromSet:(NSSet *)set inTableViewController:(TVTableViewController *)tableViewController
{
    for (NSManagedObject *obj in set) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[tableViewController.arrayDataSource indexOfObject:obj] inSection:0];
        [tableViewController selectionActionAtPath:path];
        // reloadRowsAtIndexPaths leads to clearing everything in selection, so not able to be used here
        TVTableViewCell *cell = (TVTableViewCell *)[tableViewController.tableView cellForRowAtIndexPath:path];
        if (cell) {
            [tableViewController configureStatusCodeForCell:cell atIndexPath:path];
            [cell updateEditView];
        }
    }
}

#pragma mark - targetTable multiselection dataSource based on pre-selection
// This is for newView tagSelection
// There are three parts: 1. pre-selected 2. unselected 3. new
// New is added with defalut tableView arrayDataSource procedure
// So only combine reorder the pre-selected/unselected here
- (NSArray *)getDataSourceReadyFromDataSource:(NSArray *)array withPreselectedSet:(NSSet *)preselectedSet sortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSArray *preselectedArray = [self getPreselectedArray:preselectedSet sortDescriptor:sortDescriptor];
    NSArray *unselectedArray = [self getUnselectedArrayFromDataSource:array withPreselectedSet:preselectedSet sortDescriptor:sortDescriptor];
    NSMutableArray *fullArray = [NSMutableArray arrayWithArray:preselectedArray];
    [fullArray addObjectsFromArray:unselectedArray];
    return fullArray;
}

- (NSArray *)getPreselectedArray:(NSSet *)preselectedSet sortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    return [preselectedSet sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (NSArray *)getUnselectedArrayFromDataSource:(NSArray *)array withPreselectedSet:(NSSet *)preselectedSet sortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSMutableSet *allSet = [NSMutableSet setWithArray:array];
    [allSet minusSet:preselectedSet];
    return [allSet sortedArrayUsingDescriptors:@[sortDescriptor]];
}

#pragma mark - targetTable multiselection dataSource from originTableView
// There will be four parts: 1. selected 2. unselected 3. partly selected 4. new
// New is added with defalut tableView arrayDataSource procedure

// Form the complete array, a different fetchedResultsController is used here.
- (NSArray *)getTargetTableDataSourceArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor targetFetchedResultsController:(NSFetchedResultsController *)newFetchedResultsController
{
    NSArray *unselectedSetArray = [self getTargetTableDataSourceUnselectedArrayForEditModeFromOriginalTable:tableView fetchedResultsController:fetchedResultsController byRelationshipCountKey:key additionalSortDescripter:sortDescriptor targetFetchedResultsController:newFetchedResultsController];
    NSArray *fullySelectedSetArray = [self getTargetTableDataSourceFullySelectedArrayForEditModeFromOriginalTable:tableView fetchedResultsController:fetchedResultsController byRelationshipCountKey:key additionalSortDescripter:sortDescriptor];
    NSArray *partlySelectedSetArray = [self getTargetTableDataSourcePartlySelectedArrayForEditModeFromOriginalTable:tableView fetchedResultsController:fetchedResultsController byRelationshipCountKey:key additionalSortDescripter:sortDescriptor];
    NSMutableArray *allArray = [NSMutableArray arrayWithCapacity:1];
    [allArray addObjectsFromArray:fullySelectedSetArray];
    [allArray addObjectsFromArray:partlySelectedSetArray];
    [allArray addObjectsFromArray:unselectedSetArray];
    return allArray;
}

// Turn unselectedSet to the array
- (NSArray *)getTargetTableDataSourceUnselectedArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor targetFetchedResultsController:(NSFetchedResultsController *)newFetchedResultsController
{
    NSMutableSet *allSet = [NSMutableSet setWithCapacity:1];
    [allSet addObjectsFromArray:newFetchedResultsController.fetchedObjects];
    [allSet minusSet:[self getTargetTableDataSourceSelectedSetForEditMode:tableView fetchedResultsController:fetchedResultsController byRelationshipKey:key]];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray *unselectedSetArray = [allSet sortedArrayUsingDescriptors:sortDescriptors];
    return unselectedSetArray;
}

// Turn fullySelectedSet to the array
- (NSArray *)getTargetTableDataSourceFullySelectedArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor
{
    NSMutableSet *fullySelectedSet = [self getFullySelectedSetFromOriginalTable:tableView fetchedResultsController:fetchedResultsController byRelationshipKey:key];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray *partlySelectedSetArray = [fullySelectedSet sortedArrayUsingDescriptors:sortDescriptors];
    return partlySelectedSetArray;
}

// Turn partlySelectedSet to the array
- (NSArray *)getTargetTableDataSourcePartlySelectedArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor
{
    NSMutableSet *partlySelectedSet = [self getPartlySelectedSetFromOriginalTable:tableView fetchedResultsController:fetchedResultsController byRelationshipKey:key];
    NSSortDescriptor *byCount = [NSSortDescriptor sortDescriptorWithKey:key ascending:NO comparator:^(id obj1, id obj2) {
        NSInteger obj1Value = [self uniqueCount:obj1 byRelationshipKey:key];
        NSInteger obj2Value = [self uniqueCount:obj2 byRelationshipKey:key];
        if (obj1Value > obj2Value) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (obj1Value < obj2Value) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:byCount, sortDescriptor, nil];
    NSArray *partlySelectedSetArray = [partlySelectedSet sortedArrayUsingDescriptors:sortDescriptors];
    return partlySelectedSetArray;
}

// Get the partly selected set
- (NSMutableSet *)getPartlySelectedSetFromOriginalTable:(UITableView *)table fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipKey:(NSString *)key
{
    NSMutableSet *selectedTargetSet = [self getTargetTableDataSourceSelectedSetForEditMode:table fetchedResultsController:fetchedResultsController byRelationshipKey:key];
    NSMutableSet *fullySelectedSet = [self getFullySelectedSetFromOriginalTable:table fetchedResultsController:fetchedResultsController byRelationshipKey:key];
    [selectedTargetSet minusSet:fullySelectedSet];
    return selectedTargetSet;
}

// Get the fully selected set
- (NSMutableSet *)getFullySelectedSetFromOriginalTable:(UITableView *)table fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipKey:(NSString *)key
{
    NSMutableSet *selectedTargetSet = [self getTargetTableDataSourceSelectedSetForEditMode:table fetchedResultsController:fetchedResultsController byRelationshipKey:key];
    NSMutableSet *fullySelectedSet = [NSMutableSet setWithCapacity:1];
    NSMutableSet *partlySelectedSet = [NSMutableSet setWithCapacity:1];
    NSMutableSet *originalSelectedSet = [self getOriginalManagedObjects:table fetchedResultsController:fetchedResultsController];
    for (NSManagedObject *obj in originalSelectedSet) {
        if ([[obj mutableSetValueForKey:key] isEqualToSet:selectedTargetSet]) {
            [fullySelectedSet addObject:obj];
        } else {
            [partlySelectedSet addObject:obj];
        }
    }
    return fullySelectedSet;
}

// Each selected managedObject's relationship count is not more than the union of all the selected ones'.
- (NSInteger)uniqueCount:(NSManagedObject *)managedObject byRelationshipKey:(NSString *)key
{
    NSInteger countResult = [[managedObject mutableSetValueForKey:key] count];
    return countResult;
}

// Get the origin selected set in originTableView
- (NSMutableSet *)getOriginalManagedObjects:(UITableView *)originTableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    NSMutableSet *myMutableSet;
    // Get the selected NSManagedObjects in originTableView as a set
    for (NSIndexPath *obj in originTableView.indexPathsForSelectedRows) {
        if (!myMutableSet) {
            myMutableSet = [NSMutableSet setWithCapacity:1];
        }
        [myMutableSet addObject:[fetchedResultsController objectAtIndexPath:obj]];
    }
    return myMutableSet;
}


@end

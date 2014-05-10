//
//  UIViewController+DataExchange.h
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DataExchange)

#pragma mark - pre-selection action

- (void)preselectFromSet:(NSSet *)set inTableViewController:(TVTableViewController *)tableViewController;

#pragma mark - targetTable multiselection dataSource based on pre-selection

- (NSArray *)getDataSourceReadyFromDataSource:(NSArray *)array withPreselectedSet:(NSSet *)preselectedSet sortDescriptor:(NSSortDescriptor *)sortDescriptor;
- (NSArray *)getPreselectedArray:(NSSet *)preselectedSet sortDescriptor:(NSSortDescriptor *)sortDescriptor;
- (NSArray *)getUnselectedArrayFromDataSource:(NSArray *)array withPreselectedSet:(NSSet *)preselectedSet sortDescriptor:(NSSortDescriptor *)sortDescriptor;

#pragma mark - targetTable multiselection dataSource from originTableView

- (NSArray *)getTargetTableDataSourceArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor targetFetchedResultsController:(NSFetchedResultsController *)newFetchedResultsController;
- (NSArray *)getTargetTableDataSourceUnselectedArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor targetFetchedResultsController:(NSFetchedResultsController *)newFetchedResultsController;
- (NSArray *)getTargetTableDataSourceFullySelectedArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor;
- (NSArray *)getTargetTableDataSourcePartlySelectedArrayForEditModeFromOriginalTable:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipCountKey:(NSString *)key additionalSortDescripter:(NSSortDescriptor *)sortDescriptor;

- (NSMutableSet *)getPartlySelectedSetFromOriginalTable:(UITableView *)table fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipKey:(NSString *)key;
- (NSMutableSet *)getFullySelectedSetFromOriginalTable:(UITableView *)table fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipKey:(NSString *)key;
- (NSInteger)uniqueCount:(NSManagedObject *)managedObject byRelationshipKey:(NSString *)key;
- (NSMutableSet *)getTargetTableDataSourceSelectedSetForEditMode:(UITableView *)originTableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController byRelationshipKey:(NSString *)key;
- (NSMutableSet *)getOriginalManagedObjects:(UITableView *)originTableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

@end

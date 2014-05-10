//
//  UIViewController+CRUD.m
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "UIViewController+CRUD.h"

@implementation UIViewController (CRUD)

#pragma mark - record create/update/delete action
- (TVBase *)createRecord:(Class)recordClass recordInResponse:(NSDictionary *)recordInResponse inContext:(NSManagedObjectContext *)context withNewCardController:(TVNewBaseViewController *)controller withNonCardController:(TVNonCardsBaseViewController *)anotherController user:(TVUser *)user
{
    TVBase *record;
    if ([recordClass isSubclassOfClass:[TVCard class]]) {
        record = (TVCard *)[NSEntityDescription insertNewObjectForEntityForName:@"TVCard" inManagedObjectContext:context];
        [self writeToCard:(TVCard *)record recordInResponse:recordInResponse withController:controller withUser:user];
    }
    if ([recordClass isSubclassOfClass:[TVUser class]]) {
        record = (TVUser *)[NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:context];
        [self writeToUser:(TVUser *)record recordInResponse:recordInResponse];
    }
    
    if (recordInResponse) {
        // A new record needs to be created on client, the uncommited one should be checked to delete
    } else {
        // A new record is created through local input interface instead of from response
        [self createBefore:record];
    }
    
    return record;
}

// No need to commit the create action since the locally created records will be deleted and new records will created from the response.

- (void)updateRecord:(TVBase *)record recordInResponse:(NSDictionary *)recordInResponse withCardController:(TVNewBaseViewController *)controller withNonCardController:(TVNonCardsBaseViewController *)anotherController user:(TVUser *)user
{
    if ([record isKindOfClass:[TVCard class]]) {
        [self writeToCard:(TVCard *)record recordInResponse:recordInResponse withController:controller withUser:user];
    }
    if (recordInResponse) {
        [self updateAfter:record recordInResponse:recordInResponse];
    } else {
        [self updateBefore:record];
    }
}

- (void)commitUpdateRecord:(TVBase *)record recordInResponse:(NSDictionary *)recordInResponse
{
    [self updateAfter:record recordInResponse:recordInResponse];
}

- (void)deleteRecord:(TVBase *)record
{
    [self deleteBefore:record];
}

- (void)commitDeleteRecord:(TVBase *)record
{
    [self deleteAfter:record];
}

- (void)proceedChangesInContext:(NSManagedObjectContext *)context willSendRequest:(BOOL)willSendRequest
{
    TVAppRootViewController *myRootViewController = [self getAppRootViewController];
    myRootViewController.willSendRequest = willSendRequest;
    NSError *error = nil;
    if (![context save:&error]) {
        // Handle the error.
        UIAlertView *myTest = [[UIAlertView alloc] initWithTitle:@"Save error" message:@"failed" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
        [myTest show];
    }
}

- (void)writeToCard:(TVCard *)card recordInResponse:(NSDictionary *)recordDict withController:(TVNewBaseViewController *)controller withUser:(TVUser *)user
{
    if (recordDict) {
        [self convertDict:recordDict toNSManagedObj:card];
        [[card mutableSetValueForKey:@"hasTag"] setSet:[NSSet setWithArray:[recordDict valueForKey:@"cardTags"]]];
        // HasTag/collectedBy
        
        if ([[recordDict valueForKey:@"hasTag"] count] > 0) {
            
        }
    } else {
        card.context = controller.myContextView.text;
        card.target = controller.myTargetView.text;
        card.translation = controller.myTranslationView.text;
        card.detail = controller.myDetailView.text;
        card.createdAt = [NSDate date];
        card.collectedAt = [NSDate date];
        card.createdBy = user.email;
        card.sourceLang = user.sourceLang;
        card.targetLang = user.targetLang;
        NSMutableSet *cardTags = [NSMutableSet setWithCapacity:1];
        if ([controller.tagsMultiBaseViewController.myTableViewController.tableView.indexPathsForSelectedRows count] > 0) {
            for (NSIndexPath *path in controller.tagsMultiBaseViewController.myTableViewController.tableView.indexPathsForSelectedRows) {
                TVTag *tag = [controller.tagsMultiBaseViewController.myTableViewController.arrayDataSource objectAtIndex:path.row];
                if ([controller.tagsMultiBaseViewController.myTableViewController.tempAddedRows containsObject:tag]) {
                    // Update the tag
                    tag.createdAt = nil;
                    tag.createdBy = nil;
                    tag.createdAt = [NSDate date];
                    tag.createdBy = user.email;
                }
                [cardTags addObject:tag];
            }
        }
        
        [[card mutableSetValueForKey:@"hasTag"] setSet:cardTags];
    }
}


- (void)writeToUser:(TVUser *)user recordInResponse:(NSDictionary *)recordDict
{
    /*
     Creating a new user leads to creating a new TVUser obj from response, all the initial default settings come with the response. The rest modifications on this TVUser record are not sync back to the server.
     */
    if (recordDict) {
        user.email = [recordDict valueForKey:@"email"];
        // Default is YES
        user.isLoggedIn = [recordDict valueForKey:@"isLoggedIn"];
        // Default is collectedAtDAlphabetA
        // Default is YES
        user.needToUpdateRequestVersionNo = [recordDict valueForKey:@"needToUpdateRequestVersionNo"];
        user.sortOption = [recordDict valueForKey:@"sortOption"];
        // Default is the language pair with most cards on server
        user.sourceLang = [recordDict valueForKey:@"sourceLang"];
        user.targetLang = [recordDict valueForKey:@"targetLang"];
        
        // HasCards????????
    }
    // user.currentRequestVersion is edited according to sending request action, not here
    if (user.deviceUUID.length == 0) {
        user.deviceUUID = [recordDict valueForKey:@"deviceUUID"];
    }
}

#pragma mark - common create/update/delete action
// LocalID and serverID are not required at the same time, as long as at least there is one of them to locate the record.
// The same applies to lastModifiedAtLocal and lastModifiedAtServer.
// Create before sync, no lastModifiedServer, serverID, versionNo since client has not sync with server yet.
- (void)createBefore:(TVBase *)base
{
    [self actionBefore:base action:@"create"];
}

- (void)createAfter:(TVBase *)base rootResponse:(NSDictionary *)response
{
    NSNumber *responseRequestVersion = [response valueForKey:@"requestVersion"];
    if (responseRequestVersion.integerValue >= base.requestVersionNo.integerValue) {
        [base.managedObjectContext deleteObject:base];
    } else {
        // Do nothing, let the corresponding response handle it in the future
    }
}

// Update before sync
- (void)updateBefore:(TVBase *)base
{
    [self actionBefore:base action:@"update"];
}

- (void)updateAfter:(TVBase *)base recordInResponse:(NSDictionary *)record
{
    [self actionAfter:base recordInResponse:record];
}

// Delete before sync
- (void)deleteBefore:(TVBase *)base
{
    [self actionBefore:base action:@"delete"];
    if (base.serverID.integerValue == 0 || !base.serverID) {
        // No serverID, must be created after last sync, delete right away
        [self deleteAfter:base];
    }
}

- (void)deleteAfter:(TVBase *)base
{
    // delete instantly
    [base.managedObjectContext deleteObject:base];
}

- (void)actionBefore:(TVBase *)base action:(NSString *)action
{
    base.editAction = action;
    base.lastModifiedAtLocal = [NSDate date];
}

- (void)actionAfter:(TVBase *)base recordInResponse:(NSDictionary *)record
{
    base.editAction = @"";
    base.requestVersionNo = [NSNumber numberWithInteger:0];
    base.lastModifiedAtServer = [record valueForKey:@"lastModifiedAtServer"];
    base.versionNo = [record valueForKey:@"versionNo"];
}


@end

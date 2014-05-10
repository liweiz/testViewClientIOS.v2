//
//  UIViewController+sharedMethods.m
//  testView
//
//  Created by Liwei on 2013-08-08.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "UIViewController+sharedMethods.h"

@implementation UIViewController (sharedMethods)



#pragma mark - remove blank spaces at the beginning and end of any input
- (NSString *)trimInput:(NSString *)text
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [text stringByTrimmingCharactersInSet:whitespace];
    return trimmed;
}


#pragma mark - multiselection and save

// multiselection tableViewCell has three statuses: 0: unselected, 1: fully selected, 2: partly selected

// Generate a NSSet of NSManagedObjects for next step's adding/removing operation
// Get the changed set from TVTableViewController.changeMadeSet
- (void)changeSet:(NSSet *)changeSet relationshipKey:(NSString *)key selectionSetOrigin:(NSSet *)originSet
{
    for (NSMutableArray *obj in changeSet) {
        if ([[obj lastObject] integerValue] == 1) {
            // To be added: origin status is 0 or 2, final status is 1
            [[[obj firstObject] mutableSetValueForKey:key] unionSet:originSet];
        } else if ([[obj lastObject] integerValue] == 0) {
            // To be removed: origin status is 1 or 2, final status is 0
            [[[obj firstObject] mutableSetValueForKey:key] minusSet:originSet];
        }
    }
}

- (void)saveMultiselectionChange:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
        UIAlertView *myTest = [[UIAlertView alloc] initWithTitle:@"Save error" message:@"failed" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
        [myTest show];
    }
}

#pragma mark - horizontal scrolling freeze/defreeze

// Freeze the rootView's horizontally scrolling
- (void)freezeRootView
{
    UIScrollView *rootScrollView = (UIScrollView *)[[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:555];
    rootScrollView.scrollEnabled = NO;
}

// Enable the rootView's horizontally scrolling
- (void)defreezeRootView
{
    UIScrollView *rootScrollView = (UIScrollView *)[[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:555];
    rootScrollView.scrollEnabled = YES;
}




#pragma mark - Load file from supporting files
- (NSArray *)loadLangArray
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"langListLong" ofType:@"txt"];
    if (filePath) {
        NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:nil];
        NSArray *stringArray = [contents componentsSeparatedByString:@"\r\n"];
        for (NSString *obj in stringArray) {
            if (![obj isEqualToString:@""]) {
                NSString *newObj = [NSString localizedNameOfStringEncoding:NSUnicodeStringEncoding];
                newObj = obj;
                [tempArray addObject:newObj];
            }
        }
    }
    return tempArray;
}

#pragma mark - RequestVersion generator and unique string for device identification
/*
 When to edit requestVersionNo for corresponding records?
 The requestVersionNo is reevaluated while a request is compiled and sent.
 Every edit action means the record is not the same as before, hence the previous version sent with any request needs to be updated. In this case, clear the requestVersionNo in this record to let the next request assign a new requestVersionNo.
 In short, there should be a pair of editAction and requestVersionNo. If any one of the pair is missing, the record is either not needed to be sent or a new requestVersionNo is needed to proceed. Everytime a request is sent, the system elavuate is a new requestVersionNo is needed. If yes, the new one will be assigned to TVUser and records needed.
 */
// This will be triggered when
- (void)switchRequestVersionNoUpdate:(TVUser *)user
{
    if (user.needToUpdateRequestVersionNo.boolValue == YES) {
        user.needToUpdateRequestVersionNo = [NSNumber numberWithBool:NO];
    } else {
        user.needToUpdateRequestVersionNo = [NSNumber numberWithBool:YES];
    }
}

- (void)assignRequestVersionNoWithUser:(TVUser *)user allRecord:(NSArray *)allRecord
{
    // Put all the records need to be sent, in other words, combine cards, tags, etc and create/update/delete
    
    user.needToUpdateRequestVersionNo = [NSNumber numberWithBool:NO];
    
    for (TVBase *record in allRecord) {
        // requestVersionNo is set to be nil if other edit action happens after last request.
        // So nil in requestVersionNo means requestVersionNo for this record needs to be assigned a new value
        if (!record.requestVersionNo) {
            [self switchRequestVersionNoUpdate:user];
            break;
        }
    }
    if (user.needToUpdateRequestVersionNo.boolValue == YES) {
        user.currentRequestVersion = [self generateRequestVersionNo:user.currentRequestVersion];
        for (TVBase *record in allRecord) {
            if (!record.requestVersionNo) {
                record.requestVersionNo = [NSNumber numberWithBool:user.currentRequestVersion.boolValue];
            }
        }
    }
}

- (NSNumber *)generateRequestVersionNo:(NSNumber *)currentRequestVersionNo
{
    NSInteger versionNo;
    if (currentRequestVersionNo.integerValue == 0) {
        versionNo = 1;
    } else {
        versionNo = currentRequestVersionNo.integerValue + 1;
    }
    return [NSNumber numberWithInteger:versionNo];
}

- (NSString *)getUUID
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

@end
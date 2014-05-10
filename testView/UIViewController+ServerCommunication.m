//
//  UIViewController+ServerCommunication.m
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "UIViewController+ServerCommunication.h"

@implementation UIViewController (ServerCommunication)

#pragma mark - sync action utilities
// Get rootViewController
- (TVAppRootViewController *)getAppRootViewController
{
    return (TVAppRootViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
}

// NSDate <=> NSString JSON date string http://en.wikipedia.org/wiki/ISO_8601 e.g., 2013-09-29T10:40Z
- (NSString *)convertNSDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)convertISO8601String:(NSString *)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    return [formatter dateFromString:string];
}

// NSManagedObject <=> NSDictionary
- (NSDictionary *)convertNSManagedObjToDict:(TVBase *)record withEntityDescription:(NSEntityDescription *)description
{
    NSMutableDictionary *recordDict = [NSMutableDictionary dictionaryWithSharedKeySet:[NSDictionary sharedKeySetForKeys:description.attributesByName.allKeys]];
    for (NSString *aKey in description.attributesByName.allKeys) {
        if ([record valueForKey:aKey]) {
            // Not nil
            if ([[record valueForKey:aKey] isKindOfClass:[NSDate class]]) {
                [recordDict setObject:[self convertNSDate:[record valueForKey:aKey]] forKey:aKey];
            } else {
                [recordDict setObject:[record valueForKey:aKey] forKey:aKey];
            }
        } else {
            // Nil, assign Null
            [recordDict setObject:[NSNull null] forKey:aKey];
        }
    }
    for (NSString *aRelationship in description.relationshipsByName.allKeys) {
        if ([aRelationship isEqualToString:@"collectedBy"]) {
            // Could be email NSString/serverID NSNumber to stand for user here
            [recordDict setValue:[[record valueForKey:@"collectedBy"] valueForKey:@"email"] forKey:aRelationship];
        } else {
            // User's hasCards is not sync here, so no need to prepare that so far
            // JUST ASSIGN NULL, WILL CHANGE ONCE TAG IS INTRODUCED
            [recordDict setValue:[NSNull null] forKey:aRelationship];
        }
    }
    return recordDict;
}

- (TVBase *)convertDict:(NSDictionary *)recordDict toNSManagedObj:(TVBase *)record
{
    for (NSString *aKey in recordDict.allKeys) {
        if ([recordDict valueForKey:aKey] != [NSNull null]) {
            // Not null in JSON, not NSNull in NSDictionary
            // NSDate?
            NSArray *dateKeys = @[@"lastModifiedAtLocal", @"lastModifiedAtServer", @"collectedAt", @"createdAt", @"timeAdded", @"timeStamp"];
            for (NSString *dateKey in dateKeys) {
                if ([aKey isEqualToString:dateKey]) {
                    // Convert to NSDate, if not nil
                    NSString *dateString = [recordDict valueForKey:aKey];
                    if (dateString.length > 0) {
                        // Not nil
                        [record setValue:[self convertISO8601String:dateString] forKey:aKey];
                    } else {
                        // Nil
                        [record setValue:nil forKey:aKey];
                    }
                }
            }
            // Standing for relationships?
            NSArray *relationshipKeys = @[@"hasTag", @"hasCard", @"hasCards"];
            for (NSString *relationshipKey in relationshipKeys) {
                // There is no nil for relationship set, only empty set
                if ([aKey isEqualToString:relationshipKey]) {
                    NSSet *theRelationships = [NSSet setWithArray:[recordDict valueForKey:aKey]];
                    [[record mutableSetValueForKey:relationshipKey] setSet:theRelationships];
                }
            }
            if ([aKey isEqualToString:@"collectedBy"]) {
                TVAppRootViewController *myRootViewController = [self getAppRootViewController];
                [record setValue:myRootViewController.user forKey:@"collectedBy"];
            }
        } else {
            // Nil
            [record setValue:nil forKey:aKey];
        }
    }
    return record;
}

- (void)handleConnectionError:(ConnectionErrorStatus)errorStatus
{
    switch (errorStatus) {
        case ServerNotAvailable:
            [self showAlertForMessage:@"Please make sure the internet service is available and try again." title:@"No Connection"];
            break;
        case AccountAlreadyExists:
            [self showAlertForMessage:@"This e-mail is already taken." title:@"Sign Up Not Successful"];
            break;
        case IncorrectAccountNameOrPassword:
            [self showAlertForMessage:@"Invalid e-mail or password." title:@"Sign In Not Successful"];
            break;
        case NoDataDownloaded:
            [self showAlertForMessage:@"Please try again later." title:@"Connection Not Successful"];
            break;
        case TimeOut:
            [self showAlertForMessage:@"Please try again later." title:@"Time Out"];
            break;
        case NoSuchAccountExists:
            [self showAlertForMessage:@"No account with that e-mail address exists." title:@"Not Able to Reset Password"];
            break;
        case OtherError:
            [self showAlertForMessage:@"" title:@"Error"];
            break;
        default:
            break;
    }
}

- (void)showAlertForMessage:(NSString *)message title:(NSString *)title
{
    UIAlertView *myTest = [[UIAlertView alloc] initWithTitle:@"Save error" message:@"failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [myTest show];
}

#pragma mark - sync action response
// Action based on HTTP code
- (BOOL)statusCheckForResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode == 200) {
        return YES;
    } else {
        return NO;
    }
}

// Process the JSON from response
- (BOOL)handleLoginResponse:(NSHTTPURLResponse *)response withData:(NSData *)data
{
    // Login response returns a new token and after the token is saved to keychain and , a new request is launched automatically
    // to execute the general data sync process
    if ([self savePassToKeychainFromResponse:response withData:data]) {
        // Valid token received, proceed to dataSync
        NSSet *entitySet = [NSSet setWithObject:@"TVCard"];
        NSDictionary *rootDict = [self getDictFromResponse:response withData:data];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
        // NEED TO TEST
        NSPredicate *predicateAction = [NSPredicate predicateWithFormat:@"email like %@", [rootDict valueForKey:@"email"]];
        [request setPredicate:predicateAction];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedAtLocal" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        NSArray *userArray = [[self getAppRootViewController].managedObjectContext executeFetchRequest:request error:nil];
        // Get setup user
        TVUser *user;
        if ([userArray count] > 0) {
            // The user exists in local, no need to get the user from response
            user = [userArray objectAtIndex:0];
        } else {
            // No user exists in local, need to get the user from response
            user = (TVUser *)[self createRecord:[TVUser class] recordInResponse:[rootDict valueForKey:@"user"] inContext:[self getAppRootViewController].managedObjectContext withNewCardController:nil withNonCardController:nil user:nil];
            // Commit the changes in persistence store
            [self proceedChangesInContext:[self getAppRootViewController].managedObjectContext willSendRequest:NO];
        }
        // Send dataSync request once the user logs in successfully
        [self startSyncEntitySet:entitySet withNewCardController:nil user:user];
        return YES;
    } else {
        // No token received, need to sign in again
        return NO;
    }
}

- (BOOL)savePassToKeychainFromResponse:(NSHTTPURLResponse *)response withData:(NSData *)data
{
    NSDictionary *rootDict = [self getDictFromResponse:response withData:data];
    if ([(NSString *)[rootDict valueForKey:@"pass"] length] > 0) {
        // NEED TO UPDATE @"YOUR_APP_ID_HERE.com.yourcompany.GenericKeychainSuite"
        KeychainItemWrapper *pass = [[KeychainItemWrapper alloc] initWithAccount:[rootDict valueForKey:@"email"] service:nil accessGroup:nil];
        [pass setObject:[rootDict valueForKey:@"pass"] forKey:(__bridge id)kSecValueData];
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)getPassFromKeychainEmail:(NSString *)email
{
    // NEED TO UPDATE @"YOUR_APP_ID_HERE.com.yourcompany.GenericKeychainSuite"
    KeychainItemWrapper *pass = [[KeychainItemWrapper alloc] initWithAccount:email service:nil accessGroup:nil];
    return [pass objectForKey:(__bridge id)kSecValueData];
}

- (void)handleDataSyncResponse:(NSHTTPURLResponse *)response withData:(NSData *)data user:(TVUser *)user withNewCardController:(TVNewBaseViewController *)controller
{
    NSDictionary *rootDict = [self getDictFromResponse:response withData:data];
    [self processEntity:@"TVCard" inContext:user.managedObjectContext withNewCardController:controller withNonCardController:nil user:user rootResponse:rootDict];
}

- (NSDictionary *)getDictFromResponse:(NSHTTPURLResponse *)response withData:(NSData *)data
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}

- (void)processEntity:(NSString *)entityName inContext:(NSManagedObjectContext *)context withNewCardController:(TVNewBaseViewController *)controller withNonCardController:(TVNonCardsBaseViewController *)anotherController user:(TVUser *)user rootResponse:(NSDictionary *)rootResponse
{
    NSDictionary *dict;
    if ([entityName isEqualToString:@"TVCard"]) {
        NSArray *localCards = [self getLocalRecordsForEntityName:@"TVCard" user:user];
        dict = [self categorizeCreateUpdateDeleteInRecords:[rootResponse valueForKey:@"card"] user:user inLocalEntity:localCards];
    }
    
    NSArray *entityToCreate = [dict valueForKey:@"create"];
    NSArray *entityToUpdate = [dict valueForKey:@"update"];
    NSArray *entityToDelete = [dict valueForKey:@"delete"];
    if ([entityToCreate count] > 0) {
        if ([entityName isEqualToString:@"TVCard"]) {
            for (NSDictionary *entityRecord in entityToCreate) {
                [self createRecord:[TVCard class] recordInResponse:entityRecord inContext:context withNewCardController:controller withNonCardController:nil user:user];
            }
            NSArray *toDelete = [self getArrayForSyncRequestWithEntityName:@"TVCard" forAction:@"create" inContext:context convertNSManagedObjToDict:NO];
            for (TVCard *obj in toDelete) {
                // A new record needs to be created on client, the uncommited one should be checked to delete
                [self createAfter:obj rootResponse:rootResponse];
            }
        }
    }
    if ([entityToUpdate count] > 0) {
        if ([entityName isEqualToString:@"TVCard"]) {
            for (NSDictionary *entityRecord in entityToUpdate) {
                TVCard *cardToUpdate = (TVCard *)[self getRecordForServerID:[entityRecord valueForKey:@"serverID"] WithEntityName:@"TVCard" inContext:context];
                [self updateRecord:cardToUpdate recordInResponse:entityRecord withCardController:controller withNonCardController:nil user:user];
            }
        }
    }
    if ([entityToDelete count] > 0) {
        if ([entityName isEqualToString:@"TVCard"]) {
            for (NSDictionary *entityRecord in entityToDelete) {
                TVCard *cardToDelete = (TVCard *)[self getRecordForServerID:[entityRecord valueForKey:@"serverID"] WithEntityName:@"TVCard" inContext:context];
                // Delete happens only when the record exists in local
                if (cardToDelete) {
                    [self commitDeleteRecord:cardToDelete];
                }
            }
        }
    }
    // Commit the changes in persistence store
    [self proceedChangesInContext:context willSendRequest:NO];
}

- (NSArray *)getLocalRecordsForEntityName:(NSString *)entityName user:(TVUser *)user
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    // NEED TO TEST
    NSPredicate *predicateAction = [NSPredicate predicateWithFormat:@"(%@ IN collectedBy)", user];
    [request setPredicate:predicateAction];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedAtLocal" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    return [user.managedObjectContext executeFetchRequest:request error:nil];
}

- (TVBase *)getRecordForServerID:(NSNumber *)ID WithEntityName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    NSPredicate *predicateAction = [NSPredicate predicateWithFormat:@"serverID == %d", ID.integerValue];
    [request setPredicate:predicateAction];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedAtLocal" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    NSArray *array = [context executeFetchRequest:request error:nil];
    return [array objectAtIndex:0];
}

- (NSDictionary *)categorizeCreateUpdateDeleteInRecords:(NSArray *)records user:(TVUser *)user inLocalEntity:(NSArray *)localRecords
{
    /*
     Server delivers records meet following criteria:
     1. versionNo greater than local user's highestLastSyncVersionNo
     2. for deleted ones on server, deliver those with versionNoInitial not greater than local user's highestLastSyncVersionNo and versionNo greater than local user's highestLastSyncVersionNo
     
     Filter through both versionNoInitial and versionNo.
     */
    // Firstly, check if server passes the right records
    NSMutableArray *toDelete = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *toCreate = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *toUpdate = [NSMutableArray arrayWithCapacity:1];
    for (TVBase *obj in records) {
        if (obj.deletedOnServer.boolValue == YES && obj.versionNoInitial.integerValue <= user.highestLastSyncVersionNo.integerValue && obj.versionNo.integerValue > user.highestLastSyncVersionNo.integerValue) {
            // Add to Delete array
            [toDelete addObject:obj];
        }
        else if (obj.deletedOnServer.boolValue == NO && obj.versionNo.integerValue > user.highestLastSyncVersionNo.integerValue) {
            // This is for create and update
            for (TVBase *localObj in localRecords) {
                if (obj.serverID.integerValue == localObj.serverID.integerValue) {
                    // There is a local record, update
                    [toUpdate addObject:obj];
                } else {
                    // No local record, create
                    [toCreate addObject:obj];
                }
            }
        }
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:toDelete forKey:@"delete"];
    [dict setValue:toCreate forKey:@"create"];
    [dict setValue:toUpdate forKey:@"update"];
    return dict;
}



@end

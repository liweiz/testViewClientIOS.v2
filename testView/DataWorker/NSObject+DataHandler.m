//
//  NSObject+DataHandler.m
//  testView
//
//  Created by Liwei on 2014-05-14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "NSObject+DataHandler.h"
#import "KeychainItemWrapper.h"
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestIdCandidate.h"
#import "TVAppRootViewController.h"
#import "TVQueueElement.h"
#import "TVCRUDChannel.h"

#import "TVIdPair.h"

@implementation NSObject (DataHandler)

#pragma - mark sync cycle

// First find undone records one by one, and after all are clear, send sync request. The process can be disrupted at any time when local db changes.

// Get all unsync records for further process
- (NSMutableArray *)getUndoneSet:(NSManagedObjectContext *)ctx userId:(NSString *)userServerId
{
    NSMutableArray *r = [NSMutableArray arrayWithCapacity:0];
    NSFetchRequest *fetchUser = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSPredicate *pUser = [NSPredicate predicateWithFormat:@"serverId == %@ && lastUnsyncAction != %d", userServerId, TVDocNoAction];
    fetchUser.predicate = pUser;
    NSFetchRequest *fetchCard = [NSFetchRequest fetchRequestWithEntityName:@"TVCard"];
    NSPredicate *pCard = [NSPredicate predicateWithFormat:@"belongToUser == %@ && lastUnsyncAction != %d", userServerId, TVDocNoAction];
    fetchCard.predicate = pCard;
    NSMutableArray *r1;
    if ([self fetch:fetchUser withCtx:ctx outcome:r1]) {
        if ([r1 count] > 0) {
            [r addObject:r1[0]];
        }
        NSMutableArray *r2;
        if ([self fetch:fetchCard withCtx:ctx outcome:r2]) {
            if ([r2 count] > 0) {
                [r addObjectsFromArray:r2];
            }
        }
    }
    return r;
}

#pragma - mark managedObject Dictionary converter

- (NSDictionary *)convertCardObjToDic:(NSManagedObject *)obj
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

- (NSDictionary *)convertUserObjToDic:(NSManagedObject *)obj
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setValue:[obj valueForKey:@"serverId"] forKey:@"serverId"];
    [d setValue:[obj valueForKey:@"activated"] forKey:@"activated"];
    [d setValue:[obj valueForKey:@"isSharing"] forKey:@"isSharing"];
    [d setValue:[obj valueForKey:@"isLoggedIn"] forKey:@"isLoggedIn"];
    [d setValue:[obj valueForKey:@"sourceLang"] forKey:@"sourceLang"];
    [d setValue:[obj valueForKey:@"targetLang"] forKey:@"targetLang"];
    [d setValue:[obj valueForKey:@"deviceInfoId"] forKey:@"deviceInfoId"];
    [d setValue:[obj valueForKey:@"deviceUUID"] forKey:@"deviceUUID"];
    return d;
}

#pragma - mark create new

- (void)setupNewDocBaseLocal:(TVBase *)doc
{
    doc.serverId = @"";
    doc.localId = [[NSUUID UUID] UUIDString];
    doc.locallyDeleted = [NSNumber numberWithBool:NO];
    doc.lastModifiedAtLocal = [NSDate date];
}

// dicInside is the dictionary standing for user/deviceInfo/card, etc.
- (void)setupNewDocBaseServer:(TVBase *)doc fromRequest:(NSDictionary *)dicInside
{
    doc.serverId = [dicInside valueForKey:@"_id"];
    doc.locallyDeleted = [NSNumber numberWithBool:NO];
    if ([dicInside valueForKey:@"lastModified"]) {
        doc.lastModifiedAtServer = [dicInside valueForKey:@"lastModified"];
    }
    doc.versionNo = [dicInside valueForKey:@"versionNo"];
}

// A new user must be from server. The info user inputs is not stored as local record in db but send to server and create a record based on the response from server.
- (void)setupNewUserServer:(TVUser *)user withDic:(NSDictionary *)dic
{
    if ([dic valueForKey:@"user"]) {
        NSMutableDictionary *u = [dic valueForKey:@"user"];
        user.activated = [u valueForKey:@"activated"];
        user.email = [u valueForKey:@"email"];
        user.isSharing = [u valueForKey:@"isSharing"];
        user.sourceLang = [u valueForKey:@"sourceLang"];
        user.targetLang = [u valueForKey:@"targetLang"];
    }
//    if ([dic valueForKey:@"deviceInfo"]) {
//        NSMutableDictionary *d = [dic valueForKey:@"user"];
//        if (!user.deviceUUID) {
//            user.deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//        }
//        user.isLoggedIn = [d valueForKey:@"isLoggedIn"];
//        user.rememberMe = [d valueForKey:@"rememberMe"];
//    }
}

- (void)setupNewCard:(TVCard *)card withDic:(NSDictionary *)dic
{
    card.belongTo = [dic valueForKey:@"belongTo"];
    card.collectedAt = [NSDate date];
    card.context = [dic valueForKey:@"context"];
    card.detail = [dic valueForKey:@"detail"];
    card.target = [dic valueForKey:@"target"];
    card.translation = [dic valueForKey:@"translation"];
    card.sourceLang = [dic valueForKey:@"sourceLang"];
    card.targetLang = [dic valueForKey:@"targetLang"];
}

- (void)setupNewRequestIdCandidate:(TVRequestIdCandidate *)doc action:(NSInteger)a for:(TVBase *)base
{
    doc.editAction = [NSNumber numberWithInteger:a];
    doc.requestId = [[NSUUID UUID] UUIDString];
    doc.done = [NSNumber numberWithBool:NO];
    doc.createdAtLocal = [NSDate date];
    doc.lastModifiedAtLocal = [NSDate date];
    doc.operationVersion = [NSNumber numberWithInteger:[self getRequestIdCandidateOperationVersion:base]];
    doc.belongTo = base;
}

#pragma - mark update

- (void)updateDocBaseLocal:(TVBase *)doc
{
    doc.lastModifiedAtLocal = [NSDate date];
}

- (void)generateRequestInfoForRequestIdCandidate:(TVRequestIdCandidate *)doc
{
    doc.requestId = [[NSUUID UUID] UUIDString];
    doc.lastModifiedAtLocal = [NSDate date];
}

- (void)markRequestIdAsDone:(TVRequestIdCandidate *)reqId
{
    // change in requestID does not change time modified
    reqId.done = [NSNumber numberWithBool:YES];
    reqId.lastModifiedAtLocal = [NSDate date];
}

- (void)updateDocBaseServer:(TVBase *)doc withDic:(NSDictionary *)dicInside
{
    if ([dicInside valueForKey:@"lastModified"]) {
        doc.lastModifiedAtServer = [dicInside valueForKey:@"lastModified"];
    }
    doc.serverId = [dicInside valueForKey:@"_id"];
//    if (!doc.serverId || [doc.serverId isEqualToString:@""]) {
//        doc.serverId = [dicInside valueForKey:@"serverId"];
//    }
    doc.versionNo = [dicInside valueForKey:@"versionNo"];
}

- (void)updateUser:(TVUser *)user withDic:(NSDictionary *)dic
{
    if ([dic valueForKey:@"user"]) {
        user.activated = [[dic valueForKey:@"user"] valueForKey:@"activated"];
        user.isSharing = [[dic valueForKey:@"user"] valueForKey:@"isSharing"];
    }
    if ([dic valueForKey:@"deviceInfo"]) {
        NSMutableDictionary *d = [dic valueForKey:@"deviceInfo"];
//        user.deviceUUID = [d valueForKey:@"deviceUUID"];
        user.targetLang = [d valueForKey:@"targetLang"];
        NSLog(@"user.deviceInfoId: %@", user.deviceInfoId);
        NSLog(@"user.objectID: %@", user.objectID);
        if (!user.deviceInfoId || [user.deviceInfoId isEqualToString:@""]) {
            user.deviceInfoId = [d valueForKey:@"_id"];
        }
    }
}

- (void)updateCard:(TVCard *)card withDic:(NSDictionary *)dicInside
{
    if (!card.belongTo) {
        card.belongTo = [dicInside valueForKey:@"belongTo"];
    }
    if (!card.sourceLang) {
        card.sourceLang = [dicInside valueForKey:@"sourceLang"];
    }
    if (!card.targetLang) {
        card.targetLang = [dicInside valueForKey:@"targetLang"];
    }
    if ([dicInside valueForKey:@"collectedAt"]) {
        card.collectedAt = [dicInside valueForKey:@"collectedAt"];
    }
    card.context = [dicInside valueForKey:@"context"];
    card.detail = [dicInside valueForKey:@"detail"];
    card.target = [dicInside valueForKey:@"target"];
    card.translation = [dicInside valueForKey:@"translation"];
}

#pragma - mark delete

- (void)deleteDocBaseLocal:(TVBase *)doc
{
    // requestID is not processed here
    doc.locallyDeleted = [NSNumber numberWithBool:YES];
    doc.lastModifiedAtLocal = [NSDate date];
}

- (void)deleteDocBaseServerWithServerId:(NSString *)serverId inCtx:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:@"TVCard"];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"serverId like %@",
    serverId];
    [r setPredicate:p];
    NSArray *a = [ctx executeFetchRequest:r error:nil];
    if ([a count] > 0) {
        [ctx deleteObject:a[0]];
    }
}

#pragma mark - read

- (TVUser *)getLoggedInUser:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSMutableArray *r;
    if ([ctx fetch:fr withCtx:ctx outcome:r]) {
        if ([r count] != 0) {
            for (TVUser *u in r) {
                NSString *s = [self getRefreshTokenForAccount:u.serverId];
                if (s.length != 0) {
                    return u;
                }
            }
        }
    }
    return nil;
}

- (NSArray *)getCards:(NSString *)userServerId inCtx:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"TVCard"];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(belongToUser like %@) && !(locallyDeleted like NO)", userServerId];
    [fr setPredicate:p];
    NSMutableArray *r;
    if ([self fetch:fr withCtx:ctx outcome:r]) {
        return r;
    }
    return nil;
}

- (TVCard *)getOneCard:(TVIdPair *)cardIds inCtx:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"TVCard"];
    if (cardIds.serverId.length > 0) {
        NSPredicate *p1 = [NSPredicate predicateWithFormat:@"serverId like %@", cardIds.serverId];
        [fr setPredicate:p1];
    }
    NSMutableArray *r;
    if ([self fetch:fr withCtx:ctx outcome:r]) {
        if ([r count] > 0) {
            return r[0];
        } else {
            NSPredicate *p2 = [NSPredicate predicateWithFormat:@"localId like %@", cardIds.localId];
            [fr setPredicate:p2];
            if ([self fetch:fr withCtx:ctx outcome:r]) {
                if ([r count] > 0) {
                    return r[0];
                }
            }
        }
    }
    return nil;
}

#pragma mark - idCarrier

- (NSSet *)getObjInCarrier:(NSSet *)ids entityName:(NSString *)name inCtx:(NSManagedObjectContext *)ctx
{
    NSMutableSet *s = [NSMutableSet setWithCapacity:0];
    if ([ids count] > 0) {
        NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:name];
        for (TVIdPair *pair in ids) {
            if (pair.serverId.length > 0) {
                NSPredicate *p1 = [NSPredicate predicateWithFormat:@"serverId == %@", pair.serverId];
                [fr setPredicate:p1];
                NSMutableArray *a1;
                if ([self fetch:fr withCtx:ctx outcome:a1]) {
                    if ([a1 count] > 0) {
                        [s addObject:a1[0]];
                    }
                }
                if ([a1 count] == 0) {
                    // No serverId matched before, look up with localId
                    if (pair.localId.length > 0) {
                        NSPredicate *p2 = [NSPredicate predicateWithFormat:@"localId == %@", pair.localId];
                        [fr setPredicate:p2];
                        NSMutableArray *a2;
                        if ([self fetch:fr withCtx:ctx outcome:a2]) {
                            if ([a2 count] > 0) {
                                [s addObject:a2[0]];
                            }
                        }
                    }
                }
            }
        }
    }
    return s;
}

#pragma mark - get objs by given ids

// ids has NSDictionary values like this: 1. @"serverId": store the serverId 2. @"localId": store the localId
- (NSArray *)getObjs:(NSSet *)ids name:(NSString *)entityName inCtx:(NSManagedObjectContext *)ctx
{
    NSMutableSet *serverIdToProcess = [NSMutableSet setWithCapacity:0];
    NSMutableSet *localIdToProcess = [NSMutableSet setWithCapacity:0];
    for (NSDictionary *d in ids) {
        NSString *serverId = [d valueForKey:@"serverId"];
        NSString *localId = [d valueForKey:@"localId"];
        // Only add non-empty ones.
        if (serverId.length > 0) {
            [serverIdToProcess addObject:serverId];
        }
        if (localId.length > 0) {
            [localIdToProcess addObject:localId];
        }
    }
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"serverId in %@",
                       serverIdToProcess];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"localId in %@",
                       localIdToProcess];
    [r setPredicate:p1];
    NSMutableArray *a1;
    if ([self fetch:r withCtx:ctx outcome:a1]) {
        // Remove localId corresponding to serverId that has been fetched.
        for (TVBase *b in a1) {
            for (NSDictionary *obj in ids) {
                NSString *serverId = [obj valueForKey:@"serverId"];
                NSString *localId = [obj valueForKey:@"localId"];
                if ([serverId isEqualToString:b.serverId]) {
                    for (NSString *l in localIdToProcess) {
                        if ([l isEqualToString:localId]) {
                            [localIdToProcess removeObject:l];
                            break;
                        }
                    }
                }
            }
        }
        NSMutableArray *a2;
        [r setPredicate:p2];
        if ([self fetch:r withCtx:ctx outcome:a2]) {
            [a1 addObjectsFromArray:a2];
            return a1;
        }
    }
    return nil;
}

#pragma mark - find a card from array

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

#pragma mark - fetch & save data process

// Its return value indicates if the save operation is successful.
- (BOOL)fetch:(NSFetchRequest *)r withCtx:(NSManagedObjectContext *)ctx outcome:(NSMutableArray *)outcome
{
    NSError *err;
    NSArray *a = [ctx executeFetchRequest:r error:&err];
    if (!err) {
        [[NSNotificationCenter defaultCenter] postNotificationName:tvFetchOrSaveErr object:self];
        return NO;
    } else {
        outcome = [NSMutableArray arrayWithArray:a];
        return YES;
    }
}

// Its return value indicates if the save operation is successful.
- (BOOL)saveWithCtx:(NSManagedObjectContext *)ctx
{
    NSError *err;
    [ctx save:&err];
    if (!err) {
        [[NSNotificationCenter defaultCenter] postNotificationName:tvFetchOrSaveErr object:self];
        return NO;
    } else {
        return YES;
    }
}



#pragma mark - sync

// The user in sync cycle is for deviceInfo
/*
 We have to fulfill two goals:
 A. push latest local content change to server.
 B. get most updated content from server after all.
 
 For A, we need:
 (1) the specific type of crud operation to generate correct url.
 (2) a way to find out which records to be pushed to server.
 (3) something to record each request's completion status.
 For (1) keep all the operations for a record in an array.
 For (2) add a flag to each record.
 For (3) create an obj for each request to record the completion status.
 
 Regarding (2) above, due to the async nature of push operation, there could be new operation done to the local record after the request for previous change is sent. The 200 response can only indicates previous operation is pushed, not that there is nothing to push to server for this record now. So a straightforward flag may not be the simple answer to this. An easy way is to append the request info in the array as well. Because a request is specificly corresponding to a crud operation, it's better to have crud operation and request info in on objin the array. Thus, (3) is fulfilled,too.
 Based on the reasons above, we create TVRequestIdCandidate as the element for the array. A TVRequestIdCandidate contains: (a) the info of crud operation type (b) a flag to mark a request is done if needed, which is marked done when 200 response is received. (c) the requestId to identify any potential request both on client and server (d) operationVersion to store the order number to indicate the sequence of each element to form the array. A non-nil requestId indicates it's an element having corresponding request sent.
 
 
 When nil is returned, which indicates no requestId for next steps, we don't need to proceed further since the client has already got the message from server that the request has been successfully processed on server.
*/
- (TVRequestIdCandidate *)analyzeOneRecord:(TVBase *)b inCtx:(NSManagedObjectContext *)ctx serverIsAvailable:(BOOL)isAvail
{
    // Get array with descending order to loop from the last obj.
    NSMutableArray *ids = [self getRequestIdCandidatesForRecord:b ascending:NO];
    if ([ids count] == 0) {
        // No local operation for this record, pass.
        return nil;
    } else {
        // Check last obj first
        TVRequestIdCandidate *lastObj = ids[0];
        if (lastObj.requestId.length == 0) {
            // Lastest operation not being pushed before, push it now if server is available
            if (isAvail) {
                [self generateRequestInfoForRequestIdCandidate:lastObj];
                if ([self saveWithCtx:ctx]) {
                    return lastObj;
                }
            }
            // Not able to proceed, wait for next time to retry
            return nil;
        } else {
            // Lastest operation has been pushed
            if (lastObj.done) {
                // Successfully pushed
                return nil;
            } else {
                // Push again
                return lastObj;
            }
        }
    }
}

#pragma mark - requestIdCandidate related process
- (TVRequestIdCandidate *)findReqCandidate:(TVBase *)b byReqId:(NSString *)reqId
{
    NSArray *a = [self getRequestIdCandidatesForRecord:b ascending:NO];
    for (TVRequestIdCandidate *c in a) {
        if (c.requestId.length > 0) {
            if ([reqId isEqualToString:c.requestId]) {
                return c;
            }
        }
    }
    return nil;
}

- (NSInteger)getRequestIdCandidateOperationVersion:(TVBase *)base
{
    if ([base.hasReqIdCandidate count] == 0) {
        // operationVersion starts from 1.
        return 1;
    } else {
        NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:YES];
        return [[[base.hasReqIdCandidate sortedArrayUsingDescriptors:@[s]].lastObject operationVersion] integerValue] + 1;
    }
}

- (NSMutableArray *)getRequestIdCandidatesForRecord:(TVBase *)b ascending:(BOOL)ascending
{
    NSSet *bSet = b.hasReqIdCandidate;
    NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:ascending];
    NSArray *reqIds = [bSet sortedArrayUsingDescriptors:@[s]];
    NSMutableArray *a = [[NSMutableArray alloc] init];
    [a addObjectsFromArray:reqIds];
    return a;
}

- (BOOL)dismissChangeToDBRecord:(TVBase *)base requestIdObj:(TVRequestIdCandidate *)d
{
    // For given record in local db base, check response for request identified by d if the change should be dismissed.
    NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:NO];
    NSArray *a = [base.hasReqIdCandidate sortedArrayUsingDescriptors:@[s]];
    NSInteger i = [a indexOfObject:d];
    NSInteger j = [a indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(TVRequestIdCandidate *)obj done] boolValue] == YES) {
            return YES;
        }
        return NO;
    }];
    if (i < j) {
        return NO;
    } else {
        return YES;
    }
}

/*
 When communicate with server, only status matters.
 A requestID is triggered to be generated when there is new status since last sync. It is subject to serverID's existence and specific operation. We try to generate requestID as less as possible. So each scan only go through the full cycle of request/response for one sellected record. No matter whether resonse is successfully received by client, after a cycle finishes, scan again to meet any one of selected records. Repeat this till a scan returns no record and run sync request afterwards.
 RequestID for update operation is generated everytime record being updated in db. Use NSManagedObjectContextObjectsDidChangeNotification to do this before checking server availability. This is because we use RequestID to link each update with one unique requestID to setup a one to one relationship to make sure right content is submitted to server. For record with valid serverID, TVDocUpdated is set. For record with empty serverID, TVDocNew is used.
 lastUnsyncAction == TVDocDeleted and last requestID is for deletion block all attempt to add new requestID to list since there is no way to create/update/delete a deleted record.
 
 1. check server availability when:
 a. user launches the app, check in background, user not disrupted
 b. db changed locally, this can be monitored by NSManagedObjectContextObjectsDidChangeNotification, check in background, user not disrupted
 c. user triggers the sync button/refresh control, check in main operation queue, user has to wait
 
 2. scan local db to find out records uncommited to server
 criteria: lastUnsyncAction != TVDocNoAction, this is set to TVDocNoAction everytime a successful process response received by client and to other values once change is committed to local db.
 
 3. further analyze
 a. if serverID is empty
 In this case, only "TVDocNew" request has been sent since, without a serverID, there is no way to update/delete a record on sever. There could be multiple "TVDocNew" requests sent due to local update operation after the initial local create operation. Without the serverID, local update operation is treated as creating a new record to the server each time. When user delete it locally, the delete operation could not be able to trigger any request due to its lack of the serverID. So the record has different version of records on server as many as the requests it sends to the server since each time a new record is created on server. When syncing, those records are delivered back to client and the local record is deleted accordingly. User has to delete the redundant records after the sync process. User also may find the deleted local record show up again since it is not deleted on server. The one on server is copied back to the client as a new record. User has to delete it again.
 i. no requestID in hasReqID
 No request has been generated and sent for this record. Generate a "TVDocNew" request and send. Add one requestID to the list.
 ii. requestID in hasReqID and last one done
 Because we only care about the latest content of the record, only latest requestID needs to be checked. Last request has been handled by server successfully, which indicates there is an updated record for it on server already. Wait for the next sync to get that record.
 iii. requestID in hasReqID and last one undone
 Send request again.
 b. serverID is not empty
 This is the record that has synchronized with server successfully, from which it in turn gets a serverID, editAction "TVDocNew" is impossible to be here.
 Locally deleted records and their related requestIDs have TVDocDeleted in their lastUnsyncAction fields and not deleted till corresponding requests being successfully processed.
 i. no requestID in hasReqID
 Generate a request based on lastUnsyncAction and send. Add one requestID to the list.
 ii. requestID in hasReqID and last one is done
 All current status is submitted to server successfully. Nothing to do.
 iii. requestID in hasReqID and last one undone
 Since we only care about the latest content, so:
 a. lastUnsyncAction == TVDocUpdated, which is to update, and last requestID is undone, only send update request with the last requestIDs.
 b. lastUnsyncAction == TVDocDeleted, which is to delete, if the last requestID is not for deletion, add one, then send delete request.
 
 Local operation is not locked by communicating with server to ensure client is fully responsive almost any time.
 So while local db is executing write task and user is editing existing records(create a new record not included here), the feedback from server to db should be blocked, which means not to commit change from server to local db. In this case, set corresponding requestID to done if successful without commit change to local db. Scan and communicate with server later. For sync response, ignore the result and sync next time. When user is in card editing section, stop sending any request and ignore all the responses (well, this can be optimized by only ignore the response of the related card, But let's leave it for now).
 
 Merge response's result into local db:
 
 1. serverID is empty
 All the requests sent were to create new records on server. Only merge the result for the latest request to make sure all local following potential operations to this record is based on the last content in local db. Keep the unsynced record till it is updated with serverID.
 In the case of sync process, which there is no easy way to match the one from server and the one in local, delete the local one and insert the one from server. Because sync process is not proceeded when any local change is not successfully committed to the server, so we can make sure the commited results from sync process are the most updated status for both server and local. Delete local records without serverId afterwards.
 
 2. serverID is not empty
 Only merge the response for the latest requestId since the result of previous request may conflict with the local record's content. So we only commint the last one the ensure there is absolutely no conflict.
 */

#pragma mark - token operation

- (void)saveAccessToken:(NSString *)aToken refreshToken:(NSString *)rToken toAccount:(NSString *)userId
{
    KeychainItemWrapper *itemA = [[KeychainItemWrapper alloc] initWithIdentifier:[@"accessToken" stringByAppendingString:userId] accessGroup:nil];
    [itemA setObject:aToken forKey:(__bridge id)kSecValueData];
    KeychainItemWrapper *itemR = [[KeychainItemWrapper alloc] initWithIdentifier:[@"refreshToken" stringByAppendingString:userId] accessGroup:nil];
    [itemR setObject:rToken forKey:(__bridge id)kSecValueData];
}

- (NSString *)getAccessTokenForAccount:(NSString *)userId
{
    KeychainItemWrapper *item = [[KeychainItemWrapper alloc] initWithIdentifier:[@"accessToken" stringByAppendingString:userId] accessGroup:nil];
    return (NSString *)[item objectForKey:(__bridge id)kSecValueData];
}

- (NSString *)getRefreshTokenForAccount:(NSString *)userId
{
    KeychainItemWrapper *item = [[KeychainItemWrapper alloc] initWithIdentifier:[@"refreshToken" stringByAppendingString:userId] accessGroup:nil];
    return (NSString *)[item objectForKey:(__bridge id)kSecValueData];
}

- (void)setupTokensServerForUser:(NSString *)userId withDic:(NSMutableDictionary *)dic
{
    if ([dic valueForKey:@"tokens"]) {
        NSMutableDictionary *t = [dic valueForKey:@"tokens"];
        [self saveAccessToken:[t valueForKey:@"accessToken"] refreshToken:[t valueForKey:@"refreshToken"] toAccount:userId];
    }
}

- (void)resetTokens:(NSString *)userId
{
    KeychainItemWrapper *itemA = [[KeychainItemWrapper alloc] initWithIdentifier:[@"accessToken" stringByAppendingString:userId] accessGroup:nil];
    [itemA resetKeychainItem];
    KeychainItemWrapper *itemR = [[KeychainItemWrapper alloc] initWithIdentifier:[@"refreshToken" stringByAppendingString:userId] accessGroup:nil];
    [itemR resetKeychainItem];
}

#pragma mark - user management

- (void)signOut:(NSString *)userId
{
    NSString *s = [self getRefreshTokenForAccount:userId];
    if (s.length != 0) {
        [self resetTokens:userId];
    }
    // Need to clear box.userServerId
    [[NSNotificationCenter defaultCenter] postNotificationName:tvSignOut object:self];
}

@end

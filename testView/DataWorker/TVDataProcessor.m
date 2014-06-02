//
//  TVDataContext.m
//  testView
//
//  Created by Liwei on 2014-05-14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVDataProcessor.h"
#import "TVRequester.h"
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestId.h"
#import "NSObject+DataHandler.h"

@implementation TVDataContext

@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;
@synthesize fetchRequest, fetchedResultsController, sortDescriptors, predicate, parentFetchedResultsController;
@synthesize requester, backgroundWorker;
@synthesize updated, inserted, deleted;

- (id)initForUserOperation
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionAfterDBChange:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    }
    return self;
}

- (id)initForServerOperation
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)actionAfterDBChange:(NSNotification *)n
{
    self.updated = [n valueForKey:@"NSUpdatedObjectsKey"];
    self.inserted = [n valueForKey:@"NSInsertedObjectsKey"];
    self.deleted = [n valueForKey:@"NSDeletedObjectsKey"];
    // Generate requestID for update operation for records with valid serverID everytime
    if ([self.updated count] > 0) {
        for (TVBase *x in updated) {
            NSEntityDescription *e = [NSEntityDescription entityForName:@"TVRequestId" inManagedObjectContext:self.managedObjectContext];
            TVRequestId *r = [[TVRequestId alloc] initWithEntity:e insertIntoManagedObjectContext:self.managedObjectContext];
            if ([x.serverId isEqualToString:@""]) {
                [self setupNewRequestId:r action:TVDocNew for:x];
            } else {
                [self setupNewRequestId:r action:TVDocUpdated for:x];
            }
        }
    }
    // Try to communicate with server on another operationQueue
    if (!self.backgroundWorker) {
        self.backgroundWorker = [[NSOperationQueue alloc] init];
    }
    [self.backgroundWorker addOperationWithBlock:^{
        
    }];
}

- (TVBase *)insertDocInClass:(Class)docClass
{
    TVBase *doc;
    if ([docClass isSubclassOfClass:[TVCard class]]) {
        doc = (TVCard *)[NSEntityDescription insertNewObjectForEntityForName:@"TVCard" inManagedObjectContext:self.managedObjectContext];
    } else if ([docClass isSubclassOfClass:[TVUser class]]) {
        doc = (TVUser *)[NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.managedObjectContext];
    }
    return doc;
}

#pragma mark - check internet availability and process
// Check server availablity before sending request
- (void)startCommunicationWithServerByBranch
{
    // Prepare change set
    NSMutableSet *all = [[NSMutableSet alloc] init];
    [all unionSet:self.inserted];
    [all unionSet:self.updated];
    [all unionSet:self.deleted];
    if ([all count] > 0) {
        // Send to server with a new context
        NSString *name;
        if ([all.anyObject isKindOfClass:TVCard.class]) {
            name = @"TVCard";
        }
        if ([all.anyObject isKindOfClass:TVUser.class]) {
            name = @"TVUser";
        }
        NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:name];
        // Launch a new managedObjCtx in background operationQueue
        NSManagedObjectContext *c = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        NSError *err;
        for (TVBase *x in all) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"localId like %@",
                              x.localId];
            fetchReq.predicate = p;
            [c executeFetchRequest:fetchReq error:&err];
        }
        NSSet *cSet;
        if (!err) {
            cSet = c.registeredObjects;
            for (TVBase *y in cSet) {
                // Prepare request
                NSMutableDictionary *m = [self analyzeOneUndone:y inCtx:c];
                
            }
            
        }
    }
}

- (NSMutableDictionary *)analyzeOneUndone:(TVBase *)b inCtx:(NSManagedObjectContext *)ctx
{
    NSMutableDictionary *outDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSSet *bSet = b.hasReqId;
    NSError *err;
    NSData *body;
    NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:YES];
    NSArray *reqIds = [bSet sortedArrayUsingDescriptors:@[s]];
    TVRequestId *x = reqIds.lastObject;
    if ([b.serverId isEqualToString:@""]) {
        // No valid serverID
        if ([bSet count] == 0) {
            // 1. no requestID in hasReqID
            // No request has been generated and sent for this record. Generate a "TVDocNew" request and send. Add one requestID to the list.
            TVRequestId *r = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
            [self setupNewRequestId:r action:TVDocNew for:b];
            [ctx save:&err];
            if (!err) {
                if ([b isKindOfClass:[TVUser class]]) {
                    [outDic setObject:@"User" forKey:@"class"];
                    body = [self.requester getJSONUser:(TVUser *)b err:&err];
                } else if ([b isKindOfClass:[TVCard class]]) {
                    [outDic setObject:@"Card" forKey:@"class"];
                    body = [self.requester getJSONCard:(TVCard *)b requestId:r.requestId err:&err];
                }
                [outDic setObject:body forKey:@"body"];
                [outDic setObject:@"no serverId, no requestId in hasReqId" forKey:@"decision"];
            }
        } else {
            if (x.done == [NSNumber numberWithBool:YES]) {
                // 2. requestID in hasReqID and last one done
                // Because we only care about the latest content of the record, only latest requestID needs to be checked. Last request has been handled by server successfully, which indicates there is an updated record for it on server already. Wait for the next sync to get that record.
                [outDic setObject:@"no serverId, last requestId in hasReqId done" forKey:@"decision"];
            } else {
                // 3. requestID in hasReqID and last one undone
                // Send request again.
                if ([b isKindOfClass:[TVUser class]]) {
                    [outDic setObject:@"User" forKey:@"class"];
                    body = [self.requester getJSONUser:(TVUser *)b err:&err];
                } else if ([b isKindOfClass:[TVCard class]]) {
                    [outDic setObject:@"Card" forKey:@"class"];
                    body = [self.requester getJSONCard:(TVCard *)b requestId:x.requestId err:&err];
                }
                [outDic setObject:body forKey:@"body"];
                [outDic setObject:@"no serverId, last requestId in hasReqId undone" forKey:@"decision"];
            }
        }
    } else {
        // Valid serverID
        if ([bSet count] == 0) {
            // 1. no requestID in hasReqID
            // Generate a request based on lastUnsyncAction and send. Add one requestID to the list.
            TVRequestId *r = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
            [self setupNewRequestId:r action:b.lastUnsyncAction.integerValue for:b];
            [ctx save:&err];
            if (!err) {
                if ([b isKindOfClass:[TVUser class]]) {
                    [outDic setObject:@"User" forKey:@"class"];
                    body = [self.requester getJSONUser:(TVUser *)b err:&err];
                } else if ([b isKindOfClass:[TVCard class]]) {
                    [outDic setObject:@"Card" forKey:@"class"];
                    body = [self.requester getJSONCard:(TVCard *)b requestId:r.requestId err:&err];
                }
                [outDic setObject:body forKey:@"body"];
                [outDic setObject:@"valid serverId, no requestId in hasReqId" forKey:@"decision"];
            }
        } else {
            if (x.done == [NSNumber numberWithBool:YES]) {
                // 2. requestID in hasReqID and last one done
                // All current status is submitted to server successfully. Nothing to do.
                [outDic setObject:@"valid serverId, last requestId in hasReqId done" forKey:@"decision"];
            } else {
                // 3. requestID in hasReqID and last one undone
                // Since we only care about the latest content, so:
                TVRequestId *temp;
                if (b.lastUnsyncAction.integerValue == TVDocUpdated) {
                    // a. lastUnsyncAction == TVDocUpdated, which is to update, and last requestID is undone, only send update request with the last requestIDs.
                    temp = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
                    [self setupNewRequestId:temp action:b.lastUnsyncAction.integerValue for:b];
                    [ctx save:&err];
                } else if (b.lastUnsyncAction.integerValue == TVDocDeleted) {
                    // b. lastUnsyncAction == TVDocDeleted, which is to delete, if the last requestID is not for deletion, add one, then send delete request.
                    if (x.editAction.integerValue != TVDocDeleted) {
                        temp = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
                        [self setupNewRequestId:temp action:TVDocDeleted for:b];
                        [ctx save:&err];
                    } else {
                        temp = x;
                    }
                }
                if (!err) {
                    return outDic;
                }
                if ([b isKindOfClass:[TVUser class]]) {
                    [outDic setObject:@"User" forKey:@"class"];
                    body = [self.requester getJSONUser:(TVUser *)b err:&err];
                } else if ([b isKindOfClass:[TVCard class]]) {
                    [outDic setObject:@"Card" forKey:@"class"];
                    body = [self.requester getJSONCard:(TVCard *)b requestId:temp.requestId err:&err];
                }
                [outDic setObject:body forKey:@"body"];
                [outDic setObject:@"valid serverId, last requestId in hasReqId undone" forKey:@"decision"];
            }
        }
    }
    return outDic;
}



@end

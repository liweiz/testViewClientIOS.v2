//
//  TVDataHandler.m
//  testView
//
//  Created by Liwei on 2014-05-06.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVDataHandler.h"
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestID.h"
#import "TVNetworkHandler.h"

typedef NS_ENUM(NSInteger, TVDocEditCode) {
    TVDocNoAction,
    TVDocNew,
    TVDocUpdated,
    TVDocDeleted
};

//  how to trigger request? 1. commit local change to persistent store by save 2. get NSManagedObjectContextObjectsDidChangeNotification and get the changed obj with NSInsertedObjectsKey/NSUpdatedObjectsKey/NSDeletedObjectsKey in a new managedObjectContext 3. based on the objects in the new context, form and send requests

@implementation TVDataHandler

@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;
@synthesize fetchRequest, fetchedResultsController, sortDescriptors, predicate, parentFetchedResultsController;

- (id)initForUserOperation
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChangeOnServer:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
    }
    return self;
}

- (void)updateChangeOnServer:(NSNotification *)n
{
    NSSet *inserted = [n valueForKey:@"NSInsertedObjectsKey"];
    NSSet *updated = [n valueForKey:@"NSUpdatedObjectsKey"];
    NSSet *deleted = [n valueForKey:@"NSDeletedObjectsKey"];
    if (<#condition#>) {
        <#statements#>
    }
    TVNetworkHandler *networkHandler = [[TVNetworkHandler alloc] init];
    
}

- (id)initForServerOperation
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
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

- (void)setupNewDocBase:(TVBase *)doc
{
    doc.localID = [[NSUUID UUID] UUIDString];
    doc.editAction = [NSNumber numberWithInteger:TVDocNew];
    doc.lastModifiedAtLocal = [NSDate date];
}

- (void)setupNewUser:(TVUser *)user withDic:(NSMutableDictionary *)dic
{
    user.activated = [dic valueForKey:@"activated"];
    user.deviceUUID = [dic valueForKey:@"deviceUUID"];
    user.email = [dic valueForKey:@"email"];
    user.isLoggedIn = [dic valueForKey:@"isLoggedIn"];
    user.rememberMe = [dic valueForKey:@"rememberMe"];
    user.sortOption = [dic valueForKey:@"sortOption"];
    user.sourceLang = [dic valueForKey:@"sourceLang"];
    user.targetLang = [dic valueForKey:@"targetLang"];
}

- (void)setupNewCard:(TVCard *)card withDic:(NSMutableDictionary *)dic
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

- (NSInteger)getRequestIDOperationVersion:(TVBase *)base
{
    if ([base.hasReqID count] == 0) {
        return 1;
    } else {
        NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:NO];
        return [[[[base.hasReqID sortedArrayUsingDescriptors:@[s]] objectAtIndex:0] operationVersion] integerValue] + 1;
    }
}

- (BOOL)needToDismissChangeToDb:(TVBase *)base requestIDObj:(TVRequestID *)d
{
    NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:NO];
    NSArray *a = [base.hasReqID sortedArrayUsingDescriptors:@[s]];
    NSInteger i = [a indexOfObject:d];
    NSInteger j = [a indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(TVRequestID *)obj done] boolValue] == YES) {
            return YES;
        }
        return NO;
    }];
    // only commit modification based on the latest response available
    if (i < j) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setupNewRequestID:(TVRequestID *)doc forBase:(TVBase *)base
{
    doc.requestID = [[NSUUID UUID] UUIDString];
    doc.done = NO;
    doc.createdAtLocal = [NSDate date];
    doc.lastModifiedAtLocal = [NSDate date];
    doc.operationVersion = [NSNumber numberWithInteger:[self getRequestIDOperationVersion:base]];
    doc.belongTo = base;
}

- (void)updateDocBaseLocal:(TVBase *)doc
{
    // requestID is not processed here
    doc.editAction = [NSNumber numberWithInteger:TVDocUpdated];
    doc.lastModifiedAtLocal = [NSDate date];
}

- (void)markRequestIDAsDone:(TVRequestID *)reqID
{
    // change in requestID does not change time modified
    reqID.done = [NSNumber numberWithBool:YES];
    reqID.lastModifiedAtLocal = [NSDate date];
}

- (void)updateDocBaseServer:(TVBase *)doc withDic:(NSMutableDictionary *)dic
{
    doc.lastModifiedAtServer = [NSDate date];
    doc.serverID = [dic valueForKey:@"serverID"];
    doc.versionNo = [dic valueForKey:@"versionNo"];
}

- (void)updateUser:(TVUser *)user withDic:(NSMutableDictionary *)dic
{
    user.activated = [dic valueForKey:@"activated"];
    user.deviceUUID = [dic valueForKey:@"deviceUUID"];
    user.sortOption = [dic valueForKey:@"sortOption"];
    user.sourceLang = [dic valueForKey:@"sourceLang"];
    user.targetLang = [dic valueForKey:@"targetLang"];
}

- (void)updateCard:(TVCard *)card withDic:(NSMutableDictionary *)dic
{
    card.belongTo = [dic valueForKey:@"belongTo"];
    if ([dic valueForKey:@"collectedAt"]) {
        card.collectedAt = [dic valueForKey:@"collectedAt"];
    }
    card.context = [dic valueForKey:@"context"];
    card.detail = [dic valueForKey:@"detail"];
    card.target = [dic valueForKey:@"target"];
    card.translation = [dic valueForKey:@"translation"];
    card.sourceLang = [dic valueForKey:@"sourceLang"];
    card.targetLang = [dic valueForKey:@"targetLang"];
}

- (NSError *)commitOneObjInResponseToDbWithConflictCheck:(BOOL)withCheck
{
    NSError *err;
    if (withCheck) {
        self needToDismissChangeToDb:obj requestIDObj:obj
    }
    [self.managedObjectContext save:&err];
}

@end

//
//  TVCRUDChannel.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-28.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVCRUDChannel.h"
#import "NSObject+CoreDataStack.h"
#import "NSObject+DataHandler.h"
#import "TVAppRootViewController.h"

@implementation TVCRUDChannel

@synthesize ctx;
@synthesize model;
@synthesize coordinator;
@synthesize fetchReq;
@synthesize objIdsToProcess;
@synthesize objServerIdToProcess;
@synthesize objLocalIdToProcess;
@synthesize com;

- (id)init
{
    self = [super init];
    if (self) {
        self.ctx = [self managedObjectContext:self.ctx coordinator:self.coordinator model:self.model];
        self.objIdsToProcess = [NSMutableSet setWithCapacity:0];
        self.objServerIdToProcess = [NSMutableSet setWithCapacity:0];
        self.objLocalIdToProcess = [NSMutableSet setWithCapacity:0];
    }
    return self;
}

// ids has NSDictionary values like this: 1. @"serverId": store the serverId 2. @"localId": store the localId
- (NSArray *)getObjs:(NSSet *)ids name:(NSString *)entityName
{
    for (NSDictionary *d in ids) {
        NSString *serverId = [d valueForKey:@"serverId"];
        NSString *localId = [d valueForKey:@"localId"];
        // Only add non-empty ones.
        if (serverId.length > 0) {
            [self.objServerIdToProcess addObject:serverId];
        }
        if (localId.length > 0) {
            [self.objLocalIdToProcess addObject:localId];
        }
    }
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"serverId in %@",
                      self.objServerIdToProcess];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"localId in %@",
                       self.objLocalIdToProcess];
    [r setPredicate:p1];
    NSMutableArray *a1;
    if ([self fetch:r withCtx:self.ctx outcome:a1]) {
        // Remove localId corresponding to serverId that has been fetched.
        for (TVBase *b in a1) {
            for (NSDictionary *obj in ids) {
                NSString *serverId = [obj valueForKey:@"serverId"];
                NSString *localId = [obj valueForKey:@"localId"];
                if ([serverId isEqualToString:b.serverId]) {
                    for (NSString *l in self.objLocalIdToProcess) {
                        if ([l isEqualToString:localId]) {
                            [self.objLocalIdToProcess removeObject:l];
                            break;
                        }
                    }
                }
            }
        }
        NSMutableArray *a2;
        [r setPredicate:p2];
        if ([self fetch:r withCtx:self.ctx outcome:a2]) {
            [a1 addObjectsFromArray:a2];
            return a1;
        }
    }
    return nil;
}

#pragma - mark create new

- (void)insertOneCard:(NSDictionary *)card fromServer:(BOOL)isFromServer
{
    TVCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"TVCard" inManagedObjectContext:self.ctx];
    if (isFromServer) {
        [self setupNewDocBaseServer:newCard fromRequest:card];
    } else {
        [self setupNewDocBaseLocal:newCard];
    }
    [self setupNewCard:newCard withDic:card];
}

// reuqestId is always created locally.
- (void)insertOneReqId:(NSInteger)action for:(TVBase *)base
{
    TVRequestId *newReqId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:self.ctx];
    [self setupNewRequestId:newReqId action:action for:base];
}

// User is always created at server first, client only provides information.
- (void)insertOneUser:(NSDictionary *)user
{
    TVUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
    [self setupNewDocBaseServer:newUser fromRequest:user];
    [self setupNewUserServer:newUser withDic:user];
}

#pragma - mark update

- (void)updateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card fromServer:(BOOL)isFromServer
{
    if (isFromServer) {
        [self updateDocBaseServer:cardToUpdate withDic:card];
    } else {
        [self updateDocBaseLocal:cardToUpdate];
    }
   [self updateCard:cardToUpdate withDic:card];
}

- (void)updateOneUserd:(TVUser *)userToUpdate by:(NSDictionary *)user fromServer:(BOOL)isFromServer
{
    if (isFromServer) {
        [self updateDocBaseServer:userToUpdate withDic:user];
    } else {
        [self updateDocBaseLocal:userToUpdate];
    }
    [self updateUser:userToUpdate withDic:user];
}

#pragma - mark delete

- (void)deleteOneCard:(TVCard *)cardToDelete fromServer:(BOOL)isFromServer
{
    if (isFromServer) {
        [self.ctx deleteObject:cardToDelete];
    } else {
        [self deleteDocBaseLocal:cardToDelete];
    }
}

#pragma - mark save

- (BOOL)save:(BOOL)isUserTriggered
{
    if (isUserTriggered) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionAfterUserChange:) name:NSManagedObjectContextDidSaveNotification object:self.ctx];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    if ([self saveWithCtx:self.ctx]) {
        return YES;
    }
    return NO;
}

#pragma mark - reaction to local db change

- (void)actionAfterUserChange:(NSNotification *)n
{
    // Generate requestID for update operation for records with valid serverID everytime. Only updated obj needs to be checked. See comments in NSObject+DataHandler.m for details.
    NSArray *updated = [n valueForKey:@"NSUpdatedObjectsKey"];
    if ([updated count] > 0) {
        for (TVBase *x in updated) {
            TVRequestId *newReqId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:self.ctx];
            if (x.serverId.length == 0) {
                [self setupNewRequestId:newReqId action:TVDocNew for:x];
            } else {
                [self setupNewRequestId:newReqId action:TVDocUpdated for:x];
            }
        }
        if ([self saveWithCtx:self.ctx]) {
            // Sync
            [self.com checkServerAvailToSyncInBack:NO];
        }
    }
}

#pragma mark - user management

- (TVUser *)getLoggedInUser
{
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSArray *users = [self.ctx executeFetchRequest:fRequest error:nil];
    if ([users count] != 0) {
        for (TVUser *u in users) {
            NSString *s = [self getRefreshTokenForAccount:u.serverId];
            if (!(s.length == 0)) {
                return u;
            }
        }
    }
    return nil;
}

- (void)refreshUser:(TVUser *)u
{
    if (!u) {
        u = [self getLoggedInUser];
    } else {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"serverId == %@", u.serverId];
        u = [self.ctx executeFetchRequest:fetchRequest error:nil][0];
    }
}

- (void)signOut:(TVUser *)u
{
    if (!u) {
        [self refreshUser:u];
    }
    [self resetTokens:u.serverId];
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

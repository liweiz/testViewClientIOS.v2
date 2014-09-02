//
//  TVCRUDChannel.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-28.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVRootViewCtlBox.h"
#import "TVCommunicator.h"

@interface TVCRUDChannel : NSObject

@property (strong, nonatomic) NSManagedObjectContext *ctx;
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;
@property (strong, nonatomic) NSFetchRequest *fetchReq;
// ids has NSDictionary values like this: 1. @"serverId": store the serverId 2. @"localId": store the localId
@property (strong, nonatomic) NSMutableSet *objIdsToProcess;
// Processed objs are divided into two groups since some may not come with a serverId.
@property (strong, nonatomic) NSMutableSet *objServerIdToProcess;
@property (strong, nonatomic) NSMutableSet *objLocalIdToProcess;
@property (strong, nonatomic) TVCommunicator *com;

- (NSArray *)getObjs:(NSSet *)ids name:(NSString *)entityName;
- (void)insertOneCard:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)insertOneReqId:(NSInteger)action for:(TVBase *)base;
- (void)insertOneUser:(NSDictionary *)user;
- (void)updateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)updateOneUserd:(TVUser *)userToUpdate by:(NSDictionary *)user fromServer:(BOOL)isFromServer;
- (void)deleteOneCard:(TVCard *)cardToDelete fromServer:(BOOL)isFromServer;

- (TVUser *)getLoggedInUser;
- (void)refreshUser:(TVUser *)u;
- (void)signOut:(TVUser *)u;


@end

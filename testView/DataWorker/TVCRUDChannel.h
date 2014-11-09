//
//  TVCRUDChannel.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-28.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVRootViewCtlBox.h"
#import "TVBase.h"
#import "TVCard.h"

@interface TVCRUDChannel : NSObject

// Record the tag of the view that triggers the requester.
@property (assign, nonatomic) NSInteger fromVewTag;
@property (copy, nonatomic) NSString *cycleDna;

#pragma mark - Create new
- (TVCard *)insertOneCard:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)insertOneReqId:(NSInteger)action for:(TVBase *)base;
- (void)insertOneUser:(NSDictionary *)user;
- (void)userCreateOneCard:(NSDictionary *)card;

#pragma mark - Update
- (void)updateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)updateOneUser:(TVUser *)userToUpdate by:(NSDictionary *)user fromServer:(BOOL)isFromServer;
- (void)userUpdateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card;
- (void)userUpdateOneUser:(TVUser *)userToUpdate by:(NSDictionary *)user;

#pragma mark - Delete
- (void)deleteOneCard:(TVCard *)cardToDelete fromServer:(BOOL)isFromServer;
- (void)userDeleteOneCard:(TVCard *)cardToDelete;

#pragma mark - Mark RequestIdDone
- (BOOL)markReqDone:(NSString *)recordServerId localId:(NSString *)recordLocalId reqId:(NSString *)reqId entityName:(NSString *)name;

#pragma mark - Sync Cycle
- (void)syncCycle:(BOOL)isUserTriggered;

#pragma mark - Process Response
- (BOOL)processResponseJSON:(NSMutableDictionary *)dict reqType:(NSInteger)t objDic:(NSDictionary *)od;
- (void)actionAfterReqToDbDone:(NSInteger)reqType;

#pragma mark - Record Getter
- (TVUser *)getLoggedInUser;
- (TVCard *)getOneCard:(TVIdPair *)cardIds;
- (NSArray *)getCards:(NSString *)userServerId;
- (NSSet *)getObjInCarrier:(NSSet *)ids entityName:(NSString *)name;
- (NSArray *)getObjs:(NSSet *)ids name:(NSString *)entityName;

#pragma mark - Save
- (BOOL)save;

@end

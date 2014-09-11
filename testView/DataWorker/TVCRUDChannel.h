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
#import "TVUser.h"
#import "TVIdCarrier.h"

@interface TVCRUDChannel : NSObject

@property (strong, nonatomic) NSManagedObjectContext *ctx;

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) TVIdCarrier *ids;

#pragma mark - create new
- (TVCard *)insertOneCard:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)insertOneReqId:(NSInteger)action for:(TVBase *)base;
- (void)insertOneUser:(NSDictionary *)user;
- (void)userCreateOneCard:(NSDictionary *)card;

#pragma mark - update
- (void)updateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)updateOneUser:(TVUser *)userToUpdate by:(NSDictionary *)user fromServer:(BOOL)isFromServer;
- (void)userUpdateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card;
- (void)userUpdateOneUser:(TVUser *)userToUpdate by:(NSDictionary *)user;

#pragma mark - delete
- (void)deleteOneCard:(TVCard *)cardToDelete fromServer:(BOOL)isFromServer;
- (void)userDeleteOneCard:(TVCard *)cardToDelete;

#pragma mark - mark requestIdDone
- (BOOL)markReqDone:(NSString *)recordServerId localId:(NSString *)recordLocalId reqId:(NSString *)reqId entityName:(NSString *)name;

#pragma mark - sync cycle
- (void)syncCycle:(BOOL)isUserTriggered;

#pragma mark - process response
- (BOOL)processResponseJSON:(NSMutableDictionary *)dict reqType:(NSInteger)t objDic:(NSDictionary *)od;
- (void)actionAfterReqToDbDone:(NSInteger)reqType;

@end

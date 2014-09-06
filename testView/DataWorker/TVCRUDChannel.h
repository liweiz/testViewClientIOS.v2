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
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;
@property (strong, nonatomic) NSFetchRequest *fetchReq;

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) TVIdCarrier *ids;

- (void)insertOneCard:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)insertOneReqId:(NSInteger)action for:(TVBase *)base;
- (void)insertOneUser:(NSDictionary *)user;
- (void)updateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card fromServer:(BOOL)isFromServer;
- (void)updateOneUserd:(TVUser *)userToUpdate by:(NSDictionary *)user fromServer:(BOOL)isFromServer;
- (void)deleteOneCard:(TVCard *)cardToDelete fromServer:(BOOL)isFromServer;
- (BOOL)processResponseJSON:(NSMutableDictionary *)dict reqType:(NSInteger)t objDic:(NSDictionary *)od;
- (void)signOut;


@end

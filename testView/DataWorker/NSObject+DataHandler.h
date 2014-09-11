//
//  NSObject+DataHandler.h
//  testView
//
//  Created by Liwei on 2014-05-14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestIdCandidate.h"
#import "TVIdCarrier.h"

typedef NS_ENUM(NSInteger, TVDocEditCode) {
    TVDocNoAction,
    TVDocNew,
    TVDocUpdated,
    TVDocDeleted
};

@interface NSObject (DataHandler)

- (NSMutableArray *)getUndoneSet:(NSManagedObjectContext *)ctx userId:(NSString *)userServerId;

- (void)saveAccessToken:(NSString *)aToken refreshToken:(NSString *)rToken toAccount:(NSString *)email;
- (NSString *)getAccessTokenForAccount:(NSString *)email;
- (NSString *)getRefreshTokenForAccount:(NSString *)email;
- (void)resetTokens:(NSString *)userId;

- (void)setupNewDocBaseLocal:(TVBase *)doc;
- (void)setupNewDocBaseServer:(TVBase *)doc fromRequest:(NSDictionary *)dicInside;
- (void)setupNewUserServer:(TVUser *)user withDic:(NSDictionary *)dic;
- (void)setupNewCard:(TVCard *)card withDic:(NSDictionary *)dic;
- (void)setupNewRequestIdCandidate:(TVRequestIdCandidate *)doc action:(NSInteger)a for:(TVBase *)base;

- (void)updateDocBaseLocal:(TVBase *)doc;
- (void)generateRequestInfoForRequestIdCandidate:(TVRequestIdCandidate *)doc;
- (void)markRequestIdAsDone:(TVRequestIdCandidate *)reqId;
- (void)updateDocBaseServer:(TVBase *)doc withDic:(NSDictionary *)dic;
- (void)updateUser:(TVUser *)user withDic:(NSDictionary *)dic;
- (void)updateCard:(TVCard *)card withDic:(NSDictionary *)dic;

- (void)deleteDocBaseLocal:(TVBase *)doc;
- (void)deleteDocBaseServerWithServerId:(NSString *)serverId inCtx:(NSManagedObjectContext *)ctx;
- (NSDictionary *)convertCardObjToDic:(NSManagedObject *)obj;

- (NSInteger)getRequestIdCandidateOperationVersion:(TVBase *)base;
- (TVRequestIdCandidate *)analyzeOneRecord:(TVBase *)b inCtx:(NSManagedObjectContext *)ctx serverIsAvailable:(BOOL)isAvail;
- (NSArray *)getCards:(NSString *)userServerId inCtx:(NSManagedObjectContext *)ctx;
- (TVCard *)getOneCard:(NSString *)cardServerId inCtx:(NSManagedObjectContext *)ctx;
- (NSArray *)getObjs:(NSSet *)ids name:(NSString *)entityName inCtx:(NSManagedObjectContext *)ctx;
- (NSDictionary *)findCard:(NSString *)serverId localId:(NSString *)localId inArray:(NSArray *)array;

- (BOOL)fetch:(NSFetchRequest *)r withCtx:(NSManagedObjectContext *)ctx outcome:(NSMutableArray *)outcome;
- (BOOL)saveWithCtx:(NSManagedObjectContext *)ctx;

- (TVRequestIdCandidate *)findReqCandidate:(TVBase *)b byReqId:(NSString *)reqId;
- (NSMutableArray *)getRequestIdCandidatesForRecord:(TVBase *)b ascending:(BOOL)ascending;
- (TVUser *)getLoggedInUser:(NSManagedObjectContext *)ctx;
- (NSDictionary *)getObjInCarrier:(TVIdCarrier *)ids inCtx:(NSManagedObjectContext *)ctx;

- (void)signOut:(NSString *)userId;

@end

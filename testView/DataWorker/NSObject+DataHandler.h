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
#import "TVRequestId.h"

typedef NS_ENUM(NSInteger, TVDocEditCode) {
    TVDocNoAction,
    TVDocNew,
    TVDocUpdated,
    TVDocDeleted
};

@interface NSObject (DataHandler)

- (TVBase *)scanDBForUndone:(NSSet *)objSet;

- (void)setupNewDocBaseLocal:(TVBase *)doc;
- (void)setupNewDocBaseServer:(TVBase *)doc fromRequest:(NSMutableDictionary *)dic;
- (void)setupNewUser:(TVUser *)user withDic:(NSMutableDictionary *)dic;
- (void)setupNewCard:(TVCard *)card withDic:(NSMutableDictionary *)dic;
- (void)setupNewRequestId:(TVRequestId *)doc action:(NSInteger)a for:(TVBase *)base;

- (void)updateDocBaseLocal:(TVBase *)doc;
- (void)markRequestIdAsDone:(TVRequestId *)reqId;
- (void)updateDocBaseServer:(TVBase *)doc withDic:(NSMutableDictionary *)dic;
- (void)updateUser:(TVUser *)user withDic:(NSMutableDictionary *)dic;
- (void)updateCard:(TVCard *)card withDic:(NSMutableDictionary *)dic;

- (NSInteger)getRequestIdOperationVersion:(TVBase *)base;

- (BOOL)dismissChangeToDbRecord:(TVBase *)base requestIdObj:(TVRequestId *)d;

@end

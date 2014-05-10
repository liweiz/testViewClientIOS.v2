//
//  UIViewController+CRUD.h
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CRUD)

#pragma mark - record create/update/delete action
- (TVBase *)createRecord:(Class)recordClass recordInResponse:(NSDictionary *)recordInResponse inContext:(NSManagedObjectContext *)context withNewCardController:(TVNewBaseViewController *)controller withNonCardController:(TVNonCardsBaseViewController *)anotherController user:(TVUser *)user;
- (void)updateRecord:(TVBase *)record recordInResponse:(NSDictionary *)recordInResponse withCardController:(TVNewBaseViewController *)controller withNonCardController:(TVNonCardsBaseViewController *)anotherController user:(TVUser *)user;
- (void)commitUpdateRecord:(TVBase *)record recordInResponse:(NSDictionary *)recordInResponse;
- (void)deleteRecord:(TVBase *)record;
- (void)commitDeleteRecord:(TVBase *)record;
- (void)proceedChangesInContext:(NSManagedObjectContext *)context willSendRequest:(BOOL)willSendRequest;
- (void)writeToCard:(TVCard *)card recordInResponse:(NSDictionary *)recordDict withController:(TVNewBaseViewController *)controller withUser:(TVUser *)user;
- (void)writeToUser:(TVUser *)user recordInResponse:(NSDictionary *)recordDict;

#pragma mark - common create/update/delete action

- (void)createBefore:(TVBase *)base;
- (void)createAfter:(TVBase *)base rootResponse:(NSDictionary *)response;
- (void)updateBefore:(TVBase *)base;
- (void)updateAfter:(TVBase *)base recordInResponse:(NSDictionary *)record;
- (void)deleteBefore:(TVBase *)base;
- (void)deleteAfter:(TVBase *)base;
- (void)actionBefore:(TVBase *)base action:(NSString *)action;
- (void)actionAfter:(TVBase *)base recordInResponse:(NSDictionary *)record;

@end

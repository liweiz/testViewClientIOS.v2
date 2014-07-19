//
//  TVCommunicator.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVRequester.h"
#import "TVUser.h"
#import "TVIndicator.h"
#import "TVAppRootViewController.h"

@interface TVCommunicator : NSObject

@property (strong, nonatomic) NSManagedObjectContext *ctx;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) TVRequester *requester;
@property (strong, nonatomic) NSOperationQueue *backgroundWorker;

@property (strong, nonatomic) TVUser *user;

@property (strong, nonatomic) TVIndicator *indicator;

@property (strong, nonatomic) NSMutableArray *unsynced;

@property (assign, nonatomic) NSInteger requestType;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *deviceInfoId;
@property (strong, nonatomic) NSString *deviceUuid;
@property (strong, nonatomic) NSString *cardId;

@property (strong, nonatomic) TVAppRootViewController *ctler;
@property (strong, nonatomic) NSOperationQueue *bWorker;
@property (assign, nonatomic) BOOL isUserTriggered;

@end

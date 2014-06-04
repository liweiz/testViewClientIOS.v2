//
//  TVRequester.h
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NetworkHandler.h"
#import "TVRequestId.h"

@interface TVRequester : NSObject

@property (strong, nonatomic) NSString *urlBranch;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSData *body;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *accessToken;
@property (assign, nonatomic) BOOL isBearer;
@property (assign, nonatomic) BOOL internetIsOn;
@property (assign, nonatomic) NSInteger requestType;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *deviceInfoId;
@property (strong, nonatomic) NSString *deviceUuid;
@property (strong, nonatomic) NSString *cardId;

@property (strong, nonatomic) NSMutableArray *objectIdArray;
@property (strong, nonatomic) NSMutableArray *objectArray;

@property (strong, nonatomic) NSManagedObjectContext *ctx;
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;

@property (strong, nonatomic) TVBase *record;
@property (strong, nonatomic) TVRequestId *reqId;

- (void)proceedToRequest:(NSError **)aErr;
- (void)checkServerAvailabilityToProceed;

@end

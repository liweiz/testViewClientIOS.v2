//
//  TVRequester.h
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NetworkHandler.h"
#import "TVQueueElement.h"

@interface TVRequester : NSObject

@property (copy, nonatomic) NSString *urlBranch;
@property (copy, nonatomic) NSString *contentType;
@property (copy, nonatomic) NSString *method;
// Sync request does not have requestId.
@property (copy, nonatomic) NSString *reqId;
@property (strong, nonatomic) NSData *body;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *accessToken;
@property (assign, nonatomic) BOOL isBearer;
@property (assign, nonatomic) BOOL internetIsOn;
@property (assign, nonatomic) NSInteger requestType;
// These four are used to setup request url.
@property (copy, nonatomic) NSString *deviceInfoId;
@property (copy, nonatomic) NSString *deviceUuid;
@property (copy, nonatomic) NSString *cardId;

@property (assign, nonatomic) BOOL isUserTriggered;

@property (strong, nonatomic) NSMutableSet *ids;
@property (strong, nonatomic) NSMutableSet *objs;
@property (copy, nonatomic) NSString *cycleDna;

- (void)proceedToRequest:(BOOL)cancellationFlag withDna:(BOOL)dnaIsNeeded;
- (NSMutableURLRequest *)setupRequest;
- (TVQueueElement *)setupAndLoadToQueue:(NSOperationQueue *)q withDna:(BOOL)dnaIsNeeded;

@end

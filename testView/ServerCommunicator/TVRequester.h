//
//  TVRequester.h
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NetworkHandler.h"
#import "TVRequestIdCandidate.h"
#import "TVRootViewCtlBox.h"
#import "TVQueueElement.h"

@interface TVRequester : NSObject

@property (strong, nonatomic) NSString *urlBranch;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *method;
// Sync request does not have requestId.
@property (strong, nonatomic) NSString *reqId;
@property (strong, nonatomic) NSData *body;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *accessToken;
@property (assign, nonatomic) BOOL isBearer;
@property (assign, nonatomic) BOOL internetIsOn;
@property (assign, nonatomic) NSInteger requestType;
// These four are used to setup request url.
@property (strong, nonatomic) NSString *deviceInfoId;
@property (strong, nonatomic) NSString *deviceUuid;
@property (strong, nonatomic) NSString *cardId;

@property (assign, nonatomic) BOOL isUserTriggered;

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) NSMutableSet *ids;
@property (strong, nonatomic) NSMutableSet *objs;
@property (strong, nonatomic) NSMutableString *dna;

- (void)proceedToRequest:(BOOL)cancellationFlag withDna:(BOOL)dnaIsNeeded;
- (NSMutableURLRequest *)setupRequest;
- (TVQueueElement *)setupAndLoadToQueue:(NSOperationQueue *)q withDna:(BOOL)dnaIsNeeded;

@end

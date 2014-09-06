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
#import "TVRootViewCtlBox.h"
#import "TVIdCarrier.h"

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
// These four are used to setup request url.
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *deviceInfoId;
@property (strong, nonatomic) NSString *deviceUuid;
@property (strong, nonatomic) NSString *cardId;

@property (strong, nonatomic) NSMutableArray *objectIdArray;

@property (assign, nonatomic) BOOL isUserTriggered;
// Record the tag of the view that triggers the requester.
@property (assign, nonatomic) NSInteger fromVewTag;

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) TVIdCarrier *ids;

- (NSError *)proceedToRequest;

@end

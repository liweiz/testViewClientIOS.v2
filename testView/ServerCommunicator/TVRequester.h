//
//  TVRequester.h
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NetworkHandler.h"

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
@property (strong, nonatomic) NSString *cardId;

@end

//
//  TVRequester.m
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVRequester.h"
#import "NSObject+NetworkHandler.h"
#import "TVAppRootViewController.h"

@implementation TVRequester

@synthesize urlBranch;
@synthesize contentType;
@synthesize method;
@synthesize body;
@synthesize email;
@synthesize password;
@synthesize accessToken;
@synthesize isBearer;
@synthesize requestType;
@synthesize userId;
@synthesize deviceInfoId;
@synthesize cardId;
@synthesize internetIsOn;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

// No batch operation so far. each time, we handle only a single step operation for one record only.
- (void)checkServerAndProceed
{
    if (internetIsOn) {
        NSMutableURLRequest *request = [self setupRequest];
    } else {
        // Test server availability
        NSMutableURLRequest *testRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]];
        [NSURLConnection sendAsynchronousRequest:testRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
         {
             if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                 NSMutableURLRequest *request = [self setupRequest];
             } else {
                 // For user triggered connecting attempt, show a notice to mention the unavailability of network.
             }
         }];
    }
    
}

- (NSMutableURLRequest *)setupRequest
{
    self.urlBranch = [self getUrlBranchFor:self.requestType userId:self.userId deviceInfoId:self.deviceInfoId cardId:self.cardId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[tvServerUrl stringByAppendingString:self.urlBranch]]];
    [request setHTTPMethod:self.method];
    [request setValue:self.contentType forHTTPHeaderField:@"Content-type"];
    if (self.body) {
        [request setHTTPBody:self.body];
    }
    NSString *auth;
    if (self.isBearer) {
        auth = [self authenticationStringWithToken:self.accessToken];
    } else {
        auth = [self authenticationStringWithEmail:self.email password:self.password];
    }
    [request setValue:@"Authorization" forHTTPHeaderField:auth];
    // Setup request "X-REMOLET-DEVICE-ID" in header
    [request setValue:@"X-REMOLET-DEVICE-ID" forHTTPHeaderField:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    return request;
}

@end

//
//  TVSignUpListener.m
//  testView
//
//  Created by Liwei on 2014-06-10.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVSignUpListener.h"

@implementation TVSignUpListener

@synthesize email;
@synthesize password;

- (NSError *)doWorkInBackground
{
    NSError *err;
    self.requester = [[TVRequester alloc] init];
    self.requester.coordinator = self.persistentStoreCoordinator;
    self.requester.requestType = TVSignUp;
    self.requester.isBearer = NO;
    self.requester.method = @"POST";
    self.requester.body = [self getJSONSignUpOrInWithEmail:self.email password:self.password err:&err];
    if (!err) {
        [self.requester checkServerAvailabilityToProceed];
    }
    return err;
}

@end

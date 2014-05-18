//
//  NSObject+NetworkHandler.h
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVUser.h"
#import "TVCard.h"

@interface NSObject (NetworkHandler)

- (NSData *)getJSONSignUpOrInWithEmail:(NSString *)email password:(NSString *)password err:(NSError **)err;

- (NSData *)getJSONForgotPasswordWithEmail:(NSString *)email err:(NSError **)err;

- (NSData *)getJSONRenewTokensWithAccessToken:(NSString *)aToken refreshToken:(NSString *)rToken err:(NSError **)err;

- (NSData *)getJSONUser:(TVUser *)user err:(NSError **)err;

- (NSData *)getJSONDeviceInfo:(TVUser *)user requestId:(NSString *)reqId err:(NSError **)err;

- (NSData *)getJSONCard:(TVCard *)card requestId:(NSString *)reqId err:(NSError **)err;

- (NSData *)getJSONSyncWithCardVerList:(NSArray *)array err:(NSError **)err;

- (NSData *)getJSONDicText:(NSString *)text sortOption:(NSString *)option ascending:(NSNumber *)x err:(NSError **)err;

- (NSData *)getJSONDicParentId:(NSString *)pId lastId:(NSString *)lId sortOption:(NSString *)option ascending:(NSNumber *)x err:(NSError **)err;

- (NSString *)encodeStringWithBase64:(NSString *)string;

- (NSString *)authenticationStringWithEmail:(NSString *)email password:(NSString *)password;

- (NSString *)authenticationStringWithToken:(NSString *)token;

- (void)addAuthenticationToRequest:(NSMutableURLRequest *)request withString:(NSString *)string;

- (void)addUuidToRequest:(NSMutableURLRequest *)request;

- (NSString *)getUrlBranchFor:(NSInteger)reqType userId:(NSString *)userId deviceInfoId:(NSString *)deviceInfoId cardId:(NSString *)cardId;

- (NSMutableDictionary *)getBodyIn200Response:(NSURLResponse *)response data:(NSData *)data err:(NSError **)err;

- (NSString *)getBodyInNon200Response:(NSURLResponse *)response data:(NSData *)data;

@end

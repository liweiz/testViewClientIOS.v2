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



typedef NS_ENUM(NSInteger, TVRequestType) {
    TVSignUp,
    TVSignIn,
    TVOneUser,
    TVForgotPassword, // send email request to server in the case that user only know email address, in which case the userId is not available.
    TVRenewTokens,
    TVNewDeviceInfo,
    TVOneDeviceInfo,
    TVEmailForActivation,
    TVEmailForPasswordResetting,
    TVSync,
    TVNewCard,
    TVOneCard
};

@interface NSObject (NetworkHandler)

- (NSData *)getJSONSignUpWithSource:(NSString *)s target:(NSString *)t err:(NSError **)err;

- (NSData *)getJSONSignUpOrInWithEmail:(NSString *)email password:(NSString *)password err:(NSError **)err;

- (NSData *)getJSONForgotPasswordWithEmail:(NSString *)email err:(NSError **)err;

- (NSData *)getJSONRenewTokensWithAccessToken:(NSString *)aToken refreshToken:(NSString *)rToken err:(NSError **)err;

- (NSData *)getJSONUser:(TVUser *)user err:(NSError **)err;

- (NSData *)getJSONDeviceInfo:(TVUser *)user requestId:(NSString *)reqId err:(NSError **)err;

- (NSData *)getJSONCard:(TVCard *)card requestId:(NSString *)reqId err:(NSError **)err;

- (NSData *)getJSONSyncWithCardVerList:(NSArray *)array err:(NSError **)err;

- (NSData *)getJSONDicText:(NSString *)text sortOption:(NSString *)option ascending:(NSNumber *)x err:(NSError **)err;

- (NSData *)getJSONDicParentId:(NSString *)pId lastId:(NSString *)lId sortOption:(NSString *)option ascending:(NSNumber *)x err:(NSError **)err;

- (NSMutableArray *)getCardVerList:(NSString *)userId withCtx:(NSManagedObjectContext *)ctx;

- (NSString *)encodeStringWithBase64:(NSString *)string;

- (NSString *)authenticationStringWithEmail:(NSString *)email password:(NSString *)password;

- (NSString *)authenticationStringWithToken:(NSString *)token;

- (NSString *)getUrlBranchFor:(NSInteger)reqType userId:(NSString *)userId deviceInfoId:(NSString *)deviceInfoId cardId:(NSString *)cardId;


- (NSData *)getBody:(NSString *)reqId forRecord:(TVBase *)b err:(NSError **)err;

@end

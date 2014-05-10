//
//  TVNetworkHQ.m
//  testView
//
//  Created by Liwei on 2014-05-03.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

//  There are two kinds of sync operation: 1. find out if sync is needed 2. sync and commit. 1 and 2 currently has the same request and response. The difference is 1 runs in the background and only trigger a button to be shown to let user decide whether to proceed to 2, which means app is still responsive to user's operation, while 2 is sent and commit directly to client's db, in which process user are not able to operate but wait. The reason for this setting is to avoid extra work on client side conflict

#import "TVNetworkHandler.h"
#import "TVAppRootViewController.h"
#import "TVCard.h"

typedef NS_ENUM(NSInteger, TVRequestType) {
    TVSignUp,
	 TVSignIn,
	 TVForgotPassword, // send email to server
	 TVRenewTokens,
    TVNewDeviceInfo,
	 TVOneDeviceInfo,
	 TVEmailForActivation,
    TVEmailForPasswordResetting, // send token to server
	 TVSync,
	 TVNewCard,
	 TVOneCard
};

@implementation TVNetworkHandler

@synthesize managedObjectContext, persistentStoreCoordinator, managedObjectModel;

#pragma mark - check internet availability
// Online server availablity before sending request
- (void)internetIsAccessible:(TVAppRootViewController *)controller
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:@"http://www.google.com/"]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
    {
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            controller.internetIsAccessible = YES;
        } else {
            controller.internetIsAccessible = NO;
        }
    }];
}

#pragma mark - prepare JSON for requests
- (NSData *)getJSONSignUpOrInWithEmail:(NSString *)email password:(NSString *)password err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:email forKey:@"email"];
    [dict setValue:password forKey:@"password"];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
    
}


- (NSData *)getJSONForgotPasswordWithEmail:(NSString *)email err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:email forKey:@"email"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONRenewTokensWithAccessToken:(NSString *)aToken refreshToken:(NSString *)rToken err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *dictTokens = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dictTokens setValue:aToken forKey:@"accessToken"];
    [dictTokens setValue:rToken forKey:@"refreshToken"];
    [dict setValue:dictTokens forKey:@"tokens"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONUser:(TVUser *)user err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *dictUser = [NSMutableDictionary dictionaryWithCapacity:1];
    [dictUser setValue:user.activated forKey:@"activated"];
    [dictUser setValue:user.email forKey:@"email"];
    [dictUser setValue:user.serverID forKey:@"_id"];
    [dictUser setValue:user.versionNo forKey:@"versionNo"];
    [dict setValue:dictUser forKey:@"user"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONDeviceInfo:(TVUser *)user requestID:(NSString *)reqID err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *dictDeviceInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dictDeviceInfo setValue:user.sourceLang forKey:@"sourceLang"];
    [dictDeviceInfo setValue:user.targetLang forKey:@"targetLang"];
    [dictDeviceInfo setValue:user.sortOption forKey:@"sortOption"];
    [dictDeviceInfo setValue:user.isLoggedIn forKey:@"isLoggedIn"];
    [dictDeviceInfo setValue:user.rememberMe forKey:@"rememberMe"];
    [dictDeviceInfo setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dict setValue:reqID forKey:@"requestId"];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dict setValue:dictDeviceInfo forKey:@"deviceInfo"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONCard:(TVUser *)user card:(TVCard *)card requestID:(NSString *)reqID err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *dictCard = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dictCard setValue:card.sourceLang forKey:@"sourceLang"];
    [dictCard setValue:card.targetLang forKey:@"targetLang"];
    [dictCard setValue:card.context forKey:@"context"];
    [dictCard setValue:card.target forKey:@"target"];
    [dictCard setValue:card.translation forKey:@"translation"];
    [dictCard setValue:card.detail forKey:@"detail"];
    [dict setValue:reqID forKey:@"requestId"];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dict setValue:dictCard forKey:@"card"];
    [dict setValue:card.versionNo forKey:@"cardVersionNo"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONSyncWithCardVerList:(NSArray *)array err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dict setValue:array forKey:@"cardList"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONDicText:(NSString *)text sortOption:(NSString *)option ascending:(NSNumber *)x err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:text forKey:@"wordsText"];
    [dict setValue:option forKey:@"sortOption"];
    [dict setValue:x forKey:@"isAscending"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONDicParentId:(NSString *)pId lastId:(NSString *)lId sortOption:(NSString *)option ascending:(NSNumber *)x err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:pId forKey:@"parentId"];
    [dict setValue:lId forKey:@"lastId"];
    [dict setValue:option forKey:@"sortOption"];
    [dict setValue:x forKey:@"isAscending"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

#pragma mark - setup request body in JSON
- (NSMutableURLRequest *)getBasicPostRequestWithJSON:(NSData *)data toUrlBranch:(NSString *)urlBranch {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[tvServerUrl stringByAppendingString:urlBranch]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:data];
    return request;
}

#pragma mark - setup request authentication
- (NSString *)encodeStringWithBase64:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if ([data respondsToSelector:@selector(base64EncodedDataWithOptions:)]) {
        return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    } else {
        return [data base64Encoding];
    }
}

- (NSString *)authenticationStringWithEmail:(NSString *)email password:(NSString *)password
{
    NSString *s = [NSString stringWithFormat:@"%@:%@", email, password];
    NSString *ss = [self encodeStringWithBase64:s];
    return [NSString stringWithFormat:@"Basic %@", ss];
}

- (NSString *)authenticationStringWithToken:(NSString *)token
{
    NSString *ss = [self encodeStringWithBase64:token];
    return [NSString stringWithFormat:@"Bearer %@", ss];
}

- (void)addAuthenticationToRequest:(NSMutableURLRequest *)request withString:(NSString *)string
{
    [request setValue:@"Authorization" forHTTPHeaderField:string];
}

#pragma mark - setup request "X-REMOLET-DEVICE-ID" in header
- (void)addUuidToRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"X-REMOLET-DEVICE-ID" forHTTPHeaderField:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
}

- (NSString *)getUrlBranchFor:(NSInteger)reqType userId:(NSString *)userId deviceInfoId:(NSString *)deviceInfoId cardId:(NSString *)cardId
{
    NSString *urlBranch;
    switch (reqType) {
        case TVSignUp:
            urlBranch = @"/users";
            break;
        case TVSignIn:
            urlBranch = @"/users/signin";
            break;
        case TVForgotPassword:
            urlBranch = @"/users/forgotpassword";
            break;
        case TVRenewTokens:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/tokens"];
            break;
        case TVNewDeviceInfo:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/deviceinfos"];
            break;
        case TVOneDeviceInfo:
            urlBranch = [[[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/deviceinfos"] stringByAppendingString:deviceInfoId];
            break;
        case TVEmailForActivation:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/activation"];
            break;
        case TVEmailForPasswordResetting:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/password"];
            break;
        case TVSync:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/sync"];
            break;
        case TVNewCard:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/cards"];
            break;
        case TVOneCard:
            urlBranch = [[[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/cards"] stringByAppendingString:cardId];
            break;
        default:
            break;
    }
    return urlBranch;
}

#pragma mark - decompose response
- (NSMutableDictionary *)getBodyIn200Response:(NSURLResponse *)response data:(NSData *)data err:(NSError **)err
{
    NSMutableDictionary *dict;
    if ([(NSHTTPURLResponse *)response statusCode] == 200 && !err && data.length > 0) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:err];
    }
    return dict;
}

- (NSString *)getBodyInNon200Response:(NSURLResponse *)response data:(NSData *)data
{
    if ([(NSHTTPURLResponse *)response statusCode] != 200 && data.length > 0) {
        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    return nil;
}

- (void)processResponseFor:(NSInteger)reqType json:(NSMutableDictionary *)dict text:(NSString *)errMsg info:(NSMutableDictionary *)info err:(NSError **)err
{
    switch (reqType) {
        case TVSignUp:
            if (dict) {
                <#statements#>
            }
            break;
        case TVSignIn:
            urlBranch = @"/users/signin";
            break;
        case TVForgotPassword:
            urlBranch = @"/users/forgotpassword";
            break;
        case TVRenewTokens:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/tokens"];
            break;
        case TVNewDeviceInfo:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/deviceinfos"];
            break;
        case TVOneDeviceInfo:
            urlBranch = [[[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/deviceinfos"] stringByAppendingString:deviceInfoId];
            break;
        case TVEmailForActivation:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/activation"];
            break;
        case TVEmailForPasswordResetting:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/password"];
            break;
        case TVSync:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/sync"];
            break;
        case TVNewCard:
            urlBranch = [[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/cards"];
            break;
        case TVOneCard:
            urlBranch = [[[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/cards"] stringByAppendingString:cardId];
            break;
        default:
            break;
    }
    return urlBranch;
}

#pragma mark - send and receive post request
- (void)sendReqWithbody:(NSData *)body urlBranch:(NSString *)ub info:(NSMutableDictionary *)info err:(NSError **)err
{
    
    if (err) {
        return;
    }
    NSMutableURLRequest *request = [self getBasicPostRequestWithJSON:body toUrlBranch:ub];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
     {
         
     }];
}


// Check connection error, if no error, proceed to handle specific response by returning YES
//- (BOOL)handleBasicResponse:(NSHTTPURLResponse *)response withJSONData:(NSData *)data error:(NSError *)error
//{
//    if ([data length] > 0 && error == nil) {
//        NSLog(@"Something was downloaded.");
//        return [self statusCheckForResponse:response];
//    }
//    else if ([data length] == 0 && error == nil) {
//        NSLog(@"Nothing was downloaded.");
//        [self handleConnectionError:NoDataDownloaded];
//    }
//    else if (error != nil && error.code == NSURLErrorTimedOut) {
//        NSLog(@"Time out");
//        [self handleConnectionError:TimeOut];
//    }
//    else if (error != nil) {
//        NSLog(@"Error = %@", error);
//        [self handleConnectionError:OtherError];
//    }
//    return NO;
//}



@end

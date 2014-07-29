//
//  NSObject+NetworkHandler.m
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "NSObject+NetworkHandler.h"
#import "NSObject+DataHandler.h"
#import "TVRequester.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVAppRootViewController.h"

@implementation NSObject (NetworkHandler)

#pragma mark - prepare JSON for requests

- (NSData *)getJSONSignUpWithSource:(NSString *)s target:(NSString *)t err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:s forKey:@"sourceLang"];
    [dict setValue:t forKey:@"targetLang"];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

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
    [dictUser setValue:user.serverId forKey:@"_id"];
    [dictUser setValue:user.versionNo forKey:@"versionNo"];
    [dict setValue:dictUser forKey:@"user"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONDeviceInfo:(TVUser *)user requestId:(NSString *)reqId err:(NSError **)err
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *dictDeviceInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dictDeviceInfo setValue:user.sourceLang forKey:@"sourceLang"];
    [dictDeviceInfo setValue:user.targetLang forKey:@"targetLang"];
//    [dictDeviceInfo setValue:user.sortOption forKey:@"sortOption"];
    [dictDeviceInfo setValue:user.isLoggedIn forKey:@"isLoggedIn"];
    [dictDeviceInfo setValue:user.rememberMe forKey:@"rememberMe"];
    [dictDeviceInfo setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dict setValue:reqId forKey:@"requestId"];
    [dict setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceUUID"];
    [dict setValue:dictDeviceInfo forKey:@"deviceInfo"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)getJSONCard:(TVCard *)card requestId:(NSString *)reqId err:(NSError **)err
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
    [dict setValue:reqId forKey:@"requestId"];
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

- (NSMutableArray *)getCardVerList:(NSString *)userId withCtx:(NSManagedObjectContext *)ctx
{
    NSFetchRequest *fRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVCard"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"belongTo like %@", userId];
    fRequest.predicate = predicate;
    NSArray *a = [ctx executeFetchRequest:fRequest error:nil];
    NSMutableArray *m = [NSMutableArray arrayWithCapacity:0];
    for (TVUser *x in a) {
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
        [d setValue:x.serverId forKey:@"_id"];
        [d setValue:x.versionNo forKey:@"versionNo"];
        [m addObject:d];
    }
    return m;
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
        case TVOneUser:
            urlBranch = [@"/users/" stringByAppendingString:userId];
            break;
        case TVOneDeviceInfo:
            urlBranch = [[[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/deviceinfos/"] stringByAppendingString:deviceInfoId];
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
            urlBranch = [[[@"/users/" stringByAppendingString:userId] stringByAppendingString:@"/cards/"] stringByAppendingString:cardId];
            break;
        default:
            break;
    }
    return urlBranch;
}

#pragma mark - sync

// The user in sync cycle is for deviceInfo
// When nil is returned, which indicates no requestId for next steps, we don't need to proceed further since the client has already got the message from server that the request has been successfully processed on server.
- (TVRequestId *)analyzeOneUndone:(TVBase *)b inCtx:(NSManagedObjectContext *)ctx error:(NSError **)err
{
    NSSet *bSet = b.hasReqId;
    NSSortDescriptor *s = [NSSortDescriptor sortDescriptorWithKey:@"operationVersion" ascending:YES];
    NSArray *reqIds = [bSet sortedArrayUsingDescriptors:@[s]];
    TVRequestId *x = reqIds.lastObject;
    TVRequestId *rId;
    if ([b.serverId isEqualToString:@""]) {
        // No valid serverID
        if ([bSet count] == 0) {
            // 1. no requestID in hasReqID
            // No request has been generated and sent for this record. Generate a "TVDocNew" request and send. Add one requestID to the list.
            rId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
            [self setupNewRequestId:rId action:TVDocNew for:b];
            [ctx save:err];
        } else {
            if (x.done == [NSNumber numberWithBool:YES]) {
                // 2. requestID in hasReqID and last one done
                // Because we only care about the latest content of the record, only latest requestID needs to be checked. Last request has been handled by server successfully, which indicates there is an updated record for it on server already. Wait for the next sync to get that record.
            } else {
                // 3. requestID in hasReqID and last one undone
                // Send request again.
                rId = x;
            }
        }
    } else {
        // Valid serverID
        if ([bSet count] == 0) {
            // 1. no requestID in hasReqID
            // Generate a request based on lastUnsyncAction and send. Add one requestID to the list.
            rId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
            [self setupNewRequestId:rId action:b.lastUnsyncAction.integerValue for:b];
            [ctx save:err];
        } else {
            if (x.done == [NSNumber numberWithBool:YES]) {
                // 2. requestID in hasReqID and last one done
                // All current status is submitted to server successfully. Nothing to do.
            } else {
                // 3. requestID in hasReqID and last one undone
                // Since we only care about the latest content, so:
                if (b.lastUnsyncAction.integerValue == TVDocUpdated) {
                    // a. lastUnsyncAction == TVDocUpdated, which is to update, and last requestID is undone, only send update request with the last requestIDs.
                    rId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
                    [self setupNewRequestId:rId action:b.lastUnsyncAction.integerValue for:b];
                    [ctx save:err];
                } else if (b.lastUnsyncAction.integerValue == TVDocDeleted) {
                    // b. lastUnsyncAction == TVDocDeleted, which is to delete, if the last requestID is not for deletion, add one, then send delete request.
                    if (x.editAction.integerValue != TVDocDeleted) {
                        rId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:ctx];
                        [self setupNewRequestId:rId action:TVDocDeleted for:b];
                        [ctx save:err];
                    } else {
                        rId = x;
                    }
                }
            }
        }
    }
    return rId;
}

- (NSData *)getBody:(NSString *)reqId forRecord:(TVBase *)b err:(NSError **)err
{
    if ([b isKindOfClass:[TVUser class]]) {
        return [self getJSONDeviceInfo:(TVUser *)b requestId:reqId err:err];
    } else if ([b isKindOfClass:[TVCard class]]) {
        return [self getJSONCard:(TVCard *)b requestId:reqId err:err];
    } else {
        return nil;
    }
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

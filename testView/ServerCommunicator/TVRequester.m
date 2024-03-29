//
//  TVRequester.m
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVRequester.h"
#import "NSObject+DataHandler.h"
#import "TVAppRootViewController.h"
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestIdCandidate.h"
#import "TVCRUDChannel.h"
#import "TVRootViewCtlBox.h"

@interface TVRequester ()



@end

@implementation TVRequester

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _ids = [[NSMutableSet alloc] init];
        _objs = [[NSMutableSet alloc] init];
        _cycleDna = [[NSMutableString alloc] init];
    }
    return self;
}

// No batch operation so far. each time, we handle only a single step operation for one record only.
- (void)proceedToRequest:(BOOL)cancellationFlag withDna:(BOOL)dnaIsNeeded
{
    if (cancellationFlag) {
        // Setup request and send
        NSMutableURLRequest *request = [self setupRequest];
        // Start the indicator if it is not showing.
        if (self.isUserTriggered) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:tvAddAndCheckReqNo object:self];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:tvAddAndCheckReqNoNB object:self];
            });
        }
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
         {
             NSLog(@"response code: %li", (long)[(NSHTTPURLResponse *)response statusCode]);
             if (error.code == -1004) {
                 // Error Domain=NSURLErrorDomain Code=-1004 "Could not connect to the server." https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
                 //                 [ctler showSysMsg:@"Communication not successful"];
             }
             if ([TVRootViewCtlBox sharedBox].numberOfUserTriggeredRequests <= 0) {
                 NSLog(@"number of requests in progress not right: %ld", (long)[TVRootViewCtlBox sharedBox].numberOfUserTriggeredRequests);
             }
             if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                 // Mark requestId done, if there is a requestId for the request.
                 if (self.reqId.length > 0) {
                     // Nerver cancel marking reqId done operation on local db. It's a high priority operation. It has no effect on user interaction, either.
                     TVQueueElement *o = [TVQueueElement blockOperationWithBlock:^{
                         TVCRUDChannel *crud = [[TVCRUDChannel alloc] init];
                         crud.cycleDna = self.cycleDna;
                         TVUser *u = [crud getLoggedInUser];
                         if (u) {
                             if ([crud markReqDone:u.serverId localId:u.localId reqId:self.reqId entityName:@"TVUser"]) {
                                 //
                             }
                         }
                     }];
                     o.cycleDna = self.cycleDna;
                     // No need to set queuePriority here since it's a normal one.
                     [[NSOperationQueue mainQueue] addOperation:o];
                 }
                 if (data.length > 0) {
                     BOOL toProceed1 = NO;
                     if (dnaIsNeeded) {
                         if ([TVRootViewCtlBox sharedBox].validDna.length > 0 && [[TVRootViewCtlBox sharedBox].validDna isEqualToString:self.cycleDna]) {
                             toProceed1 = YES;
                         }
                     } else {
                         toProceed1 = YES;
                     }
                     if (toProceed1) {
                         if ([self checkToProceed:self.ids withPair:[TVRootViewCtlBox sharedBox].cardIdInEditing]) {
                             // Only proceed when no card is under user interaction.
                             NSError *aErr;
                             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&aErr];
                             if (!aErr) {
                                 NSLog(@"JSON of response %li: %@", (long)self.requestType, dict);
                                 TVQueueElement *o1 = [[TVQueueElement alloc] init];
                                 o1.cycleDna = self.cycleDna;
                                 __weak __typeof__(o1) weakO1 = o1;
                                 [o1 addExecutionBlock:^{
                                     TVCRUDChannel *crud = [[TVCRUDChannel alloc] init];
                                     crud.cycleDna = self.cycleDna;
                                     TVUser *u1 = [crud getLoggedInUser];
                                     NSSet *s = [crud getObjInCarrier:self.ids entityName:@"TVCard"];
                                     NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithCapacity:0];
                                     [d1 setValue:u1 forKey:@"user"];
                                     [d1 setValue:s forKey:@"cards"];
                                     __strong __typeof__(o1) strongO1 = weakO1;
                                     BOOL toProceed2 = NO;
                                     if (dnaIsNeeded) {
                                         if ([TVRootViewCtlBox sharedBox].validDna.length > 0 && [[TVRootViewCtlBox sharedBox].validDna isEqualToString:self.cycleDna]) {
                                             toProceed2 = YES;
                                         }
                                     } else {
                                         toProceed2 = YES;
                                     }
                                     if (toProceed2) {
                                         if (![crud processResponseJSON:dict reqType:self.requestType objDic:d1]) {
                                             // Process unsuccessful
                                             // WHAT'S NEXT????????????
                                         }
                                     }
                                 }];
                                 [o1 setQueuePriority:NSOperationQueuePriorityVeryLow];
                                 [[NSOperationQueue mainQueue] addOperation:o1];
                             } else {
                                 // For non-sync request, mark requestId as done, wait for the sync request to do the job. Sync returns with a body every time. So even a failure here does not stop the next try.
                             }
                         }
                     } else {
                         // Request has been successfully processed on server previously. Set related requestId to done.
                         // Post notification to let others react.
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"TVRequestOKOnly" object:self];
                         });
                         
                     }
                 }
             } else {
                 NSString *errMsg = [self processResponseText:response data:data];
                 // Need a module to handle unsuccessful requests.
                 [self processResponseErrMsg:errMsg];
             }
             if (self.isUserTriggered) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[NSNotificationCenter defaultCenter] postNotificationName:tvMinusAndCheckReqNo object:self];
                 });
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[NSNotificationCenter defaultCenter] postNotificationName:tvMinusAndCheckReqNoNB object:self];
                 });
             }
         }];
    }
}

- (NSMutableURLRequest *)setupRequest
{
    self.urlBranch = [self getUrlBranchFor:self.requestType userId:[TVRootViewCtlBox sharedBox].userServerId deviceInfoId:self.deviceInfoId cardId:self.cardId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[tvServerUrl stringByAppendingString:self.urlBranch]]];
    [request setHTTPMethod:self.method];
    if (self.contentType) {
        [request setValue:self.contentType forHTTPHeaderField:@"Content-type"];
    }
    if (self.body) {
        [request setHTTPBody:self.body];
    }
    NSString *auth;
    if (self.requestType == TVEmailForPasswordResetting) {
        // No need to set auth here
    } else {
        if (self.isBearer) {
            auth = [self authenticationStringWithToken:self.accessToken];
        } else {
            auth = [self authenticationStringWithEmail:self.email password:self.password];
        }
        [request setValue:auth forHTTPHeaderField:@"Authorization"];
    }
    // Setup request "X-REMOLET-DEVICE-ID" in header
    [request setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forHTTPHeaderField:@"X-REMOLET-DEVICE-ID"];
    return request;
}

// Error in response is in text/plain
- (NSString *)processResponseText:(NSURLResponse *)response data:(NSData *)data
{
    if ([(NSHTTPURLResponse *)response statusCode] != 200 && data.length > 0) {
        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    return nil;
}

- (void)processResponseErrMsg:(NSString *)errMsg
{
    if ([errMsg isEqualToString:@"incorrect password format."]) {
        // SignUp
    } else if ([errMsg isEqualToString:@"User already exists."]) {
        // SignIn
    } else if ([errMsg isEqualToString:@"User does not exist."]) {
        // ForgotPassword
    } else if ([errMsg isEqualToString:@"No deviceInfo found for this account, please create one on device first."]) {
        // Sync
        // Launch setting interface for user
//        self.transitionPointInRoot = CGPointMake(ctler.view.frame.size.width * 0.5f, ctler.view.frame.size.height * 0.5f);
//        [[NSNotificationCenter defaultCenter] postNotificationName:tvShowLangPick object:self];
    } else if ([errMsg isEqualToString:@"Request not recognized."]) {
        // Invalid request type, sign in required
    } else if ([errMsg rangeOfString:@"Structure for response not able to be set:"].location != NSNotFound) {
        //
    } else if ([errMsg isEqualToString:@"Request body is nil."]) {
        //
    } else if ([errMsg isEqualToString:@"You have one card with same content already."]) {
        // Card not unique
    } else if ([errMsg isEqualToString:@"No element found in server device info slice."]) {
        //
    } else if ([errMsg isEqualToString:@"No Int found in slice."]) {
        
    } else if ([errMsg rangeOfString:@"Failed to generate response, but request has been successfully processed by server."].location != NSNotFound) {
        // from DicTextSearcher or DicIdSearcher
    } else if ([errMsg isEqualToString:@"No such text found in dic."]) {
        // from DicTextSearcher
    } else if ([errMsg isEqualToString:@"Non empty text needed for searching."]) {
        // from DicTextSearcher
    } else if ([errMsg isEqualToString:@"Incorrect parent textType."]) {
        // from DicIdSearcher
    } else if ([errMsg isEqualToString:@"No such id found in dic with this textType."]) {
        // from DicIdSearcher
    } else if ([errMsg isEqualToString:@"No matched document type for database."]) {
        // from InsertNonDicDB or InsertDicDB or UpdateNonDicDB
    } else if ([errMsg isEqualToString:@"No matched document type for nonDic database."]) {
        // from PrepareNewNonDicDocDB or PrepareUpdateNonDicDocDB
    } else if ([errMsg isEqualToString:@"No matched document type for Dic database."]) {
        // from PrepareDicDocForDB
    } else if ([errMsg isEqualToString:@"No matched document type for dicResult database."]) {
        // from PrepareDicResultDocForDB
    } else if ([errMsg isEqualToString:@"No email file set for this purpose."]) {
        // from GenerateEmail, sign in required
    } else if ([errMsg isEqualToString:@"Empty PasswordResettingUrlCodes array, previous insertion failed."]) {
        // from SendEmail
    } else if ([errMsg isEqualToString:@"User not activated."]) {
        // from NonActivationBlocker
    } else if ([errMsg isEqualToString:@"Incorrect password"]) {
        // from GateKeeper
    } else if ([errMsg isEqualToString:@"Token expired"]) {
        // from GateKeeper
    } else if ([errMsg isEqualToString:@"Invalid authorization header"]) {
        // from GateKeeper
    } else if ([errMsg isEqualToString:@"AccessToken still valid, no need to exchange for a new set."]) {
        // from GateKeeperExchange
    } else if ([errMsg isEqualToString:@"No such token and user pair found."]) {
        // from MatchPrimaryAuth
    } else if ([errMsg isEqualToString:@"Previous change was successful or the link is expired."]) {
        // from UrlCodeChecker
    }
}

#pragma mark - Load To Com Queue

- (TVQueueElement *)setupAndLoadToQueue:(NSOperationQueue *)q withDna:(BOOL)dnaIsNeeded
{
    // This is the instant operation, unlike queueElement that may execute later. So it only matters while user is interacting with the record instead of the status later, which may be different from what it is now. For later status, we put the logic in response processing phase to decide whether to continue or not.
    // No request is allowed to be generated when it contains record user is interacting with.
    if ([self checkToProceed:self.ids withPair:[TVRootViewCtlBox sharedBox].cardIdInEditing]) {
        TVQueueElement *o = [[TVQueueElement alloc] init];
        o.cycleDna = self.cycleDna;
        // weak and strong: http://blog.waterworld.com.hk/post/block-weakself-strongself
        __weak __typeof__(o) weakO = o;
        [o addExecutionBlock:^{
            __strong __typeof__(o) strongO = weakO;
            if (dnaIsNeeded) {
                [self proceedToRequest:([TVRootViewCtlBox sharedBox].validDna.length > 0 && [[TVRootViewCtlBox sharedBox].validDna isEqualToString:strongO.cycleDna]) withDna:YES];
            } else {
                [self proceedToRequest:YES withDna:NO];
            }
        }];
        [q addOperation:o];
        return o;
    }
    return nil;
}

@end

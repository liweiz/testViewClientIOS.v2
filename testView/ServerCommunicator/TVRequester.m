//
//  TVRequester.m
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVRequester.h"
#import "NSObject+NetworkHandler.h"
#import "NSObject+DataHandler.h"
#import "TVAppRootViewController.h"
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestId.h"

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
@synthesize deviceUuid;
@synthesize cardId;
@synthesize internetIsOn;

@synthesize objectIdArray;
@synthesize objectArray;

@synthesize ctx;
@synthesize model;
@synthesize coordinator;

@synthesize record;
@synthesize reqId;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.model = [self managedObjectModel];
        self.coordinator = [self persistentStoreCoordinator];
        self.ctx = [self managedObjectContext];
    }
    return self;
}

// Only successful request leads to response with
- (void)processResponseJSON:(NSMutableDictionary *)dict err:(NSError **)err
{
    BOOL toSave = NO;
    switch (self.requestType) {
        case TVSignUp:
            // device specific settings is after successful signUp.
        {
            TVUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
            if ([dict valueForKey:@"user"]) {
                [self setupNewDocBaseServer:newUser fromRequest:[dict valueForKey:@"user"]];
                NSLog(@"userId: %@", newUser.serverId);
                NSLog(@"user: %@", [dict valueForKey:@"user"]);
                NSLog(@"tokens: %@", [dict valueForKey:@"tokens"]);
                [self setupNewUserServer:newUser withDic:dict];
                if ([dict valueForKey:@"tokens"]) {
                    NSMutableDictionary *t = [dict valueForKey:@"tokens"];
                    [self saveAccessToken:[t valueForKey:@"accessToken"] refreshToken:[t valueForKey:@"refreshToken"] toAccount:newUser.serverId];
                    toSave = YES;
                }
            }
            break;
        }
        case TVSignIn:
            // A user has to sign in the first time the app is launched on a device. Internet access is needed at this time. There is no need to sign in again as long as the user does not sign out. The only situation user is blocked and promoted to sign in again is when internet is available and both tokens are not valid anymore. The principle here is that user only needs to sign in when communication with server is needed and app does not get in user's way for offline use.
        {
            TVUser *aUser;
            if ([dict valueForKey:@"user"]) {
                for (NSManagedObject *x in self.objectArray) {
                    if ([x isKindOfClass:[TVUser class]]) {
                        if ([(TVUser *)x email] == [[dict valueForKey:@"user"] valueForKey:@"email"]) {
                            // TVUser exists already.
                            aUser = (TVUser *)x;
                            break;
                        }
                    }
                }
                if (!aUser) {
                    aUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
                }
                [self setupNewDocBaseServer:aUser fromRequest:[dict valueForKey:@"user"]];
                [self setupNewUserServer:aUser withDic:dict];
                if ([dict valueForKey:@"tokens"]) {
                    NSMutableDictionary *t = [dict valueForKey:@"tokens"];
                    [self saveAccessToken:[t valueForKey:@"accessToken"] refreshToken:[t valueForKey:@"refreshToken"] toAccount:aUser.serverId];
                    toSave = YES;
                    // Proceed to sync immediately after signIn to get the deviceInfo and rest info.
                }
            }
            break;
        }
        case TVForgotPassword:
            // code 200 means email has been successfully sent by server, show user a message.
            break;
        case TVRenewTokens:
            if ([dict valueForKey:@"userId"]) {
                if ([dict valueForKey:@"tokens"]) {
                    NSMutableDictionary *t = [dict valueForKey:@"tokens"];
                    [self saveAccessToken:[t valueForKey:@"accessToken"] refreshToken:[t valueForKey:@"refreshToken"] toAccount:[dict valueForKey:@"userId"]];
                    toSave = YES;
                }
            }
            break;
        case TVNewDeviceInfo:
        {
            TVUser *aUser;
            if ([dict valueForKey:@"deviceInfo"]) {
                NSMutableDictionary *d = [dict valueForKey:@"deviceInfo"];
                for (NSManagedObject *x in self.objectArray) {
                    if ([x isKindOfClass:[TVUser class]]) {
                        if ([(TVUser *)x serverId] == [d valueForKey:@"belongTo"]) {
                            // TVUser exists already.
                            aUser = (TVUser *)x;
                            [self updateUser:aUser withDic:dict];
                            toSave = YES;
                            break;
                        }
                    }
                }
            }
            break;
        }
        case TVOneDeviceInfo:
        {
            TVUser *aUser;
            if ([dict valueForKey:@"deviceInfo"]) {
                NSMutableDictionary *d = [dict valueForKey:@"deviceInfo"];
                for (NSManagedObject *x in self.objectArray) {
                    if ([x isKindOfClass:[TVUser class]]) {
                        if ([(TVUser *)x serverId] == [d valueForKey:@"belongTo"]) {
                            // TVUser exists already.
                            aUser = (TVUser *)x;
                            [self updateUser:aUser withDic:dict];
                            toSave = YES;
                            break;
                        }
                    }
                }
            }
            break;
        }
        case TVEmailForActivation:
            // code 200 means email has been successfully sent by server, show user a message.
            break;
        case TVEmailForPasswordResetting:
            // code 200 means email has been successfully sent by server, show user a message.
            break;
        case TVNewCard:
        {
            if ([dict valueForKey:@"cards"]) {
                NSMutableArray *c = [dict valueForKey:@"cards"];
                if ([c count] == 1) {
                    [self updateDocBaseServer:self.ctx.registeredObjects.anyObject withDic:c[0]];
                    [self updateCard:self.ctx.registeredObjects.anyObject withDic:c[0]];
                    toSave = YES;
                }
            }
            break;
        }
        case TVOneCard:
        {
            if ([dict valueForKey:@"cards"]) {
                NSMutableArray *c = [dict valueForKey:@"cards"];
                if ([c count] == 1) {
                    [self updateDocBaseServer:self.ctx.registeredObjects.anyObject withDic:c[0]];
                    [self updateCard:self.ctx.registeredObjects.anyObject withDic:c[0]];
                    toSave = YES;
                } else if ([c count] == 2) {
                    NSMutableDictionary *aCard;
                    if ([[c objectAtIndex:0] valueForKey:@"serverId"] == [self.ctx.registeredObjects.anyObject serverId]) {
                        aCard = c[0];
                    } else {
                        aCard = c[1];
                    }
                    [self updateDocBaseServer:self.ctx.registeredObjects.anyObject withDic:aCard];
                    [self updateCard:self.ctx.registeredObjects.anyObject withDic:aCard];
                    toSave = YES;
                }
            }
            break;
        }
        case TVSync:
        {
            TVUser *aUser;
            for (NSManagedObject *x in self.objectArray) {
                if ([x isKindOfClass:[TVUser class]]) {
                    if ([(TVUser *)x email] == [[dict valueForKey:@"user"] valueForKey:@"email"]) {
                        // TVUser exists already.
                        aUser = (TVUser *)x;
                        break;
                    }
                }
            }
            [self updateDocBaseServer:aUser withDic:[dict valueForKey:@"user"]];
            [self updateUser:aUser withDic:dict];
            
            if ([dict valueForKey:@"cardList"]) {
                NSMutableArray *c = [dict valueForKey:@"cardList"];
                if ([c count] > 0) {
                    BOOL found;
                    for (NSMutableDictionary *x in c) {
                        for (NSManagedObject *y in self.objectArray) {
                            if ([[x valueForKey:@"serverId"] isEqualToString:[(TVCard *)y serverId]]) {
                                [self updateDocBaseServer:(TVBase *)y withDic:x];
                                [self updateCard:(TVCard *)y withDic:x];
                                found = YES;
                                break;
                            }
                        }
                        if (found) {
                            break;
                        } else {
                            TVCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"TVCard" inManagedObjectContext:self.ctx];
                            [self setupNewDocBaseServer:newCard fromRequest:x];
                            [self setupNewCard:newCard withDic:x];
                        }
                    }
                }
            }
            if ([dict valueForKey:@"cardToDelete"]) {
                NSMutableArray *c = [dict valueForKey:@"cardToDelete"];
                if ([c count] > 0) {
                    for (NSString *i in c) {
                        for (NSManagedObject *y in self.objectArray) {
                            if ([i isEqualToString:[(TVCard *)y serverId]]) {
                                [self.ctx deleteObject:y];
                                break;
                            }
                        }

                    }
                }
            }
            toSave = YES;
            break;
        }
        default:
            break;
    }
    if (toSave) {
        [self.ctx save:err];
    }
}

// Error in response is in text/plain
- (NSString *)processResponseText:(NSURLResponse *)response data:(NSData *)data
{
    if ([(NSHTTPURLResponse *)response statusCode] != 200 && data.length > 0) {
        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    return nil;
}

- (void)checkServerAvailabilityToProceed
{
    NSMutableURLRequest *testRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]];
    [NSURLConnection sendAsynchronousRequest:testRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
     {
         if ([(NSHTTPURLResponse *)response statusCode] == 200) {
             TVRequester *req = [[TVRequester alloc] init];
             [req proceedToRequest:&error];
         } else {
             // For user triggered connecting attempt, show a notice to mention the unavailability of network.
         }
     }];
}

// No batch operation so far. each time, we handle only a single step operation for one record only.
- (void)proceedToRequest:(NSError **)aErr
{
    [self getObjInCtx:aErr];
    if (!aErr) {
        // Setup request and send
        NSMutableURLRequest *request = [self setupRequest];
        NSLog(@"3: %@, %@", request.URL.host, request.URL.path);
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
         {
             NSLog(@"4");
             NSError *err;
             if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                 self.record.lastUnsyncAction = [NSNumber numberWithInteger:TVDocNoAction];
                 if (self.reqId) {
                     self.reqId.done = [NSNumber numberWithBool:YES];
                 }
                 if (data.length > 0) {
                     NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                     if (!err) {
                         [self processResponseJSON:dict err:&err];
                         NSLog(@"JSON of response %li: %@", (long)self.requestType, dict);
                     } else {
                         // For non-sync request, mark requestId as done, wait for the sync request to do the job. Sync returns with a body every time. So even a failure here deos not stop the next try.
                     }
                 } else {
                     // Request has been successfully processed on server previously. Set related requestId to done.
                 }
             } else {
                 NSString *errMsg = [self processResponseText:response data:data];
                 // Need a module to handle unsuccessful requests.
                 [self processResponseErrMsg:errMsg];
             }
         }];
        NSLog(@"5");
    }
}

- (void)getObjInCtx:(NSError **)err
{
    if ([self.objectIdArray count] > 0) {
        for (NSManagedObjectID *i in self.objectIdArray) {
            NSManagedObject *x = [self.ctx existingObjectWithID:i error:err];
            if (err) {
                return;
            }
            if (!self.objectArray) {
                self.objectArray = [NSMutableArray arrayWithCapacity:0];
            }
            [self.objectArray addObject:x];
        }
    }
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

- (NSMutableURLRequest *)setupRequest
{
    self.urlBranch = [self getUrlBranchFor:self.requestType userId:self.userId deviceInfoId:self.deviceInfoId cardId:self.cardId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[tvServerUrl stringByAppendingString:self.urlBranch]]];
    NSLog(@"tvServerUrl: %@", tvServerUrl);
    NSLog(@"self.urlBranch: %@", self.urlBranch);
    NSLog(@"URLWithString: %@", [tvServerUrl stringByAppendingString:self.urlBranch]);
    NSLog(@"request URL: %@", request.URL.host);
    [request setHTTPMethod:self.method];
    if (self.contentType) {
        [request setValue:self.contentType forHTTPHeaderField:@"Content-type"];
    }
    if (self.body) {
        [request setHTTPBody:self.body];
        NSLog(@"2");
    }
    NSString *auth;
    if (self.isBearer) {
        auth = [self authenticationStringWithToken:self.accessToken];
    } else {
        auth = [self authenticationStringWithEmail:self.email password:self.password];
    }
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    // Setup request "X-REMOLET-DEVICE-ID" in header
    [request setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forHTTPHeaderField:@"X-REMOLET-DEVICE-ID"];
    NSLog(@"X-REMOLET-DEVICE-ID: %@", [request valueForHTTPHeaderField:@"X-REMOLET-DEVICE-ID"]);
    return request;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (self.ctx != nil) {
        return self.ctx;
    }
    if (self.coordinator != nil) {
        self.ctx = [[NSManagedObjectContext alloc] init];
        [self.ctx setPersistentStoreCoordinator:self.coordinator];
    }
    return self.ctx;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (self.model != nil) {
        return self.model;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"testView" withExtension:@"momd"];
    self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return self.model;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (self.coordinator != nil) {
        return self.coordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"testView.sqlite"];
    
    NSError *error = nil;
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    if (![self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return self.coordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

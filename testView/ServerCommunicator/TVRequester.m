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

@synthesize isUserTriggered;

@synthesize record;
@synthesize reqId;
@synthesize indicator;
@synthesize ctler;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.ctler = (TVAppRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return self;
}

# pragma mark - indicator on/off

- (void)showIndicator
{
    self.indicator.hidden = NO;
    [self.indicator.superview bringSubviewToFront:self.indicator];
    [self.indicator.indicator startAnimating];
}

- (void)hideIndicator
{
    self.indicator.hidden = YES;
    [self.indicator.indicator stopAnimating];
}

// Only successful request leads to response with
- (NSError *)processResponseJSON:(NSMutableDictionary *)dict
{
    BOOL toSave = NO;
    switch (self.requestType) {
        case TVSignUp:
            // device specific settings is after successful signUp.
        {
            TVUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
            NSLog(@"self.ctx.registeredObjects: %lu", (unsigned long)[self.ctx.registeredObjects count]);
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
                        if ([[(TVUser *)x email] isEqualToString:[[dict valueForKey:@"user"] valueForKey:@"email"]]) {
                            // TVUser exists already.
                            aUser = (TVUser *)x;
                            [self updateDocBaseServer:aUser withDic:[dict valueForKey:@"user"]];
                            [self updateUser:aUser withDic:dict];
                            break;
                        }
                    }
                }
                if (!aUser) {
                    aUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
                    [self setupNewDocBaseServer:aUser fromRequest:[dict valueForKey:@"user"]];
                    [self setupNewUserServer:aUser withDic:dict];
                }
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
                        if ([[(TVUser *)x serverId] isEqualToString:[d valueForKey:@"belongTo"]]) {
                            // TVUser exists already.
                            aUser = (TVUser *)x;
                            [self updateUser:aUser withDic:dict];
                            NSLog(@"aUser.objectID: %@", aUser.objectID);
                            NSLog(@"aUser: %@", aUser);
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
                        if ([[(TVUser *)x serverId] isEqualToString:[d valueForKey:@"belongTo"]]) {
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
            TVCard *aCard;
            if ([dict valueForKey:@"cards"]) {
                NSMutableArray *c = [dict valueForKey:@"cards"];
                for (NSManagedObject *x in self.objectArray) {
                    if ([x isKindOfClass:[TVCard class]]) {
                        aCard = (TVCard *)x;
                        if ([c count] == 1) {
                            [self updateDocBaseServer:aCard withDic:c[0]];
                            [self updateCard:aCard withDic:c[0]];
                            toSave = YES;
                        }
                    }
                }
            }
            break;
        }
        case TVOneCard:
        {
            TVCard *xCard;
            if ([dict valueForKey:@"cards"]) {
                NSMutableArray *c = [dict valueForKey:@"cards"];
                for (NSManagedObject *x in self.objectArray) {
                    if ([x isKindOfClass:[TVCard class]]) {
                        xCard = (TVCard *)x;
                        if ([c count] == 1) {
                            [self updateDocBaseServer:xCard withDic:c[0]];
                            [self updateCard:xCard withDic:c[0]];
                            toSave = YES;
                        } else if ([c count] == 2) {
                            NSMutableDictionary *aCard;
                            if ([[c[0] valueForKey:@"serverId"] isEqualToString:xCard.serverId]) {
                                aCard = c[0];
                            } else {
                                aCard = c[1];
                            }
                            [self updateDocBaseServer:xCard withDic:aCard];
                            [self updateCard:xCard withDic:aCard];
                            toSave = YES;
                        }
                    }
                }
            }
            break;
        }
        case TVSync:
        {
            TVUser *aUser;
            for (NSManagedObject *x in self.objectArray) {
                if ([x isKindOfClass:[TVUser class]]) {
                    if ([[(TVUser *)x email] isEqualToString:[[dict valueForKey:@"user"] valueForKey:@"email"]]) {
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
                    BOOL found = NO;
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
    NSError *err;
    if (toSave) {
        [self.ctx save:&err];
        [self printUser];
    }
    return err;
}

- (void)printUser
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSPredicate *pUser = [NSPredicate predicateWithFormat:@"email like 'matt.z.lw@gmail.com'"];
    [fetchRequest setPredicate:pUser];
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (r[0]) {
        NSLog(@"[self.ctx objectWithID:k] count: %lu", (unsigned long)[r count]);
        NSLog(@"[self.ctx objectWithID:k] serverId: %@", [r[0] serverId]);
        NSLog(@"[self.ctx objectWithID:k]: %@", r[0]);
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
    if (self.isUserTriggered) {
        self.ctler.numberOfUserTriggeredRequests = self.ctler.numberOfUserTriggeredRequests + 1;
    }
    NSMutableURLRequest *testRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]];
    // Start the indicator if it is not showing.
    if (self.ctler.numberOfUserTriggeredRequests == 1) {
        [self showIndicator];
    }
    [NSURLConnection sendAsynchronousRequest:testRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
     {
         if (self.ctler.numberOfUserTriggeredRequests <= 0) {
             NSLog(@"number of requests in progress not right: %d", self.ctler.numberOfUserTriggeredRequests);
         }
         self.ctler.numberOfUserTriggeredRequests = self.ctler.numberOfUserTriggeredRequests - 1;
         if (self.ctler.numberOfUserTriggeredRequests == 0) {
             [self hideIndicator];
         }
         NSError *err;
         if ([(NSHTTPURLResponse *)response statusCode] == 200) {
             TVRequester *req = [[TVRequester alloc] init];
             // Pass all properties
             req.urlBranch = self.urlBranch;
             req.contentType = self.contentType;
             req.method = self.method;
             req.body = self.body;
             req.email = self.email;
             req.password = self.password;
             req.accessToken = self.accessToken;
             req.isBearer = self.isBearer;
             req.internetIsOn = self.internetIsOn;
             req.requestType = self.requestType;
             req.userId = self.userId;
             req.deviceInfoId = self.deviceInfoId;
             req.deviceUuid = self.deviceUuid;
             req.cardId = self.cardId;
             req.objectIdArray = self.objectIdArray;
             req.objectArray = self.objectArray;
             req.ctx = self.ctx;
             req.model = self.model;
             req.coordinator = self.coordinator;
             req.record = self.record;
             req.reqId = self.reqId;
             err = [req proceedToRequest];
         } else {
             // For user triggered connecting attempt, show a notice to mention the unavailability of network.
             if (!self.indicator.indicator.isAnimating) {
                 [self hideIndicator];
             }
             [self.ctler showSysMsg:@"Network not available."];
         }
     }];
}

// No batch operation so far. each time, we handle only a single step operation for one record only.
- (NSError *)proceedToRequest
{
    if (self.isUserTriggered) {
        self.ctler.numberOfUserTriggeredRequests = self.ctler.numberOfUserTriggeredRequests + 1;
    }
    NSError *err;
    self.ctx = [self managedObjectContext];
    err = [self getObjInCtx];
    if (!err) {
        // Setup request and send
        NSMutableURLRequest *request = [self setupRequest];
        // Start the indicator if it is not showing.
        if (self.indicator.indicator.isAnimating) {
            [self hideIndicator];
        }
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
         {
             NSLog(@"response code: %i", [(NSHTTPURLResponse *)response statusCode]);
             
             if (error.code == -1004) {
                 // Error Domain=NSURLErrorDomain Code=-1004 "Could not connect to the server." https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
                 [self.ctler showSysMsg:@"Communication not successful"];
             }
             
             if (self.ctler.numberOfUserTriggeredRequests <= 0) {
                 NSLog(@"number of requests in progress not right: %d", self.ctler.numberOfUserTriggeredRequests);
             }
             self.ctler.numberOfUserTriggeredRequests = self.ctler.numberOfUserTriggeredRequests - 1;
             if (self.ctler.numberOfUserTriggeredRequests == 0) {
                 [self showIndicator];
             }
             if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                 self.record.lastUnsyncAction = [NSNumber numberWithInteger:TVDocNoAction];
                 if (self.reqId) {
                     self.reqId.done = [NSNumber numberWithBool:YES];
                 }
                 if (data.length > 0) {
                     NSError *aErr;
                     NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&aErr];
                     if (!aErr) {
                         aErr = [self processResponseJSON:dict];
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
    }
    return err;
}

- (NSError *)getObjInCtx
{
    NSError *err;
    if ([self.objectIdArray count] > 0) {
        for (NSManagedObjectID *i in self.objectIdArray) {
            NSManagedObject *x = [self.ctx existingObjectWithID:i error:&err];
            if (err) {
                return err;
            }
            if (!self.objectArray) {
                self.objectArray = [NSMutableArray arrayWithCapacity:0];
            }
            [self.objectArray addObject:x];
        }
    }
    return err;
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
    NSLog(@"X-REMOLET-DEVICE-ID: %@", [request valueForHTTPHeaderField:@"X-REMOLET-DEVICE-ID"]);
    return request;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (self.ctx) {
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
    if (self.model) {
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
    if (self.coordinator) {
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

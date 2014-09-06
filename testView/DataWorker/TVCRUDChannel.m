//
//  TVCRUDChannel.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-28.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVCRUDChannel.h"
#import "NSObject+CoreDataStack.h"
#import "NSObject+DataHandler.h"
#import "TVAppRootViewController.h"
#import "TVRequester.h"
#import "TVQueueElement.h"

@implementation TVCRUDChannel

@synthesize ctx;
@synthesize model;
@synthesize coordinator;
@synthesize fetchReq;

@synthesize box;
@synthesize ids;

- (id)init
{
    self = [super init];
    if (self) {
        self.ctx = [self managedObjectContext:self.ctx coordinator:self.coordinator model:self.model];
        self.ids = [[TVIdCarrier alloc] init];
    }
    return self;
}

#pragma mark - create new

- (void)insertOneCard:(NSDictionary *)card fromServer:(BOOL)isFromServer
{
    TVCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"TVCard" inManagedObjectContext:self.ctx];
    if (isFromServer) {
        [self setupNewDocBaseServer:newCard fromRequest:card];
    } else {
        [self setupNewDocBaseLocal:newCard];
    }
    [self setupNewCard:newCard withDic:card];
}

// reuqestId is always created locally.
- (void)insertOneReqId:(NSInteger)action for:(TVBase *)base
{
    TVRequestId *newReqId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:self.ctx];
    [self setupNewRequestId:newReqId action:action for:base];
}

// User is always created at server first, client only provides information.
- (void)insertOneUser:(NSDictionary *)user
{
    TVUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
    [self setupNewDocBaseServer:newUser fromRequest:user];
    [self setupNewUserServer:newUser withDic:user];
}

#pragma mark - update

- (void)updateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card fromServer:(BOOL)isFromServer
{
    if (isFromServer) {
        [self updateDocBaseServer:cardToUpdate withDic:card];
    } else {
        [self updateDocBaseLocal:cardToUpdate];
    }
   [self updateCard:cardToUpdate withDic:card];
}

- (void)updateOneUserd:(TVUser *)userToUpdate by:(NSDictionary *)user fromServer:(BOOL)isFromServer
{
    if (isFromServer) {
        [self updateDocBaseServer:userToUpdate withDic:user];
    } else {
        [self updateDocBaseLocal:userToUpdate];
    }
    [self updateUser:userToUpdate withDic:user];
}

#pragma mark - delete

- (void)deleteOneCard:(TVCard *)cardToDelete fromServer:(BOOL)isFromServer
{
    if (isFromServer) {
        [self.ctx deleteObject:cardToDelete];
    } else {
        [self deleteDocBaseLocal:cardToDelete];
    }
}

#pragma mark - save

- (BOOL)save:(BOOL)isUserTriggered
{
    if (isUserTriggered) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionAfterUserChange:) name:NSManagedObjectContextDidSaveNotification object:self.ctx];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    if ([self saveWithCtx:self.ctx]) {
        return YES;
    }
    return NO;
}

#pragma mark - mark requestIdDone

- (BOOL)markReqDone:(NSString *)recordServerId localId:(NSString *)recordLocalId reqId:(NSString *)reqId entityName:(NSString *)name
{
    TVBase *record;
    NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:name];
    BOOL found = NO;
    if (recordServerId.length > 0) {
        NSPredicate *p1 = [NSPredicate predicateWithFormat:@"serverId == %@", recordServerId];
        [fr setPredicate:p1];
        NSMutableArray *r1;
        if ([self fetch:fr withCtx:self.ctx outcome:r1]) {
            if ([r1 count] > 0) {
                found = YES;
                record = r1[0];
            }
        }
    }
    if (!found) {
        if (recordLocalId.length > 0) {
            NSPredicate *p2 = [NSPredicate predicateWithFormat:@"localId == %@", recordLocalId];
            [fr setPredicate:p2];
            NSMutableArray *r2;
            if ([self fetch:fr withCtx:self.ctx outcome:r2]) {
                if ([r2 count] > 0) {
                    found = YES;
                    record = r2[0];
                }
            }
        }
    }
    if (!found) {
        return NO;
    }
    record.lastUnsyncAction = [NSNumber numberWithInteger:TVDocNoAction];
    if (![self saveWithCtx:self.ctx]) {
        return NO;
    }
    NSMutableArray *r3;
    NSFetchRequest *fr1 = [[NSFetchRequest alloc] initWithEntityName:@"TVRequestId"];
    NSPredicate *p3 = [NSPredicate predicateWithFormat:@"requestId == %@", reqId];
    [fr1 setPredicate:p3];
    if ([self fetch:fr1 withCtx:self.ctx outcome:r3]) {
        if ([r3 count] > 0) {
            ((TVRequestId *)r3[0]).done = [NSNumber numberWithBool:YES];
            if ([self saveWithCtx:self.ctx]) {
                return YES;
            }
        }
    }
    return NO;
}



#pragma mark - reaction to local db change

- (void)actionAfterUserChange:(NSNotification *)n
{
    // Generate requestID for update operation for records with valid serverID everytime. Only updated obj needs to be checked. See comments in NSObject+DataHandler.m for details.
    NSArray *updated = [n valueForKey:@"NSUpdatedObjectsKey"];
    if ([updated count] > 0) {
        for (TVBase *x in updated) {
            TVRequestId *newReqId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:self.ctx];
            if (x.serverId.length == 0) {
                [self setupNewRequestId:newReqId action:TVDocNew for:x];
            } else {
                [self setupNewRequestId:newReqId action:TVDocUpdated for:x];
            }
        }
        if ([self saveWithCtx:self.ctx]) {
            // Sync
            
        }
    }
}

#pragma mark - sync cycle

// Get unsynced records from local db
- (void)syncCycle:(BOOL)isUserTriggered
{
    NSArray *a = [self getUndoneSet:self.ctx userId:self.box.userServerId];
    for (TVBase *b in a) {
        TVRequestId *rId = [self analyzeOneUndone:b inCtx:self.ctx];
        if (rId) {
            TVRequester *req = [[TVRequester alloc] init];
            req.box = self.box;
            req.isUserTriggered = isUserTriggered;
            req.isBearer = YES;
            if (rId.editAction.integerValue == TVDocDeleted) {
                req.method = @"DELETE";
                // No way to delete deviceInfo from client, so the only thing to delete is card.
                req.requestType = TVOneCard;
                req.urlBranch = [self getUrlBranchFor:TVOneCard userId:self.box.userServerId deviceInfoId:nil cardId:b.serverId];
            } else {
                NSError *e;
                req.body = [self getBody:rId.requestId forRecord:b err:&e];
                if (!e) {
                    req.method = @"POST";
                    if ([b isKindOfClass:[TVCard class]]) {
                        // Card
                        if (rId.editAction.integerValue == TVDocNew) {
                            req.requestType = TVNewCard;
                            req.urlBranch = [self getUrlBranchFor:TVNewCard userId:self.box.userServerId deviceInfoId:nil cardId:nil];
                        } else if (rId.editAction.integerValue == TVDocUpdated) {
                            req.requestType = TVOneCard;
                            req.urlBranch = [self getUrlBranchFor:TVOneCard userId:self.box.userServerId deviceInfoId:nil cardId:b.serverId];
                        }
                    } else if ([b isKindOfClass:[TVUser class]]) {
                        // DeviceInfo
                        if (rId.editAction.integerValue == TVDocNew) {
                            req.requestType = TVNewDeviceInfo;
                            req.urlBranch = [self getUrlBranchFor:TVNewDeviceInfo userId:self.box.userServerId deviceInfoId:nil cardId:nil];
                        } else if (rId.editAction.integerValue == TVDocUpdated) {
                            req.requestType = TVOneDeviceInfo;
                            req.urlBranch = [self getUrlBranchFor:TVOneDeviceInfo userId:self.box.userServerId deviceInfoId:self.box.deviceInfoId cardId:nil];
                        }
                    }
                }
            }
            [self setupAndLoadToQueue:self.box.comWorker req:req];
        }
    }
    // Check again to ensure no more unsynced
    if ([a count] == 0) {
        // Sync
        TVRequester *req = [[TVRequester alloc] init];
        req.box = self.box;
        req.isUserTriggered = isUserTriggered;
        req.isBearer = YES;
        req.method = @"POST";
        req.requestType = TVSync;
        req.urlBranch = [self getUrlBranchFor:TVSync userId:self.box.userServerId deviceInfoId:nil cardId:nil];
        NSMutableArray *m = [self getCardVerList:self.box.userServerId withCtx:self.ctx];
        req.body = [self getJSONSyncWithCardVerList:m err:nil];
        [self setupAndLoadToQueue:self.box.comWorker req:req];
    }
}

#pragma mark - user management

- (void)signOut
{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"TVUser"];
    NSMutableArray *r;
    if ([ctx fetch:fr withCtx:ctx outcome:r]) {
        if ([r count] != 0) {
            for (TVUser *u in r) {
                NSString *s = [self getRefreshTokenForAccount:u.serverId];
                if (s.length != 0) {
                    [self resetTokens:u.serverId];
                }
            }
        }
    }
}

#pragma mark - load to main queue

- (TVQueueElement *)setupAndLoadDataProcess:(NSMutableDictionary *)dict reqType:(NSInteger)t objArray:(NSArray *)a
{
    TVQueueElement *o = [TVQueueElement blockOperationWithBlock:^{
        TVCRUDChannel *crud = [[TVCRUDChannel alloc] init];
        if (![crud processResponseJSON:dict reqType:t objArray:a]) {
            // Process unsuccessful
        }
    }];
    [[NSOperationQueue mainQueue] addOperation:o];
    return o;
}

#pragma mark - process response

// Only successful request leads to response with
- (BOOL)processResponseJSON:(NSMutableDictionary *)dict reqType:(NSInteger)t objArray:(NSArray *)a
{
    BOOL toSave = NO;
    switch (t) {
        case TVSignUp:
            // device specific settings is after successful signUp.
        {
            TVUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
            if ([dict valueForKey:@"user"]) {
                [self setupNewDocBaseServer:newUser fromRequest:[dict valueForKey:@"user"]];
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
                for (NSManagedObject *x in a) {
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
        case TVOneUser:
        {
            TVUser *aUser;
            if ([dict valueForKey:@"user"]) {
                NSMutableDictionary *d = [dict valueForKey:@"user"];
                for (NSManagedObject *x in a) {
                    if ([x isKindOfClass:[TVUser class]]) {
                        if ([[(TVUser *)x serverId] isEqualToString:[d valueForKey:@"_id"]]) {
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
        case TVNewDeviceInfo:
        {
            TVUser *aUser;
            if ([dict valueForKey:@"deviceInfo"]) {
                NSMutableDictionary *d = [dict valueForKey:@"deviceInfo"];
                for (NSManagedObject *x in a) {
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
                for (NSManagedObject *x in a) {
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
                for (NSManagedObject *x in a) {
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
                for (NSManagedObject *x in a) {
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
            for (NSManagedObject *x in a) {
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
                        for (NSManagedObject *y in a) {
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
                        for (NSManagedObject *y in a) {
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
        if ([self saveWithCtx:self.ctx]) {
            // action after saved to db
            return YES;
        }
    }
    return NO;
}

- (void)actionAfterReqToDbDone:(NSInteger)reqType
{
    switch (reqType) {
        case TVSignUp:
            if ([self getLoggedInUser:self.ctx].activated.integerValue == 1) {
                
            } else {
                // Show view to ask user to activate
                [[NSNotificationCenter defaultCenter] postNotificationName:tvShowActivation object:self];
            }
            
        case TVSignIn:
            if ([self getLoggedInUser:self.ctx].activated.integerValue == 1) {
                
            } else {
                // Show view to ask user to activate
                [[NSNotificationCenter defaultCenter] postNotificationName:tvShowActivation object:self];
            };
            //        case TVOneUser:
            //            if (self.box.ctlOnDuty == TVActivationCtl) {
            //                if ([self getLatestUserInDB].activated.integerValue == 1) {
            //                    [[NSNotificationCenter defaultCenter] postNotificationName:tvShowLangPick object:self];
            //                } else {
            //                    // Show message that user is still not activated
            //                }
            //            };
            //        case TVSync:
            //            if (self.box.ctlOnDuty == TVLangPickCtl) {
            //                [[NSNotificationCenter defaultCenter] postNotificationName:tvShowAfterActivated object:self];
            //            };
    }
}

/*
 crudChannel's inputs needed:
 To find specific managedObj in local db
 1. serverId: to find specific managedObj in local db and provide info for url creation
 2. localId: to find specific managedObj in local db
 
 output:
 1. NSData: for request JSON
 2. card array with each card in a dictionary: read card(s) from local db
 3. user in a dictionary: read user from local db
 4.
 */

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

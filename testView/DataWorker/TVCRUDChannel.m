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
#import "TVUser.h"

@implementation TVCRUDChannel

@synthesize ctx;
@synthesize fromVewTag;
@synthesize box;
@synthesize ids;

- (id)init
{
    self = [super init];
    if (self) {
        self.ids = [[NSMutableSet alloc] init];
        self.box = ((TVAppRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).box;
        self.ctx = [self managedObjectContext:self.ctx coordinator:self.box.coordinator model:self.box.model];
    }
    return self;
}

#pragma mark - create new

- (TVCard *)insertOneCard:(NSDictionary *)card fromServer:(BOOL)isFromServer
{
    TVCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"TVCard" inManagedObjectContext:self.ctx];
    if (isFromServer) {
        [self setupNewDocBaseServer:newCard fromRequest:card];
    } else {
        [self setupNewDocBaseLocal:newCard];
    }
    [self setupNewCard:newCard withDic:card];
    return newCard;
}

// reuqestId is always created locally.
- (void)insertOneReqId:(NSInteger)action for:(TVBase *)base
{
    TVRequestIdCandidate *newReqId = [NSEntityDescription insertNewObjectForEntityForName:@"TVRequestId" inManagedObjectContext:self.ctx];
    [self setupNewRequestIdCandidate:newReqId action:action for:base];
}

// User is always created at server first, client only provides information.
- (void)insertOneUser:(NSDictionary *)user
{
    TVUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
    [self setupNewDocBaseServer:newUser fromRequest:user];
    [self setupNewUserServer:newUser withDic:user];
}

- (void)userCreateOneCard:(NSDictionary *)card
{
    TVCard *c =[self insertOneCard:card fromServer:NO];
    [self insertOneReqId:TVDocNew for:c];
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

- (void)updateOneUser:(TVUser *)userToUpdate by:(NSDictionary *)user fromServer:(BOOL)isFromServer
{
    if (isFromServer) {
        [self updateDocBaseServer:userToUpdate withDic:user];
    } else {
        [self updateDocBaseLocal:userToUpdate];
    }
    [self updateUser:userToUpdate withDic:user];
}

- (void)userUpdateOneCard:(TVCard *)cardToUpdate by:(NSDictionary *)card
{
    [self updateOneCard:cardToUpdate by:card fromServer:NO];
    [self insertOneReqId:TVDocUpdated for:cardToUpdate];
}

- (void)userUpdateOneUser:(TVUser *)userToUpdate by:(NSDictionary *)user
{
    [self updateOneUser:userToUpdate by:user fromServer:NO];
    [self insertOneReqId:TVDocUpdated for:userToUpdate];
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

- (void)userDeleteOneCard:(TVCard *)cardToDelete
{
    [self deleteOneCard:cardToDelete fromServer:NO];
    [self insertOneReqId:TVDocDeleted for:cardToDelete];
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
        NSMutableArray *r1 = [NSMutableArray arrayWithCapacity:0];;
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
            NSMutableArray *r2 = [NSMutableArray arrayWithCapacity:0];;
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
    for (TVRequestIdCandidate *c in record.hasReqIdCandidate) {
        if (c.requestId.length > 0) {
            if ([c.requestId isEqualToString:reqId]) {
                [self markRequestIdAsDone:c];
                if ([self saveWithCtx:self.ctx]) {
                    return YES;
                }
                break;
            }
        }
    }
    return NO;
}

#pragma mark - sync cycle

- (void)syncCycle:(BOOL)isUserTriggered
{
    BOOL readyToSyncUser = YES;
    BOOL readyToSyncCard = YES;
    TVUser *u = [self getLoggedInUser:self.ctx];
    if (u) {
        TVRequester *req = [[TVRequester alloc] init];
        req.box = self.box;
        req.isUserTriggered = isUserTriggered;
        req.isBearer = YES;
        TVRequestIdCandidate *r = [self analyzeOneRecord:u inCtx:self.ctx serverIsAvailable:self.box.serverIsAvailable];
        // requestId is generated in analyzeOneRecord
        req.reqId = r.requestId;
        if (r) {
            readyToSyncUser = NO;
            // DeviceInfo
            if (r.editAction.integerValue == TVDocNew) {
                req.requestType = TVNewDeviceInfo;
                req.urlBranch = [self getUrlBranchFor:TVNewDeviceInfo userId:self.box.userServerId deviceInfoId:nil cardId:nil];
                [req setupAndLoadToQueue:self.box.comWorker];
            } else if (r.editAction.integerValue == TVDocUpdated) {
                req.requestType = TVOneDeviceInfo;
                req.urlBranch = [self getUrlBranchFor:TVOneDeviceInfo userId:self.box.userServerId deviceInfoId:self.box.deviceInfoId cardId:nil];
                [req setupAndLoadToQueue:self.box.comWorker];
            }
        }
    }
    NSArray *cards = [self getCards:self.box.userServerId inCtx:self.ctx];
    for (TVCard *c in cards) {
        TVRequestIdCandidate *r = [self analyzeOneRecord:c inCtx:self.ctx serverIsAvailable:self.box.serverIsAvailable];
        if (r) {
            if (c.serverId.length > 0) {
                readyToSyncCard = NO;
                TVRequester *req = [[TVRequester alloc] init];
                req.box = self.box;
                req.isUserTriggered = isUserTriggered;
                req.isBearer = YES;
                req.reqId = r.requestId;
                if (r.editAction.integerValue == TVDocDeleted) {
                    req.method = @"DELETE";
                    // No way to delete deviceInfo from client, so the only thing to delete is card.
                    req.requestType = TVOneCard;
                    req.urlBranch = [self getUrlBranchFor:TVOneCard userId:self.box.userServerId deviceInfoId:nil cardId:c.serverId];
                    [req setupAndLoadToQueue:self.box.comWorker];
                } else {
                    NSError *e;
                    req.body = [self getBody:r.requestId forRecord:c err:&e];
                    if (!e) {
                        req.method = @"POST";
                        // Card
                        if (r.editAction.integerValue == TVDocNew) {
                            req.requestType = TVNewCard;
                            req.urlBranch = [self getUrlBranchFor:TVNewCard userId:self.box.userServerId deviceInfoId:nil cardId:nil];
                            [req setupAndLoadToQueue:self.box.comWorker];
                        } else if (r.editAction.integerValue == TVDocUpdated) {
                            req.requestType = TVOneCard;
                            req.urlBranch = [self getUrlBranchFor:TVOneCard userId:self.box.userServerId deviceInfoId:nil cardId:c.serverId];
                            [req setupAndLoadToQueue:self.box.comWorker];
                        }
                    }
                }
            } else {
                // In this case, only "TVDocNew" request has been sent since, without a serverID, there is no way to update/delete a record on sever. There could be multiple "TVDocNew" requests sent due to local update operation after the initial local create operation. Without the serverID, local update operation is treated as creating a new record to the server each time. When user delete it locally, the delete operation could not be able to trigger any request due to its lack of the serverID. So the record has different version of records on server as many as the requests it sends to the server since each time a new record is created on server. When syncing, those records are delivered back to client and the local record is deleted accordingly. User has to delete the redundant records after the sync process. User also may find the deleted local record show up again since it is not deleted on server. The one on server is copied back to the client as a new record. User has to delete it again.
                if (r.editAction.integerValue == TVDocNew || r.editAction.integerValue == TVDocUpdated) {
                    readyToSyncCard = NO;
                    TVRequester *req = [[TVRequester alloc] init];
                    req.reqId = r.requestId;
                    req.box = self.box;
                    req.isUserTriggered = isUserTriggered;
                    req.isBearer = YES;
                    NSError *e;
                    req.body = [self getBody:r.requestId forRecord:c err:&e];
                    if (!e) {
                        req.requestType = TVNewCard;
                        req.urlBranch = [self getUrlBranchFor:TVNewCard userId:self.box.userServerId deviceInfoId:nil cardId:nil];
                        [req setupAndLoadToQueue:self.box.comWorker];
                    }
                }
            }
            
        }
    }
    // Check again to ensure no more unsynced
    if (readyToSyncCard && readyToSyncUser) {
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
        [req setupAndLoadToQueue:self.box.comWorker];
    }
}

#pragma mark - process response

// od: @"user": TVUser @"cards": NSSet TVCard
- (BOOL)processResponseJSON:(NSMutableDictionary *)dict reqType:(NSInteger)t objDic:(NSDictionary *)od
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
                NSLog(@"newUser: %@", newUser);
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
            if ([dict valueForKey:@"user"]) {
                TVUser *u = [od valueForKey:@"user"];
                if ([u.email isEqualToString:[[dict valueForKey:@"user"] valueForKey:@"email"]]) {
                    // TVUser exists already.
                    [self updateDocBaseServer:u withDic:[dict valueForKey:@"user"]];
                    [self updateUser:u withDic:dict];
                    break;
                }
                if (!u) {
                    u = [NSEntityDescription insertNewObjectForEntityForName:@"TVUser" inManagedObjectContext:self.ctx];
                    [self setupNewDocBaseServer:u fromRequest:[dict valueForKey:@"user"]];
                    [self setupNewUserServer:u withDic:dict];
                }
                if ([dict valueForKey:@"tokens"]) {
                    NSMutableDictionary *t = [dict valueForKey:@"tokens"];
                    [self saveAccessToken:[t valueForKey:@"accessToken"] refreshToken:[t valueForKey:@"refreshToken"] toAccount:u.serverId];
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
            TVUser *u = [od valueForKey:@"user"];
            if ([dict valueForKey:@"user"]) {
                NSMutableDictionary *d = [dict valueForKey:@"user"];
                if ([u.serverId isEqualToString:[d valueForKey:@"_id"]]) {
                    // TVUser exists already.
                    [self updateUser:u withDic:dict];
                    toSave = YES;
                    break;
                }
            }
            break;
        }
        case TVNewDeviceInfo:
        {
            TVUser *u = [od valueForKey:@"user"];
            if ([dict valueForKey:@"deviceInfo"]) {
                NSMutableDictionary *d = [dict valueForKey:@"deviceInfo"];
                if ([u.serverId isEqualToString:[d valueForKey:@"belongTo"]]) {
                    // TVUser exists already.
                    [self updateUser:u withDic:dict];
                    toSave = YES;
                    break;
                }
            }
            break;
        }
        case TVOneDeviceInfo:
        {
            TVUser *u = [od valueForKey:@"user"];
            if ([dict valueForKey:@"deviceInfo"]) {
                NSMutableDictionary *d = [dict valueForKey:@"deviceInfo"];
                if ([u.serverId isEqualToString:[d valueForKey:@"belongTo"]]) {
                    // TVUser exists already.
                    [self updateUser:u withDic:dict];
                    toSave = YES;
                    break;
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
            NSSet *s = [od valueForKey:@"cards"];
            if ([dict valueForKey:@"cards"]) {
                NSMutableArray *c = [dict valueForKey:@"cards"];
                if ([s count] == 1) {
                    TVCard *aCard = [s anyObject];
                    [self updateDocBaseServer:aCard withDic:c[0]];
                    [self updateCard:aCard withDic:c[0]];
                    toSave = YES;
                }
            }
            break;
        }
        case TVOneCard:
        {
            NSSet *s = [od valueForKey:@"cards"];
            if ([dict valueForKey:@"cards"]) {
                NSMutableArray *c = [dict valueForKey:@"cards"];
                TVCard *aCard = [s anyObject];
                if ([c count] == 1) {
                    [self updateDocBaseServer:aCard withDic:c[0]];
                    [self updateCard:aCard withDic:c[0]];
                    toSave = YES;
                } else if ([c count] == 2) {
                    NSMutableDictionary *dCard;
                    if ([[c[0] valueForKey:@"serverId"] isEqualToString:aCard.serverId]) {
                        dCard = c[0];
                    } else {
                        dCard = c[1];
                    }
                    [self updateDocBaseServer:aCard withDic:dCard];
                    [self updateCard:aCard withDic:dCard];
                    toSave = YES;
                }
            }
            break;
        }
        case TVSync:
        {
            TVUser *u = [od valueForKey:@"user"];
            NSSet *cards = [od valueForKey:@"cards"];
            if (![u.email isEqualToString:[[dict valueForKey:@"user"] valueForKey:@"email"]]) {
                break;
            }
            [self updateDocBaseServer:u withDic:[dict valueForKey:@"user"]];
            [self updateUser:u withDic:dict];
            
            if ([dict valueForKey:@"cardList"]) {
                NSMutableArray *c = [dict valueForKey:@"cardList"];
                if ([c count] > 0) {
                    BOOL found = NO;
                    for (NSMutableDictionary *x in c) {
                        for (TVCard *y in cards) {
                            if ([[x valueForKey:@"serverId"] isEqualToString:y.serverId]) {
                                [self updateDocBaseServer:y withDic:x];
                                [self updateCard:y withDic:x];
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
                        for (TVCard *y in cards) {
                            if ([i isEqualToString:y.serverId]) {
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
            [self actionAfterReqToDbDone:t];
            return YES;
        }
    }
    return NO;
}

- (void)actionAfterReqToDbDone:(NSInteger)reqType
{
    switch (reqType) {
        case TVSignUp:
        {
            // Set userServerId for box
            TVUser *u = [self getLoggedInUser:self.ctx];
            [self.box.userServerId setString:u.serverId];
            if (u.activated.integerValue == 1) {
                // Show contentCtl
            } else {
                // Show view to ask user to activate
                [[NSNotificationCenter defaultCenter] postNotificationName:tvMinusAndCheckReqNo object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:tvShowActivation object:self];
            }
            break;
        }
        case TVSignIn:
            // Set userServerId for box
            [self.box.userServerId setString:[self getLoggedInUser:self.ctx].serverId];
            if ([self getLoggedInUser:self.ctx].activated.integerValue == 1) {
                
            } else {
                // Show view to ask user to activate
                [[NSNotificationCenter defaultCenter] postNotificationName:tvShowActivation object:self];
            }
            break;
        case TVOneUser:
            if (self.box.ctlOnDuty == TVActivationCtl) {
                TVUser *u = [self getLoggedInUser:self.ctx];
                if (u.activated.boolValue == YES) {
                    if (u.sourceLang.length > 0) {
                        // User already selected lang pair before.
                        [[NSNotificationCenter defaultCenter] postNotificationName:tvShowContent object:self];
                    } else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:tvShowTarget object:self];
                    }
                } else {
                    // Show message that user is still not activated
                    [self.box.warning setString:@"Activation needed."];
                    [[NSNotificationCenter defaultCenter] postNotificationName:tvShowWarning object:self];
                }
            }
            break;
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

@end

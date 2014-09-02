//
//  TVCommunicator.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVCommunicator.h"
#import "TVRequester.h"
#import "TVBase.h"
#import "TVUser.h"
#import "TVCard.h"
#import "TVRequestId.h"
#import "NSObject+DataHandler.h"
#import "TVAppRootViewController.h"
#import "NSObject+CoreDataStack.h"

@implementation TVCommunicator

@synthesize ctx;

@synthesize unsynced;
@synthesize requestType;
@synthesize deviceInfoId;
@synthesize deviceUuid;
@synthesize cardId;
@synthesize indicator;
@synthesize isUserTriggered;
@synthesize bWorker;
@synthesize box;

// There should be only one communicator instance existing in the app.

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        // Mornitor user triggered local db change
    }
    return self;
}

#pragma mark - work in background

- (void)checkServerAvailToSyncInBack:(BOOL)itIsUserTriggered
{
    [self.bWorker addOperationWithBlock:^(void){
        [self checkServerAvailToSync:itIsUserTriggered];
    }];
}

- (void)syncCycleInBack:(BOOL)itIsUserTriggered
{
    [self.bWorker addOperationWithBlock:^(void){
        [self syncCycle:itIsUserTriggered];
    }];
}

#pragma mark - sync cycle

- (void)checkServerAvailToSync:(BOOL)itIsUserTriggered
{
    // Use itIsUserTriggered as the parameter to avoid future change of self.isUserTriggered.
    // Check indicator
    if (itIsUserTriggered) {
        [[NSNotificationCenter defaultCenter] postNotificationName:tvAddAndCheckReqNo object:self];
    }
    NSMutableURLRequest *testRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]];
    [NSURLConnection sendAsynchronousRequest:testRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error)
     {
         if ([(NSHTTPURLResponse *)response statusCode] == 200) {
             [self syncCycle:itIsUserTriggered];
         }
         if (itIsUserTriggered) {
             [[NSNotificationCenter defaultCenter] postNotificationName:tvMinusAndCheckReqNo object:self];
         }
     }];
}

// Get unsynced records from local db
- (void)syncCycle:(BOOL)itIsUserTriggered
{
    if ([self.unsynced count] == 0) {
        self.unsynced = [self getUndoneSet:self.ctx user:self.box.user];
    }
    for (TVBase *b in self.unsynced) {
        TVRequestId *rId = [self analyzeOneUndone:b inCtx:self.ctx];
        if (rId) {
            TVRequester *req = [[TVRequester alloc] init];
            req.box = self.box;
            req.isUserTriggered = itIsUserTriggered;
            req.isBearer = YES;
            if (rId.editAction.integerValue == TVDocDeleted) {
                req.method = @"DELETE";
                // No way to delete deviceInfo from client, so the only thing to delete is card.
                req.requestType = TVOneCard;
                req.urlBranch = [self getUrlBranchFor:TVOneCard userId:self.box.user.serverId deviceInfoId:nil cardId:b.serverId];
            } else {
                NSError *e;
                req.body = [self getBody:rId.requestId forRecord:b err:&e];
                if (!e) {
                    req.method = @"POST";
                    if ([b isKindOfClass:[TVCard class]]) {
                        // Card
                        if (rId.editAction.integerValue == TVDocNew) {
                            req.requestType = TVNewCard;
                            req.urlBranch = [self getUrlBranchFor:TVNewCard userId:self.box.user.serverId deviceInfoId:nil cardId:nil];
                        } else if (rId.editAction.integerValue == TVDocUpdated) {
                            req.requestType = TVOneCard;
                            req.urlBranch = [self getUrlBranchFor:TVOneCard userId:self.box.user.serverId deviceInfoId:nil cardId:b.serverId];
                        }
                    } else if ([b isKindOfClass:[TVUser class]]) {
                        // DeviceInfo
                        if (rId.editAction.integerValue == TVDocNew) {
                            req.requestType = TVNewDeviceInfo;
                            req.urlBranch = [self getUrlBranchFor:TVNewDeviceInfo userId:self.box.user.serverId deviceInfoId:nil cardId:nil];
                        } else if (rId.editAction.integerValue == TVDocUpdated) {
                            req.requestType = TVOneDeviceInfo;
                            req.urlBranch = [self getUrlBranchFor:TVOneDeviceInfo userId:self.box.user.serverId deviceInfoId:self.box.user.deviceInfoId cardId:nil];
                        }
                    }
                }
            }
            [req proceedToRequest];
        }
    }
    // Check again to ensure no more unsynced
    if ([self.unsynced count] == 0) {
        // Sync
        TVRequester *req = [[TVRequester alloc] init];
        req.box = self.box;
        req.isUserTriggered = itIsUserTriggered;
        req.isBearer = YES;
        req.method = @"POST";
        req.requestType = TVSync;
        req.urlBranch = [self getUrlBranchFor:TVSync userId:self.box.user.serverId deviceInfoId:nil cardId:nil];
        NSMutableArray *m = [self getCardVerList:self.box.user.serverId withCtx:self.ctx];
        req.body = [self getJSONSyncWithCardVerList:m err:nil];
        [req proceedToRequest];
    }
}

@end

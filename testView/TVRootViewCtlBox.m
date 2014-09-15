//
//  TVRootViewCtlBox.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-22.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVRootViewCtlBox.h"
#import "NSObject+DataHandler.h"
#import "TVQueueElement.h"
#import "TVAppRootViewController.h"

@implementation TVRootViewCtlBox

@synthesize ctlOnDuty;
@synthesize numberOfUserTriggeredRequests;
@synthesize transitionPointInRoot;
@synthesize sourceLang;
@synthesize targetLang;
@synthesize warning;

@synthesize appRect;
@synthesize originX;
@synthesize labelWidth;
@synthesize gapY;
@synthesize serverIsAvailable;
@synthesize userServerId;
@synthesize coordinator;
@synthesize model;
@synthesize indicator;
@synthesize dbWorker;
@synthesize comWorker;
@synthesize deviceInfoId;
@synthesize ids;
@synthesize taskArray;
@synthesize isCheckingServer;
@synthesize cardIdInEditing;

- (id)init
{
    self = [super init];
    if (self) {
        self.ctlOnDuty = TVNoCtl;
        self.numberOfUserTriggeredRequests = 0;
        self.userServerId = [[NSMutableString alloc] init];
        self.warning = [[NSMutableString alloc] init];
        self.sourceLang = [[NSMutableString alloc] init];
        self.targetLang = [[NSMutableString alloc] init];
        self.dbWorker = [[NSOperationQueue alloc] init];
        self.comWorker = [[NSOperationQueue alloc] init];
        self.serverIsAvailable = NO;
        self.isCheckingServer = NO;
        self.taskArray = [NSMutableArray arrayWithCapacity:0];
        self.ids = [[NSMutableSet alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFromTaskArray:) name:tvRemoveOperation object:nil];
    }
    return self;
}

- (void)setupBox
{
    self.originX = self.appRect.size.width * 0.05f;
    self.labelWidth = self.appRect.size.width * 0.9f;
    self.gapY = 5.0f;
}

- (void)removeFromTaskArray:(NSNotification *)n
{
    TVQueueElement *q = (TVQueueElement *)n;
    [self.taskArray removeObject:q];
}

@end
//
//  TVRootViewCtlBox.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-22.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVRootViewCtlBox.h"

@implementation TVRootViewCtlBox

@synthesize ctlOnDuty;
@synthesize numberOfUserTriggeredRequests;
@synthesize transitionPointInRoot;
@synthesize sourceLang;
@synthesize targetLang;
@synthesize warning;

- (id)init
{
    self = [super init];
    if (self) {
        self.ctlOnDuty = TVNoCtl;
        self.numberOfUserTriggeredRequests = 0;
    }
    return self;
}

@end

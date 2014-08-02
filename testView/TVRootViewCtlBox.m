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

@synthesize appRect;
@synthesize originX;
@synthesize labelWidth;
@synthesize gapY;

- (id)init
{
    self = [super init];
    if (self) {
        self.ctlOnDuty = TVNoCtl;
        self.numberOfUserTriggeredRequests = 0;
        self.warning = [[NSMutableString alloc] init];
        self.sourceLang = [[NSMutableString alloc] init];
        self.targetLang = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)setupBox
{
    self.originX = self.appRect.size.width * 0.05f;
    self.labelWidth = self.appRect.size.width * 0.9f;
    self.gapY = 5.0f;
}

@end
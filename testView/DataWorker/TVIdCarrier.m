//
//  TVIdCarrier.m
//  testView
//
//  Created by Liwei Zhang on 2014-09-05.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVIdCarrier.h"

@implementation TVIdCarrier

@synthesize userServerId;
@synthesize cardIds;

- (id)init
{
    self = [super init];
    if (self) {
        self.cardIds = [NSMutableSet setWithCapacity:0];
    }
    return self;
}

@end

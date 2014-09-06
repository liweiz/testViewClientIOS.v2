//
//  TVQueueElement.m
//  testView
//
//  Created by Liwei Zhang on 2014-09-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVQueueElement.h"
#import "TVAppRootViewController.h"

@implementation TVQueueElement

@synthesize isForRequest;
@synthesize box;

- (id)init
{
    self = [super init];
    if (self) {
        // From: http://stackoverflow.com/questions/14556605/capturing-self-strongly-in-this-block-is-likely-to-lead-to-a-retain-cycle
        __weak typeof(self) weakSelf = self;
        [self setCompletionBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:tvRemoveOperation object:weakSelf];
        }];
    }
    return self;
}

@end

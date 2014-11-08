//
//  TVQueueElement.h
//  testView
//
//  Created by Liwei Zhang on 2014-09-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVQueueElement : NSBlockOperation

@property (assign, nonatomic) BOOL isForServerAvailCheck;
@property (copy, nonatomic) NSString *cycleDna;

@end

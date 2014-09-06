//
//  TVIdCarrier.h
//  testView
//
//  Created by Liwei Zhang on 2014-09-05.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVIdCarrier : NSObject

// TVUser must come with serverId since it is created on server first and sync back to client afterwards.
@property (strong, nonatomic) NSString *userServerId;
@property (strong, nonatomic) NSMutableSet *cardIds;

@end

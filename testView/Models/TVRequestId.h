//
//  TVRequestId.h
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVBase;

@interface TVRequestId : NSManagedObject

@property (nonatomic, retain) NSDate * createdAtLocal;
@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSNumber * editAction;
@property (nonatomic, retain) NSDate * lastModifiedAtLocal;
@property (nonatomic, retain) NSNumber * operationVersion;
@property (nonatomic, retain) NSString * requestId;
@property (nonatomic, retain) TVBase *belongTo;

@end

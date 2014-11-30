//
//  TVRequestIdCandidate.h
//  testView
//
//  Created by Liwei Zhang on 2014-09-08.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVBase;

@interface TVRequestIdCandidate : NSManagedObject

@property (nonatomic, retain) NSDate * createdAtLocal;
@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSNumber * editAction;
@property (nonatomic, retain) NSDate * lastModifiedAtLocal;
@property (nonatomic, retain) NSNumber * operationVersion;
@property (nonatomic, retain) NSString * requestId;
@property (nonatomic, retain) TVBase *belongTo;

@end

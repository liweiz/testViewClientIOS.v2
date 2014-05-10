//
//  TVRequestID.h
//  testView
//
//  Created by Liwei on 2014-05-09.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVBase;

@interface TVRequestID : NSManagedObject

@property (nonatomic, retain) NSString * requestID;
@property (nonatomic, retain) NSNumber * operationVersion;
@property (nonatomic, retain) NSDate * createdAtLocal;
@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSDate * lastModifiedAtLocal;
@property (nonatomic, retain) TVBase *belongTo;

@end

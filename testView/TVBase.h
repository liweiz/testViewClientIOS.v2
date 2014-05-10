//
//  TVBase.h
//  testView
//
//  Created by Liwei on 2014-05-09.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVRequestID;

@interface TVBase : NSManagedObject

@property (nonatomic, retain) NSNumber * editAction;
@property (nonatomic, retain) NSDate * lastModifiedAtLocal;
@property (nonatomic, retain) NSDate * lastModifiedAtServer;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSString * versionNo;
@property (nonatomic, retain) NSString * localID;
@property (nonatomic, retain) NSSet *hasReqID;
@end

@interface TVBase (CoreDataGeneratedAccessors)

- (void)addHasReqIDObject:(TVRequestID *)value;
- (void)removeHasReqIDObject:(TVRequestID *)value;
- (void)addHasReqID:(NSSet *)values;
- (void)removeHasReqID:(NSSet *)values;

@end

//
//  TVBase.h
//  testView
//
//  Created by Liwei on 2014-05-17.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVRequestId;

@interface TVBase : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedAtLocal;
@property (nonatomic, retain) NSDate * lastModifiedAtServer;
@property (nonatomic, retain) NSNumber * lastUnsyncAction;
@property (nonatomic, retain) NSString * localId;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSNumber * versionNo;
@property (nonatomic, retain) NSSet *hasReqId;
@end

@interface TVBase (CoreDataGeneratedAccessors)

- (void)addHasReqIdObject:(TVRequestId *)value;
- (void)removeHasReqIdObject:(TVRequestId *)value;
- (void)addHasReqId:(NSSet *)values;
- (void)removeHasReqId:(NSSet *)values;

@end

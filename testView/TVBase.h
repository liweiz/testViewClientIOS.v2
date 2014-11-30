//
//  TVBase.h
//  testView
//
//  Created by Liwei Zhang on 2014-09-08.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TVRequestIdCandidate;

@interface TVBase : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedAtLocal;
@property (nonatomic, retain) NSDate * lastModifiedAtServer;
@property (nonatomic, retain) NSString * localId;
@property (nonatomic, retain) NSNumber * locallyDeleted;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSNumber * versionNo;
@property (nonatomic, retain) NSSet *hasReqIdCandidate;
@end

@interface TVBase (CoreDataGeneratedAccessors)

- (void)addHasReqIdCandidateObject:(TVRequestIdCandidate *)value;
- (void)removeHasReqIdCandidateObject:(TVRequestIdCandidate *)value;
- (void)addHasReqIdCandidate:(NSSet *)values;
- (void)removeHasReqIdCandidate:(NSSet *)values;

@end

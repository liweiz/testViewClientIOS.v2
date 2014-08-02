//
//  TVDraft.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-29.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TVDraft : NSManagedObject

@property (nonatomic, retain) NSString * context;
@property (nonatomic, retain) NSString * target;
@property (nonatomic, retain) NSString * translation;
@property (nonatomic, retain) NSString * detail;

@end

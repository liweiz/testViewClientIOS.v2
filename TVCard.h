//
//  TVCard.h
//  testView
//
//  Created by Liwei Zhang on 2014-09-08.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TVBase.h"

@class TVUser;

@interface TVCard : TVBase

@property (nonatomic, retain) NSString * belongTo;
@property (nonatomic, retain) NSDate * collectedAt;
@property (nonatomic, retain) NSString * context;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSString * sourceLang;
@property (nonatomic, retain) NSString * target;
@property (nonatomic, retain) NSString * targetLang;
@property (nonatomic, retain) NSString * translation;
@property (nonatomic, retain) TVUser *belongToUser;

@end

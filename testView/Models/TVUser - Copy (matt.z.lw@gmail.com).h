//
//  TVUser.h
//  testView
//
//  Created by Liwei on 2014-05-13.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TVBase.h"

@class TVCard;

@interface TVUser : TVBase

@property (nonatomic, retain) NSNumber * activated;
@property (nonatomic, retain) NSString * deviceUUID;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * isLoggedIn;
@property (nonatomic, retain) NSNumber * rememberMe;
@property (nonatomic, retain) NSString * sortOption;
@property (nonatomic, retain) NSString * sourceLang;
@property (nonatomic, retain) NSString * targetLang;
@property (nonatomic, retain) TVCard *hasCards;

@end

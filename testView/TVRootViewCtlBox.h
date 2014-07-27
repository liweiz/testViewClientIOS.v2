//
//  TVRootViewCtlBox.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-22.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TVCtl) {
    TVNoCtl,
    TVLoginCtl,
    TVActivationCtl,
    TVNativePickCtl,
    TVTargetPickCtl,
    TVContentCtl
};

@interface TVRootViewCtlBox : NSObject

// Show the current viewController on duty
@property (assign, nonatomic) TVCtl ctlOnDuty;
// Number of requests undone
@property (assign, nonatomic) NSInteger numberOfUserTriggeredRequests;
@property (assign, nonatomic) CGPoint transitionPointInRoot;
@property (assign, nonatomic) NSString *sourceLang;
@property (assign, nonatomic) NSString *targetLang;
@property (assign, nonatomic) NSString *warning;

@end

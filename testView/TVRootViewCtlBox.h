//
//  TVRootViewCtlBox.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-22.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVUser.h"
#import "TVIndicator.h"
#import "TVCommunicator.h"

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
@property (strong, nonatomic) NSMutableString *sourceLang;
@property (strong, nonatomic) NSMutableString *targetLang;
@property (strong, nonatomic) NSMutableString *warning;

@property (assign, nonatomic) CGRect appRect;
@property (assign, nonatomic) CGFloat originX;
@property (assign, nonatomic) CGFloat labelWidth;
@property (assign, nonatomic) CGFloat gapY;

@property (strong, nonatomic) TVUser *user;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) TVIndicator *indicator;

@property (strong, nonatomic) NSOperationQueue *dbWorker;
@property (strong, nonatomic) NSOperationQueue *comWorker;

@property (strong, nonatomic) TVCommunicator *com;

- (void)setupBox;


@end

//
//  TVRootViewCtlBox.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-22.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVBlockIndicator.h"
#import "TVNonBlockIndicator.h"
#import "TVIdPair.h"

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
@property (assign, nonatomic) NSInteger numberOfNonUserTriggeredRequests;
@property (assign, nonatomic) CGPoint transitionPointInRoot;
@property (strong, nonatomic) NSMutableString *sourceLang;
@property (strong, nonatomic) NSMutableString *targetLang;
@property (strong, nonatomic) NSMutableString *warning;
@property (assign, nonatomic) NSInteger numberOfUncommittedRecord;
@property (assign, nonatomic) CGRect appRect;
@property (assign, nonatomic) CGFloat originX;
@property (assign, nonatomic) CGFloat labelWidth;
@property (assign, nonatomic) CGFloat gapY;

@property (assign, nonatomic) BOOL serverIsAvailable;

@property (strong, nonatomic) NSMutableString *userServerId;
@property (strong, nonatomic) TVIdPair *cardIdInEditing;
@property (strong, nonatomic) NSString *deviceInfoId;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) TVBlockIndicator *bIndicator;
@property (strong, nonatomic) TVNonBlockIndicator *nbIndicator;
@property (strong, nonatomic) NSOperationQueue *dbWorker;
@property (strong, nonatomic) NSOperationQueue *comWorker;
// validDna is used to store app's current sync cycle's dna. If no sync cycle is needed, it is set to be empty.
@property (strong, nonatomic) NSMutableString *validDna;
@property (strong, nonatomic) NSMutableSet *ids;

- (void)setupBox;


@end

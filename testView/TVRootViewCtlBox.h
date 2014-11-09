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

extern NSString *const tvEnglishFontName;
extern NSString *const tvServerUrl;
extern CGFloat const goldenRatio;
extern CGFloat const tvRowHeight;

extern CGFloat const tvFontSizeLarge;
extern CGFloat const tvFontSizeRegular;
extern NSString *const tvShowNative;
extern NSString *const tvShowTarget;
extern NSString *const tvShowActivation;
extern NSString *const tvShowContent;
extern NSString *const tvShowAfterActivated;
extern NSString *const tvPinchToShowAbove;
extern NSString *const tvAddAndCheckReqNo;
extern NSString *const tvMinusAndCheckReqNo;
extern NSString *const tvAddAndCheckReqNoNB;
extern NSString *const tvMinusAndCheckReqNoNB;

extern NSString *const tvUserChangedLocalDb;
extern NSString *const tvUserSignUp;
extern NSString *const tvShowWarning;
extern NSString *const tvPinchToShowSave;
extern NSString *const tvSaveAsNew;
extern NSString *const tvSaveAsUpdate;
extern NSString *const tvDismissSaveViewOnly;
extern NSString *const tvHideExpandedCard;

extern NSString *const tvFetchOrSaveErr;
extern NSString *const tvRemoveOperation;

extern NSString *const tvMarkReqIdDone;
extern NSString *const tvSignOut;

extern NSString *const tvAddOneToUncommitted;
extern NSString *const tvMinusOneToUncommitted;

extern CGFloat const gapY;

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

+ (instancetype)sharedBox;

- (void)setupBox;

@end

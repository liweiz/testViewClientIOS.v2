//
//  TVRootViewCtlBox.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-22.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVRootViewCtlBox.h"
#import "NSObject+DataHandler.h"
#import "TVQueueElement.h"
#import "TVAppRootViewController.h"

NSString *const tvEnglishFontName = @"TimesNewRomanPSMT";
NSString *const tvServerUrl = @"http://localhost:3000";
CGFloat const goldenRatio = 1.6180339887498948482 / 2.6180339887498948482;
CGFloat const tvRowHeight = 50.0f;

CGFloat const tvFontSizeLarge = 23.0f;
CGFloat const tvFontSizeRegular = 17.0f;
NSString *const tvShowLogin = @"tvShowLogin";
NSString *const tvShowActivation = @"tvShowActivation";
NSString *const tvShowNative = @"tvShowLangPickNative";
NSString *const tvShowTarget = @"tvShowLangPickTarget";
NSString *const tvShowContent = @"tvShowContent";
NSString *const tvShowAfterActivated = @"tvShowAfterActivated";

NSString *const tvPinchToShowAbove = @"tvPinchToShowAbove";
NSString *const tvAddAndCheckReqNo = @"tvAddAndCheckReqNo";
NSString *const tvMinusAndCheckReqNo = @"tvMinusAndCheckReqNo";
NSString *const tvAddAndCheckReqNoNB = @"tvAddAndCheckReqNoNB";
NSString *const tvMinusAndCheckReqNoNB = @"tvMinusAndCheckReqNoNB";
NSString *const tvUserChangedLocalDb = @"tvUserChangedLocalDb";
NSString *const tvUserSignUp = @"tvUserSignUp";

NSString *const tvShowWarning = @"tvShowWarning";

NSString *const tvPinchToShowSave = @"tvPinchToShowSave";
NSString *const tvSaveAsNew = @"tvSaveAsNew";
NSString *const tvSaveAsUpdate = @"tvSaveAsUpdate";

NSString *const tvDismissSaveViewOnly = @"tvDismissSaveViewOnly";

NSString *const tvHideExpandedCard = @"tvHideExpandedCard";

NSString *const tvFetchOrSaveErr = @"tvFetchOrSaveErr";
NSString *const tvRemoveOperation = @"tvRemoveOperation";
NSString *const tvMarkReqIdDone = @"tvMarkReqIdDone";

NSString *const tvSignOut = @"tvSignOut";

NSString *const tvAddOneToUncommitted = @"tvAddOneToUncommitted";
NSString *const tvMinusOneToUncommitted = @"tvMinusOneToUncommitted";

CGFloat const gapY = 5;

@implementation TVRootViewCtlBox

+ (instancetype)sharedBox {
    static TVRootViewCtlBox *box = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        box = [[self alloc] init];
    });
    return box;
}

- (id)init
{
    self = [super init];
    if (self) {
        _ctlOnDuty = TVNoCtl;
        _numberOfNonUserTriggeredRequests = 0;
        _numberOfUserTriggeredRequests = 0;
        _numberOfUncommittedRecord = 0;
        _userServerId = [[NSMutableString alloc] init];
        _warning = [[NSMutableString alloc] init];
        _sourceLang = [[NSMutableString alloc] init];
        _targetLang = [[NSMutableString alloc] init];
        _dbWorker = [[NSOperationQueue alloc] init];
        _comWorker = [[NSOperationQueue alloc] init];
        _serverIsAvailable = NO;
        _validDna = [[NSMutableString alloc] init];
        _ids = [[NSMutableSet alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFromTaskArray:) name:tvRemoveOperation object:nil];
    }
    return self;
}

- (void)setupBox
{
    self.originX = self.appRect.size.width * 0.05;
    self.labelWidth = self.appRect.size.width * 0.9;
}

- (void)removeFromTaskArray:(NSNotification *)n
{
    TVQueueElement *q = (TVQueueElement *)n;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
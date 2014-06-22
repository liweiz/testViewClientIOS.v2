//
//  TVAppRootViewController.h
//  testView
//
//  Created by Liwei Zhang on 2013-10-18.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVUser.h"
#import "TVIndicator.h"
#import "TVLoginViewController.h"
#import "KeychainItemWrapper.h"

extern NSString *const tvEnglishFontName;
extern NSString *const tvServerUrl;
extern CGFloat const goldenRatio;
//extern UIColor *const tvBackgroundColor;
//extern UIColor *const tvBackgroundColorAlternative;
//extern UIColor *const tvFontColor;
//extern CGFloat *const tvFontSizeHeader;
//extern CGFloat *const tvFontSizeContent;


@interface TVAppRootViewController : UIViewController

@property (nonatomic, assign) CGRect appRect;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSFetchRequest *userFetchRequest;
@property (strong, nonatomic) TVUser *user;
@property (strong, nonatomic) TVLoginViewController *loginViewController;
//@property (strong, nonatomic) TVContentRootViewController *contentViewController;

@property (assign, nonatomic) BOOL requestReceivedResponse;
@property (assign, nonatomic) BOOL willSendRequest;
@property (assign, nonatomic) BOOL internetIsAccessible;
// the number of requests undone
@property (assign, nonatomic) NSInteger numberOfUserTriggeredRequests;

@property (strong, nonatomic) KeychainItemWrapper *passItem;

@property (strong, nonatomic) TVIndicator *indicator;
@property (strong, nonatomic) UILabel *sysMsg;

- (void)showSysMsg:(NSString *)msg;

@end

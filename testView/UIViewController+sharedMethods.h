//
//  UIViewController+sharedMethods.h
//  testView
//
//  Created by Liwei on 2013-08-08.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVTableViewController.h"
#import "TVNewBaseViewController.h"
#import "TVBase.h"
#import "TVCard.h"
#import "TVUser.h"
#import "TVTableViewCell0.h"
#import "TVAppRootViewController.h"
#import "KeychainItemWrapper.h"

typedef NS_ENUM(NSInteger, ConnectionErrorStatus) {
    ServerNotAvailable,
    AccountAlreadyExists,
    IncorrectAccountNameOrPassword,
    DataDownloaded,
    NoDataDownloaded,
    TimeOut,
    NoSuchAccountExists,
    OtherError
};

@interface UIViewController (sharedMethods)

#pragma mark - remove blank spaces at the beginning and end of any input

- (NSString *)trimInput:(NSString *)text;

#pragma mark - multiselection and save

- (void)changeSet:(NSSet *)changeSet relationshipKey:(NSString *)key selectionSetOrigin:(NSSet *)originSet;
- (void)saveMultiselectionChange:(NSManagedObjectContext *)managedObjectContext;

#pragma mark - horizontal scrolling freeze/defreeze

- (void)freezeRootView;
- (void)defreezeRootView;

#pragma mark - Load file from supporting files
- (NSArray *)loadLangArray;

#pragma mark - RequestVersion generator and unique string for device identification

- (void)switchRequestVersionNoUpdate:(TVUser *)user;
- (void)assignRequestVersionNoWithUser:(TVUser *)user allRecord:(NSArray *)allRecord;
- (NSNumber *)generateRequestVersionNo:(NSNumber *)currentRequestVersionNo;
- (NSString *)getUUID;

@end
//
//  TVTestViewController.h
//  testView
//
//  Created by Liwei on 2014-05-29.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVUser.h"
#import "KeychainItemWrapper.h"

@interface TVTestViewController : UIViewController

@property (nonatomic, assign) CGRect appRect;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) TVUser *user;

@property (assign, nonatomic) BOOL requestReceivedResponse;
@property (assign, nonatomic) BOOL willSendRequest;
@property (assign, nonatomic) BOOL internetIsAccessible;

@property (strong, nonatomic) KeychainItemWrapper *passItem;

@end

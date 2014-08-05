//
//  TVNewBaseViewController.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-04.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVNewViewController.h"
#import "TVRootViewCtlBox.h"

@interface TVNewBaseViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) TVNewViewController *myNewViewCtl;
@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) TVSaveViewController *saveViewCtl;
@property (assign, nonatomic) BOOL createNewOnly;

@end
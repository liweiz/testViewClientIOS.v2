//
//  TVLayerBaseViewController.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-01.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVUser.h"
#import "TVIndicator.h"
#import "TVRootViewCtlBox.h"

@interface TVLayerBaseViewController : UIViewController

@property (nonatomic, assign) CGRect appRect;
@property (strong, nonatomic) TVIndicator *indicator;
@property (strong, nonatomic) TVUser *user;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchToShow;
@property (strong, nonatomic) TVRootViewCtlBox *box;

@end

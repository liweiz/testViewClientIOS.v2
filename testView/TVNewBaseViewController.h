//
//  TVNewBaseViewController.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-04.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVNewViewController.h"

@interface TVNewBaseViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *ctx;

@property (strong, nonatomic) TVNewViewController *myNewViewCtl;
@property (strong, nonatomic) TVSaveViewController *saveViewCtl;
@property (assign, nonatomic) BOOL createNewOnly;
@property (strong, nonatomic) NSString *cardToUpdateServerId;
@property (strong, nonatomic) NSString *cardToUpdateLocalId;

@end

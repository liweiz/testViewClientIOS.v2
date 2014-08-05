//
//  TVSaveViewController.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-31.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVLayerBaseViewController.h"
#import "TVRootViewCtlBox.h"

@interface TVSaveViewController : UIViewController

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) UILabel *saveAsNewBtn;
@property (strong, nonatomic) UITapGestureRecognizer *saveAsNewTap;
@property (strong, nonatomic) UILabel *updateBtn;
@property (strong, nonatomic) UITapGestureRecognizer *updateTap;
@property (assign, nonatomic) BOOL createNewOnly;
@property (strong, nonatomic) UIViewController *ctlInCharge;

- (void)checkIfUpdateBtnNeeded;

@end

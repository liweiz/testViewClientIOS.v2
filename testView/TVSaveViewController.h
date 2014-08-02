//
//  TVSaveViewController.h
//  testView
//
//  Created by Liwei Zhang on 2014-07-31.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVLayerBaseViewController.h"
#import "TVRootViewCtlBox.h"
#import "TVNewBaseViewController.h"

@interface TVSaveViewController : TVLayerBaseViewController

@property (nonatomic, assign) CGRect appRect;

@property (strong, nonatomic) TVRootViewCtlBox *box;
@property (strong, nonatomic) UILabel *saveAsNewBtn;
@property (strong, nonatomic) UITapGestureRecognizer *saveAsNewTap;
@property (strong, nonatomic) UILabel *updateBtn;
@property (strong, nonatomic) UITapGestureRecognizer *updateTap;
@property (strong, nonatomic) UITapGestureRecognizer *cancelTap;

@end

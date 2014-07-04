//
//  TVActivationViewController.h
//  testView
//
//  Created by Liwei Zhang on 2014-06-25.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVLayerBaseViewController.h"

@interface TVActivationViewController : TVLayerBaseViewController

@property (nonatomic, strong) UILabel *connectIntro;
@property (nonatomic, strong) UILabel *connectBtn;
@property (nonatomic, strong) UITapGestureRecognizer *connectBtnTap;

@property (nonatomic, strong) UILabel *sendIntro;
@property (nonatomic, strong) UILabel *sendBtn;
@property (nonatomic, strong) UITapGestureRecognizer *sendBtnTap;

@property (nonatomic, strong) UILabel *emailDisplay;
@property (nonatomic, strong) UILabel *signOutBtn;
@property (nonatomic, strong) UITapGestureRecognizer *signOutBtnTap;

@end

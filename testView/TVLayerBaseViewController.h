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

typedef NS_ENUM(NSInteger, TVPinchAction) {
    TVPinchNoAction,
    TVPinchRoot,
    TVPinchToSave
};

@interface TVLayerBaseViewController : UIViewController

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchToShow;
@property (strong, nonatomic) TVRootViewCtlBox *box;

@property (assign, nonatomic) TVPinchAction actionNo;

@end

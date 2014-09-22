//
//  TVNonBlockIndicator.h
//  testView
//
//  Created by Liwei Zhang on 2014-09-21.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVNonBlockIndicator : UIView

// This is the loading indicator that does not block user interaction since it's small and not full screen.
@property (strong, nonatomic) CABasicAnimation *goDark;
@property (strong, nonatomic) CABasicAnimation *goLight;

- (void)startAni;
- (void)stopAni;

@end

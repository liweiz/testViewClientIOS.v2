//
//  TVNonBlockIndicator.h
//  testView
//
//  Created by Liwei Zhang on 2014-09-21.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>

@interface TVNonBlockIndicator : UIView

// This is the loading indicator that does not block user interaction since it's small and not full screen.
@property (strong, nonatomic) POPBasicAnimation *goDark;
@property (strong, nonatomic) POPBasicAnimation *goLight;
// This is used to identify if the view's animation is on.
@property (assign, nonatomic) BOOL isActive;
@property (assign, nonatomic) CGFloat aniDuration;

- (void)startAni;
- (void)stopAni;

@end

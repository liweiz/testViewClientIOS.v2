//
//  TVSignUpListener.h
//  testView
//
//  Created by Liwei on 2014-06-10.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVDataListener.h"

@interface TVSignUpListener : TVDataListener

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

@end

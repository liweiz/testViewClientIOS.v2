//
//  TVExpandedCard.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-20.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TVExpandedCard : NSObject

@property (strong, nonatomic) NSMutableString *target;
@property (strong, nonatomic) NSMutableString *translation;
@property (strong, nonatomic) NSMutableString *detail;
@property (strong, nonatomic) NSMutableString *context;
@property (strong, nonatomic) NSMutableString *serverId;
@property (strong, nonatomic) NSMutableString *localId;
@property (assign, nonatomic) NSInteger versionNo;
@property (strong, nonatomic) NSDate *lastModifiedAtLocal;
@property (assign, nonatomic) NSInteger rowNo;

// This only contains the most up-to-date blanks. And it is reevaluated every time tableDataSource changes(in other words, take a new snapShot). So the blank obj may be removed from blanks here but still exists in that snapShot. In other cases, an added blank obj may not exist in previous snapShot.
@property (strong, nonatomic) NSMutableArray *blanks;
// This is also an indicator for the most up-to-date snapShot.
@property (assign, nonatomic) NSInteger numberOfRowsNeeded;
@property (strong, nonatomic) UIScrollView *baseView;
@property (strong, nonatomic) UITapGestureRecognizer *tapToHide;
@property (strong, nonatomic) UILabel *labelTranslation;
@property (strong, nonatomic) UILabel *labelDetail;
@property (strong, nonatomic) UILabel *labelContext;
@property (assign, nonatomic) CGFloat originY;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat gap;
@property (assign, nonatomic) CGFloat cellHeight;


- (void)setup;
- (void)show:(BOOL)isAnimated;

@end

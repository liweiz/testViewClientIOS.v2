//
//  TVSortBox.h
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVSortBox : NSObject

@property (strong, nonatomic) NSString *keyToSort;

@property (strong, nonatomic) NSSortDescriptor *byCellTitleAlphabetA;
@property (strong, nonatomic) NSSortDescriptor *byTimeCollectedA;
@property (strong, nonatomic) NSSortDescriptor *byTimeCreatedA;
@property (strong, nonatomic) NSSortDescriptor *byCreatorA;
@property (strong, nonatomic) NSSortDescriptor *byCellTitleAlphabetD;
@property (strong, nonatomic) NSSortDescriptor *byTimeCollectedD;
@property (strong, nonatomic) NSSortDescriptor *byTimeCreatedD;
@property (strong, nonatomic) NSSortDescriptor *byCreatorD;

@property (strong, nonatomic) NSArray *cardSortDescriptorsAlphabetAFirst;
@property (strong, nonatomic) NSArray *cardSortDescriptorsTimeCollectedDFirst;


@end

//
//  TVSortBox.m
//  testView
//
//  Created by Liwei on 2014-05-02.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVSortBox.h"

@implementation TVSortBox

@synthesize keyToSort, byCellTitleAlphabetA, byCreatorA, byTimeCollectedA, byTimeCreatedA, byCellTitleAlphabetD, byCreatorD, byTimeCollectedD, byTimeCreatedD, cardSortDescriptorsAlphabetAFirst, cardSortDescriptorsTimeCollectedDFirst;

- (id)init
{
    // Config sort setting
    self.byCreatorA = [NSSortDescriptor sortDescriptorWithKey:@"createdBy" ascending:YES comparator:^(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCompare:obj2];
    }];
    
    self.byTimeCollectedD = [[NSSortDescriptor alloc] initWithKey:@"collectedAt" ascending:NO];
    
    self.byCellTitleAlphabetA = [NSSortDescriptor sortDescriptorWithKey:self.keyToSort ascending:YES comparator:^(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCompare:obj2];
    }];
    
    self.byTimeCreatedD = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    
    self.byCreatorD = [NSSortDescriptor sortDescriptorWithKey:@"createdBy" ascending:NO comparator:^(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCompare:obj2];
    }];
    
    self.byTimeCollectedA = [[NSSortDescriptor alloc] initWithKey:@"collectedAt" ascending:YES];
    
    self.byCellTitleAlphabetD = [NSSortDescriptor sortDescriptorWithKey:self.keyToSort ascending:NO comparator:^(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCompare:obj2];
    }];
    
    self.byTimeCreatedA = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    
    self.cardSortDescriptorsTimeCollectedDFirst = @[self.byTimeCollectedD, self.byCellTitleAlphabetA];
    
    self.cardSortDescriptorsAlphabetAFirst = @[self.byCellTitleAlphabetA, self.byTimeCollectedD];
    
    return self;
}

@end

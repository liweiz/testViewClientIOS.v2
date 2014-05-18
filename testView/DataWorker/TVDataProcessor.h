//
//  TVDataContext.h
//  testView
//
//  Created by Liwei on 2014-05-14.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVRequester.h"

@interface TVDataContext : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *parentFetchedResultsController;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) TVRequester *requester;
@property (strong, nonatomic) NSOperationQueue *backgroundWorker;

@property (strong, nonatomic) NSSet *updated;
@property (strong, nonatomic) NSSet *inserted;
@property (strong, nonatomic) NSSet *deleted;

- (NSMutableDictionary *)analyzeOneUndone:(TVBase *)b inCtx:(NSManagedObjectContext *)ctx;

@end

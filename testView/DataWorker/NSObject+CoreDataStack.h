//
//  NSObject+CoreDataStack.h
//  testView
//
//  Created by Liwei Zhang on 2014-08-26.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CoreDataStack)

- (NSManagedObjectContext *)managedObjectContext:(NSManagedObjectContext *)ctx coordinator:(NSPersistentStoreCoordinator *)coordinator model:(NSManagedObjectModel *)model;
- (NSManagedObjectModel *)managedObjectModel:(NSManagedObjectModel *)model;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator model:(NSManagedObjectModel *)model;
- (NSURL *)applicationDocumentsDirectory;

@end

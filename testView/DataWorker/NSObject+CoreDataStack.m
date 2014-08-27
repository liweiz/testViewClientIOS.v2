//
//  NSObject+CoreDataStack.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-26.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "NSObject+CoreDataStack.h"

@implementation NSObject (CoreDataStack)

#pragma mark - Core Data stack

/*
 managedObjectContext structure in our app:
 1. system settings, such as user, deviceInfo, pass the one from appDelegate
 2. cards, CRUD, use a customized one-time only context, and drop it once the task is done. So we pass NSPersistentStoreCoordinator to
 */

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext:(NSManagedObjectContext *)ctx coordinator:(NSPersistentStoreCoordinator *)coordinator model:(NSManagedObjectModel *)model
{
    if (ctx != nil) {
        return ctx;
    }
    
    NSPersistentStoreCoordinator *coordinator0 = [self persistentStoreCoordinator:coordinator model:model];
    if (coordinator0 != nil) {
        ctx = [[NSManagedObjectContext alloc] init];
        [ctx setPersistentStoreCoordinator:coordinator0];
    }
    return ctx;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel:(NSManagedObjectModel *)model
{
    if (model != nil) {
        return model;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"testView" withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return model;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator model:(NSManagedObjectModel *)model
{
    if (coordinator != nil) {
        return coordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"testView.sqlite"];
    
    NSError *error = nil;
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel:model]];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return coordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

//
//  TVAppDelegate.m
//  testView
//
//  Created by Liwei on 2013-07-22.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVAppDelegate.h"
#import "TVAppRootViewController.h"
//#import <Crashlytics/Crashlytics.h>
#import "TVTestViewController.h"
#import "NSObject+CoreDataStack.h"

@implementation TVAppDelegate

@synthesize ctx;
@synthesize model;
@synthesize coordinator;
@synthesize appRect;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect aRect = [[UIScreen mainScreen] applicationFrame];
    // [[UIScreen mainScreen] applicationFrame].origin.y is 20 and it will be updated by system to 0 later. So we assign it manually first here.
    self.appRect = CGRectMake(aRect.origin.x, 0.0f, aRect.size.width, aRect.size.height);
    self.window = [[UIWindow alloc] initWithFrame:aRect];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    // set TVRootViewController as rootViewController
    TVAppRootViewController *tempViewController = [[TVAppRootViewController alloc] initWithNibName:nil bundle:nil];
    tempViewController.appRect = self.appRect;
    self.window.rootViewController = tempViewController;
//    [Crashlytics startWithAPIKey:@"d30dc014389e0e949766f2cd80d7559c4af53569"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

//- (void)saveContext
//{
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.ctx;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//             // Replace this implementation with code to handle the error appropriately.
//             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        } 
//    }
//}

@end

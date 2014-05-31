//
//  TVRequesterTestCase.m
//  testView
//
//  Created by Liwei on 2014-05-25.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TVRequester.h"
#import "NSObject+DataHandler.h"
#import "NSObject+NetworkHandler.h"

@interface TVRequesterTestCase : XCTestCase

@end

@implementation TVRequesterTestCase {
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectContext *managedObjectContext;
    
    NSArray *reqTypeArray;
    TVRequester *reqster;
    
    NSString *email;
    NSString *password;
    NSMutableDictionary *card1;
    NSMutableDictionary *card2;
    NSMutableDictionary *card3;
    NSMutableDictionary *card4;
    NSMutableDictionary *card5;
    NSMutableDictionary *card6;
    NSMutableDictionary *card7;
    
    NSString *context;
    NSString *target;
    NSString *translation;
    NSString *detail1;
    NSString *detail2;
    NSString *detail3;
    NSString *detail4;
    NSString *detail5;
    NSString *detail6;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"testView" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    //    TVSignUp,
    //    TVSignIn,
    //    TVForgotPassword,
    //    TVRenewTokens,
    //    TVNewDeviceInfo,
    //    TVOneDeviceInfo,
    //    TVEmailForActivation,
    //    TVEmailForPasswordResetting,
    //    TVSync,
    //    TVNewCard,
    //    TVOneCard
    reqTypeArray = @[[NSNumber numberWithInteger:TVSignUp],
                              [NSNumber numberWithInteger:TVSignIn],
                              [NSNumber numberWithInteger:TVForgotPassword],
                              [NSNumber numberWithInteger:TVRenewTokens],
                              [NSNumber numberWithInteger:TVNewDeviceInfo],
                              [NSNumber numberWithInteger:TVOneDeviceInfo],
                              [NSNumber numberWithInteger:TVEmailForActivation],
                              [NSNumber numberWithInteger:TVEmailForPasswordResetting],
                              [NSNumber numberWithInteger:TVSync],
                              [NSNumber numberWithInteger:TVNewCard],
                              [NSNumber numberWithInteger:TVOneCard]];
    reqster = [[TVRequester alloc] init];
    reqster.ctx = managedObjectContext;
    
    email = @"matt.z.lw@gmail.com";
    password = @"1a2b!!";
    
    context = @"As designers, we must not forget that we design for the people. We must gain empathy and ride on the arc of modern design.";
    target = @"empathy";
    translation = @"感同身受";
    detail1 = @"直译为“移情作用”，在中文中不易理解。";
    detail2 = @"直译为“移情作用”。wiki中有详解，却不易理解。";
    detail3 = @"直译为“移情作用”。";
    detail4 = @"a直译为“移情作用”，在中文中不易理解。";
    detail5 = @"a直译为“移情作用”。wiki中有详解，却不易理解。";
    detail6 = @"a直译为“移情作用”。";
    
    NSLog(@"1");
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testProceedToRequest
{
    for (NSNumber *x in reqTypeArray) {
        reqster.requestType = x.integerValue;
        [reqster proceedToRequest];
    }
}

- (void)testSignUp
{
    
    reqster.requestType = [reqTypeArray[0] integerValue];
    reqster.body = [self getJSONSignUpOrInWithEmail:email password:password err:nil];
    reqster.method = @"POST";
    reqster.contentType = @"application/json";
    reqster.authNeeded = NO;
    [reqster proceedToRequest];
    
}

@end

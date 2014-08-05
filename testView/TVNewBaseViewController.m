//
//  TVNewBaseViewController.m
//  testView
//
//  Created by Liwei Zhang on 2014-08-04.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVNewBaseViewController.h"
#import "TVNewViewController.h"
#import "UIViewController+InOutTransition.h"
#import "TVAppRootViewController.h"
#import "NSObject+DataHandler.h"

@interface TVNewBaseViewController ()

@end

@implementation TVNewBaseViewController

@synthesize managedObjectContext;
@synthesize managedObjectModel;

@synthesize myNewViewCtl;
@synthesize box;
@synthesize createNewOnly;
@synthesize saveViewCtl;
@synthesize cardToUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSaveView) name:tvPinchToShowSave object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSaveView) name:tvDismissSaveViewOnly object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAsNew) name:tvSaveAsNew object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAsUpdate) name:tvSaveAsUpdate object:nil];
        self.createNewOnly = YES;
    }
    return self;
}

- (void)loadView
{
    CGRect viewRect = CGRectMake(self.box.appRect.size.width * 0.0f, 0.0f, self.box.appRect.size.width, self.box.appRect.size.height);
    self.view = [[UIView alloc] initWithFrame:viewRect];
    self.view.backgroundColor = [UIColor purpleColor];
    self.view.clipsToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myNewViewCtl = [[TVNewViewController alloc] initWithNibName:nil bundle:nil];

    self.myNewViewCtl.managedObjectContext = self.managedObjectContext;
    self.myNewViewCtl.managedObjectModel = self.managedObjectModel;
    self.myNewViewCtl.box = self.box;
    [self addChildViewController:self.myNewViewCtl];
    [self.view addSubview:self.myNewViewCtl.view];
    [self.myNewViewCtl didMoveToParentViewController:self];
}

#pragma mark - SaveView

- (void)getSaveView
{
    [self launchSaveView:self.createNewOnly];
}

- (void)launchSaveView:(BOOL)toCreateNewOnly
{
    if (!self.saveViewCtl) {
        self.saveViewCtl = [[TVSaveViewController alloc] init];
        self.saveViewCtl.box = self.box;
        [self addChildViewController:self.saveViewCtl];
        [self.saveViewCtl didMoveToParentViewController:self];
        [self.view addSubview:self.saveViewCtl.view];
    }
    self.saveViewCtl.createNewOnly = toCreateNewOnly;
    [self.saveViewCtl checkIfUpdateBtnNeeded];
    NSLog(@"x: %f", self.box.transitionPointInRoot.x);
    NSLog(@"y: %f", self.box.transitionPointInRoot.y);
    [self showViewAbove:self.saveViewCtl.view currentView:self.myNewViewCtl.view baseView:self.view pointInBaseView:self.box.transitionPointInRoot];
}

- (void)dismissSaveView
{
    [self showViewBelow:self.myNewViewCtl.view currentView:self.saveViewCtl.view baseView:self.view pointInBaseView:self.box.transitionPointInRoot];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *name = [anim valueForKey:@"animationName"];
        NSLog(@"name: %@", name);
        if (self.saveViewCtl.view.hidden == YES) {
            NSLog(@"is hidden");
        } else {
            NSLog(@"is NOT hidden");
        }
        if ([name isEqualToString:@"goThrough"]) {
            self.myNewViewCtl.view.hidden = YES;
            [self.myNewViewCtl.view.layer removeAllAnimations];
        } else if ([name isEqualToString:@"comeUp"]) {
            self.saveViewCtl.view.hidden = YES;
            [self.saveViewCtl.view.layer removeAllAnimations];
        }
    }
}

#pragma mark - check and save

- (void)saveAsNew
{
    if ([self checkIfTargetIsInContext]) {
        TVCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"TVCard" inManagedObjectContext:self.managedObjectContext];
        [self setupNewDocBaseLocal:newCard];
        [self setupNewCard:newCard withDic:[self getReadyForCard]];
        [self.managedObjectContext save:nil];
        [self dismissSaveView];
    }
}

- (void)saveAsUpdate
{
    if ([self checkIfTargetIsInContext]) {
        if (self.cardToUpdate) {
            [self updateDocBaseLocal:self.cardToUpdate];
            [self updateCard:self.cardToUpdate withDic:[self getReadyForCard]];
            [self.managedObjectContext save:nil];
        } else {
            [self saveAsNew];
        }
        [self dismissSaveView];
    }
}

- (NSMutableDictionary *)getReadyForCard
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setObject:self.myNewViewCtl.myContextView.text forKey:@"context"];
    [d setObject:self.myNewViewCtl.myTargetView.text forKey:@"target"];
    [d setObject:self.myNewViewCtl.myTranslationView.text forKey:@"translation"];
    [d setObject:self.myNewViewCtl.myDetailView.text forKey:@"detail"];
    [d setObject:self.box.user.serverId forKey:@"belongTo"];
    [d setObject:self.box.user.sourceLang forKey:@"sourceLang"];
    [d setObject:self.box.user.targetLang forKey:@"targetLang"];
    return d;
}

- (BOOL)checkIfTargetIsInContext
{
    // Add target language locale
    NSRange range = [self.myNewViewCtl.myContextView.text rangeOfString:self.myNewViewCtl.myTargetView.text options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.myNewViewCtl.myContextView.text.length) locale:nil];
    // Returns {NSNotFound, 0} if aString is not found or is empty (@"").
    if (range.location == NSNotFound) {
        // Send system alert
        return NO;
    }
    return  YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

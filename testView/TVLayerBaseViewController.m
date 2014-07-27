//
//  TVLayerBaseViewController.m
//  testView
//
//  Created by Liwei Zhang on 2014-07-01.
//  Copyright (c) 2014 Liwei. All rights reserved.
//

#import "TVLayerBaseViewController.h"
#import "TVAppRootViewController.h"
#import "UIViewController+InOutTransition.h"

@interface TVLayerBaseViewController ()

@end

@implementation TVLayerBaseViewController

@synthesize appRect;
@synthesize indicator;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize pinchToShow;
@synthesize box;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.pinchToShow = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:self.pinchToShow];
}

- (void)pinchAction
{
    // Avoid pinchGesture triggered multiple times by limiting its action only when gesture just begins to be recognized.
    if (self.pinchToShow.state == UIGestureRecognizerStateBegan) {
        self.box.transitionPointInRoot = [self pointBy:self.pinchToShow inView:[[UIApplication sharedApplication] keyWindow].rootViewController.view];
        [[NSNotificationCenter defaultCenter] postNotificationName:tvPinchToShowAbove object:self];
    }
    
}

- (void)didReceiveMemoryWarning
{
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

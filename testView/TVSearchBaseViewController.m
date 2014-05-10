//
//  TVSearchViewController.m
//  testView
//
//  Created by Liwei on 2013-07-23.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVSearchBaseViewController.h"

@interface TVSearchBaseViewController ()

@end

@implementation TVSearchBaseViewController

@synthesize tempSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    CGRect firstRect = [[UIScreen mainScreen] applicationFrame];
    self.tempSize = firstRect.size;
    CGRect viewRect = CGRectMake(tempSize.width * 2, 0, tempSize.width, tempSize.height);
    
    self.view = [[UIView alloc] initWithFrame:viewRect];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.clipsToBounds = YES;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITableView *tView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tempSize.width, tempSize.height) style:UITableViewStylePlain];
    tView.dataSource = self;
    tView.delegate = self;
    tView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tView];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    // This part is not effected by wether dataSouce is array
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *array = [NSArray arrayWithObjects:@"hhh", @"sss", nil];
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIScrollView *rootScrollView = (UIScrollView *)[[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:555];
    rootScrollView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TVLangPickTableViewController.m
//  testView
//
//  Created by Liwei on 10/23/2013.
//  Copyright (c) 2013 Liwei. All rights reserved.
//

#import "TVLangPickTableViewController.h"
#import "UIViewController+sharedMethods.h"

@interface TVLangPickTableViewController ()

@end

@implementation TVLangPickTableViewController

@synthesize langArray;
@synthesize originY1;
@synthesize originY2;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)loadView
{
    CGRect firstRect = [[UIScreen mainScreen] applicationFrame];
    CGRect viewRect = CGRectMake(0.0f, self.originY1, firstRect.size.width, self.originY2 - self.originY1);
    self.langArray = [self loadLangArray];
    self.tableView = [[UITableView alloc] initWithFrame:viewRect style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load file from supporting files
- (NSArray *)loadLangArray
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"langListLong" ofType:@"txt"];
    if (filePath) {
        NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:nil];
        NSArray *stringArray = [contents componentsSeparatedByString:@"\r\n"];
        for (NSString *obj in stringArray) {
            if (![obj isEqualToString:@""]) {
                NSString *newObj = [NSString localizedNameOfStringEncoding:NSUnicodeStringEncoding];
                newObj = obj;
                [tempArray addObject:newObj];
            }
        }
    }
    return tempArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.langArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.langArray objectAtIndex:indexPath.row];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

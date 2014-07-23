//
//  YGSearchDisplayHelper.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 22/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGSearchDisplayHelper.h"
#import "YGLocallyViewController.h"
#import "YGAppDelegate.h"

@interface YGSearchDisplayHelper ()

@end

@implementation YGSearchDisplayHelper
@synthesize shoppingController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self->appSettings = ((YGAppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
		self.history = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (YGSearchDisplayHelper *)initWithShoppingController:(YGLocallyViewController *)shoppingController {
	YGSearchDisplayHelper *selfInstance = [[YGSearchDisplayHelper alloc] initWithStyle:UITableViewStylePlain];
	selfInstance.shoppingController = shoppingController;
	return selfInstance;
}

- (void)viewDidLoad {
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

#pragma mark - SearchDisplayController delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	if(searchString && ![searchString isEqual:[NSNull null]]) {
		[self.history removeAllObjects];
		for (NSDictionary *historyDict in self->appSettings.searchHistory) {
			NSString *regEx = [NSString stringWithFormat:@".*%@.*", [searchString lowercaseString]];
			NSRange range = [[[historyDict objectForKey:@"searchString"] lowercaseString] rangeOfString:regEx options:NSRegularExpressionSearch];
			if (range.location != NSNotFound) {
				[self.history addObject:[historyDict objectForKey:@"searchString"]];
			} else {
				regEx = [NSString stringWithFormat:@".*%@.*", [[historyDict objectForKey:@"searchString"] lowercaseString]];
				range = [[searchString lowercaseString] rangeOfString:regEx options:NSRegularExpressionSearch];
				if (range.location != NSNotFound) {
					[self.history addObject:[historyDict objectForKey:@"searchString"]];
				}
			}
		}
	}
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.history.count < 11? self.history.count : 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	cell.textLabel.text = [self.history objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[((YGLocallyViewController *)self.shoppingController) startSearching:cell.textLabel.text];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

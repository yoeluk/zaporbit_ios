//
//  YGMerchantSettingsViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 02/06/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGMerchantSettingsViewController.h"
#import "GCPlaceholderTextView.h"
#import "YGAppDelegate.h"

static NSString *kApiUrl = @"https://zaporbit.com/api/";

@interface YGMerchantSettingsViewController ()

@end

@implementation YGMerchantSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self->userInfo = [YGUserInfo sharedInstance];
	self->appSettings = ((YGAppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat height = section == 0 ? 0 : 35;
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height;
	switch (indexPath.section) {
		case 0:
			height = 84;
			break;
		case 1:
			height = 64;
			break;
		default:
			height = 64;
			break;
	}
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 2 : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *sellerCellIdentifier = @"sellerCell";
	static NSString *secrectCellIdentifier = @"secretCell";
	static NSString *cellIdentifier = @"Cell";
	
	UITableViewCell *cell;
	
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				cell = [tableView dequeueReusableCellWithIdentifier:sellerCellIdentifier forIndexPath:indexPath];
				GCPlaceholderTextView *sellerIdentifierTextView = (GCPlaceholderTextView *)[cell.contentView viewWithTag:10];
				sellerIdentifierTextView.text = appSettings.sellerIdentifier ? appSettings.sellerIdentifier : @"";
				sellerIdentifierTextView.placeholder = @"Google wallet seller identifier";
				//[sellerIdentifierTextView setTextColor:[UIColor blackColor]];
				UIToolbar *titleToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
				UIBarButtonItem *flexTitleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
				UIBarButtonItem *doneTitleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyBoard:)];
				[titleToolBar setItems:@[flexTitleBtn, doneTitleBtn] animated:NO];
				sellerIdentifierTextView.inputAccessoryView = titleToolBar;
			} else if (indexPath.row == 1) {
				cell = [tableView dequeueReusableCellWithIdentifier:secrectCellIdentifier forIndexPath:indexPath];
				GCPlaceholderTextView *sellerSecretTextView = (GCPlaceholderTextView *)[cell.contentView viewWithTag:20];
				sellerSecretTextView.text = appSettings.sellerSecret ? appSettings.sellerSecret : @"";
				sellerSecretTextView.placeholder = @"Google wallet seller secret";
				//[sellerSecretTextView setTextColor:[UIColor blackColor]];
				UIToolbar *titleToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
				UIBarButtonItem *flexTitleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
				UIBarButtonItem *doneTitleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyBoard:)];
				[titleToolBar setItems:@[flexTitleBtn, doneTitleBtn] animated:NO];
				sellerSecretTextView.inputAccessoryView = titleToolBar;
			} else {
				cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
			}
			break;
		case 1:
			if (indexPath.row == 0) {
				cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
				if (self->userInfo.user) {
					UILabel *postbackURL = (UILabel *)[cell.contentView viewWithTag:30];
					postbackURL.text = [NSString stringWithFormat:@"https://zaporbit.com/merchant/%ld", (long)self->userInfo.user.id];
				}
			}
			break;
			
		default:
			break;
	}
    
    return cell;
}

- (void)textViewDidChange:(UITextView *)textView {
	if (textView.tag == 10)
		appSettings.sellerIdentifier = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	else if (textView.tag == 20)
		appSettings.sellerSecret = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)dismissKeyBoard:(id)sender {
	[self.view endEditing:YES];
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

- (IBAction)setUpGoogleWalletMerchant:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://checkout.google.com/inapp/merchant/settings.html"]];
}

- (IBAction)submitMerchantInfo:(id)sender {
	
	NSString *urlString = @"addmerchant";
	
	NSMutableDictionary *merchantData = [[NSMutableDictionary alloc] initWithCapacity:3];
	merchantData[@"identifier"] = appSettings.sellerIdentifier;
	merchantData[@"secret"] = appSettings.sellerSecret;
    merchantData[@"userid"] = @(userInfo.user.id);
	YGWebService *ws = [YGWebService initWithDelegate:self];
	[ws addMerchantDataForUser:merchantData withService:urlString andMethod:@"POST"];
}

-(void)coughRequestedData:(NSData *)data {
	NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if ([dataObj[@"status"] isEqualToString:@"OK"]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}


@end

//
//  YGHomeViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 21/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGHomeViewController.h"
#import "YGInboxViewController.h"

@interface YGHomeViewController ()

@end

@implementation YGHomeViewController
@synthesize records = _records;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		//
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	userInfo = [YGUserInfo sharedInstance];
	self->appSetting = [(YGAppDelegate *)[[UIApplication sharedApplication] delegate] appSettings];
	self.fbLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]];
	self.fbLoginView.frame = CGRectMake(14, 5, 291, 44);
	self.fbLoginView.delegate = self;
	self.fbLoginView.tag = 15;
	
	_profilePictureView = [[FBProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
	[_ovalPicView addSubview:_profilePictureView];
	
	CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.tableViewHeaderView.layer addSublayer:topBorder];
	
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	self.records = [[NSMutableDictionary alloc] init];
	
	self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -2, self.tableView.frame.size.width, 2)];
	self.progressView.tag = 15;
	self.progressView.hidden = YES;
	self.progressView.progress = 0.0f;
	
	[self.tableView addSubview:self.progressView];
	
	CGRect rect = CGRectZero;
	
	self.statusLabel.hidden = YES;
	rect = CGRectMake(105, 39, 150, 50);
	self->ratingView = [[YGRatingView alloc] initWithFrame:rect];
	self->ratingView.tag = 50;
	[self.statusLabel.superview addSubview:self->ratingView];
	self.nameLabel.text = @"You're logged out";
	
	self->kUrlHead = [YGWebService baseApiUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)didDisconnectWithError:(NSError *)error {
	if (error) {
		NSLog(@"Received error %@", error);
	} else {
		// The user is signed out and disconnected.
		// Clean up user data as specified by the Google+ terms.
	}
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
	YGUser *zapUser = [[YGUser alloc] init];
	zapUser.email = user[@"email"];
	zapUser.name = user.first_name;
	zapUser.surname = user.last_name;
	zapUser.fbuserid = user.id;
	
	if (FBSession.activeSession.isOpen && (!zapUser.email || !zapUser.name || !zapUser.surname || !zapUser.fbuserid || [zapUser.email isEqualToString:@""])) {
        [FBSession.activeSession closeAndClearTokenInformation];
    } else {
		zapUser.middle_name = user.middle_name;
		zapUser.link = user.link;
		self.profilePictureView.profileID = user.id;
		self.nameLabel.text = user.name;
		for (UIImageView *subview in self.profilePictureView.subviews) {
			if ([[[subview class] description] isEqualToString:@"UIImageView"]) {
				zapUser.profilePicView = subview;
			}
		}
		[userInfo setUser:zapUser];
		[self verifyFbLogin:nil];
	}
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
	[self.loginButton setTitle:@"Log out"];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
	[userInfo setIsLoggedIn:NO];
	self.profilePictureView.profileID = nil;
	self.nameLabel.text = @"You're logged out";
	[self->ratingView setRating:1 animated:YES];
	[self->ratingView setRatingText:@"~ Level ~"];
	[userInfo setUser:nil];
	[self.loginButton setTitle:@"Log in"];
}

-(void)verifyFbLogin:(id)sender {
	if (!userInfo.isLoggedIn && !userInfo.isProcessingLogin) {
		int expiresIn = [[[[FBSession activeSession] accessTokenData] expirationDate] timeIntervalSinceDate:[NSDate date]];
		NSDictionary *tokenData = @{
									@"email":userInfo.user.email,
									@"info": @{
										@"accessToken":[[[FBSession activeSession] accessTokenData] accessToken],
										@"expiresIn":[NSNumber numberWithInt:expiresIn]
									}};
		[userInfo setIsProcessingLogin:YES];
		YGWebService *ws = [YGWebService initWithDelegate:self];
		
		[ws verifyUser:tokenData];
	}
}

-(void)verifyingUserResponse:(NSData *)data {
	[userInfo setIsLoggedIn:YES];
	[userInfo setIsProcessingLogin:NO];
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if (response && [response[@"status"] isEqualToString:@"OK"]) {
		NSDictionary *rating = response[@"rating"];
		[self->ratingView setRating:[rating[@"rating"] floatValue] animated:YES];
		[self->ratingView setRatingText:@"Basic Level"];
		userInfo.user.id = [(NSString *) response[@"userid"] integerValue];
		[self getUsersRecords:0];
	}
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
	NSString *alertMessage, *alertTitle;
	
	// If the user should perform an action outside of you app to recover,
	// the SDK will provide a message for the user, you just need to surface it.
	// This conveniently handles cases like Facebook password change or unverified Facebook accounts.
	if ([FBErrorUtility shouldNotifyUserForError:error]) {
		alertTitle = @"Facebook error";
		alertMessage = [FBErrorUtility userMessageForError:error];
		
  // This code will handle session closures that happen outside of the app
  // You can take a look at our error handling guide to know more about it
  // https://developers.facebook.com/docs/ios/errors
	} else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
		alertTitle = @"Session Error";
		alertMessage = @"Your current session is no longer valid. Please log in again.";
		
		// If the user has cancelled a login, we will do nothing.
		// You can also choose to show the user a message if cancelling login will result in
		// the user not being able to complete a task they had initiated in your app
		// (like accessing FB-stored information or posting to Facebook)
	} else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
		NSLog(@"user cancelled login");
		
		// For simplicity, this sample handles other errors with a generic message
		// You can checkout our error handling guide for more detailed information
		// https://developers.facebook.com/docs/ios/errors
	} else {
		alertTitle  = @"Something went wrong";
		alertMessage = @"Please try again later.";
		NSLog(@"Unexpected error:%@", error);
	}
	
	if (alertMessage) {
		[[[UIAlertView alloc] initWithTitle:alertTitle
									message:alertMessage
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}


-(void)getUsersRecords:(int)page {
	[self.progressView setHidden:NO];
	[self.progressView setProgress:0.4 animated:YES];
	NSURL *recordsURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@getrecords/%d", kUrlHead, page]];
	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSString *token = [YGWebService tokenData][@"token"];
	sessionConfig.HTTPAdditionalHeaders = @{@"X-Auth-Token": token};
	NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:sessionConfig] dataTaskWithURL:recordsURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (data) {
			NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
			if (dataObj && [dataObj[@"status"] isEqualToString:@"OK"]) {
				if (dataObj[@"buying_records"]) {
					id buying_records = dataObj[@"buying_records"];
					(self.records)[@"buyingRecords"] = [self recordsWithArray:buying_records];
				}
				if (dataObj[@"selling_records"]) {
					id selling_records = dataObj[@"selling_records"];
					(self.records)[@"sellingRecords"] = [self recordsWithArray:selling_records];
				}
				if (dataObj[@"billing_records"]) {
#warning gotta come back here and sort out billing_records
//					id billing_records = dataObj[@"billing_records"];
//					(self.records)[@"billingRecords"] = [self recordsWithArray:billing_records];
				}
				if (dataObj[@"messages_records"]) {
                    (self.records)[@"inboxRecords"] = dataObj[@"messages_records"];
				}
				self->appSetting.dataRetrievalDate = [NSDate date];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.progressView setProgress:1.0f animated:YES];
				[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(refreshUI:) userInfo:nil repeats:NO];
			});
		} else NSLog(@"no data");
	}];
	[session resume];
}

-(void)refreshUI:(id)sender {
	[self.progressView setHidden:YES];
	self.progressView.progress = 0.0f;
}

-(NSMutableDictionary *)recordsWithArray:(NSMutableArray *)recordsArray {
	
	NSMutableArray *pendingRecords = [[NSMutableArray alloc] init];
	NSMutableArray *processingRecords = [[NSMutableArray alloc] init];
	NSMutableArray *completedRecords = [[NSMutableArray alloc] init];
	NSMutableArray *failedRecords = [[NSMutableArray alloc] init];
	
	for (NSMutableDictionary *record in recordsArray) {
		if ([record[@"status"] isEqualToString:@"pending"])
			[pendingRecords addObject:record];
		else if ([record[@"status"] isEqualToString:@"accepted"])
			[processingRecords addObject:record];
		else if ([record[@"status"] isEqualToString:@"completed"])
			[completedRecords addObject:record];
		else if ([record[@"status"] isEqualToString:@"failed"])
			[failedRecords addObject:record];
	}
	
	return [@{@"pendingRecords" : pendingRecords,
            @"processingRecords" : processingRecords,
            @"completedRecords" : completedRecords,
            @"failedRecords" : failedRecords} mutableCopy];
}

-(void)coughRequestedData:(NSData *)data {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if (response && [response[@"status"] isEqualToString:@"OK"]) {
		userInfo.user.id = [(NSString *) response[@"userid"] integerValue];
	}
}

#pragma mark - Scrollview related methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (-scrollView.contentOffset.y > 125) {
		[self getUsersRecords:0];
	}
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat height = section == 0 || section == 2 ? 0 : section == 4 ? 44 : 35;
	return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, 35);
	if (section == 4) frame.size.height = 44;
	UIView *view = [[UIView alloc] initWithFrame:frame];
	[view setBackgroundColor:[UIColor colorWithRed:230/255.f green:229/255.f blue:233/255.f alpha:1]];
	CALayer *bottom = [CALayer layer];
	bottom.frame = CGRectMake(0, frame.size.height-0.5f, tableView.frame.size.width, 0.5f);
	bottom.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
	if (section != 4) [view.layer addSublayer:bottom];
	CALayer *topBorder = [CALayer layer];
	topBorder.frame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f);
	topBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
	[view.layer addSublayer:topBorder];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, view.frame.size.height-18, 300, 10)];
	NSString *titleTex = section == 1 ? @"" : section == 3 ? @"" : @"LOGIN WITH FACEBOOK";
	[titleLabel setText:titleTex];
	[titleLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
	[titleLabel setTextColor:[UIColor lightGrayColor]];
	[view addSubview:titleLabel];
	return section == 0 || section == 2 ? nil : view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = indexPath.section == 0 && indexPath.row == 0 ? 2 : indexPath.section == 4 ? 70 : 44;
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section == 0 ? 2 : section == 1 ? 0 : section == 2 ? 4 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIndentifier = @"Cell";
	static NSString *fbCellIndentifier = @"fbCell";
	
    UITableViewCell *cell;
	
	switch (indexPath.section) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];
			if (indexPath.row == 0) {
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.textLabel.text = @"";
				cell.detailTextLabel.text = @"";
			} else if (indexPath.row == 1) {
				cell.textLabel.text = @"Log in options";
				cell.detailTextLabel.text = @"";
				cell.textLabel.font = [UIFont systemFontOfSize:15];
				cell.textLabel.textColor = [UIColor grayColor];
				UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: 10];
				imageView.image = [[UIImage imageNamed:@"899-key"] imageWithTintColor:[UIColor colorWithRed:0 green:100/255.f blue:1 alpha:1]];
			}
			break;
			
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Messages";
				UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: 10];
				imageView.image = [[UIImage imageNamed:@"749-inbox"] imageWithTintColor:[UIColor colorWithRed:0 green:100/255.f blue:1 alpha:1]];
			} else if (indexPath.row == 1) {
				cell.textLabel.text = @"Purchases";
				UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: 10];
				imageView.image = [[UIImage imageNamed:@"710-folder"] imageWithTintColor:[UIColor colorWithRed:0 green:100/255.f blue:1 alpha:1]];
			} else if (indexPath.row == 2) {
				cell.textLabel.text = @"Sales";
				UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: 10];
				imageView.image = [[UIImage imageNamed:@"710-folder"] imageWithTintColor:[UIColor colorWithRed:0 green:100/255.f blue:1 alpha:1]];
			} else if (indexPath.row == 3) {
				cell.textLabel.text = @"Billing";
				if ([cell.contentView viewWithTag: 15]) {
					[[cell.contentView viewWithTag: 15] removeFromSuperview];
				}
				UIImageView *billingView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 8, 22, 25)];
				billingView.tag = 15;
				[billingView setContentMode:UIViewContentModeScaleAspectFit];
				billingView.image = [[UIImage imageNamed:@"808-documents"] imageWithTintColor:[UIColor orangeColor]];
				
				[cell.contentView addSubview:billingView];
			} else if (indexPath.row == 4) {
				cell.textLabel.text = @"Trash";
				cell.detailTextLabel.text = @"0";
				UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: 10];
				imageView.image = [UIImage imageNamed:@"ios7_bin"];
			}
			break;
			
		case 3:
			cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Following";
				cell.detailTextLabel.text = @"";
				UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: 10];
				imageView.image = [[UIImage imageNamed:@"779-users"] imageWithTintColor:[UIColor colorWithRed:0 green:100/255.f blue:1 alpha:1]];
			}
			break;
			
		case 4:
			cell = [tableView dequeueReusableCellWithIdentifier:fbCellIndentifier forIndexPath:indexPath];
			if (indexPath.row == 0) {
				[cell setBackgroundColor:[UIColor clearColor]];
				cell.separatorInset = UIEdgeInsetsMake(0, 320, 0, 0);
				if (![cell.contentView viewWithTag:15]) {
					[cell.contentView addSubview:self.fbLoginView];
				}
			}
			break;
			
		default:
			break;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 1) {
				[self performSegueWithIdentifier:@"loginOptionsSegue" sender:indexPath];
			}
			break;
			
		case 2:
			if (indexPath.row == 0) {
				[self performSegueWithIdentifier:@"inboxSegue" sender:indexPath];
			} else if (indexPath.row == 1) {
				[self performSegueWithIdentifier:@"buyingSegue" sender:indexPath];
			} else if (indexPath.row == 2) {
				[self performSegueWithIdentifier:@"sellingSegue" sender:indexPath];
			} else if (indexPath.row == 3) {
				[self performSegueWithIdentifier:@"billingSegue" sender:indexPath];
			}
			break;
			
		case 3:
			if (indexPath.row == 0) {
				[self performSegueWithIdentifier:@"friendsSegue" sender:indexPath];
			}
			break;
			
		default:
			break;
	}
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"buyingSegue"]) {
        [[segue destinationViewController] setRecords:(self.records)[@"buyingRecords"]];
	} else if ([segue.identifier isEqualToString:@"sellingSegue"]) {
        [[segue destinationViewController] setRecords:(self.records)[@"sellingRecords"]];
	} else if ([segue.identifier isEqualToString:@"inboxSegue"]) {
        [[segue destinationViewController] setConversations:(self.records)[@"inboxRecords"]];
	}
}

- (IBAction)loginAction:(id)sender forEvent:(UIEvent *)event {
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end

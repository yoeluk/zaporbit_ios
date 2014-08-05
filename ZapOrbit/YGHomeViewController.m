//
//  YGHomeViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 21/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGHomeViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "YGInboxViewController.h"
#import "YGUser.h"
#import "YGRatingView.h"

static NSString * const kGoogleClientId = @"252408930349-1otbutcank3df2grgcav7djt4o7c6trc.apps.googleusercontent.com";
static NSString *kUrlHead = @"https://zaporbit.com/api/";

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
	
	_profilePictureView = [[FBProfilePictureView alloc] initWithFrame:CGRectMake(-25, 15, 70, 70)];
	[_ovalPicView addSubview:_profilePictureView];
	
	CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.tableViewHeaderView.layer addSublayer:topBorder];
	
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	_signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *originalImage = [UIImage imageNamed:@"gpp_sign_in_dark_button_normal.png"];
	UIEdgeInsets insets = UIEdgeInsetsMake(10, 45, 10, 45);
	UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets];
	[_signOutButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
	CGRect rect = CGRectMake(_signInButton.frame.origin.x, _signInButton.frame.origin.y, _signInButton.frame.size.width, _signInButton.frame.size.height);
	_signOutButton.frame = rect;
	[_signOutButton setTitle:@"Sign out" forState:UIControlStateNormal];
	_signOutButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:14];
	[_signOutButton setTintColor:[UIColor whiteColor]];
	[_signOutButton addTarget:self action:@selector(googleSignOut:) forControlEvents:UIControlEventTouchUpInside];
	
	//[self.tableViewFooterView addSubview:_signOutButton];
	//[_signOutButton setHidden:YES];
	
	_signIn = [GPPSignIn sharedInstance];
	_signIn.shouldFetchGooglePlusUser = YES;
	_signIn.shouldFetchGoogleUserID = YES;
	_signIn.shouldFetchGoogleUserEmail = YES;
	_signIn.clientID = kGoogleClientId;
	//_signIn.scopes = @[kGTLAuthScopePlusLogin];
	_signIn.scopes = @[@"profile"];
	_signIn.delegate = self;
	
	//[_signIn trySilentAuthentication];
	
	self.records = [[NSMutableDictionary alloc] init];
	
	//UIImage *tabImageSelected = [UIImage imageNamed:@"750-home-selected"];
	//[self.navigationController.tabBarItem setSelectedImage:tabImageSelected];
	
	self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -2, self.tableView.frame.size.width, 2)];
	self.progressView.tag = 15;
	self.progressView.hidden = YES;
	self.progressView.progress = 0.0f;
	
	[self.tableView addSubview:self.progressView];
	
	self.statusLabel.hidden = YES;
	rect = CGRectMake(105, 39, 150, 50);
	self->ratingView = [[YGRatingView alloc] initWithFrame:rect];
	self->ratingView.tag = 50;
	[self.statusLabel.superview addSubview:self->ratingView];
	self.nameLabel.text = @"You're logged out";
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *) error {
	NSLog(@"Received error %@ and auth object %@",error, auth);
	if (error) {
		// Do some error handling here.
	} else {
		[self refreshInterfaceBasedOnSignIn];
		//NSLog(@"%@", _signIn.authentication.userEmail);
		//NSLog(@"%@", _signIn.userID);
		//NSLog(@"%@", _signIn.googlePlusUser.image.url);
		//[self getCircles];
	}
}

-(void)getCircles {
	GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
	plusService.retryEnabled = YES;
	
	[plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
	
	GTLQueryPlus *query = [GTLQueryPlus queryForPeopleListWithUserId:@"me"
														  collection:kGTLPlusCollectionVisible];
	[plusService executeQuery:query
			completionHandler:^(GTLServiceTicket *ticket,
								GTLPlusPeopleFeed *peopleFeed,
								NSError *error) {
				if (error) {
					GTMLoggerError(@"Error: %@", error);
				} else {
					// Get an array of people from GTLPlusPeopleFeed
					NSLog(@"%@", peopleFeed.items);
					for (GTLPlusPerson *person in peopleFeed.items) {
						NSLog(@"%@", person.image.url);
					}
				}
			}];
}

-(void)refreshInterfaceBasedOnSignIn {
	if ([[GPPSignIn sharedInstance] authentication]) {
		// The user is signed in.
		self.signInButton.hidden = YES;
		self.signOutButton.hidden = NO;
		
	} else {
		self.signOutButton.hidden = YES;
		self.signInButton.hidden = NO;
	}
}

- (void)googleSignOut:(id)sender {
	[[GPPSignIn sharedInstance] signOut];
	self.signOutButton.hidden = YES;
	self.signInButton.hidden = NO;
}

- (void)disconnectGoogle {
	[[GPPSignIn sharedInstance] disconnect];
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
	zapUser.fbuserid = [NSNumber numberWithLongLong:[user.id longLongValue]];
	
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
		//self.fbLoginView.hidden = YES;
		[self verifyFbLogin:nil];
	}
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
	
	//self->ratingView = [[YGRatingView alloc] initWithFrame:rect];
	//self->ratingView.tag = 50;
	//[self.statusLabel.superview addSubview:self->ratingView];
	[self.loginButton setTitle:@"Log out"];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
	[userInfo setIsLoggedIn:NO];
	self.profilePictureView.profileID = nil;
	self.nameLabel.text = @"You're logged out";
	[self->ratingView setRating:1 animated:YES];
	[self->ratingView setRatingText:@"~ Level ~"];
	//self.statusLabel.hidden = NO;
	//self.statusLabel.text= @"You're not logged in!";
	[userInfo setUser:nil];
	[self.loginButton setTitle:@"Login"];
}

-(void)verifyFbLogin:(id)sender {
	if (!userInfo.isLoggedIn && !userInfo.isProcessingLogin) {
		[userInfo setIsProcessingLogin:YES];
		NSMutableDictionary *userDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										userInfo.user.name, @"name",
										userInfo.user.surname, @"surname",
										userInfo.user.fbuserid, @"fbuserid",
										userInfo.user.email, @"email", nil];
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws verifyUser:userDictionary :@"verifyinguser" :@"POST"];
	}
}

-(void)verifyingUserResponse:(NSData *)data {
	[userInfo setIsLoggedIn:YES];
	[userInfo setIsProcessingLogin:NO];
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if (response && [[response objectForKey:@"status"] isEqualToString:@"OK"]) {
		NSDictionary *rating = [response objectForKey:@"rating"];
		[self->ratingView setRating:[[rating objectForKey:@"rating"] floatValue] animated:YES];
		[self->ratingView setRatingText:@"Basic Level"];
		userInfo.user.id = [(NSString *)[response objectForKey:@"userid"] integerValue];
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
	NSURL *buyingURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@getrecords/%ld/%d", kUrlHead, (long)userInfo.user.id, page]];
	NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:buyingURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (data) {
			NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
			if (dataObj && [[dataObj objectForKey:@"status"] isEqualToString:@"OK"]) {
				if ([dataObj objectForKey:@"buying_records"]) {
					id buying_records = [dataObj objectForKey:@"buying_records"];
					[self.records setObject:[self recordsWithArray:buying_records] forKey:@"buyingRecords"];
				}
				if ([dataObj objectForKey:@"selling_records"]) {
					id selling_records = [dataObj objectForKey:@"selling_records"];
					[self.records setObject:[self recordsWithArray:selling_records] forKey:@"sellingRecords"];
				}
				if ([dataObj objectForKey:@"billing_records"]) {
					id billing_records = [dataObj objectForKey:@"billing_records"];
					[self.records setObject:[self recordsWithArray:billing_records] forKey:@"billingRecords"];
				}
				if ([dataObj objectForKey:@"messages_records"]) {
					[self.records setObject:[dataObj objectForKey:@"messages_records"] forKey:@"inboxRecords"];
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
		if ([[record objectForKey:@"status"] isEqualToString:@"pending"])
			[pendingRecords addObject:record];
		else if ([[record objectForKey:@"status"] isEqualToString:@"accepted"])
			[processingRecords addObject:record];
		else if ([[record objectForKey:@"status"] isEqualToString:@"completed"])
			[completedRecords addObject:record];
		else if ([[record objectForKey:@"status"] isEqualToString:@"failed"])
			[failedRecords addObject:record];
	}
	
	return [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			pendingRecords, @"pendingRecords",
			processingRecords, @"processingRecords",
			completedRecords, @"completedRecords",
			failedRecords, @"failedRecords", nil];
}

-(void)coughRequestedData:(NSData *)data {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if (response && [[response objectForKey:@"status"] isEqualToString:@"OK"]) {
		userInfo.user.id = [(NSString *)[response objectForKey:@"userid"] integerValue];
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
				cell.textLabel.text = @"Login Options";
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
				cell.textLabel.text = @"Bought Items";
				UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: 10];
				imageView.image = [[UIImage imageNamed:@"710-folder"] imageWithTintColor:[UIColor colorWithRed:0 green:100/255.f blue:1 alpha:1]];
			} else if (indexPath.row == 2) {
				cell.textLabel.text = @"Sold Items";
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
		[[segue destinationViewController] setRecords:[self.records objectForKey:@"buyingRecords"]];
	} else if ([segue.identifier isEqualToString:@"sellingSegue"]) {
		[[segue destinationViewController] setRecords:[self.records objectForKey:@"sellingRecords"]];
	} else if ([segue.identifier isEqualToString:@"inboxSegue"]) {
		[[segue destinationViewController] setConversations:[self.records objectForKey:@"inboxRecords"]];
	}
}

- (IBAction)loginAction:(id)sender forEvent:(UIEvent *)event {
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
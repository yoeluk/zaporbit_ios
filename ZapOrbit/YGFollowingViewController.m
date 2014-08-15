//
//  YGFollowingViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 13/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGFollowingViewController.h"
#import "YGAppDelegate.h"

static NSString *kApiUrl = @"https://zaporbit.com/api/";

@interface YGFollowingViewController ()

@end

@implementation YGFollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self->ZOFriends = [NSMutableArray new];
	self->appSettings = ((YGAppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
	self->userInfo = [YGUserInfo sharedInstance];
	[self fetchFriends:^(NSArray *friends) {
		if (friends.count) {
			self->ZOFriends = [NSMutableArray arrayWithArray:friends];
			[self.tableView reloadData];
		} else {
			UILabel *emptyMessage = [[UILabel alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width/2)-50, (self.tableView.frame.size.height/2)-self.tableView.contentInset.top, self.tableView.frame.size.width, 30)];
			emptyMessage.text = @"None Found";
			emptyMessage.textColor = [UIColor lightGrayColor];
			emptyMessage.tag = 88;
			emptyMessage.font = [UIFont boldSystemFontOfSize:18];
			[self.tableView addSubview:emptyMessage];
		}
	}];
	
	UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	infoLabel.font = [UIFont systemFontOfSize:12];
	infoLabel.text = @"Friends Using ZapOrbit";
	infoLabel.textAlignment = NSTextAlignmentCenter;
	[infoLabel sizeToFit];
	
	self.titleBarButton.customView = infoLabel;
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchFriends:(void(^)(NSArray *fds))callback {
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id response, NSError *error) {
        NSMutableArray *friends = [NSMutableArray new];
        if (!error) {
            [friends addObjectsFromArray:[response data]];
        }
        callback(friends);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = 44;
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self->ZOFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	UILabel *friendLabel = (UILabel *)[cell.contentView viewWithTag:20];
	friendLabel.text = [(self->ZOFriends)[(NSUInteger) indexPath.row] objectForKey:@"name"];
	friendLabel.font = [UIFont boldSystemFontOfSize:16];
	 
	UISwitch *followSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
	bool following = NO;
	NSString *friendId = [(self->ZOFriends)[(NSUInteger) indexPath.row] objectForKey:@"id"];
	for (NSString *fFriendId in self->appSettings.followingFriends) {
		if ([fFriendId isEqualToString:friendId]) {
			following = YES;
			break;
		}
	}
    followSwitch.on = following;
	
	return cell;
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

- (IBAction)followFriendAction:(id)sender {
	UISwitch *sendSwitch = (UISwitch *)sender;
	CGPoint aPoint = [self.tableView convertPoint:sendSwitch.bounds.origin fromView:sendSwitch];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:aPoint];
	NSString *friendId = [(self->ZOFriends)[(NSUInteger) indexPath.row] objectForKey:@"id"];
	if (sendSwitch.isOn) {
		[self->appSettings.followingFriends addObject:friendId];
	} else {
		for (NSString *fFriendId in self->appSettings.followingFriends) {
			if ([fFriendId isEqualToString:friendId]) {
				[self->appSettings.followingFriends removeObject:fFriendId];
				break;
			}
		}
	}
}

- (IBAction)saveFollowingFriends:(id)sender {
	NSMutableArray *followTheseFriends = [NSMutableArray new];
	NSNumber *userid = @((long long) userInfo.user.id);
	for (NSString *friendId in self->appSettings.followingFriends) {
		NSDictionary *friend = @{@"userid" : userid, @"friendid" : @([friendId longLongValue])};
		[followTheseFriends addObject:friend];
	}
	
	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@followthesefriends/%llu", kApiUrl, (long long)userInfo.user.id]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:followTheseFriends options:0 error:&error];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:jsonData];
	
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:request
													    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
															if(error == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
																NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
																if ([dataObj[@"status"] isEqualToString:@"OK"]) {
																	//NSLog(@"following friends updated: %@", dataObj);
																	[self.navigationController popViewControllerAnimated:YES];
																}
															}
															
														}];
    [dataTask resume];
	
	
}

@end

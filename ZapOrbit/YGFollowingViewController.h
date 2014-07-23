//
//  YGFollowingViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 13/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppSettings.h"
#import "YGUserInfo.h"

@interface YGFollowingViewController : UIViewController {
	NSMutableArray *ZOFriends;
	AppSettings *appSettings;
	YGUserInfo *userInfo;
}

- (IBAction)followFriendAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleBarButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)saveFollowingFriends:(id)sender;

@end

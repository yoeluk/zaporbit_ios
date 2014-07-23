//
//  YGInboxViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 25/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YGUserInfo.h"
#import "AppSettings.h"
#import "YGAppDelegate.h"
#import "YGHomeViewController.h"

@interface YGInboxViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate> {
	YGUserInfo *userInfo;
	CATransition *textTransition;
	AppSettings *appSettings;
	NSTimer *updateInfoTimer;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolbarInfoView;

@property (strong, nonatomic) UIProgressView *progressView;

@end

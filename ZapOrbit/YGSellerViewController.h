//
//  YGSellerViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 10/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGWebService.h"
#import "YGUserInfo.h"
#import "YGOvalView.h"
#import "YGAppDelegate.h"

@interface YGSellerViewController : UIViewController {
	NSArray *feedbacks;
	NSDictionary *rating;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *tableViewHeader;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet YGOvalView *ovalPicView;

@property (strong, nonatomic) YGUser *user;

@end

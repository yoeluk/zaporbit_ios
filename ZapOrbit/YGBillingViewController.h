//
//  YGBillingViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 13/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGUserInfo.h"
#import "YGWebService.h"

@interface YGBillingViewController : UIViewController<WebServiceDelegate> {
	YGUserInfo *userInfo;
	NSMutableArray *paidBills;
	NSMutableArray *unpaidBills;
	UIProgressView *progressView;
	NSDateFormatter *dateFormatter;
	NSMutableArray *heights;
	NSNumberFormatter *currencyFormatter;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

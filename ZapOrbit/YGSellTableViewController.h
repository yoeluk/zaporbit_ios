//
//  YGSellTableViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 15/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGWebService.h"
#import "YGUserInfo.h"
#import "YGAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface YGSellTableViewController : UITableViewController <WebServiceDelegate, UITableViewDelegate, UIScrollViewDelegate> {
	YGUserInfo *userInfo;
	NSNumberFormatter *priceFormatter;
	BOOL waggling;
}

@property (strong, nonatomic) NSMutableArray *itemsForSale;
@property (strong, nonatomic) UIProgressView *progressView;

@end

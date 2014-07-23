//
//  YGMerchantSettingsViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 02/06/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGUserInfo.h"
#import "AppSettings.h"
#import "YGWebService.h"

@interface YGMerchantSettingsViewController : UIViewController <WebServiceDelegate> {
	YGUserInfo *userInfo;
	AppSettings *appSettings;
}
- (IBAction)setUpGoogleWalletMerchant:(id)sender;

- (IBAction)submitMerchantInfo:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

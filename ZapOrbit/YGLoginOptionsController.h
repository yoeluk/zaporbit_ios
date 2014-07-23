//
//  YGLoginOptionsController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 27/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGUserInfo.h"
#import "AppSettings.h"

@interface YGLoginOptionsController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) YGUserInfo *userInfo;
@property (strong, nonatomic) AppSettings *appSettings;

- (IBAction)logmeOut:(id)sender;
@end

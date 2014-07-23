//
//  YGSettingsViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 30/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AppSettings.h"

@class YGUserInfo;

@interface YGSettingsViewController : UITableViewController <GMSMapViewDelegate, UIActionSheetDelegate> {
	GMSMapView *mapView_;
	BOOL firstLocationUpdate_;
	YGUserInfo *userInfo;
}

@property(strong, nonatomic) AppSettings *appSettings;

@end

//
//  YGMapViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 06/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AppSettings.h"
#import "ListingRecord.h"

@class YGUserInfo;

@interface YGMapViewController : UIViewController <GMSMapViewDelegate, UIActionSheetDelegate> {
	GMSMapView *mapView_;
	BOOL firstLocationUpdate_;
	YGUserInfo *userInfo;
	int locationUpdateCount;

	NSMutableArray *waypointStrings_;
}

@property (nonatomic, strong) ListingRecord *listing;
- (IBAction)mapWithDrivingDirections:(id)sender;

- (IBAction)showCurrentLocation:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *mapView;
@property(strong, nonatomic) AppSettings *appSettings;

@end

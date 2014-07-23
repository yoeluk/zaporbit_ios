//
//  YGNewItemTableViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 15/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

@class ListingRecord;

#import <UIKit/UIKit.h>
#import "YGUserInfo.h"
#import "YGWebService.h"
#import "AppSettings.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface YGNewItemTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, WebServiceDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, CLLocationManagerDelegate> {
	@private
	UIImage *_picImage;
	NSNumberFormatter *decimalFormatter;
	NSNumberFormatter *currencyFormatter;
	CLLocationManager *locationManager;
	BOOL postWithCurrentLocation;
	BOOL firstLocationUpdate;
	YGUserInfo *userInfo;
	bool isWaggled;
	bool isHighlighted;
	bool isUpgrading;
}

@property (nonatomic, strong) ListingRecord *listing;
@property (nonatomic, strong) ListingRecord *listingUpdate;

@property(strong, nonatomic) AppSettings *appSettings;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UICollectionView *carousel;
- (IBAction)wagglePrice:(id)sender;
- (IBAction)highlightListing:(id)sender;
@end

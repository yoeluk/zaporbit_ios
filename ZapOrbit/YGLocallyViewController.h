//
//  YGLocallyViewController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 01/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGWebService.h"
#import "YGUserInfo.h"
#import "AppSettings.h"
#import "YGSearchDisplayHelper.h"
#import "YGRatingView.h"
#import "YGProfilePictureDownloader.h"
#import "YGInnerCollectionView.h"
#import "YGListLayout.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface YGLocallyViewController : UICollectionViewController <WebServiceDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UICollectionViewDelegateFlowLayout, NSLayoutManagerDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
	YGUserInfo *userInfo;
	NSNumberFormatter *priceFormatter;
	BOOL downloading_;
	NSString *searchString;
	UISearchDisplayController *searchController;
	NSMutableArray *descriptonHeights;
	ZOLocation *currentLocation;
	CLLocationManager *locationManager;
	BOOL firstLocationUpdate;
	@public
	bool shouldHideStatusBar;
	bool waggling;
	YGSearchDisplayHelper *searchHelper;
}

@property (strong, nonatomic) NSMutableArray *itemsLocally;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) UICollectionViewFlowLayout *listLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *tilesLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *streamLayout;
@property (strong, nonatomic) AppSettings *appSettings;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) NSOperationQueue *imageQueue;

- (void)startSearching:(NSString *)filter;

@end

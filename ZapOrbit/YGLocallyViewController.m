//
//  YGLocallyViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 01/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGLocallyViewController.h"
#import "YGDetailItemController.h"
#import "ZOLocallyLongCell.h"
#import "ZOLocallyTilesCell.h"
#import "YGPriceView.h"
#import "VALabel.h"
#import "ListingRecord.h"
#import "ImageDownloader.h"
#import "YGAppDelegate.h"
#import "YGPicturesDownloader.h"

@implementation YGLocallyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Do any additional setup after loading the view.
	[self.collectionView registerClass:[ZOLocallyLongCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
	[self.collectionView registerClass:[ZOLocallyTilesCell class] forCellWithReuseIdentifier:@"tileCellIdentifier"];
	[self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:nil action:nil]];
	
	self.itemsLocally = [[NSMutableArray alloc] initWithCapacity:5];
	userInfo = [YGUserInfo sharedInstance];
	
	priceFormatter = [[NSNumberFormatter alloc] init];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[priceFormatter setLocale:[NSLocale currentLocale]];
	
	UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"List",@"Tiles", @"Stream"]];
	[seg addTarget:self action:@selector(changeLayout:) forControlEvents:UIControlEventValueChanged];
	[seg setSelectedSegmentIndex:0];
	seg.frame = CGRectMake(0, 0, 180, 25);
	self.navigationItem.titleView = seg;
	
	self.appSettings = ((YGAppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
	
	self.tilesLayout = [[UICollectionViewFlowLayout alloc] init];
	self.tilesLayout.minimumLineSpacing = 5;
	self.tilesLayout.minimumInteritemSpacing = 5;
	self.tilesLayout.itemSize = CGSizeMake(152.5, 180);
	
	self.streamLayout = [[UICollectionViewFlowLayout alloc] init];
	self.streamLayout.minimumLineSpacing = 0;
	self.streamLayout.minimumInteritemSpacing = 0;
	self.streamLayout.itemSize = CGSizeMake(320, 420);
	
	self.listLayout = [[UICollectionViewFlowLayout alloc] init];
	self.listLayout.minimumLineSpacing = 0;
	self.listLayout.minimumInteritemSpacing = 0;
	self.listLayout.itemSize = CGSizeMake(320, 90);
	
	self.collectionView.collectionViewLayout = self.listLayout;
	
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, 44)];
	searchBar.delegate = self;
	searchBar.tag = 22;
	searchBar.placeholder = @"Search";
	
	UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 78)];
	accessoryView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
	
	UILabel *priceLabelStr = [[UILabel alloc] initWithFrame:CGRectMake(80, 8, 100, 21)];
	priceLabelStr.font = [UIFont systemFontOfSize:15];
	priceLabelStr.textColor = [UIColor colorWithWhite:0.3 alpha:1];
	priceLabelStr.text = @"Price Range:";
	
	UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(175, 8, 150, 21)];
	priceLabel.font = [UIFont systemFontOfSize:15];
	priceLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
	priceLabel.text = @"Any";
	priceLabel.tag = 10;
	
	UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 40, 280, 22)];
	[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
	[accessoryView addSubview:slider];
	[accessoryView addSubview:priceLabel];
	[accessoryView addSubview:priceLabelStr];
	
	self->searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	[self->searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
	self->searchHelper = [YGSearchDisplayHelper initWithShoppingController:self];
	//self->searchHelper = [[YGSearchDisplayHelper alloc] initWithStyle:UITableViewStylePlain];
	self->searchController.delegate = self->searchHelper;
	self->searchController.searchResultsDataSource  = self->searchHelper;
	self->searchController.searchResultsDelegate  = self->searchHelper;
	
	self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -2, self.collectionView.frame.size.width, 2)];
	self.progressView.tag = 15;
	self.progressView.hidden = YES;
	self.progressView.progress = 0.0f;
	[self.collectionView addSubview:self.progressView];
	[self.collectionView insertSubview:searchBar atIndex:0];
	
	self->locationManager = [[CLLocationManager alloc] init];
	self->locationManager.delegate = self;
	self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if (self->currentLocation) {
		[self requestItemsForLoc:nil withLocation:self->currentLocation];
	} else [self->locationManager startUpdatingLocation];
	
	self.users = [[NSMutableArray alloc] initWithCapacity:5];
	self->descriptonHeights = [[NSMutableArray alloc] initWithCapacity:3];
	
	self.collectionView.delegate = self;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	self->currentLocation = nil;
	self->firstLocationUpdate = NO;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if (status == kCLAuthorizationStatusNotDetermined) {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.1) {
			//[locationManager requestWhenInUseAuthorization];
//#warning remind me to add logic to alert the use the user that the app needs access to location services
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
	if (!self->firstLocationUpdate) {
		self->firstLocationUpdate = YES;
	} else {
		CLLocation *location = [locations lastObject];
		ZOLocation *pseudoLocation = [ZOLocation locationWithCLLocation:location];
		GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
		[geocoder reverseGeocodeCoordinate:location.coordinate completionHandler:^(GMSReverseGeocodeResponse *callBack, NSError *error) {
			pseudoLocation.locality = callBack.firstResult.locality;
			pseudoLocation.street = callBack.firstResult.thoroughfare;
			pseudoLocation.administrativeArea = callBack.firstResult.administrativeArea;
			self->currentLocation = pseudoLocation;
			if (self.itemsLocally.count == 0) {
				[self.collectionView setContentOffset:CGPointMake(0, -66)];
				[self requestItemsForLoc:nil withLocation:self->currentLocation];
			}
		}];
		[self->locationManager stopUpdatingLocation];
	}
}

-(void)sliderChanged:(UISlider *)slider {
	UILabel *priceLabel = (UILabel *)[slider.superview viewWithTag:10];
	NSNumber *price;
	float val = 500*slider.value;
	[priceFormatter setMaximumFractionDigits:0];
	
	if (slider.value <= 0.2) {
		price = [NSNumber numberWithInt:(int)(val-fmodf(val, 5))];
	} else if (slider.value < 0.5) {
		price = [NSNumber numberWithInt:(int)(val-fmodf(val, 10))];
	} else {
		price = [NSNumber numberWithInt:(int)(val-fmodf(val, 20))];
	}
	if (val < 1) {
		priceLabel.text = @"Any";
	} else if (val >= 1 && val < 5) {
		priceLabel.text = [NSString stringWithFormat:@"%@ - %@",
						   [priceFormatter stringFromNumber:[NSNumber numberWithInt:0]],
						   [priceFormatter stringFromNumber:[NSNumber numberWithInt:10]]];
	} else if (val == 500) {
		priceLabel.text = [NSString stringWithFormat:@"Above %@", [priceFormatter stringFromNumber:[NSNumber numberWithInt:500]]];
	} else if (val < 200) {
		int priceRangeMin = (int)[price integerValue] - 5;
		int priceRangeMax = (int)[price integerValue] + 5;
		priceLabel.text = [NSString stringWithFormat:@"%@ - %@",
						   [priceFormatter stringFromNumber:[NSNumber numberWithInt:priceRangeMin]],
						   [priceFormatter stringFromNumber:[NSNumber numberWithInt:priceRangeMax]]];
	} else {
		int priceRangeMin = (int)[price integerValue] - 10;
		int priceRangeMax = (int)[price integerValue] + 10;
		priceLabel.text = [NSString stringWithFormat:@"%@ - %@",
						   [priceFormatter stringFromNumber:[NSNumber numberWithInt:priceRangeMin]],
						   [priceFormatter stringFromNumber:[NSNumber numberWithInt:priceRangeMax]]];
	}
	[priceFormatter setMinimumFractionDigits:2];
}

- (BOOL)prefersStatusBarHidden {
    return shouldHideStatusBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	for (ListingRecord *listing in self.itemsLocally) {
		[listing.picturesCache removeAllObjects];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!self.progressView.hidden) {
		[self.collectionView setContentOffset:CGPointMake(0, -66) animated:NO];
	}
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		for (UIView *subview in [self.view.window subviews]) {
			if (subview.tag == 21) {
				[subview removeFromSuperview];
			}
		}
	}
}

-(void)descriptionHeights {
	[self->descriptonHeights removeAllObjects];
	CGRect frame = CGRectMake(0, 0, 255, 18);
	UILabel *listingLabel = [[UILabel alloc] initWithFrame:frame];
	listingLabel.numberOfLines = 0;
	NSMutableParagraphStyle *listingStyle = [[NSMutableParagraphStyle alloc] init];
	listingStyle.lineHeightMultiple = 1.35f;
	NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
							NSParagraphStyleAttributeName : listingStyle};
	for (ListingRecord *listing in self.itemsLocally) {
		[listingLabel setFrame:frame];
		listingLabel.attributedText = [[NSAttributedString alloc] initWithString:listing.description attributes:attrs];
		[listingLabel sizeToFit];
		[self->descriptonHeights addObject:[NSNumber numberWithFloat:listingLabel.bounds.size.height+26]];
	}
}

#pragma mark - Requesting the listings data

-(void)cancelPicturesDownloading {
	if (self.itemsLocally.count) {
		for (ListingRecord *listing in self.itemsLocally) {
			if (listing.picturesDownloader) {
				[listing.picturesDownloader cancelDownload];
			}
		}
	}
}

-(void)filterItemsForLoc:(id)sender withFilter:(NSString *)filter withLocation:(ZOLocation *)location {
	[self cancelPicturesDownloading];
	YGWebService *ws = [YGWebService initWithDelegate:self];
	NSInteger userId = userInfo.user ? userInfo.user.id : 0;
	NSString *url = [NSString stringWithFormat:@"filterlocation/0?filter=%@&id=%ld", filter, (long)userId];
	NSMutableDictionary *locDict = [ZOLocation dictionaryWithLocation:location];
	[ws filterItemsForLocation:[NSDictionary dictionaryWithObjectsAndKeys:locDict, @"location", nil] service:url method:@"POST"];
	
	[self.progressView setHidden:NO];
	[self.progressView setProgress:0.4 animated:YES];
}

-(void)requestItemsForLoc:(id)sender withLocation:(ZOLocation *)location {
	[self cancelPicturesDownloading];
	YGWebService *ws = [YGWebService initWithDelegate:self];
	NSInteger userId = userInfo.user ? userInfo.user.id : 0;
	NSString *url = [NSString stringWithFormat:@"listingsbylocation/0/5?id=%ld", (long)userId];
	NSMutableDictionary *locDict = [ZOLocation dictionaryWithLocation:location];
	[ws getItemsForLocation:[NSDictionary dictionaryWithObjectsAndKeys:locDict, @"location", nil] :url :@"POST"];
	[self.progressView setHidden:NO];
	[self.progressView setProgress:0.4 animated:YES];
}

-(void)coughRequestedData:(NSData *)data {
	NSMutableArray *response = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:data
																				 options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
																				   error:nil];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	[self.itemsLocally removeAllObjects];
	[self.users removeAllObjects];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directory = [NSString stringWithFormat:@"%@/listingPictures", paths[0]];
	NSString *profilePics = [NSString stringWithFormat:@"%@/profilesPictures", paths[0]];
	NSError *error = nil;
	[fileManager removeItemAtPath:directory error:&error];
	[fileManager removeItemAtPath:profilePics error:&error];
	
	if (response.count) {
		NSMutableArray *receivedItems = [[NSMutableArray alloc] initWithCapacity:3];
		for (NSDictionary *dict in response) {
			NSDictionary *listDict = [dict objectForKey:@"listing"];
			NSDictionary *locDict = [dict objectForKey:@"location"];
			NSDictionary *userDict = [dict objectForKey:@"user"];
			if ([(NSArray *)[listDict objectForKey:@"pictures"] count]) {
				YGUser *user = [[YGUser alloc] init];
				user.id = [[userDict objectForKey:@"id"] intValue];
				user.name = [userDict objectForKey:@"name"];
				user.surname = [userDict objectForKey:@"surname"];
				user.email = [userDict objectForKey:@"email"];
				user.isMerchant = [userDict objectForKey:@"isMerchant"];
				user.fbuserid = [userDict objectForKey:@"fbuserid"];
				NSString *rawUpdateDate = [listDict objectForKey:@"updated_on"];
				NSString *dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
				NSDate *date = [df dateFromString:dateStr];
				ListingRecord *listing = [[ListingRecord alloc] init];
				listing.id = [NSNumber numberWithInt:[[listDict objectForKey:@"id"] intValue]];
				listing.title = [listDict objectForKey:@"title"];
				listing.description = [listDict objectForKey:@"description"];
				listing.locale = [listDict objectForKey:@"locale"];
				listing.pictures = [[NSMutableArray alloc] initWithCapacity:5];
				listing.picturesCache = [[NSCache alloc] init];
				listing.highlight = [[listDict objectForKey:@"highlight"] boolValue];
				listing.waggle = [[listDict objectForKey:@"waggle"] boolValue];
				listing.icons = [[NSCache alloc] init];
				listing.pictureNames = [listDict objectForKey:@"pictures"];
				listing.price = [NSNumber numberWithFloat:[[listDict objectForKey:@"price"] floatValue]];
				listing.shop = [listDict objectForKey:@"shop"];
				listing.telephone = [listDict objectForKey:@"telephone"];
				if ([listing.telephone isEqual:[NSNull null]]) listing.telephone = Nil;
				listing.userid = [[listDict objectForKey:@"userid"] intValue];
				listing.updated_on = [date formattedDateRelativeToNow:date];
				listing.location = locDict;
				listing.user = user;
				[receivedItems addObject:listing];
			}
		}
		[self.itemsLocally addObjectsFromArray:receivedItems];
		[self startPicturesDownload:receivedItems];
		[self descriptionHeights];
	}
	[self.progressView setProgress:1.0f animated:YES];
	[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(refreshUI:) userInfo:nil repeats:NO];
}

-(void)refreshUI:(id)sender {
	[self.collectionView setContentOffset:CGPointMake(0, -64) animated:NO];
	[self.progressView setHidden:YES];
	[self.collectionView reloadData];
	self.progressView.progress = 0.0f;
}

#pragma mark - Searchbar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self->searchString = searchBar.text;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	searchBar.showsScopeBar = YES;
	[searchBar sizeToFit];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	searchBar.showsScopeBar = NO;
	[searchBar sizeToFit];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = nil;
	if (self->currentLocation) {
		[self requestItemsForLoc:nil withLocation:self->currentLocation];
		[self->searchController setActive:NO animated:YES];
		[self.collectionView setContentOffset:CGPointMake(0, -66) animated:NO];
	}  else [self->locationManager startUpdatingLocation];
}

- (void)startSearching:(NSString *)filter {
	[self->searchController.searchBar resignFirstResponder];
	if (self->currentLocation) {
		[self filterItemsForLoc:self withFilter:filter withLocation:self->currentLocation];
		[self->searchController setActive:NO animated:YES];
		[self.collectionView setContentOffset:CGPointMake(0, -66) animated:NO];
	} else [self->locationManager startUpdatingLocation];
	[self addToSearchHistory:filter];
	self->searchController.searchBar.text = filter;
}

- (void)addToSearchHistory:(NSString *)filter {
	if (filter.length) {
		bool found = NO;
		for (NSMutableDictionary *searchDict in self.appSettings.searchHistory) {
			if ([filter isEqualToString:[searchDict objectForKey:@"searchString"]]) {
				found = YES;
				[searchDict setObject:[NSDate date] forKey:@"date"];
				break;
			}
		}
		if (!found) {
			[self.appSettings.searchHistory addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:filter, @"searchString", [NSDate date], @"date", nil]];
		}
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSString *filter = searchBar.text;
	[self startSearching:filter];
	
}

#pragma mark - Scrollview related methods

-(void)wagglePriceLables {
	if (!self->waggling && self.collectionView.collectionViewLayout == self.listLayout) {
		for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
			NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
			ListingRecord *listing = (ListingRecord *)[self.itemsLocally objectAtIndex:indexPath.item];
			if (listing.waggle) {
				self->waggling = YES;
				UIView *priceView = [cell.contentView viewWithTag:40];
				[UIView animateWithDuration:0.2 animations:^{
					if (priceView)
						priceView.transform = CGAffineTransformMakeRotation(-0.2);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.2 animations:^{
						if (priceView)
							priceView.transform = CGAffineTransformMakeRotation(0.2);
					} completion:^(BOOL finished) {
						[UIView animateWithDuration:0.2 animations:^{
							if (priceView)
								priceView.transform = CGAffineTransformMakeRotation(-0.2);
						} completion:^(BOOL finished) {
							[UIView animateWithDuration:0.2 animations:^{
								if (priceView)
									priceView.transform = CGAffineTransformMakeRotation(0.2);
							} completion:^(BOOL finished) {
								self->waggling = NO;
							}];
						}];
					}];
				}];
			}
		}
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self wagglePriceLables];
	if ([self.navigationController.navigationBar isHidden]) {
		[self setTabBarHidden:self.tabBarController.tabBar hidden:NO animated:YES];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self wagglePriceLables];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < -44) {
		id searchBar = [scrollView viewWithTag:22];
		[[scrollView viewWithTag:22] removeFromSuperview];
		[scrollView addSubview:searchBar];
	}
}

- (void)setTabBarHidden:(UITabBar *)tabBar hidden:(BOOL)hidden animated:(BOOL)animated {
	if (hidden) {
		if (!animated) [tabBar setHidden:YES];
		else {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDelegate:nil];
			[UIView setAnimationDuration:0.2];
			[tabBar setAlpha:0.0];
			[UIView commitAnimations];
		}
	} else {
		if (!animated) [tabBar setHidden:NO];
		else {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDelegate:nil];
			[UIView setAnimationDuration:0.2];
			[tabBar setAlpha:1.0];
			[UIView commitAnimations];
		}
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (-scrollView.contentOffset.y > 125) {
		CGPoint stopPoint = {0,-66};
		targetContentOffset->y = stopPoint.y;
		if (velocity.y != 0) {
			[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:velocity.y options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
				[scrollView setContentOffset:stopPoint];
			} completion:^(BOOL finished) {}];
		} // else [scrollView setContentOffset:stopPoint animated:YES];
		
		if (self->searchString && ![[self->searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
			if (self->currentLocation) [self filterItemsForLoc:self withFilter:[self->searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] withLocation:self->currentLocation];
			else [self->locationManager startUpdatingLocation];
		} else {
			if (self->currentLocation) [self requestItemsForLoc:self withLocation:self->currentLocation];
			else [self->locationManager startUpdatingLocation];
		}
	}
	if (velocity.y > 0) {
		//[self setTabBarHidden:self.tabBarController.tabBar hidden:YES animated:YES];
		if (![self.navigationController.navigationBar isHidden]) {
			[self.navigationController setNavigationBarHidden:YES animated:YES];
			UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,320, 20)];
			view.backgroundColor=[UIColor colorWithWhite:0.96 alpha:0.9];
			view.tag = 21;
			[self.view.window addSubview:view];
		}
	} else if ([self.navigationController.navigationBar isHidden] && velocity.y < 0) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		//[self setTabBarHidden:self.tabBarController.tabBar hidden:NO animated:YES];
		
		for (UIView *subview in [self.view.window subviews]) {
			if (subview.tag == 21) {
				[subview removeFromSuperview];
			}
		}
	}
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 5;
}

#pragma mark - CollectionView related methods

-(void)changeLayout:(id)sender {
	NSInteger layoutIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
	if (layoutIndex) {
		if (layoutIndex == 1) {
			[self.collectionView setCollectionViewLayout:self.tilesLayout animated:NO completion:^(BOOL finished) {
			}];
		} else {
			[self.collectionView setCollectionViewLayout:self.streamLayout animated:NO completion:^(BOOL finished) {
			}];
		}
	} else {
		[self.collectionView setCollectionViewLayout:self.listLayout animated:NO completion:^(BOOL finished) {
		}];
	}
	[self.collectionView reloadData];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
						layout:(UICollectionViewLayout*)collectionViewLayout
		insetForSectionAtIndex:(NSInteger)section {
	UIEdgeInsets inset;
	if (collectionView == self.collectionView) {
		if (collectionViewLayout == self.tilesLayout) inset = UIEdgeInsetsMake(49, 5, 5, 5);
		else if (collectionViewLayout == self.streamLayout) inset = UIEdgeInsetsMake(44, 0, 5, 0);
		else inset = UIEdgeInsetsMake(44, 0, 0, 0);
	} else inset = UIEdgeInsetsZero;
	
    return inset;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	CGSize size = CGSizeZero;
	if (collectionViewLayout == self.tilesLayout) {
		size = CGSizeMake(152.5, 180);
	} else if (collectionViewLayout == self.streamLayout) {
		size = CGSizeMake(320, 370);
	} else if (collectionViewLayout == self.listLayout) {
		size = CGSizeMake(320, 90);
	}
	if (size.width == 0) {
		NSLog(@"not a known layout");
	}
	return size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	int numberOfItems = 0;
	if (collectionView == self.collectionView) {
		numberOfItems = (int)self.itemsLocally.count;
	}
	return numberOfItems;
}

/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	CGSize size;
	size = CGSizeMake(self.collectionView.frame.size.width, 44);
	return size;
}
*/

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"cellIdentifier";
	static NSString *tileCellIdentifier = @"tileCellIdentifier";
	static NSString *streamCellIdentifier = @"streamCellIdentifier";
	static NSString *innerCellIdentifier = @"innerCellIdentifier";
	
	UICollectionViewCell *cell;
	
	if (collectionView.collectionViewLayout == self.tilesLayout) {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:tileCellIdentifier forIndexPath:indexPath];
	} else if (collectionView.collectionViewLayout == self.listLayout) {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	} else if (collectionView.collectionViewLayout == self.streamLayout) {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:streamCellIdentifier forIndexPath:indexPath];
	} else {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:innerCellIdentifier forIndexPath:indexPath];
	}
	
	VALabel *titleLabel;
	YGPriceView *priceView;
	NSString *price;
	CGSize size;
	CGRect frame;
	UILabel *timeLabel;
	UILabel *priceLabel;
	YGRatingView *rating;
	
	ListingRecord *listing = (ListingRecord *)[self.itemsLocally objectAtIndex:indexPath.row];
	
	switch (indexPath.section) {
		case 0:
			
			// Set the title
			titleLabel = (VALabel *)[cell.contentView viewWithTag:10];
			titleLabel.textColor = [UIColor blackColor];
			titleLabel.text = listing.title;
			
			// Add the price label
			if (listing.locale && ![listing.locale isEqualToString:@""]) {
				NSLocale *locale = [NSLocale localeWithLocaleIdentifier:listing.locale];
				[priceFormatter setLocale:locale];
				[priceFormatter setMinimumFractionDigits:2];
				[priceFormatter setMaximumFractionDigits:2];
			}
			if ([listing.price floatValue] >= 100) {
				[priceFormatter setMaximumFractionDigits:0];
				price = [priceFormatter stringFromNumber:listing.price];
				[priceFormatter setMinimumFractionDigits:2];
			} else {
				price = [priceFormatter stringFromNumber:listing.price];
			}
			[priceFormatter setLocale:[NSLocale currentLocale]];
			[priceFormatter setMinimumFractionDigits:2];
			[priceFormatter setMaximumFractionDigits:2];
			
			if (self.listLayout == collectionView.collectionViewLayout) {
				
				size = [price sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13],NSFontAttributeName, nil]];
				frame = CGRectMake(301-size.width, 16, size.width+11, size.height+4);
				priceView = (YGPriceView *)[cell.contentView viewWithTag:40];
				if (priceView) [priceView removeFromSuperview];
				priceView = [[YGPriceView alloc] initWithFrame:frame];
				[priceView setPrice:price];
				priceView.tag = 40;
				priceView.transform = CGAffineTransformMakeRotation(0.2);
				[cell.contentView addSubview:priceView];
				
			} else if (self.tilesLayout == collectionView.collectionViewLayout) {
				
				// Set the price label
				priceLabel = (UILabel *)[cell.contentView viewWithTag:25];
				priceLabel.text = price;
				
			} else if (self.streamLayout == collectionView.collectionViewLayout) {
				
				// stream cell set up here
				
				[(UILabel *)[cell.contentView viewWithTag:12] setText:listing.user.fullName];
				UIImageView *profilePicView = (UIImageView *)[[cell.contentView viewWithTag:66] viewWithTag:55];
				if (![listing.user.picCache objectForKey:@"pic"]) {
					
					// look and see if this users pic is already downloaded in self users
					YGUser *userFound = nil;
					for (YGUser *user in self.users) {
						if (user.id == listing.user.id) {
							userFound = user;
							break;
						}
					}
					if (userFound) {
						if ([userFound.picCache objectForKey:@"pic"]) {
							[profilePicView setImage:(UIImage *)[userFound.picCache objectForKey:@"pic"]];
							profilePicView.contentMode = UIViewContentModeScaleAspectFill;
							[profilePicView setFrame:CGRectMake(-19, 12, 60, 60)];
						} else {
							[profilePicView setImage:nil];//[[UIImage imageNamed:@"profile-placeholder2"] imageWithTintColor:[UIColor colorWithRed:148/255.f green:184/255.f blue:221/255.f alpha:1]]];
							[profilePicView setFrame:CGRectMake(-19, 12, 60, 60)];
							[profilePicView setContentMode:UIViewContentModeScaleAspectFill];
							[self renderProfilePicture:userFound forIndexPath:indexPath];
						}
					} else {
						[profilePicView setImage:nil];//[[UIImage imageNamed:@"profile-placeholder2"] imageWithTintColor:[UIColor colorWithRed:148/255.f green:184/255.f blue:221/255.f alpha:1]]];
						[profilePicView setFrame:CGRectMake(-19, 12, 60, 60)];
						[profilePicView setContentMode:UIViewContentModeScaleAspectFill];
						[self profilePictureDownload:listing.user forIndexPath:indexPath];
					}
				} else {
					[profilePicView setImage:(UIImage *)[listing.user.picCache objectForKey:@"pic"]];
					[profilePicView setFrame:CGRectMake(-15, 20, 50, 50)];
					[profilePicView setContentMode:UIViewContentModeScaleAspectFill];
				}
				
				[(UILabel *)[cell.contentView viewWithTag:33] setText:listing.title];
				rating = (YGRatingView *)[cell.contentView viewWithTag:50];
				[rating setRating:1.0 animated:NO];
				[rating setRatingText:@"Basic Level"];
				
				if ([cell.contentView viewWithTag:90]) {
					YGInnerCollectionView *innerCollectionView = (YGInnerCollectionView *)[cell.contentView viewWithTag:90];
					[innerCollectionView setListing:listing];
				} else {
					YGInnerCollectionView *innerCollectionView = [YGInnerCollectionView collectionViewWithListing:listing withFrame:CGRectMake(0, 125, 320, 220)];
					innerCollectionView.tag = 90;
					[cell.contentView addSubview:innerCollectionView];
				}
			}
			// Set the time label
			timeLabel = (UILabel *)[cell.contentView viewWithTag:20];
			titleLabel.textColor = [UIColor blackColor];
			timeLabel.text = listing.updated_on;
			[timeLabel setTextColor:[UIColor grayColor]];
			
			// Highligh the cell if highlight == YES
			if (listing.highlight) {
				if (self.listLayout == collectionView.collectionViewLayout) {
					[cell.contentView setBackgroundColor:[UIColor colorWithRed:1 green:50/255.f blue:1 alpha:1]];
					titleLabel.textColor = [UIColor whiteColor];
					priceView.layer.shadowOpacity = 0.8;
					[timeLabel setTextColor:[UIColor colorWithWhite:0.85 alpha:1]];
				} else if (self.tilesLayout == collectionView.collectionViewLayout) {
					[[cell.contentView viewWithTag:23] setBackgroundColor:[UIColor colorWithRed:1 green:50/255.f blue:1 alpha:1]];
				}
				
			} else {
				[cell.contentView setBackgroundColor:[UIColor clearColor]];
				if (self.tilesLayout == collectionView.collectionViewLayout) {
					[[cell.contentView viewWithTag:23] setBackgroundColor:[UIColor whiteColor]];
				}
			}
			
			// get the pic from disk if the cache is empty
			if ([listing.icons objectForKey:@"icon"]) {
				[(UIImageView *)[cell.contentView viewWithTag:15] setImage:(UIImage *)[listing.icons objectForKey:@"icon"]];
			} else {
				[(UIImageView *)[cell.contentView viewWithTag:15] setImage:[[UIImage imageNamed:@"picture_placeholder"] imageWithTintColor:[UIColor lightGrayColor]]];
				[self renderListingIcon:listing atIndexPath:indexPath];
			}
			break;
		case 1:
			break;
		default:
			break;
	}
	return cell;
}

- (void)profilePictureDownload:(YGUser *)user forIndexPath:(NSIndexPath *)indexPath {
    YGProfilePictureDownloader *pictureDownloader = [[YGProfilePictureDownloader alloc] init];
    if (pictureDownloader != nil) {
		pictureDownloader.user = user;
		__weak typeof(self) weakSelf = self;
        [pictureDownloader setCompletionHandler:^{
			[weakSelf.users addObject:user];
			[weakSelf renderProfilePicture:user forIndexPath:indexPath];
        }];
        [pictureDownloader startDownload:user.fbuserid];
    }
}

-(void)renderProfilePicture:(YGUser *)user forIndexPath:(NSIndexPath *)indexPath {
	if (![user.picCache objectForKey:@"pic"]) {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *directory = [NSString stringWithFormat:@"%@/profilesPictures", paths[0]];
			NSString *fullPathToImage = [NSString stringWithFormat:@"%@/%@", directory, user.fbuserid];
			UIImage *image = [UIImage imageWithContentsOfFile:fullPathToImage];
			[user.picCache setObject:image forKey:@"pic"];
			dispatch_async(dispatch_get_main_queue(), ^{
				UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
				if ([[self.collectionView visibleCells] indexOfObject:cell] != NSNotFound) {
					UIImageView *profilePicView = (UIImageView *)[[cell.contentView viewWithTag:66] viewWithTag:55];
					[profilePicView setImage:image];
				}
			});
		});
	}
}

-(void)checkDownloadingStatus:(NSTimer *)timer {
	if (self.itemsLocally.count) {
		BOOL isDownloading = NO;
		for (ListingRecord *listing in self.itemsLocally) {
			if (listing.picturesDownloader && listing.picturesDownloader.imageConnection) {
				isDownloading = YES;
				break;
			}
		}
		if (!isDownloading) {
			[timer invalidate];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		}
	}
}

- (void)startPicturesDownload:(NSArray *)listings {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	for (ListingRecord *aListing in listings) {
		[self downloadPicturesInListing:aListing index:0];
	}
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkDownloadingStatus:) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

-(void)downloadPicturesInListing:(ListingRecord *)aListing index:(int)index {
	YGPicturesDownloader *picturesDownloader = [[YGPicturesDownloader alloc] init];
	if (picturesDownloader != nil) {
		picturesDownloader.listing = aListing;
		[picturesDownloader setCompletionHandler:^{
			if (aListing.pictures.count == 1) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.itemsLocally indexOfObject:aListing] inSection:0];
				[self renderListingIcon:aListing atIndexPath:indexPath];
			}
			NSNotificationCenter *centre = [NSNotificationCenter defaultCenter];
			NSDictionary *dictWithListing = [[NSDictionary alloc] initWithObjectsAndKeys:aListing, @"listing", nil];
			[centre postNotificationName:@"ListingPicturesDownloaded" object:nil userInfo:dictWithListing];
			if (aListing.pictures.count < aListing.pictureNames.count) {
				[self downloadPicturesInListing:aListing index:index+1];
			} else {
				
			}
		}];
		aListing.picturesDownloader = picturesDownloader;
		[picturesDownloader startDownload:index];
	}
}

-(void)renderListingIcon:(ListingRecord *)listing atIndexPath:(NSIndexPath *)indexPath{
	if (listing.pictures.count) {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSString *fullPathToImage = [NSString stringWithFormat:@"%@",[listing.pictures objectAtIndex:0]];
			UIImage *image = [UIImage imageWithContentsOfFile:fullPathToImage];
			CGRect rect;
			CGImageRef imageRef;
			if (image.size.width < image.size.height) {
				rect = CGRectMake(0, (image.size.height - image.size.width)/2, image.size.width, image.size.width);
				imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
				image = [UIImage imageWithCGImage:imageRef];
			} else {
				rect = CGRectMake((image.size.width - image.size.height)/2, 0, image.size.height, image.size.height);
				imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
				image = [UIImage imageWithCGImage:imageRef];
			}
			CFRelease(imageRef);
			[listing.icons setObject:image forKey:@"icon"];
			dispatch_async(dispatch_get_main_queue(), ^{
				UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
				if ([[self.collectionView visibleCells] indexOfObject:cell] != NSNotFound) {
					[(UIImageView *)[cell.contentView viewWithTag:15] setImage:image];
				}
			});
		});
	}
}

-(UIImage *)decompressImage:(UIImage *)image {
	
	UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
    [image drawAtPoint:CGPointZero];
    UIImage *decompressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return decompressedImage;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"itemDetailSegue" sender:indexPath];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"itemDetailSegue"]) {
		NSIndexPath *indexPath = (NSIndexPath *)sender;
		id listing = self.itemsLocally[indexPath.row];
		[[segue destinationViewController] setListing:listing];
	}
}


@end

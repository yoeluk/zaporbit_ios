//
//  YGMapViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 06/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGMapViewController.h"
#import "YGDirectionServices.h"
#import "YGAppDelegate.h"
#import "YGUserInfo.h"
#import "ZOLocation.h"

static int locationObservanceContext;

@interface YGMapViewController ()

@end

@implementation YGMapViewController

-(void)setListing:(ListingRecord *)listing {
	_listing = listing;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	userInfo = [YGUserInfo sharedInstance];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
															longitude:103.848
																 zoom:15];
	mapView_ = [GMSMapView mapWithFrame:self.mapView.frame camera:camera];
	mapView_.delegate = self;
	[self.mapView addSubview:mapView_];
	
	// Listen to the myLocation property of GMSMapView.
	[mapView_ addObserver:self
			   forKeyPath:@"myLocation"
				  options:NSKeyValueObservingOptionNew
				  context:&locationObservanceContext];
	
	self.appSettings = ((YGAppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
	
	waypointStrings_ = [[NSMutableArray alloc]init];
}

- (void)getDirectionsToListing:(CLLocationCoordinate2D)position {
	
	//CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
	GMSMarker *marker = [GMSMarker markerWithPosition:position];
	marker.map = mapView_;
	NSString *positionStr = [[NSString alloc] initWithFormat:@"%f,%f",
								position.latitude,position.longitude];
	NSString *currPositionStr = [[NSString alloc] initWithFormat:@"%f,%f",
								mapView_.myLocation.coordinate.latitude,mapView_.myLocation.coordinate.longitude];
    [waypointStrings_ addObject:positionStr];
	[waypointStrings_ addObject:currPositionStr];
	if([waypointStrings_ count] > 1){
		NSString *sensor = @"false";
		NSArray *parameters = @[sensor, waypointStrings_];
		NSArray *keys = @[@"sensor", @"waypoints"];
		NSDictionary *query = @{keys : parameters};
		YGDirectionServices *dws= [YGDirectionServices initWithDelegate:self];
		[dws requestDirectionsForListing:query];
	}
}

-(void)coughDirectionData:(NSDictionary *)json {
	NSDictionary *routes = json[@"routes"][0];
	
	NSDictionary *route = routes[@"overview_polyline"];
	NSString *overview_route = route[@"points"];
	GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
	GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
	polyline.map = mapView_;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[mapView_ removeObserver:self
				  forKeyPath:@"myLocation"
					 context:&locationObservanceContext];
}

#pragma location - Listen to location updates

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	dispatch_async(dispatch_get_main_queue(), ^{
		mapView_.myLocationEnabled = YES;
	});
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	if (!firstLocationUpdate_ && context == &locationObservanceContext) {
		firstLocationUpdate_ = YES;
		if (change[NSKeyValueChangeNewKey]) {
			CLLocation *location = change[NSKeyValueChangeNewKey];
			mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
															 zoom:15];
		}
	} else if (_listing.location && locationUpdateCount == 2) {
		ZOLocation *loc = [ZOLocation locationWithDictionary:_listing.location];
		[self getDirectionsToListing:CLLocationCoordinate2DMake([loc.latitude floatValue], [loc.longitude floatValue])];
	}
	locationUpdateCount++;
}

- (IBAction)mapWithDrivingDirections:(id)sender {
	NSURL *testURL = [NSURL URLWithString:@"comgooglemaps-x-callback://"];
	NSString *directionsRequest = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"?daddr=%f,%f",
																	  [(_listing.location)[@"latitude"] floatValue],
																	  [(_listing.location)[@"longitude"] floatValue]],
								   @"&x-success=zaporbit://?resume=true&x-source=ZapOrbit"];
	if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
		directionsRequest = [NSString stringWithFormat:@"%@%@", @"comgooglemaps-x-callback://", directionsRequest];
		NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
		[[UIApplication sharedApplication] openURL:directionsURL];
	} else {
		directionsRequest = [NSString stringWithFormat:@"%@%@", @"http://maps.apple.com/", directionsRequest];
		NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
		[[UIApplication sharedApplication] openURL:directionsURL];
	}

}

- (IBAction)showCurrentLocation:(id)sender {
	GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:mapView_.myLocation.coordinate
													 zoom:15];
	/*[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
	[mapView_ animateToCameraPosition:camera];
	[CATransaction setCompletionBlock:^{
		// ... whatever you want to do when the animation is complete
	}];
	[CATransaction commit];*/
	[mapView_ animateToCameraPosition:camera];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

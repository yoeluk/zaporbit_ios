//
//  YGSettingsViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 30/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGSettingsViewController.h"
#import "YGAppDelegate.h"
#import "YGUserInfo.h"
#import "ZOLocation.h"

static int locationObservanceContext;

@interface YGSettingsViewController ()

@end

@implementation YGSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	userInfo = [YGUserInfo sharedInstance];
	
	GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
															longitude:103.848
																 zoom:12];
	mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 80, 80) camera:camera];
	mapView_.delegate = self;
	mapView_.userInteractionEnabled = NO;
	
	[mapView_ addObserver:self
			   forKeyPath:@"myLocation"
				  options:NSKeyValueObservingOptionNew
				  context:&locationObservanceContext];
	
	self.appSettings = ((YGAppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
	self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[mapView_ removeObserver:self
				  forKeyPath:@"myLocation"
					 context:&locationObservanceContext];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	mapView_.myLocationEnabled = YES;
}

#pragma location - Listen to location updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	if (!firstLocationUpdate_ && context == &locationObservanceContext) {
		firstLocationUpdate_ = YES;
		if (change[NSKeyValueChangeNewKey]) {
			CLLocation *location = change[NSKeyValueChangeNewKey];
			mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
															 zoom:12];
			[self.tableView reloadData];
			
		}
	}
}


#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat height = section == 0 ? 0 : 35;
	return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, section == 0 ? 0 : 35)];
	view.backgroundColor = [UIColor colorWithRed:230/255.f green:229/255.f blue:233/255.f alpha:1];
	return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = indexPath.section == 0 && indexPath.row == 0 ? 92 : indexPath.section == 0 && indexPath.row == 1 ? 54 : 44;
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section == 0 ? 2 : section == 1 ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIndentifier = @"Cell";
	static NSString *customCellIndentifier = @"customCell";
	
    UITableViewCell *cell;
	UIImageView *imageView;
	
	switch (indexPath.section) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
			if (indexPath.row == 0) {
				CALayer *topBorder = [CALayer layer];
				topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.5f);
				topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
				[cell.contentView.layer addSublayer:topBorder];
				CGRect rect = CGRectMake(6, 6, 80, 80);
				UIView *subview = [[UIView alloc] initWithFrame:rect];
				subview.tag = 10;
				[cell.contentView addSubview:subview];
				cell.selectionStyle = UITableViewCellSelectionStyleDefault;
				[subview addSubview:mapView_];
				if (self.appSettings.defaultLocation) {
					GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([self.appSettings.defaultLocation.latitude doubleValue], [self.appSettings.defaultLocation.longitude doubleValue])];
					marker.title = @"Default location";
					[mapView_ clear];
					marker.map = mapView_;
				}
				GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
				[geocoder reverseGeocodeCoordinate:mapView_.myLocation.coordinate completionHandler:^(GMSReverseGeocodeResponse *callBack, NSError *error) {
					if (callBack.firstResult) {
						if ([cell.contentView viewWithTag:20]) {
							[[cell.contentView viewWithTag:20] removeFromSuperview];
						}
						if ([cell.contentView viewWithTag:35]) {
							[[cell.contentView viewWithTag:35] removeFromSuperview];
						}
						UILabel *streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, 220, 45)];
						streetLabel.font = [UIFont systemFontOfSize:15];
						streetLabel.textColor = [UIColor grayColor];
						[streetLabel setTextAlignment:NSTextAlignmentCenter];
						streetLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
						streetLabel.numberOfLines = 0;
						streetLabel.text = [NSString stringWithFormat:@"%@, %@.", callBack.firstResult.thoroughfare ,callBack.firstResult.locality]; ;
						streetLabel.tag = 20;
						[cell.contentView addSubview:streetLabel];
						UIButton *save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
						[save setTitle:@"Save as default location" forState:UIControlStateNormal];
						[save setFrame:CGRectMake(90, 50, 220, 30)];
						[save addTarget:self action:@selector(saveDefaultLocation:) forControlEvents:UIControlEventTouchUpInside];
						save.tag = 35;
						save.userInteractionEnabled = NO;
						[cell.contentView addSubview:save];
					}
				}];
			} else if (indexPath.row == 1) {
				//cell.textLabel.text = @"Set current location as default";
				cell.textLabel.font = [UIFont systemFontOfSize:15];
				cell.textLabel.textColor = [UIColor grayColor];
				[cell.textLabel setTextAlignment:NSTextAlignmentCenter];
				//NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
				//cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Set current location as default" attributes:underlineAttribute];
				cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
				cell.textLabel.numberOfLines = 0;
				cell.textLabel.text = self.appSettings.defaultLocation ? [NSString stringWithFormat:@"%@, %@ %@.", self.appSettings.defaultLocation.street, self.appSettings.defaultLocation.locality, self.appSettings.defaultLocation.administrativeArea] : @"No saved location";
				UIImageView *uiImageView = (UIImageView *)[cell.contentView viewWithTag:25];
				uiImageView.image = [UIImage imageNamed:@"ios7_place"];
			}
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier forIndexPath:indexPath];
			//cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.text = @"Merchant";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			imageView = (UIImageView *)[cell.contentView viewWithTag:25];
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			imageView.image = [[UIImage imageNamed:@"742-wrench"] imageWithTintColor:[UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1]];
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier forIndexPath:indexPath];
			break;
		default:
			break;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0 && mapView_.myLocation) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[cell setSelected:NO animated:YES]; // <-- setSelected instead of setHighlighted
		if (!self.appSettings.defaultLocation) {
			[self saveDefaultLocation:nil];
		} else {
			UIActionSheet *saveSheet = [[UIActionSheet alloc] initWithTitle:@"You are about to update your default location with your current one." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Ok, update it!" otherButtonTitles:nil];
			saveSheet.tag = 10;
			[saveSheet showInView:self.tableView];
		}
	} else if (indexPath.section == 1) {
		[self performSegueWithIdentifier:@"merchantSegue" sender:indexPath];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self saveDefaultLocation:nil];
	}
}

-(void)saveDefaultLocation:(id)sender {
	GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
	[geocoder reverseGeocodeCoordinate:mapView_.myLocation.coordinate completionHandler:^(GMSReverseGeocodeResponse *callBack, NSError *error) {
		if (!self.appSettings.defaultLocation) {
			self.appSettings.defaultLocation = [[ZOLocation alloc] init];
		}
		//NSLog(@"address: %@", callBack.firstResult);
		self.appSettings.defaultLocation.street = callBack.firstResult.thoroughfare;
		self.appSettings.defaultLocation.locality = callBack.firstResult.locality;
		self.appSettings.defaultLocation.administrativeArea = callBack.firstResult.administrativeArea;
		self.appSettings.defaultLocation.latitude = @((float) callBack.firstResult.coordinate.latitude);
		self.appSettings.defaultLocation.longitude = @((float) callBack.firstResult.coordinate.longitude);
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
		GMSMarker *marker = [GMSMarker markerWithPosition:mapView_.myLocation.coordinate];
		marker.title = @"Default location";
		[mapView_ clear];
		marker.map = mapView_;
	}];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

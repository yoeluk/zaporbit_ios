//
//  YGNewItemTableViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 15/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGNewItemTableViewController.h"
#import "YGAppDelegate.h"
#import "ListingRecord.h"
#import "GCPlaceholderTextView.h"

#define LOCALE_IDENTIFIER [[NSLocale currentLocale] localeIdentifier]
#define CURRECY_CODE [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]

@interface YGNewItemTableViewController ()
@end

@implementation YGNewItemTableViewController

-(void)setListing:(ListingRecord *)listing {
	_listing = listing;
	[_listing.pictures removeAllObjects];
	_listingUpdate = [[ListingRecord alloc] init];
	_listingUpdate.pictureNames = [[NSMutableArray alloc] initWithCapacity:3];
	_listingUpdate.pictures = [[NSMutableArray alloc] initWithCapacity:3];
	self->isHighlighted = _listing.highlight;
	self->isWaggled = _listing.waggle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	userInfo = [YGUserInfo sharedInstance];
	
	if (!_listing) {
		_listing = [[ListingRecord alloc] init];
		_listing.waggle = NO;
		_listing.highlight = NO;
		_listing.shop = @"none";
		_listing.userid = userInfo.user ? userInfo.user.id : 0;
		_listing.pictureNames = [[NSMutableArray alloc] initWithCapacity:5];
		_listing.pictures = [[NSMutableArray alloc] initWithCapacity:5];
		_listing.picturesCache = [[NSCache alloc] init];
	}
	
	decimalFormatter = [[NSNumberFormatter alloc] init];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[decimalFormatter setMaximumFractionDigits:2];
	
	currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setLocale:[NSLocale currentLocale]];
	
	if (_listingUpdate) {
		self.navigationItem.title = @"Listing";
		if (_listing.pictureNames.count) {
			[self downloadPicturesInListing:_listing index:0];
		}
		UIBarButtonItem *postBtn = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleDone target:self action:@selector(updateImages:)];
		self.navigationItem.rightBarButtonItem = postBtn;
	} else {
		UIBarButtonItem *postBtn = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(checkLocationForPosting:)];
		self.navigationItem.rightBarButtonItem = postBtn;
	}
	self.appSettings = ((YGAppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings;
	 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)dealloc {
	_listing = nil;
	_listingUpdate = nil;
	_carousel = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)appWillEnterForeground:(id)sender {
	if (self->isUpgrading) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (![userInfo user]) {
		[[[UIAlertView alloc] initWithTitle:@"You are not logged in!"
									message:@"Use the Login with Facebook button in the home screen to sign in. An active login is required to post an item."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 101 && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
		[self postImages:nil];
	} else
	 [self.navigationController popViewControllerAnimated:YES];
}

//#############################################################################################
//############################## UPDATE LISTING ###############################################

// updateImages is always called first when updating a listing
-(void)updateImages:(id)sender {
	if (_listingUpdate.pictures.count) {
		NSString *fullPathToImage = (_listingUpdate.pictures)[0];
		NSData *imageData = [NSData dataWithContentsOfFile:fullPathToImage];
		NSString *pictureName = [[fullPathToImage componentsSeparatedByString:@"/"] lastObject];
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws uploadMorePictures:imageData :[NSString stringWithFormat:@"uploadpictures/%@", pictureName] :@"POST"];
		[_listingUpdate.pictures removeObjectAtIndex:0];
	} else [self updateListing:nil];
}

-(void)coughUpdatingPictures:(NSData *)data {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if ([response[@"status"] isEqualToString:@"OK"]) {
		if (_listingUpdate.pictures.count) {
			[self updateImages:nil];
		} else {
			[self updateListing:nil];
		}
	}
}

-(void)updateListing:(id)sender {
	if ([userInfo user] && _listing.id) {
		NSMutableDictionary *postDict = [[NSMutableDictionary alloc] initWithCapacity:5];
		if (_listingUpdate.title) {
			postDict[@"title"] = _listingUpdate.title;
		}
		if (_listingUpdate.description) {
			postDict[@"description"] = _listingUpdate.description;
		}
		if (_listingUpdate.price) {
			postDict[@"price"] = _listingUpdate.price;
			postDict[@"locale"] = _listingUpdate.locale;
			postDict[@"currency_code"] = _listingUpdate.currency_code;
		}
		if (_listingUpdate.shop) {
			postDict[@"shop"] = _listingUpdate.shop;
		}
		if (_listingUpdate.pictureNames && _listingUpdate.pictureNames.count) {
			postDict[@"pictures"] = _listingUpdate.pictureNames;
		}
        postDict[@"highlight"] = @(_listing.highlight);
        postDict[@"waggle"] = @(_listing.waggle);
		if (postDict.count) {
			YGWebService *ws = [YGWebService initWithDelegate:self];
			[ws WSRequest:postDict :[NSString stringWithFormat:@"updatelisting/%@", _listing.id] :@"POST"];
			[_listingUpdate.pictureNames removeAllObjects];
		}
	}
}

-(void)coughUpdatingResponse:(NSData *)data {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if ([response[@"status"] isEqualToString:@"OK"]) {
		if ((_listingUpdate.highlight && _listingUpdate.highlight != self->isHighlighted) ||
			(_listingUpdate.waggle && _listingUpdate.waggle != self->isWaggled)) {
			[self upgradeLinsting:_listing.id isWaggle:_listingUpdate.waggle isHighlight:_listingUpdate.highlight];
		} else [self.navigationController popViewControllerAnimated:YES];
		_listingUpdate = [[ListingRecord alloc] init];
	} else if ([response[@"status"] isEqualToString:@"KO"]) {
		NSLog(@"there was an error: %@", response[@"message"]);
	}
}
/* END UPDATING LISTING */

//#############################################################################################
//############################## POSTING LISTING ##############################################

-(void)checkLocationForPosting:(id)sender {
	UIActionSheet *locationSheet;
	if (self.appSettings.defaultLocation) {
		locationSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a location for this item." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Saved Location", @"Current Location", nil];
	} else {
		locationSheet = [[UIActionSheet alloc] initWithTitle:@"Posting requires to access your current location." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
	}
	locationSheet.tag = 999;
	[locationSheet showInView:self.tableView];
}

// postImages is always called first when posting a listing
-(void)postImages:(id)sender {
	if (_listing.pictures.count) {
		NSString *fullPathToImage = (_listing.pictures)[0];
		NSData *imageData = [NSData dataWithContentsOfFile:fullPathToImage];
		NSString *pictureName = [[fullPathToImage componentsSeparatedByString:@"/"] lastObject];
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws uploadPictures:imageData :[NSString stringWithFormat:@"uploadpictures/%@", pictureName] :@"POST"];
		[_listing.pictures removeObjectAtIndex:0];
	} else [self postListing:nil];
}

-(void)postListing:(id)sender {
	if ([userInfo user]) {
		NSDictionary *postDict = @{
				@"offer": @{
					@"title" : _listing.title,
					@"description" : _listing.description,
					@"price" : _listing.price,
					@"shop" : _listing.shop,
					@"locale" : _listing.locale,
					@"currency_code" : _listing.currency_code,
					@"highlight" : [NSNumber numberWithBool:false],
					@"waggle" : [NSNumber numberWithBool:false],
					@"userid" : @(_listing.userid)
				},
                @"pictures" : _listing.pictureNames,
                @"location" : _listing.location
        };
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws WSRequest:postDict :@"newlisting" :@"POST"];
		[_listing.pictureNames removeAllObjects];
	}
}

// WS delegate callback for uploading pictures
-(void)coughUploadingResponse:(NSData *)data {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if ([response[@"status"] isEqualToString:@"OK"]) {
		if (_listing.pictures.count) {
			[self postImages:nil];
		} else {
			[self postListing:nil];
		}
	}
}

// WS delegate callback for new listing request
-(void)coughRequestedData:(NSData *)data {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if ([response[@"status"] isEqualToString:@"OK"]) {
		if (_listing.highlight || _listing.waggle) {
			NSNumber *listingid = response[@"listingid"];
			[self upgradeLinsting:listingid isWaggle:_listing.waggle isHighlight:_listing.highlight];
		} else [self.navigationController popViewControllerAnimated:YES];
	}
}
/* END POSTING LISTING */

-(NSString*)generateRandomString:(int)num {
	NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@*_$";
    NSMutableString* string = [NSMutableString stringWithCapacity:(NSUInteger) num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    return string;
}

-(void)upgradeLinsting:(NSNumber *)listingid isWaggle:(bool)waggle isHighlight:(bool)highlight {
	self->isUpgrading = YES;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://zaporbit.com/cart/upgradelisting/%@/%d/%d", listingid, waggle, highlight]]];
}

-(void)prepareForPosting:(id)sender {
	_listing.title = @"";
}

-(void)dismissController:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

-(void) getPicture:(id)sender {
	[self startCameraControllerFromViewController:self usingDelegate:(self)];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
								   usingDelegate: (id <UIImagePickerControllerDelegate,
												   UINavigationControllerDelegate>) delegate {

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
		|| (delegate == nil)
		|| (controller == nil))
        return NO;
	
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
	
    cameraUI.mediaTypes =
	[UIImagePickerController availableMediaTypesForSourceType:
	UIImagePickerControllerSourceTypeCamera];
	
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
	
    [controller presentViewController:cameraUI animated:(YES) completion:^{
		
	}];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissViewControllerAnimated:YES completion:^{
		if ([[info[UIImagePickerControllerMediaType] description] isEqualToString:@"public.image"]) {
			NSIndexPath *picIndexPath = [NSIndexPath indexPathForRow:3 inSection:1];
			UITableViewCell *picCell = [self.tableView cellForRowAtIndexPath:picIndexPath];
			_picImage = [self compressForUpload:info[UIImagePickerControllerOriginalImage] scalingFactor:0.3f];
			[(UIImageView *)[picCell.contentView viewWithTag:10] setImage:_picImage];
			
			NSString *pictureName = [self generateRandomString:24];
			NSData *imageData = UIImageJPEGRepresentation(_picImage, 1);
			
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *directory = [NSString stringWithFormat:@"%@/listingPictures", paths[0]];
			NSString *fullPath = [NSString stringWithFormat:@"%@/%@", directory, pictureName];
			
			BOOL isDir = YES;
			NSError *error = nil;
			if(![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
				if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
					NSLog(@"Failed to create directory \"%@\". Error: %@", directory, error);
				}
			}
			bool dataWritten = [imageData writeToFile:fullPath atomically:YES];
			NSAssert(dataWritten, @"could not write image data to file");
			
			if (dataWritten) {
				[_listing.pictures addObject:fullPath];
				[_listing.pictureNames addObject:pictureName];
				if (_listingUpdate) {
					[_listingUpdate.pictures addObject:fullPath];
					[_listingUpdate.pictureNames addObject:pictureName];
				}
                [self renderListingPicture:_listing atIndex:(NSUInteger) ((int) _listing.pictures.count - 1)];
			}
		}
	}];
}

- (UIImage *)compressForUpload:(UIImage *)original scalingFactor:(CGFloat)scale {
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width+1, newSize.height+1)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *shopName = _listing.shop ? _listing.shop : @"none";
	return shopName;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height;
	switch (indexPath.row) {
		case 0:
			height = 77;
			break;
		case 1:
			height = 220;
			break;
		case 2:
			height = 44;
			break;
		case 3:
			height = 120;
			break;
		case 4:
			height = 100;
			break;
		default:
			height = 64;
			break;
	}
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *descriptionCell = @"descriptionCell";
	static NSString *priceCell = @"priceCell";
	static NSString *pictureCell = @"pictureCell";
	//static NSString *shopCell = @"shopCell";
	static NSString *premiumCell = @"premiumCell";
	static NSString *titleCell = @"titleCell";
	
	UITableViewCell *cell;
	//UIPickerView *picker;
	GCPlaceholderTextView *titleView;
	GCPlaceholderTextView *descriptionView;
	UITextField *priceTextField;
	UISwitch *highlight;
	UISwitch *waggle;
	UIToolbar *titleToolBar;
	UIToolbar *descriptionToolBar;
	UIBarButtonItem *doneTitleBtn;
	UIBarButtonItem *flexTitleBtn;
	UIBarButtonItem *doneDescriptionBtn;
	UIBarButtonItem *flexDescriptionBtn;
	UIToolbar *priceToolBar;
	UIBarButtonItem *donePriceBtn;
	UIBarButtonItem *flexPriceBtn;
	switch (indexPath.row) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:titleCell forIndexPath:indexPath];
			titleView = (GCPlaceholderTextView *)[cell.contentView viewWithTag:30];
			titleView.text = _listing.title;
			titleView.placeholder = @"Set the title for this listing.";
			[titleView setTextColor:[UIColor blackColor]];
			titleToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
			flexTitleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
			doneTitleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyBoard:)];
			[titleToolBar setItems:@[flexTitleBtn, doneTitleBtn] animated:NO];
			[titleView setDelegate:self];
			titleView.inputAccessoryView = titleToolBar;
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:descriptionCell forIndexPath:indexPath];
			descriptionView = (GCPlaceholderTextView *)[cell.contentView viewWithTag:60];
			descriptionView.text = _listing.description;
			descriptionView.placeholder = @"Add a description of the item or service you wish to post with this listing.";
			[descriptionView setTextColor:[UIColor blackColor]];
			descriptionToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
			flexDescriptionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
			doneDescriptionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyBoard:)];
			[descriptionToolBar setItems:@[flexDescriptionBtn, doneDescriptionBtn] animated:NO];
			[descriptionView setDelegate:self];
			descriptionView.inputAccessoryView = descriptionToolBar;
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:priceCell forIndexPath:indexPath];
			priceTextField = (UITextField *)[cell.contentView viewWithTag:25];
			priceTextField.placeholder = @"Enter the price here";
			if (priceTextField.inputAccessoryView == nil) {
				priceToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
				flexPriceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
				donePriceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyBoard:)];
				[priceToolBar setItems:@[flexPriceBtn, donePriceBtn] animated:NO];
				priceTextField.inputAccessoryView = priceToolBar;
			}
			if (_listing.price) {
				NSString *localizedMoneyString;
				NSNumber *priceNumber = _listing.price;
				if (_listing.locale && ![_listing.locale isEqualToString:@""]) {
					NSLocale *locale = [NSLocale localeWithLocaleIdentifier:_listing.locale];
					[currencyFormatter setLocale:locale];
				}
				if ([priceNumber floatValue] > 99.99) {
					priceNumber = @((int) ceilf([priceNumber floatValue]));
					[currencyFormatter setMaximumFractionDigits:0];
					localizedMoneyString = [currencyFormatter stringFromNumber:priceNumber];
					[currencyFormatter setMinimumFractionDigits:2];
				} else {
					localizedMoneyString = [currencyFormatter stringFromNumber:priceNumber];
				}
				[currencyFormatter setLocale:[NSLocale currentLocale]];
				priceTextField.text = localizedMoneyString;
			}
			priceTextField.delegate = self;
			break;
		case 3:
			cell = [tableView dequeueReusableCellWithIdentifier:pictureCell forIndexPath:indexPath];
			if (!_carousel) {
				UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
				layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
				layout.itemSize = CGSizeMake(130, 100);
				layout.minimumInteritemSpacing = 30;
				_carousel = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 5, 300, 112) collectionViewLayout:layout];
				[_carousel registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
				_carousel.backgroundColor = [UIColor clearColor];
				_carousel.tag = 15;
				_carousel.delegate = self;
				_carousel.dataSource = self;
			}
			if (![cell.contentView viewWithTag:15]) {
				[cell.contentView addSubview:_carousel];
			}
			break;
		/*case 4:
			cell = [tableView dequeueReusableCellWithIdentifier:shopCell forIndexPath:indexPath];
			if (![cell.contentView viewWithTag:20]) {
				picker = [[UIPickerView alloc] initWithFrame:CGRectMake(70, -49, 250, 162)];
				picker.tag = 20;
				picker.delegate = self;
				picker.dataSource = self;
				[cell.contentView addSubview:picker];
			}
			break;*/
		case 4:
			cell = [tableView dequeueReusableCellWithIdentifier:premiumCell forIndexPath:indexPath];
			highlight = (UISwitch *)[cell.contentView viewWithTag:45];
			waggle = (UISwitch *)[cell.contentView viewWithTag:55];
			[highlight setOnTintColor:[UIColor colorWithRed:1 green:50/255.f blue:1 alpha:1]];
			//[waggle setOnTintColor:[UIColor colorWithRed:1 green:50/255.f blue:1 alpha:1]];
			highlight.on = _listing.highlight;
			waggle.on = _listing.waggle;
			break;
		default:
			break;
	}
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(130, 100);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return section == 0 ? _listing.pictures.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [_carousel dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
	switch (indexPath.section) {
		case 0:
			if ([cell.contentView viewWithTag:20]) [[cell.contentView viewWithTag:20] removeFromSuperview];
			if ([_listing.picturesCache objectForKey:(_listing.pictureNames)[(NSUInteger) indexPath.row]]) {
				UIImage *image = (UIImage *) [_listing.picturesCache objectForKey:(_listing.pictureNames)[(NSUInteger) indexPath.row]];
				UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 100)];
				NSAssert(image != nil, @"could not find cached image");
				[pictureView setImage:image];
				UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletePicture:)];
				[tap setCancelsTouchesInView:NO];
				[pictureView addGestureRecognizer:tap];
				pictureView.contentMode = UIViewContentModeScaleAspectFit;
				pictureView.userInteractionEnabled = YES;
				pictureView.tag = 20;
				[cell.contentView addSubview:pictureView];
			} else {
                [self renderListingPicture:_listing atIndex:(NSUInteger) (int) indexPath.row];
			}
			break;
		case 1:
			if ([cell.contentView viewWithTag:20]) {
				[[cell.contentView viewWithTag:20] removeFromSuperview];
			}
			if (indexPath.row == 0) {
				UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 100)];
				pictureView.contentMode = UIViewContentModeScaleAspectFit;
				if (_listing.pictureNames.count > 5) {
					[pictureView setImage : [[UIImage imageNamed:@"1396037708_add_photo"] imageWithTintColor:[UIColor colorWithWhite:0.85 alpha:1]]];
					pictureView.userInteractionEnabled = NO;
				} else [pictureView setImage : [[UIImage imageNamed:@"1396037708_add_photo"] imageWithTintColor:[UIColor lightGrayColor]]];
				UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPicture:)];
				[tap setCancelsTouchesInView:NO];
				[pictureView addGestureRecognizer:tap];
				pictureView.tag = 20;
				pictureView.userInteractionEnabled = YES;
				[cell.contentView addSubview:pictureView];
			}
			break;
		default:
			break;
	}
	return cell;
}

-(void)deletePicture:(id)sender {
	NSIndexPath *indexPath = [_carousel indexPathForCell:(UICollectionViewCell *)[[[sender view] superview] superview]];
	UIActionSheet *deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm deleting this picture." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Ok, delete it!" otherButtonTitles:nil];
	deleteSheet.tag = indexPath.row;
	[deleteSheet showInView:self.tableView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSInteger index = actionSheet.tag;
	if (buttonIndex == 0 && index != 999) {
		if (index <= _listing.pictureNames.count-1 ) {
			if (_listingUpdate) {
				YGWebService *ws = [YGWebService initWithDelegate:self];
				[ws deletePicture:[NSString stringWithFormat:@"deletepicture/%@/%@", _listing.id, (_listing.pictureNames)[(NSUInteger) index]] :index :@"GET"];
			} else {
                [_listing.pictureNames removeObjectAtIndex:(NSUInteger) index];
                [_listing.pictures removeObjectAtIndex:(NSUInteger) index];
				[_carousel reloadSections:[NSIndexSet indexSetWithIndex:0]];
			}
		} else {
            [_listingUpdate.pictures removeObjectAtIndex:(NSUInteger) (index - _listing.pictureNames.count)];
            [_listingUpdate.pictureNames removeObjectAtIndex:(NSUInteger) (index - _listing.pictureNames.count)];
            [_listing.pictures removeObjectAtIndex:(NSUInteger) index];
            [_listing.pictureNames removeObjectAtIndex:(NSUInteger) index];
			[_carousel reloadSections:[NSIndexSet indexSetWithIndex:0]];
		}
	} else {
		if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Saved Location"]) {
			_listing.location = [ZOLocation dictionaryWithLocation:self.appSettings.defaultLocation];
			if (!_listing.pictures.count) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No pictures found" message:@"Listings without at least one picture will not show on searches" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
				alertView.tag = 101;
				[alertView show];
			} else
				[self postImages:nil];
		} else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Current Location"] || [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
			if (nil == self->locationManager) {
				self->locationManager = [[CLLocationManager alloc] init];
				self->locationManager.delegate = self;
				self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			}
			self->postWithCurrentLocation = YES;
			[self->locationManager startUpdatingLocation];
			
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	self->postWithCurrentLocation = NO;
	self->firstLocationUpdate = NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if (!self->firstLocationUpdate) {
		self->firstLocationUpdate = YES;
	} else {
		CLLocation *currentLocation = [locations lastObject];
		if (self->postWithCurrentLocation) {
			ZOLocation *currLoc = [[ZOLocation alloc] init];
			currLoc.latitude = @(currentLocation.coordinate.latitude);
			currLoc.longitude = @(currentLocation.coordinate.longitude);
			GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
			[geocoder reverseGeocodeCoordinate:currentLocation.coordinate completionHandler:^(GMSReverseGeocodeResponse *callBack, NSError *error) {
				currLoc.street = callBack.firstResult.thoroughfare;
				currLoc.locality = callBack.firstResult.locality;
				currLoc.administrativeArea = callBack.firstResult.administrativeArea;
				currLoc.locality = callBack.firstResult.locality;
				currLoc.street = callBack.firstResult.thoroughfare;
				_listing.location = [ZOLocation dictionaryWithLocation:currLoc];
				[self postImages:nil];
			}];
			self->postWithCurrentLocation = NO;
		}
		self->firstLocationUpdate = NO;
		[manager stopUpdatingLocation];
	}
}

-(void)coughDeletePictureData:(NSData *)data :(int)index {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if ([response[@"status"] isEqualToString:@"OK"]) {
		if ([_listingUpdate.pictureNames indexOfObject:_listing.pictureNames[(NSUInteger) index]] != NSNotFound) {
            [_listingUpdate.pictureNames removeObjectAtIndex:(NSUInteger) index];
            [_listingUpdate.pictures removeObjectAtIndex:(NSUInteger) index];
		}
        [_listing.pictureNames removeObjectAtIndex:(NSUInteger) index];
        [_listing.pictures removeObjectAtIndex:(NSUInteger) index];
		[_carousel reloadSections:[NSIndexSet indexSetWithIndex:0]];
	}
}

- (void)downloadPicturesInListing:(ListingRecord *)listing index:(int)index {
	YGPicturesDownloader *picturesDownloader = [[YGPicturesDownloader alloc] init];
	if (picturesDownloader != nil) {
		picturesDownloader.listing = listing;
		[picturesDownloader setCompletionHandler:^{
			if (listing.pictures.count < listing.pictureNames.count) {
				[self downloadPicturesInListing:listing index:index+1];
			}
            [self renderListingPicture:listing atIndex:(NSUInteger) index];
		}];
		[picturesDownloader startDownload:index];
	}
}

-(void)renderListingPicture:(ListingRecord *)listing atIndex:(NSUInteger)index {
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		NSString *fullPathToImage = (listing.pictures)[(NSUInteger) index];
		UIImage *image = [UIImage imageWithContentsOfFile:fullPathToImage];
		if (image != nil) {
			CGRect rect;
			if (image.size.width < image.size.height) {
				rect = CGRectMake(0, (image.size.height - image.size.width)/2, image.size.width, (CGFloat) (image.size.width/1.3));
				CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
				image = [UIImage imageWithCGImage:imageRef];
				CFRelease(imageRef);
			}
			[listing.picturesCache setObject:image forKey:(listing.pictureNames)[(NSUInteger) index]];
			NSAssert([listing.picturesCache objectForKey:(listing.pictureNames)[index]] != nil, @"the image is not saved to the cache");
			dispatch_async(dispatch_get_main_queue(), ^{
				UICollectionViewCell *cell = [_carousel cellForItemAtIndexPath:indexPath];
				[(UIImageView *)[cell.contentView viewWithTag:20] setImage:image];
				[_carousel reloadSections:[NSIndexSet indexSetWithIndex:0]];
			});
		}
	});
}


-(void)dismissKeyBoard:(id)sender {
	[self.view endEditing:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	
	NSString *trimmedText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if ([trimmedText isEqualToString: @""]) {
		textView.text = nil;
	} else textView.text = trimmedText;
	
	switch (textView.tag) {
		case 30:
			_listing.title = textView.text;
			if (_listingUpdate) {
				_listingUpdate.title = _listing.title;
			}
			break;
			
		case 60:
			_listing.description = textView.text;
			if (_listingUpdate) {
				_listingUpdate.description = _listing.description;
			}
			break;
			
		default:
			break;
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = nil;
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSCharacterSet* notDigits = [[NSCharacterSet characterSetWithCharactersInString:@",.0123456789"] invertedSet];
	if (textField.text.length) {
		if ([textField.text rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
			NSString *localizedMoneyString;
			NSNumber *decimalNumber = [decimalFormatter numberFromString:textField.text];
			if ([decimalNumber floatValue] > 99.99) {
				decimalNumber = @((int) ceilf([decimalNumber floatValue]));
				[currencyFormatter setMaximumFractionDigits:0];
				localizedMoneyString = [currencyFormatter stringFromNumber:decimalNumber];
				[currencyFormatter setMinimumFractionDigits:2];
			} else {
				localizedMoneyString = [currencyFormatter stringFromNumber:decimalNumber];
			}
			_listing.price = decimalNumber;
			_listing.locale = LOCALE_IDENTIFIER;
			_listing.currency_code = CURRECY_CODE;
			if (_listingUpdate) {
				_listingUpdate.price = _listing.price;
				_listingUpdate.locale = LOCALE_IDENTIFIER;
				_listingUpdate.currency_code = CURRECY_CODE;
			}
			textField.text = localizedMoneyString;
		}
	} else {
		_listing.price = @0;
		_listing.locale = @"";
		_listing.currency_code = @"";
		if (_listingUpdate) {
			_listingUpdate.price = _listing.price;
			_listingUpdate.locale = @"";
			_listingUpdate.currency_code = @"";
		}
	}
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)wagglePrice:(id)sender {
	if ([sender isKindOfClass:[UISwitch class]]) {
		_listing.waggle = ((UISwitch *)sender).on;
		if (_listingUpdate) {
			_listingUpdate.waggle = _listing.waggle;
		}
	}
}

- (IBAction)highlightListing:(id)sender {
	if ([sender isKindOfClass:[UISwitch class]]) {
		_listing.highlight = ((UISwitch *)sender).on;
		if (_listingUpdate) {
			_listingUpdate.highlight = _listing.highlight;
		}
	}
}

@end

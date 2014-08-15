//
//  YGDetailItemController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 03/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGDetailItemController.h"
#import "YGSellerViewController.h"
#import "YGComposerViewController.h"
#import "YGMapViewController.h"
#import "ListingRecord.h"
#import "YGPicturesDownloader.h"
#import "YGTableViewCell.h"
#import "ZOLocation.h"
#import "YGImage.h"
#import "VALabel.h"

static NSString *kApiUrl = @"http://zaporbit.com/api/";

@interface YGDetailItemController ()
@end

@implementation YGDetailItemController
@synthesize previewing = _previewing;
@synthesize buyerId = _buyerId;

- (void)setListing:(ListingRecord *)listing {
	_listing = listing;
}

-(void)setPreviewing:(BOOL)previewing {
	_previewing = previewing;
}

-(void)setBuyerId:(NSNumber *)buyerId {
	_buyerId = buyerId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	userInfo = [YGUserInfo sharedInstance];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareOptions:)];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Listing" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	priceFormatter = [[NSNumberFormatter alloc] init];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[priceFormatter setLocale:[NSLocale currentLocale]];
	
	if (!_listing.telephone) {
		[self.telephoneButton setEnabled:NO];
	}
	[self.purchaseContainer.layer setCornerRadius:10];
	[self.purchaseContainer.layer setBorderWidth:0.5f];
	[self.purchaseContainer.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[self.purchaseContainer setClipsToBounds:YES];
	if (self.previewing) {
		[self.payButton setEnabled:NO];
		if (self.buyerId) {
			listingOwnerModeText = @"Buyer's profile";
			NSURL *userURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@getuserbyid/%@", kApiUrl, self.buyerId]];
			NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:userURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
				if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
					NSDictionary *response1 = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
					if (response1 && [response1[@"status"] isEqualToString:@"OK"]) {
						NSDictionary *userDict = response1[@"user"];
						YGUser *buyerUser = [YGUser userWithDictionary:userDict];
						[self setUserAsBuyer:buyerUser];
					} else NSLog(@"response1:- %@", response1);
				} else NSLog(@"no user data");
			}];
			[session resume];
		} else listingOwnerModeText = @"Seller's profile";
		[self downloadPicturesInListing:_listing index:0];
	} else listingOwnerModeText = @"Seller's profile";
	if (!userInfo.user || _listing.user.id == userInfo.user.id) {
		[self.payButton setEnabled:NO];
		[self.composeButton setEnabled:NO];
		[self.telephoneButton setEnabled:NO];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareOptions:(id)sender {
	if (_listing.pictures.count) {
		NSString *fullPathToImage = (_listing.pictures)[0];
		UIImage *image = [UIImage imageWithContentsOfFile:fullPathToImage];
		
		UIActivityViewController *activityController = [[UIActivityViewController alloc]
														initWithActivityItems:@[[NSString stringWithFormat:@"%@.", _listing.title],
																				image]
														applicationActivities:nil];
		activityController.excludedActivityTypes = @[UIActivityTypePrint,
													 UIActivityTypeCopyToPasteboard,
													 UIActivityTypeAssignToContact,
													 UIActivityTypeSaveToCameraRoll];
		[self presentViewController:activityController animated:YES completion:nil];
	}
}

- (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale {
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImage;
}

-(UIImage *)compressToMegaBytesSize:(float)size withImage:(UIImage *)image {
	
	CGFloat compression = 0.9f;
	CGFloat maxCompression = 0.1f;
	int maxFileSize = (int) (size*1024*1024);
	
	NSData *imageData = UIImageJPEGRepresentation(image, compression);
	
	while ([imageData length] > maxFileSize && compression > maxCompression) {
		compression -= 0.1;
		imageData = UIImageJPEGRepresentation(image, compression);
	}
	return image;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return NO;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height;
	UITextView *tempTextView;
	NSDictionary *ats;
	UILabel *label;
	NSMutableParagraphStyle *paragraphStyle;
	
	switch (indexPath.row) {
		case 0:
			label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 293, 15)];
			label.font = [UIFont boldSystemFontOfSize:14];
			label.numberOfLines = 3;
			label.text = _listing.title;
			[label sizeToFit];
			height = label.frame.size.height+26;
			break;
		case 3:
			tempTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 295, 44)];
			tempTextView.font = [UIFont systemFontOfSize:14];
			paragraphStyle = [[NSMutableParagraphStyle alloc] init];
			paragraphStyle.lineHeightMultiple = 1.5f;
			ats = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
								  NSParagraphStyleAttributeName : paragraphStyle};
			tempTextView.attributedText = [[NSAttributedString alloc] initWithString:_listing.description attributes:ats];
			[tempTextView sizeToFit];
			height = tempTextView.frame.size.height+10;
			break;
		case 2:
			height = 32;
			break;
		case 1:
			height = 255;
			break;
		default:
			height = 44;
			break;
	}
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"Cell";
	static NSString *customCellIdentifier = @"customCell";
	static NSString *postedDateCellIdentifier = @"postedDateCell";
	static NSString *descriptionCellIdentifier = @"descriptionCell";
	static NSString *sellerCellIdentifier = @"sellerCell";
	
    UITableViewCell *cell;
	UILabel *postedLabel;
	UILabel *priceLabel;
	UITextView *descriptionTextView;
	
	CGRect frame;
    
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				cell = [tableView dequeueReusableCellWithIdentifier:customCellIdentifier forIndexPath:indexPath];
				if ([cell.contentView viewWithTag:20]) {
					[[cell.contentView viewWithTag:20] removeFromSuperview];
				}
				UILabel *titleLabel;
				titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 293, 15)];
				titleLabel.font = [UIFont boldSystemFontOfSize:14];
				titleLabel.numberOfLines = 3;
				titleLabel.text = _listing.title;
				titleLabel.tag = 20;
				[titleLabel sizeToFit];
				[cell.contentView addSubview:titleLabel];
			} else if (indexPath.row == 1) {
				cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
				if (!self.carousel) {
					UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
					layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
					layout.minimumInteritemSpacing = 5;
					self.carousel = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 14, 320, 225) collectionViewLayout:layout];
					[self.carousel registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"pictureCellIdentifier"];
					self.carousel.backgroundColor = [UIColor clearColor];
					self.carousel.indicatorStyle = UIScrollViewIndicatorStyleWhite;
					self.carousel.showsHorizontalScrollIndicator = YES;
					self.carousel.tag = 15;
					self.carousel.delegate = self;
					self.carousel.dataSource = self;
				}
				if (![cell.contentView viewWithTag:15]) {
					[cell.contentView addSubview:self.carousel];
				}
			} else if (indexPath.row == 2) {
				cell = [tableView dequeueReusableCellWithIdentifier:postedDateCellIdentifier forIndexPath:indexPath];
				postedLabel = (UILabel *)[cell.contentView viewWithTag:35];
				if (![_listing.updated_on isEqualToString:@"Now"]) {
					postedLabel.text = [NSString stringWithFormat:@"Posted %@ ago", _listing.updated_on];
				} else postedLabel.text = _listing.updated_on;
				
				
				NSString *price;
				if (_listing.locale && ![_listing.locale isEqualToString:@""]) {
					NSLocale *locale = [NSLocale localeWithLocaleIdentifier:_listing.locale];
					[priceFormatter setLocale:locale];
				}
				if ([_listing.price floatValue] >= 100) {
					[priceFormatter setMaximumFractionDigits:0];
					price = [priceFormatter stringFromNumber:_listing.price];
					[priceFormatter setMinimumFractionDigits:2];
				} else
					price = [priceFormatter stringFromNumber:_listing.price];
				
				priceLabel = (UILabel *)[cell.contentView viewWithTag:23];
				priceLabel.text = price;
				
			} else if (indexPath.row == 3) {
				
				cell = [tableView dequeueReusableCellWithIdentifier:descriptionCellIdentifier forIndexPath:indexPath];
				if ([cell.contentView viewWithTag:45]) {
					[[cell.contentView viewWithTag:45] removeFromSuperview];
				}
				frame = CGRectMake(15, 0, 293, 44);
				
				descriptionTextView = [[UITextView alloc] initWithFrame:frame];
				descriptionTextView.delegate = self;
				descriptionTextView.textAlignment = NSTextAlignmentJustified;
				descriptionTextView.font = [UIFont systemFontOfSize:14];
				descriptionTextView.tag = 45;
				descriptionTextView.scrollEnabled = NO;
				descriptionTextView.textContainer.lineFragmentPadding = 0;
				NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
				paragraphStyle.lineHeightMultiple = 1.5f;
				paragraphStyle.alignment = NSTextAlignmentJustified;
				NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
									  NSParagraphStyleAttributeName : paragraphStyle};
				descriptionTextView.attributedText = [[NSAttributedString alloc] initWithString:_listing.description attributes:attrs];
				[descriptionTextView sizeToFit];
				[cell.contentView addSubview:descriptionTextView];
				
			} else if (indexPath.row == 4) {
				cell = [tableView dequeueReusableCellWithIdentifier:sellerCellIdentifier forIndexPath:indexPath];
				cell.textLabel.textColor = [UIColor grayColor];
				cell.textLabel.font = [UIFont systemFontOfSize:14];
				if (_listing.user.id != userInfo.user.id) {
					cell.textLabel.text = listingOwnerModeText;
				} else {
					cell.textLabel.text = @"This is your own item.";
					cell.userInteractionEnabled = NO;
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
			}
			break;
		default:
			break;
	}
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _listing.pictures.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	CGSize size;
	UIImage *image;
	NSString *fullPathToImage = (_listing.pictures)[(NSUInteger) indexPath.row];
	image = [UIImage imageWithContentsOfFile:fullPathToImage];
	size = CGSizeMake(image.size.width*225/image.size.height, 225);
	return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	UICollectionViewCell *cell = [self.carousel dequeueReusableCellWithReuseIdentifier:@"pictureCellIdentifier" forIndexPath:indexPath];
	
	__block UIImage *image;
	__block UIImageView *pictureView;
	__block CGSize size;
	
	switch (indexPath.section) {
		case 0:
			[[cell.contentView viewWithTag:20] removeFromSuperview];
			
			if (_listing.pictures && _listing.pictures.count) {
				dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
				dispatch_async(queue, ^{
					NSString *fullPathToImage = (_listing.pictures)[(NSUInteger) indexPath.row];
					image = [UIImage imageWithContentsOfFile:fullPathToImage];
					size = CGSizeMake(image.size.width*226/image.size.height, 226);
					//NSLog(@"size {%f, %f", size.width, size.height);
					dispatch_async(dispatch_get_main_queue(), ^{
						UICollectionViewCell *updateCell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
						if (updateCell) {
							pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
							[pictureView setImage:image];
							pictureView.contentMode = UIViewContentModeScaleAspectFit;
							pictureView.userInteractionEnabled = YES;
							pictureView.tag = 20;
							UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenPicture:)];
							[tap setCancelsTouchesInView:NO];
							[pictureView addGestureRecognizer:tap];
							[cell.contentView addSubview:pictureView];
						}
					});
				});
			}
			break;
		default:
			break;
	}
	return cell;
}

- (BOOL)prefersStatusBarHidden {
    return shouldHideStatusBar;
}

-(void)fullScreenPicture:(id)sender {
	UITapGestureRecognizer *oldTap = (UITapGestureRecognizer *)sender;
	self->fullImageTransform = CGAffineTransformIdentity;
	if ([[oldTap view] frame].size.width > [[oldTap view] frame].size.height) {
		self->fullImageTransform = CGAffineTransformMakeRotation((CGFloat) (M_PI/2));
	}
	UIView *rootView = self.view;
	if (!self->imageFullScreen) {
		self->imageRectInRootView = [rootView convertRect:[oldTap view].bounds fromView:[oldTap view]];
		self->tappedImageView = [oldTap view];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[(UIImageView *)[oldTap view] image]];
		[imageView setFrame:self->imageRectInRootView];
		imageView.backgroundColor = [UIColor clearColor];
		imageView.tag = 6;
		UIView *blindView = [[UIView alloc] initWithFrame:self->imageRectInRootView];
		[blindView setBackgroundColor:[UIColor blackColor]];
		blindView.tag = 7;
		[self.view.window addSubview:blindView];
		[self.view.window addSubview:imageView];
		[self->tappedImageView setHidden:YES];
		blindView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		[UIView animateWithDuration:0.35 delay:0 options:0 animations:^{
			imageView.transform = self->fullImageTransform;
			blindView.transform = self->fullImageTransform;
			[blindView setFrame:[self.view bounds]];
			[imageView setFrame:[self.view bounds]];
		} completion:^(BOOL finished) {
			self->shouldHideStatusBar = YES;
			[self setNeedsStatusBarAppearanceUpdate];
			UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenPicture:)];
			[tap setCancelsTouchesInView:NO];
			[blindView addGestureRecognizer:tap];
			self->imageFullScreen = YES;
		}];
		return;
	} else {
		UIView *imageView;
		UIView *blindView;
		for (UIView *subview in [self.view.window subviews]) {
			if (subview.tag == 6) {
				imageView = subview;
			} else if (subview.tag == 7) blindView = subview;
		}
		self->shouldHideStatusBar = NO;
		[self setNeedsStatusBarAppearanceUpdate];
		[UIView animateWithDuration:0.35 delay:0 options:0 animations:^{
			imageView.transform = CGAffineTransformIdentity;
			blindView.transform = CGAffineTransformIdentity;
			[imageView setFrame:self->imageRectInRootView];
			[blindView setFrame:self->imageRectInRootView];
		}completion:^(BOOL finished){
			[self->tappedImageView setHidden:NO];
			[imageView removeFromSuperview];
			[blindView removeFromSuperview];
			self->imageFullScreen = NO;
		}];
		return;
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
		UIImage *image = [UIImage imageWithContentsOfFile:(listing.pictures)[(NSUInteger) index]];
		NSAssert(image != nil, @"the image found is could not be loaded from disk");
        [listing.picturesCache setObject:image forKey:(listing.pictureNames)[(NSUInteger) index]];
		NSAssert([listing.picturesCache objectForKey:(listing.pictureNames)[index]] != nil, @"the image is not saved to the cache");
		dispatch_async(dispatch_get_main_queue(), ^{
			UICollectionViewCell *cell = [_carousel cellForItemAtIndexPath:indexPath];
			[(UIImageView *)[cell.contentView viewWithTag:20] setImage:image];
			[_carousel reloadSections:[NSIndexSet indexSetWithIndex:0]];
		});
	});
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

-(void)dissmissMapViewController:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

#pragma mark - WS delegate

-(void)coughRequestedData:(NSData *)data {
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if (response && [response[@"status"] isEqualToString:@"OK"]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 10 && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:5];
		dict[@"status"] = @"pending";
		dict[@"offer_title"] = _listing.title;
		dict[@"offer_description"] = _listing.description;
		dict[@"offer_price"] = _listing.price;
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:_listing.locale];
		dict[@"currency_code"] = [locale objectForKey:NSLocaleCurrencyCode];
		dict[@"locale"] = _listing.locale;
        dict[@"buyerid"] = @(userInfo.user.id);
        dict[@"sellerid"] = @(_listing.userid);
		dict[@"offerid"] = _listing.id;
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws WSRequest:dict :@"createtransaction" :@"POST"];
	}
}

- (IBAction)purchaseItem:(id)sender {
	//[self performSegueWithIdentifier:@"purchaseSegue" sender:self];
	if ([_listing.user.isMerchant boolValue]) {
		NSLog(@"this is a merchant");
		NSString *urlString = [NSString stringWithFormat:@"https://zaporbit.com/cart/buyitem/%@", _listing.id];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
		NSLog(@"url = %@", urlString);
	} else {
		UIAlertView *purchaseAlert = [[UIAlertView alloc] initWithTitle:@"Start Puchasing?"
																message:@"This action will initiate this purchasing by immediately contacting the seller and creating a buying record."
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"OK", nil];
		purchaseAlert.tag = 10;
		[purchaseAlert show];
	}
}

-(void)dismissController {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)contactSeller:(id)sender {

	UIStoryboard *sb = [self.navigationController storyboard];
	UINavigationController *composerNav = [sb instantiateViewControllerWithIdentifier:@"composerNav"];
	UIBarButtonItem *discardButton = [[UIBarButtonItem alloc] initWithTitle:@"Discard" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
	[[composerNav.childViewControllers[0] navigationItem] setLeftBarButtonItem:discardButton];
	NSDictionary *details = @{@"toUser" : _listing.user, @"listing" : _listing, @"me" : userInfo.user};
	[composerNav.childViewControllers[0] setDetails:details];
	[self presentViewController:composerNav animated:YES completion:^{
		
	}];
}

- (IBAction)callSeller:(id)sender {
	if (_listing.telephone) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", _listing.telephone]]];
	}
}

- (IBAction)showDirections:(id)sender {
	[self performSegueWithIdentifier:@"mapSegue" sender:self];
}

- (IBAction)pinItem:(id)sender {
	UIBarButtonItem *pinButton = (UIBarButtonItem *)sender;
	pinButton.image = [UIImage imageNamed:@"869-pin-selected"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"mapSegue"]) {
		UINavigationController *navController = [segue destinationViewController];
		YGMapViewController *mapViewController = (YGMapViewController *) [navController childViewControllers][0];
		mapViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dissmissMapViewController:)];
		[mapViewController setListing:_listing];
		// Pass the selected object to the new view controller.
	} else if ([segue.identifier isEqualToString:@"sellersSegue"]) {
		if (self.buyerId) {
			if (buyer) {
				[(YGSellerViewController *)[segue destinationViewController] setUser:buyer];
			}
		} else
			[(YGSellerViewController *)[segue destinationViewController] setUser:_listing.user];
	}
}

-(void)setUserAsBuyer:(YGUser *)user {
	buyer = user;
}

@end

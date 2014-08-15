//
//  YGSellTableViewController.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 15/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGSellTableViewController.h"
#import "YGPriceView.h"
#import "VALabel.h"
#import "ListingRecord.h"
#import "ImageDownloader.h"
#import "YGTableViewCell.h"


@interface YGSellTableViewController ()

@end

@implementation YGSellTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.itemsForSale = [[NSMutableArray alloc] initWithCapacity:5];
	userInfo = [YGUserInfo sharedInstance];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(doItemSegue:)];
	
	CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
	[self.tableView.layer addSublayer:topBorder];
	
	priceFormatter = [[NSNumberFormatter alloc] init];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[priceFormatter setLocale:[NSLocale currentLocale]];
	[priceFormatter setMinimumFractionDigits:2];
	[priceFormatter setMaximumFractionDigits:2];
	
	self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, -2, self.tableView.frame.size.width, 2)];
	self.progressView.tag = 15;
	self.progressView.hidden = YES;
	self.progressView.progress = 0.0f;
	[self.tableView addSubview:self.progressView];
	
	[self requestItemsForSale:nil];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!self.progressView.hidden) {
		[self.tableView setContentOffset:CGPointMake(0, -66) animated:NO];
	}
}

-(void)cancelImageDownloading {
	if (self.itemsForSale.count) {
		for (ListingRecord *listing in self.itemsForSale) {
			if (listing.imageDownloader) {
				[listing.imageDownloader cancelDownload];
			}
		}
	}
}

-(void)requestItemsForSale:(id)sender {
	if ([userInfo user]) {
		[self cancelImageDownloading];
		YGWebService *ws = [YGWebService initWithDelegate:self];
		[ws getItemsForUser:[NSString stringWithFormat:@"listingsbyuser/0/1/%ld", (long)userInfo.user.id] :@"GET"];
		
		[self.progressView setHidden:NO];
		[self.progressView setProgress:0.4 animated:YES];
	}
}

-(void)coughRequestedData:(NSData *)data {
	NSMutableArray *response = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
	
	[self.itemsForSale removeAllObjects];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directory = [NSString stringWithFormat:@"%@/firstPictureForListing", paths[0]];
	NSError *error = nil;
	[fileManager removeItemAtPath:directory error:&error];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	if (response.count) {
		for (NSDictionary *dict in response) {
			NSString *rawUpdateDate = dict[@"updated_on"];
			NSString *dateStr = [rawUpdateDate substringToIndex:rawUpdateDate.length-2];
			NSDate *date = [df dateFromString:dateStr];
			ListingRecord *listing = [[ListingRecord alloc] init];
			listing.title = dict[@"title"];
			listing.description = dict[@"description"];
			listing.pictures = [[NSMutableArray alloc] initWithCapacity:5];
			listing.picturesCache = [[NSCache alloc] init];
			listing.pictureNames = dict[@"pictures"];
			listing.locale = dict[@"locale"];
			listing.price = @([dict[@"price"] floatValue]);
			listing.highlight = [dict[@"highlight"] boolValue];
			listing.waggle = [dict[@"waggle"] boolValue];
			listing.shop = dict[@"shop"];
			listing.userid = [dict[@"userid"] intValue];
			listing.id = @([dict[@"id"] intValue]);
			listing.updated_on =[date formattedDateRelativeToNow:date];
			[self.itemsForSale addObject:listing];
		}
		[self startImagesDownload:self.itemsForSale];
	}
	[self.progressView setProgress:1.0f animated:YES];
	[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(refreshUI:) userInfo:nil repeats:NO];
}

-(void)refreshUI:(id)sender {
	[self.tableView setContentOffset:CGPointMake(0, -64) animated:NO];
	[self.progressView setHidden:YES];
	[self.tableView reloadData];
	self.progressView.progress = 0.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)waggleAllVisiblePriceLables {
	if (!self->waggling && ![self.tableView isEditing]) {
		self->waggling = YES;
		for (UITableViewCell *cell in [self.tableView visibleCells]) {
			UIView *priceView = [cell.contentView viewWithTag:40];
			[UIView animateWithDuration:0.2 animations:^{
				priceView.transform = CGAffineTransformMakeRotation(-0.2);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.2 animations:^{
					priceView.transform = CGAffineTransformMakeRotation(0.2);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.2 animations:^{
						priceView.transform = CGAffineTransformMakeRotation(-0.2);
					} completion:^(BOOL finished) {
						[UIView animateWithDuration:0.2 animations:^{
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

#pragma mark - Scrollview related methods

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self waggleAllVisiblePriceLables];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self waggleAllVisiblePriceLables];
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (-scrollView.contentOffset.y > 125) {
		CGPoint stopPoint = {0.f, -66.f};
		targetContentOffset->y = scrollView.contentOffset.y;
		[scrollView setContentOffset:stopPoint animated:YES];
		[self requestItemsForSale:self];
	}
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
    return self.itemsForSale.count;
}

-(void)doItemSegue:(id)sender {
	[self performSegueWithIdentifier: @"itemSegue" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIndentifier = @"Cell";
	
    UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];
	
	cell.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);
	if (indexPath.row == self.itemsForSale.count-1) cell.separatorInset = UIEdgeInsetsZero;
    
    // setting the title
	ListingRecord *listing = self.itemsForSale[(NSUInteger) indexPath.row];
	VALabel *titleLabel = (VALabel *)[cell.contentView viewWithTag:20];
	[titleLabel setText:listing.title];
	titleLabel.textColor = [UIColor blackColor];
	
	// adding the price label
	if (listing.locale && ![listing.locale isEqualToString:@""]) {
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:listing.locale];
		[priceFormatter setLocale:locale];
	}
	NSString *price;
	if ([listing.price floatValue] >= 100) {
		[priceFormatter setMaximumFractionDigits:0];
		price = [priceFormatter stringFromNumber:listing.price];
		[priceFormatter setMinimumFractionDigits:2];
		[priceFormatter setMaximumFractionDigits:2];
	} else
		price = [priceFormatter stringFromNumber:listing.price];
	[priceFormatter setLocale:[NSLocale currentLocale]];
	CGSize size = [price sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]}];
	CGRect frame = CGRectMake(301-size.width, 15, size.width+11, size.height+4);
	YGPriceView *priceView = (YGPriceView *)[cell.contentView viewWithTag:40];
	if (priceView) [priceView removeFromSuperview];
	priceView = [[YGPriceView alloc] initWithFrame:CGRectZero];
	[priceView setFrame:frame];
	[priceView setPrice:price];
	priceView.transform = CGAffineTransformMakeRotation(0.2);
	priceView.tag = 40;
	[cell.contentView addSubview:priceView];
	
	UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:50];
	[timeLabel setTextColor:[UIColor grayColor]];
	timeLabel.text = listing.updated_on;
	
	UIImage *buttonImage = [UIImage imageNamed:@"712-reply.png"];
	
	// highligh the cell if highlight == YES
	if (listing.highlight) {
		[cell.contentView setBackgroundColor:[UIColor colorWithRed:1 green:50/255.f blue:1 alpha:1]];
		titleLabel.textColor = [UIColor whiteColor];
		priceView.layer.shadowOpacity = 0.8;
		[timeLabel setTextColor:[UIColor colorWithWhite:0.85 alpha:1]];
		buttonImage = [buttonImage imageWithTintColor:[UIColor whiteColor]];
	} else {
		[cell.contentView setBackgroundColor:[UIColor clearColor]];
		buttonImage = [buttonImage imageWithTintColor:[UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1]];
	}
	
	// get the pic from disk if the cache is empty
	//[(UIImageView *)[cell.contentView viewWithTag:10] setContentMode:UIViewContentModeScaleAspectFit];
	if ([listing.icons objectForKey:@"icon"])
		[(UIImageView *)[cell.contentView viewWithTag:10] setImage:(UIImage *)[listing.icons objectForKey:@"icon"]];
	else {
		[(UIImageView *)[cell.contentView viewWithTag:10] setImage:[[UIImage imageNamed:@"picture_placeholder"] imageWithTintColor:[UIColor lightGrayColor]]];
		[self setListingIcon:listing];
	}

	UIButton *shareButton = (UIButton *)[cell.contentView viewWithTag:13];
	[shareButton setImage:buttonImage forState:UIControlStateNormal];
	if ([tableView isEditing]) {
		shareButton.hidden = YES;
		priceView.hidden = YES;
	} else {
		shareButton.hidden = NO;
		priceView.hidden = NO;
	}
	shareButton.transform = CGAffineTransformMakeScale(-1, 1);
	[shareButton addTarget:self action:@selector(shareListingWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
	
    return cell;
}

-(void)startImagesDownload:(NSArray *)listings {
	for (ListingRecord *listing in listings) {
		[self downloadImageForListing:listing startAt:0];
	}
}

- (void)downloadImageForListing:(ListingRecord *)listing startAt:(int)startAt {
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] init];
    if (imageDownloader != nil) {
        imageDownloader.listing = listing;
        [imageDownloader setCompletionHandler:^{
			[self setListingIcon:listing];
        }];
		listing.imageDownloader = imageDownloader;
        [imageDownloader startDownload];
    }
}

-(void)setListingIcon:(ListingRecord *)listing {
	if (listing.pictures.count) {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSString *fullPathToImage = [NSString stringWithFormat:@"%@", (listing.pictures)[0]];
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
			[listing.icons setObject:image forKey:@"icon"];
			CFRelease(imageRef);
			dispatch_async(dispatch_get_main_queue(), ^{
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.itemsForSale indexOfObject:listing] inSection:0];
				UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
				if ([[self.tableView visibleCells] indexOfObject:cell] != NSNotFound) {
					[(UIImageView *)[cell.contentView viewWithTag:10] setImage:image];
				}
			});
		});
	}
}

/*
// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if (self.itemsForSale.count) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            ListingRecord *listing = [self.itemsForSale objectAtIndex:indexPath.row];
            if (listing.pictures.count && !listing.pic) {
                [self startImageDownload:listing forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		ListingRecord *deletedListing = self.itemsForSale[(NSUInteger) indexPath.row];
        [self.itemsForSale removeObjectAtIndex:(NSUInteger) indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self deleteListingOnServer:deletedListing];
    }
}

-(void)deleteListingOnServer:(ListingRecord *)listing {
	YGWebService *ws = [YGWebService initWithDelegate:self];
	[ws deleteListing:listing :[NSString stringWithFormat:@"deletelisting/%@", listing.id] :@"POST"];
}

-(void)deleteListingResponse:(NSData *)data :(id)listing{
	NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	if (response && [response[@"status"] isEqualToString:@"OK"]) {
		NSLog(@"listing with title '%@' was deleted", ((ListingRecord *)listing).title);
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"itemSegue" sender:indexPath];
}

-(void)shareListingWithFacebook:(id)sender {
	
	UIButton *button = (UIButton *)sender;
	CGPoint originPoint = button.superview.frame.origin;
	CGPoint aPoint = {originPoint.x+5, originPoint.y+5};
	
	NSIndexPath *indexpath = [self.tableView indexPathForRowAtPoint:[button.superview convertPoint:aPoint toView:self.tableView]];
	
	ListingRecord *listing = self.itemsForSale[(NSUInteger) indexpath.row];
	
	if ([[FBSession activeSession] isOpen]) {
		NSArray *permissions = [[FBSession activeSession] permissions];
		NSArray *newPermissions = @[@"publish_actions"];
		if (![permissions containsObject:@"publish_actions"]) {
			[[FBSession activeSession] requestNewPublishPermissions:newPermissions defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
				if (error == nil) {
					[self publishListingToFacebook:listing];
				}
			}];
		} else [self publishListingToFacebook:listing];
	}
}

// publish a story to facebook
-(void)publishListingToFacebook:(ListingRecord *)listing {
	
	id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
	
	NSMutableDictionary<FBGraphObject> *item =
    [FBGraphObject openGraphObjectForPostWithType:@"zaporbit:bargain"
                                            title:listing.title
                                            image:[NSString stringWithFormat:@"https://zaporbit.com/pictures/%@.jpg", (listing.pictureNames)[0]]
											  url:nil
                                      description:listing.description];
	
	//object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
	
	[action setObject:item forKey:@"bargain"];
	
	FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
	params.action = action;
	params.actionType = @"zaporbit:bargain";
	
	if ([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
		[FBDialogs presentShareDialogWithOpenGraphAction:action
											  actionType:@"zaporbit:list"
									 previewPropertyName:@"bargain"
												 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
													 if(error) {
														 NSLog(@"Error: %@", error.description);
													 } else {
														 bool didComplete = [results[@"didComplete"] boolValue];
														 NSString *completedStatus = results[@"completionGesture"];
														 if (didComplete && [completedStatus isEqualToString:@"post"]) {
															 NSLog(@"item posted with postId: %@", results[@"postId"]);
														 } else {
															 NSLog(@"could not post the item: %@", results);
														 }
													 }
												 }];
	}
	
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"itemSegue"] && sender != self) {
		NSIndexPath *indexPath = (NSIndexPath *)sender;
        id listing = self.itemsForSale[(NSUInteger) indexPath.row];
        [[segue destinationViewController] setListing:listing];
    }
}

@end

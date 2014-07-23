//
//  YGInnerCollectionView.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 03/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGInnerCollectionView.h"
#import "YGPicturesDownloader.h"
#import "YGLocallyViewController.h"

@implementation YGInnerCollectionView
@synthesize listing = _listing;

- (id)initWithFrame:(CGRect)frame {
	UICollectionViewFlowLayout *innerLayout = [[UICollectionViewFlowLayout alloc] init];
	innerLayout.minimumLineSpacing = 5;
	innerLayout.minimumInteritemSpacing = 0;
	innerLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:frame collectionViewLayout:innerLayout];
    if (self) {
        // Initialization code
		[self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		[self configure];
    }
    return self;
}

-(void)configure {
	[self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"innerCellIdentifier"];
	self.backgroundColor = [UIColor clearColor];
	self.delegate = self;
	self.dataSource = self;
	self.scrollEnabled = YES;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	self.pagingEnabled = NO;
	NSNotificationCenter *centre = [NSNotificationCenter defaultCenter];
	[centre addObserver:self selector:@selector(updatePictureContent:) name:@"ListingPicturesDownloaded" object:nil];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setListing:(ListingRecord *)listing {
	_listing = listing;
	[self reloadData];
	[self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_listing->index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

+(YGInnerCollectionView *)collectionViewWithListing:(ListingRecord *)listing withFrame:(CGRect)rect {
	YGInnerCollectionView *selfCollectionView = [[YGInnerCollectionView alloc] initWithFrame:rect];
	[selfCollectionView setListing:listing];
	return selfCollectionView;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
					 withVelocity:(CGPoint)velocity
			  targetContentOffset:(inout CGPoint *)targetContentOffset {
	
	int itemsCount = (int)[self numberOfItemsInSection:0];
	
	float easiness = 0.1;
	float easeFactor = 10;
	float pictureWidth = 290;
	float picWidthPlussSpacing = pictureWidth + [(UICollectionViewFlowLayout *)self.collectionViewLayout minimumLineSpacing];
	float damping = 1;
	
	float factor = pictureWidth * _listing->index;
	float surpluss = scrollView.contentOffset.x - factor;
	
	UIViewAnimationOptions curveOption = UIViewAnimationOptionCurveEaseOut;
	
	if (surpluss > 0) {
		if ((surpluss >= picWidthPlussSpacing/2 || (surpluss >= picWidthPlussSpacing/easeFactor && velocity.x > easiness)) && _listing->index < itemsCount-1) {
			targetContentOffset->x = scrollView.contentOffset.x;
			CGFloat pointX = picWidthPlussSpacing*(_listing->index+1);
			CGFloat velocityX = velocity.x;
			if (velocity.x)
				[UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocityX options:curveOption | UIViewAnimationOptionAllowUserInteraction animations:^{
					[self setContentOffset:CGPointMake(pointX, 0)];
				} completion:^(BOOL finished) {}];
			else
				[self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_listing->index+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
			++_listing->index;
		} else if ((surpluss < picWidthPlussSpacing/2 || (surpluss < picWidthPlussSpacing/easeFactor && velocity.x > easiness)) && _listing->index < itemsCount) {
			targetContentOffset->x = scrollView.contentOffset.x;
			CGFloat pointX = picWidthPlussSpacing*_listing->index;
			CGFloat velocityX = velocity.x? velocity.x : 0.1;
			if (velocity.x)
				[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocityX options:curveOption | UIViewAnimationOptionAllowUserInteraction animations:^{
					[self setContentOffset:CGPointMake(pointX, 0)];
				} completion:^(BOOL finished) {}];
			else
				[self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_listing->index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		}
	} else {
		if ((-surpluss >= picWidthPlussSpacing/2 || (-surpluss >= picWidthPlussSpacing/easeFactor && -velocity.x > easiness)) && _listing->index > 0) {
			targetContentOffset->x = scrollView.contentOffset.x;
			CGFloat pointX = picWidthPlussSpacing*(_listing->index-1);
			CGFloat velocityX = velocity.x;
			if (velocity.x)
				[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocityX options:curveOption | UIViewAnimationOptionAllowUserInteraction animations:^{
					[self setContentOffset:CGPointMake(pointX, 0)];
				} completion:^(BOOL finished) {}];
			else
				[self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_listing->index-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
			--_listing->index;
		} else if ((-surpluss < picWidthPlussSpacing/2 || (-surpluss < picWidthPlussSpacing/easeFactor && velocity.x > easiness)) && _listing->index < itemsCount) {
			targetContentOffset->x = scrollView.contentOffset.x;
			CGFloat pointX = picWidthPlussSpacing*_listing->index;
			CGFloat velocityX = velocity.x;
			if (velocity.x)
				[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocityX options:curveOption | UIViewAnimationOptionAllowUserInteraction animations:^{
					[self setContentOffset:CGPointMake(pointX, 0)];
				} completion:^(BOOL finished) {}];
			else
				[self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_listing->index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		}
	}
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
						layout:(UICollectionViewLayout*)collectionViewLayout
		insetForSectionAtIndex:(NSInteger)section {
	
	UIEdgeInsets inset = UIEdgeInsetsMake(0, 15, 0, 15);
    return inset;
}

-(void)updatePictureContent:(NSNotification *)note {
	ListingRecord *aListing = [[note userInfo] objectForKey:@"listing"];
	if (_listing == aListing) {
		[self reloadData];
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGSize size = CGSizeMake(290, 218);
	return size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _listing.pictureNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *innerCellIdentifier = @"innerCellIdentifier";
	CGSize pictureSize = CGSizeMake(290, 218);
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:innerCellIdentifier forIndexPath:indexPath];
	
	if (_listing.pictures && _listing.pictures.count && indexPath.row < _listing.pictures.count) {
		[[cell.contentView viewWithTag:101] removeFromSuperview];
		NSString *imageName = [_listing.pictureNames objectAtIndex:indexPath.row];
		if (![_listing.picturesCache objectForKey:imageName]) {
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
			dispatch_async(queue, ^{
				NSString *fullPathToImage = [NSString stringWithFormat:@"%@", [_listing.pictures objectAtIndex:indexPath.row]];
				UIImage *image = [UIImage imageWithContentsOfFile:fullPathToImage];
				if (image) {
					CGRect rect;
					if (image.size.width < image.size.height) {
						rect = CGRectMake(0, (image.size.height - image.size.width)/2, image.size.width, image.size.width/1.35);
						CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
						image = [UIImage imageWithCGImage:imageRef];
						CFRelease(imageRef);
					}
					[_listing.picturesCache setObject:image forKey:imageName];
					dispatch_async(dispatch_get_main_queue(), ^{
						UIImageView *pictureView;
						if ([cell.contentView viewWithTag:20] != nil) {
							pictureView = (UIImageView *)[cell.contentView viewWithTag:20];
							[pictureView setImage:image];
						} else {
							pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pictureSize.width, pictureSize.height)];
							[pictureView setImage:image];
							UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenPicture:)];
							[tap setCancelsTouchesInView:NO];
							[pictureView addGestureRecognizer:tap];
							pictureView.contentMode = UIViewContentModeScaleAspectFit;
							pictureView.userInteractionEnabled = YES;
							pictureView.tag = 20;
							[cell.contentView addSubview:pictureView];
						}
					});
				}
			});
		} else {
			UIImageView *pictureView;
			UIImage *image = (UIImage *)[_listing.picturesCache objectForKey:imageName];
			if ([cell.contentView viewWithTag:20] != nil) {
				pictureView = (UIImageView *)[cell.contentView viewWithTag:20];
				[pictureView setImage:image];
			} else {
				UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pictureSize.width, pictureSize.height)];
				[pictureView setImage:image];
				UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenPicture:)];
				[tap setCancelsTouchesInView:NO];
				[pictureView addGestureRecognizer:tap];
				pictureView.contentMode = UIViewContentModeScaleAspectFit;
				pictureView.userInteractionEnabled = YES;
				pictureView.tag = 20;
				[cell.contentView addSubview:pictureView];
			}
		}
	} else {
		for (UIView *subview in [cell.contentView subviews]) {
			[subview removeFromSuperview];
		}
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[activityIndicator setFrame:CGRectMake(95, 50, 100, 100)];
		activityIndicator.tag = 101;
		[activityIndicator setColor:[UIColor lightGrayColor]];
		[cell.contentView addSubview:activityIndicator];
		[activityIndicator startAnimating];
	}
	return cell;
}


-(void)fullScreenPicture:(id)sender {
	
	UITapGestureRecognizer *oldTap = (UITapGestureRecognizer *)sender;
	CGPoint touchedPoint = [oldTap locationInView:self];
	NSIndexPath *indexPath = [self indexPathForItemAtPoint:touchedPoint];
	NSString *fullPathToImage = [_listing.pictures objectAtIndex:indexPath.item];
	UIImage *image = [UIImage imageWithContentsOfFile:fullPathToImage];
	self->fullImageTransform = CGAffineTransformIdentity;
	if (image.size.width > image.size.height) {
		self->fullImageTransform = CGAffineTransformMakeRotation(M_PI/2);
	}
	if (!self->imageFullScreen) {
		self->imageRectInRootView = [self.window convertRect:[oldTap view].bounds fromView:[oldTap view]];
		self->tappedImageView = [oldTap view];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		[imageView setFrame:self->imageRectInRootView];
		imageView.tag = 6;
		UIView *blindView = [[UIView alloc] initWithFrame:self->imageRectInRootView];
		[blindView setBackgroundColor:[UIColor blackColor]];
		blindView.tag = 7;
		[self.window addSubview:blindView];
		[self.window addSubview:imageView];
		[self->tappedImageView setHidden:YES];
		blindView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		[UIView animateWithDuration:0.35 delay:0 options:0 animations:^{
			imageView.transform = self->fullImageTransform;
			blindView.transform = self->fullImageTransform;
			[blindView setFrame:[[UIScreen mainScreen] bounds]];
			[imageView setFrame:[[UIScreen mainScreen] bounds]];
		} completion:^(BOOL finished) {
			((YGLocallyViewController *)self.window.rootViewController)->shouldHideStatusBar = YES;
			[self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
			UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenPicture:)];
			[tap setCancelsTouchesInView:NO];
			[blindView addGestureRecognizer:tap];
			self->imageFullScreen = YES;
		}];
	} else {
		UIView *imageView;
		UIView *blindView;
		for (UIView *subview in [self.window subviews]) {
			if (subview.tag == 6) {
				imageView = subview;
			} else if (subview.tag == 7) blindView = subview;
		}
		((YGLocallyViewController *)self.window.rootViewController)->shouldHideStatusBar = NO;
		[self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
		if (!CGAffineTransformIsIdentity(self->fullImageTransform)) {
			[UIView animateWithDuration:0.35 delay:0 options:0 animations:^{
				imageView.transform = CGAffineTransformIdentity;
				blindView.transform = CGAffineTransformIdentity;
				[imageView setFrame:self->imageRectInRootView];
				[blindView setFrame:self->imageRectInRootView];
			} completion:^(BOOL finished){
				[self->tappedImageView setHidden:NO];
				[blindView removeFromSuperview];
				[imageView removeFromSuperview];
				self->imageFullScreen = NO;
			}];
		} else {
			UIImageView *copyImageView = [[UIImageView alloc] initWithImage:((UIImageView *)self->tappedImageView).image];
			[copyImageView setFrame:CGRectMake(0, 2*64, 320, self->tappedImageView.bounds.size.height)];
			[copyImageView setAlpha:0.2f];
			[self.window addSubview:copyImageView];
			[UIView animateWithDuration:0.35 delay:0 options:0 animations:^{
				[imageView setFrame:self->imageRectInRootView];
				[blindView setFrame:self->imageRectInRootView];
				[copyImageView setFrame:self->imageRectInRootView];
				//[blindView setAlpha:0.f];
				[imageView setAlpha:0.f];
				[copyImageView setAlpha:1.f];
				[self->tappedImageView setAlpha:1.f];
			} completion:^(BOOL finished){
				[self->tappedImageView setHidden:NO];
				[copyImageView removeFromSuperview];
				[blindView removeFromSuperview];
				[imageView removeFromSuperview];
				self->imageFullScreen = NO;
			}];
		}
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

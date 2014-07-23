//
//  YGDetailItemController.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 03/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

@class ListingRecord;

#import <UIKit/UIKit.h>
#import "YGUserInfo.h"
#import "YGWebService.h"

@interface YGDetailItemController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate, UIAlertViewDelegate, WebServiceDelegate> {
	@private
	NSNumberFormatter *priceFormatter;
	YGUserInfo *userInfo;
	NSString *listingOwnerModeText;
	YGUser *buyer;
	BOOL imageFullScreen;
	CGAffineTransform fullImageTransform;
	bool shouldHideStatusBar;
	CGRect imageRectInRootView;
	UIView *tappedImageView;
}

@property (strong, nonatomic) IBOutlet UIView *purchaseContainer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *payButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *telephoneButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pinButton;

- (IBAction)purchaseItem:(id)sender;
- (IBAction)contactSeller:(id)sender;
- (IBAction)callSeller:(id)sender;
- (IBAction)showDirections:(id)sender;
- (IBAction)pinItem:(id)sender;

@property (nonatomic) BOOL previewing;
@property (nonatomic) NSNumber *buyerId;

@property (nonatomic, strong) ListingRecord *listing;
@property (strong, nonatomic) UICollectionView *carousel;

@end

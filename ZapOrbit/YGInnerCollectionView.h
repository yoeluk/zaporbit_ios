//
//  YGInnerCollectionView.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 03/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingRecord.h"

@interface YGInnerCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate> {
	@public
	int numberOfItems;
	int itemIndex;
	int _currentPage;
	BOOL imageFullScreen;
	CGAffineTransform fullImageTransform;
	CGRect imageRectInRootView;
	UIView *tappedImageView;
}


+(YGInnerCollectionView *)collectionViewWithListing:(ListingRecord *)listing withFrame:(CGRect)rect;

@property(strong, nonatomic) ListingRecord *listing;

@end

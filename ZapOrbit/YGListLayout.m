//
//  YGListLayout.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 04/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGListLayout.h"

@implementation YGListLayout

- (CGSize)collectionViewContentSize {
	CGSize size = [super collectionViewContentSize];
	return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
	
	return attrs;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	
	return attrs;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return YES;
}

@end

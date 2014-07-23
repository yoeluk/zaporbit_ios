//
//  YGScrollViewCopiable.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 25/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGScrollViewCopiable.h"

@implementation YGScrollViewCopiable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)copyWithZone:(NSZone *)zone {
	YGScrollViewCopiable *scrollView = [[YGScrollViewCopiable allocWithZone:zone] initWithFrame:self.frame];
	[scrollView addSubview:[self.subviews objectAtIndex:0]];
	scrollView.tag = 10;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.pagingEnabled = YES;
	scrollView.scrollEnabled = YES;
	scrollView.userInteractionEnabled = YES;
	return scrollView;
}

@end

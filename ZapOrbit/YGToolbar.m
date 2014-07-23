//
//  YGToolbar.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 11/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGToolbar.h"

@implementation YGToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		[self configure];
    }
    return self;
}

+(YGToolbar *)initWithFrame:(CGRect)frame andButtonTitles:(NSArray *)titles {
	YGToolbar *selfToolBar = [[YGToolbar alloc] initWithFrame:frame];
	[selfToolBar addButtons:titles];
	return selfToolBar;
}

-(void)configure {
	//CGRect frame = self.frame;
	
}

-(void)addButtons:(NSArray *)titles {
	
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

//
//  YGTileView.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 06/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGTileView.h"

@implementation YGTileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configure];
	}
	return self;
}

-(void)configure {
	self.layer.cornerRadius = 2;
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

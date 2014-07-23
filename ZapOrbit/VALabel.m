//
//  VALabel.m
//
//  Created by Tom Parry on 23/07/13.
//  Copyright (c) 2013 b2cloud. All rights reserved.
//

#import "VALabel.h"

@implementation VALabel

@synthesize verticalAlignment;

-(id)initWithCoder:(NSCoder *)aCoder {
	self = [super initWithCoder:aCoder];
	if (self) {
		[self configure];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self configure];
    }
    return self;
}

-(void)configure {
	self.numberOfLines = 0;
	[self setVerticalAlignment:UIControlContentVerticalAlignmentTop];
}

- (void) drawTextInRect:(CGRect)rect {
	if(verticalAlignment == UIControlContentVerticalAlignmentTop ||
	   verticalAlignment == UIControlContentVerticalAlignmentBottom) {
		
		//	If one line, we can just use the lineHeight, faster than querying sizeThatFits
		const CGFloat height = ((self.numberOfLines == 1) ? ceilf(self.font.lineHeight) : [self sizeThatFits:self.frame.size].height);
		
		rect.origin.y = ((self.frame.size.height - height) / 2.0f) * ((verticalAlignment == UIControlContentVerticalAlignmentTop) ? -1.0f : 1.0f);
	}
	[super drawTextInRect:rect];
}

- (void) setVerticalAlignment:(UIControlContentVerticalAlignment)_verticalAlignment {
	verticalAlignment = _verticalAlignment;
	[self setNeedsDisplay];
}

@end

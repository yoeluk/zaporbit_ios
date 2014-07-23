//
//  YGPriceView.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 15/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGPriceView.h"

@implementation YGPriceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		// [self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void) setPrice:(NSString *)price {
	UILabel *priceLabel = (UILabel *)[self viewWithTag:10];
	if (!priceLabel) {
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.frame.size.width, self.frame.size.height)];
		[priceLabel setText:price];
		[priceLabel setTextColor:[UIColor whiteColor]];
		[priceLabel setFont:[UIFont systemFontOfSize:13]];
		[priceLabel setTag:10];
		[self addSubview:priceLabel];
	} else {
		[priceLabel setText:price];
	}
}


- (void)drawRect:(CGRect)rect {
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(rect.origin.x, rect.origin.y+rect.size.height/2)];
	[path addLineToPoint:CGPointMake(rect.origin.x+rect.size.height/2-2, rect.origin.y)];
	[path addLineToPoint:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y)];
	[path addLineToPoint:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height)];
	[path addLineToPoint:CGPointMake(rect.origin.x+rect.size.height/2-2, rect.origin.y+rect.size.height)];
	[path closePath];
	[[UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1] set];
	// [[UIColor colorWithRed:230/255.f green:213/255.f blue:25/255.f alpha:1] set];
	[path fill];
	self.layer.shadowColor = [UIColor whiteColor].CGColor;
	self.layer.shadowRadius = 2;
	self.layer.shadowOpacity = 0.8;
	self.layer.shadowOffset = CGSizeZero;
	self.layer.shadowPath = path.CGPath;
	self.layer.shouldRasterize = YES;
	/*
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGColorRef color = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
	//CGColorRef color = [UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1].CGColor;
	CGContextSetFillColorWithColor(c, color);
	CGContextSetStrokeColorWithColor(c, color);
	CGContextSetLineJoin(c, kCGLineJoinRound);
	CGContextSetLineCap(c, kCGLineCapRound);
	CGContextAddPath(c, path.CGPath);
	CGContextStrokePath(c);
	CGContextAddPath(c, path.CGPath);
	CGContextFillPath(c);
	 */
	// [super drawRect:rect];
}

@end

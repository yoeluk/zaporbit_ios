//
//  YGOvalView.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 24/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGOvalView.h"

@implementation YGOvalView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
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
	self.backgroundColor = [UIColor clearColor];
	UIImageView *picView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"profile-placeholder2"] imageWithTintColor:[UIColor colorWithRed:148/255.f green:184/255.f blue:221/255.f alpha:1]]];
	picView.tag = 55;
	picView.contentMode = UIViewContentModeScaleAspectFit;
	[picView setFrame:CGRectMake(0, 5, self.frame.size.width, self.frame.size.height)];
	[self addSubview:picView];
}

-(void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CAShapeLayer *shapeMask = [CAShapeLayer layer];
	//UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2.0, 2.0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
	//CGRect ovalRect = CGRectMake(2.0, 2.0, CGRectGetWidth(rect), CGRectGetHeight(rect));
	//CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) (3.14/4));
	//CGPathRef path = CGPathCreateWithEllipseInRect(ovalRect, &transform);
	shapeMask.path = CGPathCreateWithEllipseInRect(rect, &CGAffineTransformIdentity);
	[self.layer setMask:shapeMask];
	//CGPathRelease(path);
}

@end

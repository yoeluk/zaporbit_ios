//
//  YGRatingView.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 09/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGRatingView.h"

@implementation YGRatingView

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configure:self.frame];
	}
	return self;
}

- (id)initWithFrame:(CGRect)aRect {
	self = [super initWithFrame:aRect];
	if (self) {
		[self configure:aRect];
	}
	return self;
}

-(void)configure:(CGRect)aRect {
	if (aRect.size.width >= 150 && aRect.size.height >= 50) {
		CGRect rect = CGRectMake(0, 0, 150, 21);
		self.ratingView = [[DPMeterView alloc] init];
		[self.ratingView setFrame:rect];
		[self.ratingView setMeterType:DPMeterTypeLinearHorizontal];
		[self.ratingView setTrackTintColor:[UIColor lightGrayColor]];
		[self.ratingView setProgressTintColor:[UIColor orangeColor]];
		[self.ratingView setShape:[UIBezierPath stars:5 shapeInFrame:self.ratingView.bounds].CGPath];
		self.ratingView.tag = 25;
		[self addSubview:self.ratingView];
		
		rect = CGRectMake(0, 25, 150, 21);
		self.ratingLabel = [[UILabel alloc] initWithFrame:rect];
		self.ratingLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		self.ratingLabel.textAlignment = NSTextAlignmentCenter;
		self.ratingLabel.tag = 30;
		[self addSubview:self.ratingLabel];
	} else {
		CGRect rect = CGRectMake(0, 0, 100, 15);
		self.ratingView = [[DPMeterView alloc] init];
		[self.ratingView setFrame:rect];
		[self.ratingView setMeterType:DPMeterTypeLinearHorizontal];
		[self.ratingView setTrackTintColor:[UIColor lightGrayColor]];
		[self.ratingView setProgressTintColor:[UIColor orangeColor]];
		[self.ratingView setShape:[UIBezierPath stars:5 shapeInFrame:self.ratingView.bounds].CGPath];
		self.ratingView.tag = 25;
		[self addSubview:self.ratingView];
		
		rect = CGRectMake(0, 20, 100, 15);
		self.ratingLabel = [[UILabel alloc] initWithFrame:rect];
		self.ratingLabel.font = [UIFont systemFontOfSize:12];
		//self.ratingLabel.textColor = [UIColor grayColor];
		//self.ratingLabel.shadowColor = [UIColor whiteColor];
		//self.ratingLabel.shadowOffset = CGSizeMake(0, 1);
		self.ratingLabel.textAlignment = NSTextAlignmentCenter;
		self.ratingLabel.tag = 30;
		[self addSubview:self.ratingLabel];
	}
}

-(void)setRatingTintColor:(UIColor *)color {
	[self.ratingView setProgressTintColor:color];
}

-(void)setRatingTrackColor:(UIColor *)color {
	[self.ratingView setTrackTintColor:color];
}

-(void)setRating:(CGFloat)rating animated:(BOOL)animated {
	[self.ratingView setProgress:rating animated:animated];
}

-(void)setRatingText:(NSString *)ratingText {
	[self.ratingLabel setText:[NSString stringWithFormat:@"~ %@ ~", ratingText]];
}

@end

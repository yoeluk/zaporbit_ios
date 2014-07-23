//
//  YGStarRateView.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 02/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGStarRateView.h"

@implementation YGStarRateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self configure];
    }
    return self;
}

-(NSNumber *)rating {
	return _rating ? _rating : @1;
}

-(void)configure {
	
	float separation = 47;
	
	self->firstStar = [UIButton buttonWithType:UIButtonTypeCustom];
	[self->firstStar setImage:[[UIImage imageNamed:@"726-star"] imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
	[self->firstStar setImage:[[UIImage imageNamed:@"726-star-selected"] imageWithTintColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]] forState:UIControlStateSelected];
	[self->firstStar addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
	self->firstStar.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self->firstStar.tag = 1;
	[self->firstStar setFrame:CGRectMake(0, (self.frame.size.height/2)-11, 50, 22)];
	[self->firstStar setSelected:YES];
	[self addSubview:self->firstStar];
	
	self->secondStar = [UIButton buttonWithType:UIButtonTypeCustom];
	[self->secondStar setImage:[[UIImage imageNamed:@"726-star"] imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
	[self->secondStar setImage:[[UIImage imageNamed:@"726-star-selected"] imageWithTintColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]] forState:UIControlStateSelected];
	[self->secondStar addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
	self->secondStar.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self->secondStar.tag = 2;
	[self->secondStar setFrame:CGRectMake(separation, (self.frame.size.height/2)-11, 50, 22)];
	[self addSubview:self->secondStar];
	
	self->thirdStar = [UIButton buttonWithType:UIButtonTypeCustom];
	[self->thirdStar setImage:[[UIImage imageNamed:@"726-star"] imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
	[self->thirdStar setImage:[[UIImage imageNamed:@"726-star-selected"] imageWithTintColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]] forState:UIControlStateSelected];
	[self->thirdStar addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
	self->thirdStar.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self->thirdStar.tag = 3;
	[self->thirdStar setFrame:CGRectMake(separation*2, (self.frame.size.height/2)-11, 50, 22)];
	[self addSubview:self->thirdStar];
	
	self->forthStar = [UIButton buttonWithType:UIButtonTypeCustom];
	[self->forthStar setImage:[[UIImage imageNamed:@"726-star"] imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
	[self->forthStar setImage:[[UIImage imageNamed:@"726-star-selected"] imageWithTintColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]] forState:UIControlStateSelected];
	[self->forthStar addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
	self->forthStar.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self->forthStar.tag = 4;
	[self->forthStar setFrame:CGRectMake(separation*3, (self.frame.size.height/2)-11, 50, 22)];
	[self addSubview:self->forthStar];
	
	self->fifthStar = [UIButton buttonWithType:UIButtonTypeCustom];
	[self->fifthStar setImage:[[UIImage imageNamed:@"726-star"] imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
	[self->fifthStar setImage:[[UIImage imageNamed:@"726-star-selected"] imageWithTintColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]] forState:UIControlStateSelected];
	[self->fifthStar addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
	self->fifthStar.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self->fifthStar.tag = 5;
	[self->fifthStar setFrame:CGRectMake(separation*4, (self.frame.size.height/2)-11, 50, 22)];
	[self addSubview:self->fifthStar];
}

-(void)starAction:(UIButton *)sender {
	self.rating = @1;
	for (UIButton *star in self.subviews) {
		if (star.tag <= sender.tag) {
			[star setSelected:YES];
			if ([self.rating integerValue] < star.tag) self.rating = [NSNumber numberWithInt:(int)star.tag];
		} else {
			[star setSelected:NO];
		}
	}
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

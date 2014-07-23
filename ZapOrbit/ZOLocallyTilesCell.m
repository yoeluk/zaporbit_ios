//
//  ZOLocallyTilesCell.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 02/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "ZOLocallyTilesCell.h"

@implementation ZOLocallyTilesCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		CALayer *bottomBorder = [CALayer layer];
		bottomBorder.frame = CGRectMake(2.0f, 153.f, 148.5, 0.5f);
		bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
		
		UIView *frameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 152.5, 152.5)];
		frameView.backgroundColor = [UIColor whiteColor];
		frameView.tag = 23;
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 148.5, 148.5)];
		imageView.tag = 15;
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 158.f, 60, 18)];
		timeLabel.textColor = [UIColor colorWithRed:127/255.f green:127/255.f blue:127/255.f alpha:1];
		timeLabel.font = [UIFont systemFontOfSize:13];
		timeLabel.textAlignment = NSTextAlignmentLeft;
		timeLabel.tag = 20;
		
		UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(69, 158.f, 80, 18)];
		priceLabel.textColor = [UIColor colorWithRed:0 green:112/255.f blue:1 alpha:1];
		priceLabel.font = [UIFont italicSystemFontOfSize:13];
		priceLabel.textAlignment = NSTextAlignmentRight;
		priceLabel.tag = 25;
		
		[self.contentView addSubview:priceLabel];
		[self.contentView addSubview:timeLabel];
		[self.contentView addSubview:frameView];
		[self.contentView addSubview:imageView];
		[self.contentView.layer addSublayer:bottomBorder];
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

@end

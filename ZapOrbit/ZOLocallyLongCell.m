//
//  ZOLocallyLongCell.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 02/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "ZOLocallyLongCell.h"
#import "VALabel.h"

@implementation ZOLocallyLongCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		float height = frame.size.height;
		VALabel *titleLabel = [[VALabel alloc] initWithFrame:CGRectMake(height+1, 5, 150, 65)];
		[titleLabel setVerticalAlignment:UIControlContentVerticalAlignmentTop];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.font = [UIFont systemFontOfSize:13];
		titleLabel.numberOfLines = 4;
		titleLabel.tag = 10;
		
		CALayer *separator = [CALayer layer];
		separator.frame = CGRectMake(80.0f, self.frame.size.height-0.5f, self.frame.size.width, 0.5f);
		separator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, height-4, height-4)];
		imageView.tag = 15;
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(218, 67, 95, 18)];
		timeLabel.textColor = [UIColor colorWithRed:127/255.f green:127/255.f blue:127/255.f alpha:1];
		timeLabel.font = [UIFont systemFontOfSize:12];
		timeLabel.textAlignment = NSTextAlignmentRight;
		timeLabel.tag = 20;
		
		[self.contentView addSubview:timeLabel];
		[self.contentView addSubview:imageView];
		[self.contentView addSubview:titleLabel];
		[self.contentView.layer addSublayer:separator];
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

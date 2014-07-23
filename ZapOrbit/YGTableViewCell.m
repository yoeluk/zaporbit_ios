//
//  YGTableViewCell.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 26/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGTableViewCell.h"
#import "VALabel.h"

@implementation YGTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configureCell];
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		[self configureCell];
    }
    return self;
}

-(void)configureCell {
	CALayer *topBorder = [CALayer layer];
	topBorder.frame = CGRectMake(0.0f, 0.0f, self.contentView.frame.size.width, 0.5f);
	topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
	[self.contentView.layer addSublayer:topBorder];
	VALabel *titleLabel = [[VALabel alloc] initWithFrame:CGRectMake(90, 7, 160, 51)];
	titleLabel.font = [UIFont boldSystemFontOfSize:14];
	[titleLabel setVerticalAlignment:UIControlContentVerticalAlignmentTop];
	titleLabel.textColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1];
	titleLabel.tag = 20;
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
	imageView.tag = 10;
	[self.contentView addSubview:imageView];
	[self.contentView addSubview:titleLabel];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

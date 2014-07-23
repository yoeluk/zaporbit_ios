//
//  YGDetailTitleCell.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 07/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGDetailTitleCell.h"
#import "VALabel.h"

@implementation YGDetailTitleCell

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
	VALabel *titleLabel = [[VALabel alloc] initWithFrame:CGRectMake(15, 5, 285, 35)];
	titleLabel.font = [UIFont boldSystemFontOfSize:14];
	titleLabel.textColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1];
	titleLabel.tag = 20;
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

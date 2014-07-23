//
//  YGMyListingCell.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 30/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGMyListingCell.h"

@implementation YGMyListingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)didTransitionToState:(UITableViewCellStateMask)state {
	[super didTransitionToState:state];
	UIView *priceView = (UIView *)[self.contentView viewWithTag:40];
	UIView *shareButton = (UIView *)[self.contentView viewWithTag:13];
	if (self->aState != state && state == UITableViewCellStateShowingEditControlMask) {
		self->aState = state;
		priceView.hidden = YES;
		shareButton.hidden = YES;
	} else if (self->aState != state && (aState == UITableViewCellStateShowingEditControlMask || aState == 3) && state == UITableViewCellStateDefaultMask) {
		priceView.hidden = NO;
		shareButton.hidden = NO;
	}
	self->aState = state;
}

@end

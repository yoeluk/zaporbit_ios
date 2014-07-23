//
//  YGMesaagesCell.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 30/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGMesaagesCell.h"

@implementation YGMesaagesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
	[super didTransitionToState:state];
    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
		self->aState = state;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"swipeToDeleteDetected" object:nil];
    } else if (self->aState && aState == UITableViewCellStateShowingDeleteConfirmationMask && state == UITableViewCellStateDefaultMask) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"endedSwipeToDeleteDetected" object:nil];
	} else self->aState = 0;
}

@end

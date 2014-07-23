//
//  YGCarruselView.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 17/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGCarruselView.h"

@implementation YGCarruselView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setPictures:(NSArray *)pictures{
	_pictures = pictures;
	[self configure];
}

-(void)setGestureRecognizerDelegate:(id)gestureRecognizerDelegate {
	_gestureRecognizerDelegate = gestureRecognizerDelegate;
}

-(void)setTarget:(id)target {
	_target = target;
}

-(void)configure {
	if (![self findSubview:self  tag:20]) {
		_pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 100)];
		_pictureView.tag = 20;
		_pictureView.contentMode = UIViewContentModeScaleAspectFit;
		[_pictureView setImage : _pictures.count ? (UIImage *)_pictures[0] : [[UIImage imageNamed:@"1396037708_add_photo"] imageWithTintColor:[UIColor lightGrayColor]]];
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_target action:@selector(getPicture:)];
		[tap setCancelsTouchesInView:NO];
		[_pictureView addGestureRecognizer:tap];
		_pictureView.userInteractionEnabled = YES;
		[self addSubview:_pictureView];
	} else {
		UIImageView *picView = (UIImageView *)[self findSubview:self tag:20];
		[picView setImage : _pictures.count ? (UIImage *)_pictures[0] : [UIImage imageWithColor:[UIColor colorWithWhite:0.5 alpha:1]]];
	}
}

-(UIView *)findSubview:(UIView *)view tag:(int)tag {
	UIView *subviewWithTag;
	for (UIView *subview in view.subviews) {
		if (subview.tag == tag) {
			subviewWithTag = subview;
		}
	}
	return subviewWithTag;
}

-(void)getPicture:(id)sender {
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

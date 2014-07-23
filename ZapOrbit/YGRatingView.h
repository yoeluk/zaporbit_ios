//
//  YGRatingView.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 09/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPMeterView.h"
#import "UIBezierPath+BasicShapes.h"

@interface YGRatingView : UIView

@property (strong, nonatomic) DPMeterView *ratingView;
@property (strong, nonatomic) UILabel *ratingLabel;

-(void)setRating:(CGFloat)rating animated:(BOOL)animated;
-(void)setRatingText:(NSString *)ratingText;
-(void)setRatingTintColor:(UIColor *)color;
-(void)setRatingTrackColor:(UIColor *)color;

@end

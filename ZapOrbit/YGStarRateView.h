//
//  YGStarRateView.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 02/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGAppDelegate.h"

@interface YGStarRateView : UIView {
	@private
	UIButton *firstStar;
	UIButton *secondStar;
	UIButton *thirdStar;
	UIButton *forthStar;
	UIButton *fifthStar;
}

@property(strong, nonatomic) NSNumber *rating;

@end

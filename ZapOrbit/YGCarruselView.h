//
//  YGCarruselView.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 17/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGAppDelegate.h"

@interface YGCarruselView : UIView

@property(nonatomic) NSArray *pictures;
@property(nonatomic) UIImageView *pictureView;
@property(nonatomic) id gestureRecognizerDelegate;
@property(nonatomic) id target;

@end

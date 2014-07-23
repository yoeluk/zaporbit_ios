//
//  YGImage.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 29/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGImage.h"

@implementation YGImage

- (id) copyWithZone: (NSZone *) zone {
    return [[UIImage allocWithZone: zone] initWithCGImage: self.CGImage];
}

@end

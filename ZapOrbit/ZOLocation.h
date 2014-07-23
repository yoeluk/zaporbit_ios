//
//  ZOLocation.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 31/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ZOLocation : NSObject <NSCoding>

@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;
@property (nonatomic) NSString *street;
@property (nonatomic) NSString *locality;
@property (nonatomic) NSString *administrativeArea;

+(ZOLocation *)locationWithDictionary:(NSDictionary *)locationDictionary;
+(NSMutableDictionary *)dictionaryWithLocation:(ZOLocation *)location;
+(ZOLocation *)locationWithCLLocation:(CLLocation *)location;

@end

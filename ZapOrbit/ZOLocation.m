//
//  ZOLocation.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 31/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "ZOLocation.h"

@implementation ZOLocation

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self) {
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
		self.street = [decoder decodeObjectForKey:@"street"];
		self.locality = [decoder decodeObjectForKey:@"locality"];
		self.administrativeArea = [decoder decodeObjectForKey:@"administrativeArea"];
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.longitude forKey:@"longitude"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.street forKey:@"street"];
	[encoder encodeObject:self.locality forKey:@"locality"];
	[encoder encodeObject:self.administrativeArea forKey:@"administrativeArea"];
}

+(ZOLocation *)locationWithDictionary:(NSDictionary *)locationDictionary {
	ZOLocation *newLocation = [[ZOLocation alloc] init];
	newLocation.locality = [locationDictionary objectForKey:@"locality"];
	newLocation.street = [locationDictionary objectForKey:@"street"];
	newLocation.latitude = [locationDictionary objectForKey:@"latitude"];
	newLocation.longitude = [locationDictionary objectForKey:@"longitude"];
	newLocation.administrativeArea = [locationDictionary objectForKeyedSubscript:@"administrativeArea"];
	return newLocation;
}

+(NSMutableDictionary *)dictionaryWithLocation:(ZOLocation *)location {
	NSMutableDictionary *locDictionary = [[NSMutableDictionary alloc] init];
	[locDictionary setObject:location.street forKey:@"street"];
	[locDictionary setObject:location.locality forKey:@"locality"];
	[locDictionary setObject:location.latitude forKey:@"latitude"];
	[locDictionary setObject:location.longitude forKey:@"longitude"];
	[locDictionary setObject:location.administrativeArea forKey:@"administrativeArea"];
	return locDictionary;
}
+(ZOLocation *)locationWithCLLocation:(CLLocation *)location {
	ZOLocation *newLocation = [[ZOLocation alloc] init];
	newLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
	newLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
	return newLocation;
}

@end
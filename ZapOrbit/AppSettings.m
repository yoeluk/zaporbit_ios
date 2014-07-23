//
//  AppSettings.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 31/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self) {
		self.defaultLocation = [decoder decodeObjectForKey:@"defaultLocation"];
		self.searchRadius = [decoder decodeObjectForKey:@"searchRadius"];
		self.dataRetrievalDate = [decoder decodeObjectForKey:@"dataRetrievalDate"];
		self.searchHistory = [decoder decodeObjectForKey:@"searchHistory"];
		if (!self.searchHistory) self.searchHistory = [[NSMutableArray alloc] init];
		self.sellerIdentifier = [decoder decodeObjectForKey:@"sellerIdentifier"];
		self.sellerSecret = [decoder decodeObjectForKey:@"sellerSecret"];
		self.followingFriends = [decoder decodeObjectForKey:@"followingFriends"];
		if (!self.followingFriends) self.followingFriends = [NSMutableArray new];
		self.logmeOut = [decoder decodeObjectForKey:@"logmeOut"];
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.defaultLocation forKey:@"defaultLocation"];
	[encoder encodeObject:self.searchRadius forKey:@"searchRadius"];
	[encoder encodeObject:self.dataRetrievalDate forKey:@"dataRetrievalDate"];
	[encoder encodeObject:self.searchHistory forKey:@"searchHistory"];
	[encoder encodeObject:self.sellerIdentifier forKey:@"sellerIdentifier"];
	[encoder encodeObject:self.sellerSecret forKey:@"sellerSecret"];
	[encoder encodeObject:self.followingFriends forKey:@"followingFriends"];
	[encoder encodeObject:self.logmeOut forKey:@"logmeOut"];
}

@end

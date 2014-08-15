//
//  YGUser.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 21/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGUser.h"

@implementation YGUser

-(NSString *)fullName {
	return [NSString stringWithFormat:@"%@ %@", self.name, self.surname];
	
}

+(YGUser *)userWithDictionary:(NSDictionary *)locationDictionary {
	YGUser *newUser = [[YGUser alloc] init];
	newUser.id = [locationDictionary[@"id"] integerValue];
	newUser.name = locationDictionary[@"name"];
	newUser.surname = locationDictionary[@"surname"];
	newUser.fbuserid = locationDictionary[@"fbuserid"];
	newUser.email = locationDictionary[@"email"];
	newUser.isMerchant = locationDictionary[@"isMerchant"];
	return newUser;
}

@end

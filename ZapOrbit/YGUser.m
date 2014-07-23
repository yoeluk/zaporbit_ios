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
	newUser.id = [[locationDictionary objectForKey:@"id"] integerValue];
	newUser.name = [locationDictionary objectForKey:@"name"];
	newUser.surname = [locationDictionary objectForKey:@"surname"];
	newUser.fbuserid = [locationDictionary objectForKey:@"fbuserid"];
	newUser.email = [locationDictionary objectForKey:@"email"];
	newUser.isMerchant = [locationDictionary objectForKey:@"isMerchant"];
	return newUser;
}

@end

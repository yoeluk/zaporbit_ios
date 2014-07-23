//
//  YGUser.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 21/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGImage.h"

@interface YGUser : NSObject

@property (nonatomic, strong) UIImageView *profilePicView;

@property (nonatomic) NSInteger id;
@property (nonatomic) NSNumber *fbuserid;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *fullName;
@property (retain, nonatomic) NSString *middle_name;
@property (retain, nonatomic) NSString *surname;
@property (retain, nonatomic) NSString *link;
@property (retain, nonatomic) NSString *username;
@property (retain, nonatomic) NSString *birthday;
@property (retain, nonatomic) NSString *email;
@property (retain, nonatomic) NSNumber *isMerchant;
@property (retain, nonatomic) NSCache *picCache;
@property (retain, nonatomic) NSMutableDictionary *location;

+(YGUser *)userWithDictionary:(NSDictionary *)locationDictionary;

@end

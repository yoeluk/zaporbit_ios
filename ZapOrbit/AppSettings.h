//
//  AppSettings.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 31/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOLocation.h"

@interface AppSettings : NSObject <NSCoding>

@property (retain, nonatomic) ZOLocation *defaultLocation;
@property (retain, nonatomic) NSNumber *searchRadius;
@property (retain, nonatomic) NSDate *dataRetrievalDate;
@property (retain, nonatomic) NSMutableArray *searchHistory;
@property (retain, nonatomic) NSString *sellerIdentifier;
@property (retain, nonatomic) NSString *sellerSecret;
@property (retain, nonatomic) NSMutableArray *followingFriends;
@property (retain, nonatomic) NSNumber *logmeOut;
@end

//
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 14/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "ZOLocation.h"
#import "YGUser.h"
#import "YGPicturesDownloader.h"
#import "ImageDownloader.h"

@interface ListingRecord : NSObject {
	@public
	NSInteger index;
}

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *pic;
@property (atomic, copy) NSString *description;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *currency_code;
@property (nonatomic, strong) NSMutableArray *pictureNames;
@property (nonatomic, strong) NSMutableArray *pictures;
@property (nonatomic, strong) NSCache *picturesCache;
@property (nonatomic, strong) NSCache *icons;
@property (nonatomic, strong) NSString *shop;
@property (nonatomic, strong) NSString *updated_on;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) YGPicturesDownloader *picturesDownloader;
@property (nonatomic, strong) ImageDownloader *imageDownloader;
@property (nonatomic) NSNumber *fbuserid;
@property (nonatomic) NSInteger userid;
@property (nonatomic, strong) YGUser *user;
@property (assign) BOOL highlight;
@property (assign) BOOL waggle;

@end
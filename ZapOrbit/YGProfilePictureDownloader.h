//
//  YGProfilePicDownloader.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 03/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGUser.h"
#import "YGImage.h"

@interface YGProfilePictureDownloader : NSObject

@property (nonatomic, strong) YGUser *user;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) UIView *profilePictureSuperView;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload:(NSNumber *)fbuserid;
- (void)cancelDownload;

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;

@end

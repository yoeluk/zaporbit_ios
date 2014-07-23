//
//  YGPicturesDownloader.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 29/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListingRecord;

@interface YGPicturesDownloader : NSObject 

@property (nonatomic, strong) ListingRecord *listing;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, copy) void (^completionHandler)(void);

@property (nonatomic, strong) NSURLConnection *imageConnection;

- (void)startDownload:(int)indx;
- (void)cancelDownload;

@end

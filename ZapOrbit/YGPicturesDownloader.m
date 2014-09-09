//
//  YGPicturesDownloader.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 29/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGPicturesDownloader.h"
#import "ListingRecord.h"
#import "YGWebService.h"

@interface YGPicturesDownloader ()
@property (nonatomic, strong) NSMutableData *activeDownload;

@end

@implementation YGPicturesDownloader

-(NSString*)generateRandomString:(int)num {
	NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@*_$";
    NSMutableString *string = [NSMutableString stringWithCapacity:(NSUInteger) num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    return [NSString stringWithFormat:@"%@.png", string];
}

#pragma mark

- (void)startDownload:(int)indx {
	self.activeDownload = [NSMutableData data];
	self.index = @(indx);
	NSString *kBaseApiUrl = [YGWebService baseApiUrl];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@downloadpictures/%@", kBaseApiUrl, self.listing.pictureNames[(NSUInteger) indx]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection = conn;
}

- (void)cancelDownload {
	[self.imageConnection cancel];
	self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"downloading failed with error:\n %@", [error userInfo][NSLocalizedFailureReasonErrorKey]);
    self.activeDownload = nil;
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directory = [NSString stringWithFormat:@"%@/listingPictures", paths[0]];
	NSString *fullPath = [NSString stringWithFormat:@"%@/%@", directory, self.listing.pictureNames[(NSUInteger) [self.index integerValue]]];
	
	BOOL isDir = YES;
	NSError *error = nil;
	if(![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
		if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Failed to create directory \"%@\". Error: %@", directory, error);
		}
	}
	
	bool dataWritten = [self.activeDownload writeToFile:fullPath atomically:YES];
	[self.listing.pictures addObject:fullPath];
	if (self.completionHandler && dataWritten)
		self.completionHandler();
	
	self.activeDownload = nil;
	self.imageConnection = nil;
}

@end

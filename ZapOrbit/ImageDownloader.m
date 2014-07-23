//
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 14/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "ImageDownloader.h"
#import "ListingRecord.h"

#define kAppIconSize 70

@interface ImageDownloader ()
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@end


@implementation ImageDownloader

#pragma mark

- (void)startDownload {
	if (self.listing.pictureNames.count && self.listing.pictureNames[0]) {
		self.activeDownload = [NSMutableData data];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://zaporbit.com/api/downloadpictures/%@", self.listing.pictureNames[0]]];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
		// alloc+init and start an NSURLConnection; release on completion/failure
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		self.imageConnection = conn;
	} else {
		[self cancelDownload];
	}
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
    self.activeDownload = nil;
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directory = [NSString stringWithFormat:@"%@/firstPictureForListing", paths[0]];
	NSString *fullPathToImage = [NSString stringWithFormat:@"%@/%@", directory, self.listing.pictureNames[0]];
	BOOL isDir = YES;
	NSError *error = nil;
	if(![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
		if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Failed to create directory \"%@\". Error: %@", directory, error);
		}
	}
	[self.activeDownload writeToFile:fullPathToImage atomically:YES];
	[self.listing.pictures addObject:fullPathToImage];
	
    self.activeDownload = nil;
    self.imageConnection = nil;
    
    if (self.completionHandler)
        self.completionHandler();
}

@end


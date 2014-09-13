//
//  YGProfilePicDownloader.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 03/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGProfilePictureDownloader.h"

@implementation YGProfilePictureDownloader

#pragma mark

- (void)startDownload:(NSString *)fbuserid {
	//self.index = [NSNumber numberWithInt:indx];
    self.activeDownload = [NSMutableData data];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", fbuserid]];
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
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directory = [NSString stringWithFormat:@"%@/profilesPictures", paths[0]];
	NSString *fullPathToImage = [NSString stringWithFormat:@"%@/%@", directory, self.user.fbuserid];
	BOOL isDir = YES;
	NSError *error = nil;
	if(![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
		if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Failed to create directory \"%@\". Error: %@", directory, error);
		}
	}
	
	[self.activeDownload writeToFile:fullPathToImage atomically:YES];
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
	
    // call our delegate and tell it that our icon is ready for display
    if (self.completionHandler)
        self.completionHandler();
}

@end

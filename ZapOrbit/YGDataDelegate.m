//
//  YGDataDelegate.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 31/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGDataDelegate.h"

@interface YGDataDelegate()
@property (nonatomic, strong) NSMutableData *activeDownload;
@end

@implementation YGDataDelegate

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.activeDownload = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (self.completionHandler)
        self.completionHandler();
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		//if ([trustedHosts containsObject:challenge.protectionSpace.host])
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end

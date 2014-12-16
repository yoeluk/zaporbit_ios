//
//  YGWebService.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 19/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGWebService.h"
#import "ListingRecord.h"
#import "RNEncryptor.h"

static NSString *baseUrl = @"https://zaporbit.com/";
//static NSString *baseUrl = @"http://100.0.0.22:9000/";

static NSMutableDictionary *tokenData;

static NSString *password = @"bjmlBqAfiBEQ4oZfaGtI0oMcd5IGkCp";

@implementation YGWebService
@synthesize delegate;
@synthesize kUrlHead;

- (id)init {
    self = [super init];
    if (self) {
		kUrlHead = [NSString stringWithFormat:@"%@%@", baseUrl, @"api/"];
    }
    return self;
}

+ (NSDictionary *)tokenData {
	return tokenData;
}

+ (void)setTokenData:(NSDictionary *)data {
	tokenData = [NSMutableDictionary dictionaryWithDictionary:data];
}

+ (NSString *)baseApiUrl {
	return [NSString stringWithFormat:@"%@%@", baseUrl, @"api/"];;
}

+ (id)initWithDelegate:(id)delegate {
	YGWebService *instance = [[YGWebService alloc] init];
	if (instance) {
		[instance setDelegate:delegate];
	}
	return instance;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
	return NO;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
}

-(NSString *)getTick {
	return [NSString stringWithFormat:@"%llu",(unsigned long long)([[NSDate date] timeIntervalSince1970]*1000000)];
}

-(NSData *)encryptMyBody:(NSData *)myData withPassword:(NSString *)myPassword andTick:(NSString *)myTick {
	NSError *encryptError = nil;
	return [RNEncryptor encryptData:myData withSettings:kRNCryptorAES256Settings password:[NSString stringWithFormat:@"%@%@",myPassword,myTick] error:&encryptError];
}

-(void)addMerchantDataForUser:(NSDictionary *)dictRequest
				  withService:(NSString *)service
					andMethod:(NSString *)method {
	
	NSString *tick = [self getTick];
	
	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?tick=%@", kUrlHead, service, tick]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictRequest options:0 error:&error];
	NSData *encryptedJsonData = [self encryptMyBody:jsonData withPassword:password andTick:tick];
	
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[encryptedJsonData length]];
	
	[request setURL:url];
	[request setHTTPMethod:method];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:encryptedJsonData];
	
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:request
													    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
															//NSLog(@"headers: %@", response);
															if (error == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
																[self.delegate coughRequestedData:data];
															} //else NSLog(@"response: ", response);
														}];
    [dataTask resume];
	
}

-(void)getBillingDataForUser:(NSUInteger)userId {
	NSString *tick = [self getTick];
	
	NSString *sig = [NSString stringWithFormat:@"%@%@", [[NSTimeZone systemTimeZone] name], tick];
	NSData *data = [sig dataUsingEncoding:NSUTF8StringEncoding];
	NSData *encryptedData = [self encryptMyBody:data withPassword:password andTick:tick];
	NSString *encodedString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
	
	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
	NSString *urlString = [NSString stringWithFormat:@"%@getbillingforuser?id=%ld&sig=%@&tick=%@", kUrlHead, (long)userId, encodedString, tick];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[encryptedData length]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:encryptedData];
	
	NSURLSessionDataTask *session = [defaultSession dataTaskWithRequest:request
													  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
														  if (error == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
															  [self.delegate coughRequestedData:data];
														  }
													  }];
	[session resume];
	 
}

-(void)startConversation:(NSDictionary *)dictRequest
			 withService:(NSString *)service
			   andMethod:(NSString *)method {
	
	NSError *RequestError = nil;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictRequest options:0 error:&RequestError];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setValue:tokenData[@"token"] forHTTPHeaderField:@"X-Auth-Token"];
	[request setHTTPBody:jsonData];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if (data) {
								   [self.delegate coughRequestedData:data];
							   } else if (error) NSLog(@"error found: %@", error);
							   if ([(NSHTTPURLResponse *)response statusCode] != 200) NSLog(@"%@", response);
						   }];
	
}

-(void)verifyUser:(NSDictionary *)fbTokenData {
	
	NSError *RequestError = nil;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fbTokenData options:0 error:&RequestError];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", baseUrl, @"auth/api/authenticate/facebook"];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	[request setURL:serverURL];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:jsonData];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
								   //[self.delegate verifyingUserResponse:data];
								   NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
								   if (json && [httpResponse statusCode] == 200) {
									   [YGWebService setTokenData:json];
									   [self getCurrentUser];
								   }
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
							   else NSLog(@"unknow error");
						   }];
	/*
	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
	NSURLSessionDataTask *session = [defaultSession dataTaskWithRequest:request
													  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
														  if ([data length] > 0 && error == nil) {
															  [self.delegate verifyingUserResponse:data];
														  }
														  else if (error) NSLog(@"received error: %@", error);
														  else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
													  }];
	[session resume];
	*/
}

- (void)getCurrentUser {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, @"currentUser"];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	[request setURL:serverURL];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:tokenData[@"token"] forHTTPHeaderField:@"X-Auth-Token"];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
								   //[self.delegate verifyingUserResponse:data];
								   if ([httpResponse statusCode] == 200) {
									   [self.delegate verifyingUserResponse:data];
								   }
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
							   else NSLog(@"unknow error");
						   }];
}

-(void)deletePicture:(NSString *)service
					:(int)index
					:(NSString *)method {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   [self.delegate coughDeletePictureData:data :index];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
						   }];
	
}

-(void)deleteListing:(id)listing
					:(NSString *)service
					:(NSString *)method {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:((ListingRecord *)listing).pictures options:0 error:nil];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setHTTPBody:jsonData];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   [self.delegate deleteListingResponse:data :listing];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
						   }];
}

-(void)getItemsForUser:(NSString *)service
					  :(NSString *)method {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setValue:tokenData[@"token"] forHTTPHeaderField:@"X-Auth-Token"];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   [self.delegate coughRequestedData:data];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
						   }];
}

-(void)filterItemsForLocation:(NSDictionary *)dictRequest
					  service:(NSString *)service
					   method:(NSString *)method {
	
	NSError *RequestError = nil;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSString *encodedUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *serverURL = [NSURL URLWithString:encodedUrl];
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictRequest options:0 error:&RequestError];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:jsonData];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([(NSHTTPURLResponse *)response statusCode] == 200 && [data length] > 0 && error == nil) {
								   [self.delegate coughRequestedData:data];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
							   else NSLog(@"response: %@", response);
						   }];
}

-(void)getItemsForLocation:(NSDictionary *)dictRequest :(NSString *)service :(NSString *)method {
	
	NSError *RequestError = nil;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictRequest options:0 error:&RequestError];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:jsonData];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   [self.delegate coughRequestedData:data];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
						   }];
}

-(void)uploadMorePictures:(id)data
					 :(NSString *)service
					 :(NSString *)method {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setValue:@"image/jpg" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:data];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   [self.delegate coughUpdatingPictures:data];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
						   }];
}

-(void)uploadPictures:(NSData *)data
					 :(NSString *)service
					 :(NSString *)method {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kUrlHead, service];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setValue:length forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"image/jpg" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:data];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if ([data length] > 0 && error == nil) {
								   [self.delegate coughUploadingResponse:data];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
						   }];
	
}

- (void)WSRequest:(id)dictData
				 :(NSString *)service
				 :(NSString *)method {
	
	BOOL isUpdating = [[service substringToIndex:6] isEqualToString:@"update"];
	NSString *tick = [self getTick];
	NSError *RequestError = nil;
	NSDictionary *dictRequest = (NSDictionary *)dictData;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSData *data = [NSJSONSerialization dataWithJSONObject:dictRequest options:0 error:&RequestError];
	NSString *urlString = !isUpdating? [NSString stringWithFormat:@"%@%@", kUrlHead, service] : [NSString stringWithFormat:@"%@%@/%@", kUrlHead, service, tick];
	NSData *jsonData = !isUpdating? data : [self encryptMyBody:data withPassword:password andTick:tick];
	NSURL *serverURL = [NSURL URLWithString:urlString];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
	[request setURL:serverURL];
	[request setHTTPMethod:method];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:jsonData];
	
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   //NSLog(@"update response %@", response);
							   //NSMutableDictionary *dataObj = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
							   //NSLog(@"data response: %@", dataObj);
							   if ([data length] > 0 && error == nil) {
								  
								   if (isUpdating) {
									   [self.delegate coughUpdatingResponse:data];
								   } else
									   [self.delegate coughRequestedData:data];
							   }
							   else if (error) NSLog(@"received error: %@", error);
							   else if (data == nil) NSLog(@"data is nil from %@ ", [response URL]);
						   }];
}

@end

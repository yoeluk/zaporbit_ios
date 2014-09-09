//
//  YGWebService.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 19/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGDataDelegate.h"

// WebService protocol
@protocol WebServiceDelegate <NSObject>
-(void)coughRequestedData:(NSData *)data;
@optional
-(void)coughUpdatingPictures:(NSData *)data;
-(void)coughUpdatingResponse:(NSData *)data;
-(void)coughUploadingResponse:(NSData *)data;
-(void)deleteListingResponse:(NSData *)data :(id)listing;
-(void)verifyingUserResponse:(NSData *)data;
-(void)coughDeletePictureData:(NSData *)data :(int)index;
@end

@interface YGWebService : NSObject

@property (nonatomic, strong) YGDataDelegate *dataDelegate;
@property (nonatomic, weak) id <WebServiceDelegate> delegate;

+ (id)initWithDelegate:(id)delegate;

+ (NSString *)baseApiUrl;

-(void)WSRequest:(id)dictRequest
				:(NSString *)service
				:(NSString *)method;
-(void)uploadPictures:(id)data
					 :(NSString *)service
					 :(NSString *)method;
-(void)getItemsForUser:(NSString *)service
					  :(NSString *)method;
-(void)getItemsForLocation:(NSDictionary *)dictRequest
						  :(NSString *)service
						  :(NSString *)method;
-(void)deleteListing:(id)listing
					:(NSString *)service
					:(NSString *)method;
-(void)deletePicture:(NSString *)service
					:(int)index
					:(NSString *)method;
-(void)verifyUser:(NSDictionary *)dictRequest
				 :(NSString *)service
				 :(NSString *)method;
-(void)uploadMorePictures:(id)data
						 :(NSString *)service
						 :(NSString *)method;
-(void)filterItemsForLocation:(NSDictionary *)dictRequest
					  service:(NSString *)service
					   method:(NSString *)method;
-(void)startConversation:(NSDictionary *)dictRequest
			 withService:(NSString *)service
			   andMethod:(NSString *)method;
-(void)addMerchantDataForUser:(NSDictionary *)dictRequest
				  withService:(NSString *)service
					andMethod:(NSString *)method;

-(void)getBillingDataForUser:(NSUInteger)userId;


@end

//
//  YGUserInfo.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 21/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGUser.h"

@interface YGUserInfo : NSObject 

+ (YGUserInfo *)sharedInstance;

@property (strong, nonatomic) YGUser *user;
@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic) BOOL isProcessingLogin;

@end

//
//  YGUserInfo.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 21/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGUserInfo.h"

static YGUserInfo *_sharedInstance;

@implementation YGUserInfo

- (id)init {
	self = [super init];
	if (self) {
		_user = [[YGUser alloc] init];
	}
	return self;
}

+ (YGUserInfo *) sharedInstance {
	if (!_sharedInstance) {
		_sharedInstance = [[YGUserInfo alloc] init];
	}
	return _sharedInstance;
}

-(void)setUser:(YGUser *)user {
	if (_user != user) {
		_user = user;
	}
}

-(void)setIsLoggedIn:(BOOL)isLoggedIn {
	if (_isLoggedIn != isLoggedIn) {
		_isLoggedIn = isLoggedIn;
	}
}

-(void)setIsProcessingLogin:(BOOL)isProcessingLogin {
	if (_isProcessingLogin != isProcessingLogin) {
		_isProcessingLogin = isProcessingLogin;
	}
}

@end

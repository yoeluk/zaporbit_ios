//
//  YGDataDelegate.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 31/05/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGDataDelegate : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, copy) void (^completionHandler)(void);
@property (nonatomic, strong) NSURLResponse *response;

@end

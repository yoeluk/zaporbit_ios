//
//  YGDirectionServices.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 06/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YGDirectionServices <NSObject>
-(void)coughDirectionData:(NSDictionary *)json;
@end

@interface YGDirectionServices : NSObject

@property (nonatomic, weak) id <YGDirectionServices> delegate;

+ (id)initWithDelegate:(id)delegate;

-(void)requestDirectionsForListing:(NSDictionary *)query;

@end

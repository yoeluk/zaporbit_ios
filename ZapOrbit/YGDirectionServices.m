//
//  YGDirectionServices.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 06/04/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGDirectionServices.h"

@implementation YGDirectionServices {
@private
	BOOL _sensor;
	BOOL _alternatives;
	NSURL *_directionsURL;
	NSArray *_waypoints;
}

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
		//
    }
    return self;
}

static NSString *kWSDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

+ (id)initWithDelegate:(id)delegate {
	YGDirectionServices *instance = [[YGDirectionServices alloc] init];
	if (instance) {
		[instance setDelegate:delegate];
	}
	return instance;
}

-(void)requestDirectionsForListing:(NSDictionary *)query {
	NSArray *waypoints = [query objectForKey:@"waypoints"];
	NSString *origin = [waypoints objectAtIndex:0];
	NSInteger waypointCount = [waypoints count];
	NSInteger destinationPos = waypointCount -1;
	NSString *destination = [waypoints objectAtIndex:destinationPos];
	NSString *sensor = [query objectForKey:@"sensor"];
	NSMutableString *url = [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@",
	 kWSDirectionsURL,origin,destination, sensor];
	if(waypointCount>2) {
		[url appendString:@"&waypoints=optimize:true"];
		NSInteger wpCount = waypointCount-2;
		for(int i=1;i<wpCount;i++){
			[url appendString: @"|"];
			[url appendString:[waypoints objectAtIndex:i]];
		}
	}
    _directionsURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding]];
	[self retrieveDirections];
}

- (void)retrieveDirections {
	NSURLSessionDataTask *session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:_directionsURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if ([(NSHTTPURLResponse *)response statusCode] == 200 && data) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self fetchedData:data];
			});
		} else NSLog(@"no data");
	}];
	[session resume];
}

- (void)fetchedData:(NSData *)data {
	if (data) {
		NSError* error;
		NSDictionary *json = [NSJSONSerialization
							  JSONObjectWithData:data
							  options:kNilOptions
							  error:&error];
		[delegate coughDirectionData:json];
	}
}

@end

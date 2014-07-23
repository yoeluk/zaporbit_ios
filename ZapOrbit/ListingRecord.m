//
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 14/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "ListingRecord.h"

@implementation ListingRecord
@synthesize description;

-(void)setIndex:(NSInteger)newIndex {
	self->index = newIndex;
}

-(NSInteger)index {
	return self->index ? self->index : 0;
}

@end


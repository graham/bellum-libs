//
//  BLAction.m
//  Commodity
//
//  Created by Graham Abbott on 2/19/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import "BLImage.h"

@implementation BLImage

-(void)dealloc {
#ifdef BLTESTING
	NSLog(@"BLImage Dealloc: %@", self);
#endif
    [super dealloc];
}


@end

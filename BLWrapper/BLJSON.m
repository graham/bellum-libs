//
//  BLJSON.m
//  Confection
//
//  Created by Graham Abbott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BLJSON.h"


@implementation BLJSON

@synthesize obj;

-(id)initWithData:(NSData*)data {
    id jsonData = [[CJSONDeserializer deserializer] deserialize:data error:nil];

    if (jsonData == nil) {
        obj = nil;
    } else {
        obj = jsonData;
    }
    [obj retain];
}

-(id)initWithDictionary:(NSDictionary*)d {
    obj = d;
}

-(void)dealloc {
    [super dealloc];
    [obj release];
}

@end

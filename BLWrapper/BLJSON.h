//
//  BLJSON.h
//  Confection
//
//  Created by Graham Abbott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"

@interface BLJSON : NSObject {
    id obj;
}

-(id)initWithData:(NSData*)data;
-(id)initWithDictionary:(NSDictionary*)d;

@property (nonatomic, readwrite, retain) id obj;

@end

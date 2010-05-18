//
//  BLURLOpener.m
//  ESPNFantasy
//
//  Created by Graham Abbott on 8/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLURLOpener.h"


@implementation BLURLOpener

+(BLURLOpener*)sharedInstance {
    if (BL_URLOPENER_INSTANCE == nil) {
        BL_URLOPENER_INSTANCE = [[BLURLOpener alloc] init];
    }
    return BL_URLOPENER_INSTANCE;
}

- (id)init {
    if (self = [super init]) {
        // Get the custom queue object from the app delegate.
        cookieJar = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(BLRequest*)createRequest {
    BLRequest *r = [[BLRequest alloc] init];
    for (NSString *i in cookieJar) {
        [[r cookies] setValue:[cookieJar valueForKey:i] forKey:i];
    }
    [r addDelegate:self withSelector:@selector(downloadComplete:)];
    
    return r;
}

-(void)downloadComplete:(BLRequest*)r {
    NSDictionary *headers = [r.theResponse allHeaderFields];
    NSLog(@"HERE: %@", [headers valueForKey:@"Set-Cookie"]);

    for(NSString *i in headers) {
        NSLog(@"key: %@ value: %@", i, [headers valueForKey:i]);
    }
}

-(void)save {
    NSData *d = [[CJSONSerializer serializer] serializeDictionary:cookieJar];
    [BLCache storeData:d withName:@"COOKIE_JAR" asType:[NSData class] expiresIn:-1];
}
    
-(void)load {
    NSString *s = [BLCache fetchDataWithName:@"COOKIE_JAR" andCall:self withSelector:@selector(doLoad:) asType:[NSData class]];
}

-(void)doLoad:(NSData *)d {
    cookieJar = [[CJSONDeserializer deserializer] deserialize:d error:nil];
}


@end

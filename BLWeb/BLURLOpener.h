//
//  BLURLOpener.h
//  ESPNFantasy
//
//  Created by Graham Abbott on 8/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLRequest.h"
#import "BLCache.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

static id BL_URLOPENER_INSTANCE;

@interface BLURLOpener : NSObject {
    NSMutableDictionary *cookieJar;
}

+(BLURLOpener*)sharedInstance;
-(BLRequest*)createRequest;

-(void)save;
-(void)load;

@end

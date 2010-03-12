//
//  BLCacheObject.h
//  Confection
//
//  Created by Graham Abbott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDatabase.h"
#import "BLRequest.h"
#import "BLCache.h"

@interface BLCacheObject : NSObject {
    NSString *targetURL;

    id delegate;
    SEL selector;

    BOOL forceFresh;
    id theType;
    
    BLRequest *theRequest;
    
}

@property (nonatomic, readwrite, assign) BOOL forceFresh;

-(id)initWithURL:(NSString*)url andDelegate:(id)d withSelector:(SEL)s;
-(id)initWithURL:(NSString*)url andDelegate:(id)d withSelector:(SEL)s asType:(id)theType;
-(BLRequest*)fetch;
-(void)addDataFromRequest:(BLRequest*)r;
-(void)errorDataLoading:(BLRequest*)r;

@end

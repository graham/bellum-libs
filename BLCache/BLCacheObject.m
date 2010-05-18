//
//  BLCacheObject.m
//  Confection
//
//  Created by Graham Abbott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BLCacheObject.h"


@implementation BLCacheObject

@synthesize forceFresh;

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

-(id)initWithURL:(NSString*)url andDelegate:(id)d withSelector:(SEL)s {
    self = [self init];
    
    targetURL = url;
    delegate = d;
    selector = s;
    
    [targetURL retain];
    [d retain];
    
    return self;
}

-(id)initWithURL:(NSString*)url andDelegate:(id)d withSelector:(SEL)s asType:(id)tt {
    self = [self initWithURL:url andDelegate:d withSelector:s];
    
    theType = tt;
    
    return self;
}

-(void)dealloc {
    [super dealloc];
    [targetURL release];
    [delegate release];
}

-(BLRequest*)fetch {
    FMDatabase *db = [BLDatabase getDatabase];
	
    NSString *query = [NSString stringWithFormat:@"select content from bl_cache_storage where name = '%@';", targetURL];
    FMResultSet *rs = [db executeQuery:query];
	
    if ([rs next] && !forceFresh) {
        NSLog(@"Cache hit for %@", targetURL);
        NSData *imageData = [rs dataForColumnIndex:0];
        id image = [[theType alloc] initWithData:imageData];
        
		BLCallback *cb = [[BLCallback alloc] init];
		cb.target = delegate;
		cb.selector = selector;
        //[cb performSelector:@selector(callAndRelease:) withObject:image afterDelay:0.001f];
        [cb call:image];
        [image release];
        [cb release];
		return nil;
    } else {
        NSLog(@"No cache hit going to the web, %@", targetURL);        

		BLCache *ci = [[BLCache alloc] init];
        ci.resourceType = theType;
        
        ci.target = delegate;
        ci.selector = selector;
		
        BLRequest *r = [[BLRequest alloc] init];
        [r setURL:targetURL];
        [r addOnetimeDelegate:ci withSelector:@selector(addDataFromRequest:)];
		[r addErrorDelegate:ci withSelector:@selector(errorDataLoading:)];
        [ci release];
        [r fetch];
		return r;
    }
}


-(void)addDataFromRequest:(BLRequest*)r {
	id image = [[theType alloc] initWithData:[r payload]];
    
    [[self class] storeData:[r payload] withName:r.url asType:[theType description] expiresIn:-1];
    [[r payload] release];
    
    BLCallback *cb = [[BLCallback alloc] init];
    cb.target = delegate;
    cb.selector = selector;
    [cb call:image];
    [image release];
    
    [cb release];
    [r release];
}

-(void)errorDataLoading:(BLRequest*)r {
    BLCallback *cb = [[BLCallback alloc] init];
    cb.target = delegate;
    cb.selector = selector;
    [cb call:nil];
    [cb release];
    [r release];
}

@end

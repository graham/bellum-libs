//
//  BLRequest.m
//  Commodity
//
//  Created by Graham Abbott on 2/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLRequest.h"

@implementation BLRequest

@synthesize markForStop;
@synthesize url;
@synthesize requestType;
@synthesize isComplete;
@synthesize cookies;
@synthesize theRequest;
@synthesize headerFields;
@synthesize expectedLength;
@synthesize receivedData;

- (id)init {
    if (self = [super init]) {
        // Get the custom queue object from the app delegate.
        dargs = [[NSMutableDictionary alloc] init];
        requestType = @"GET";
        isComplete = NO;
		expectedLength = 0;
        
        callbacks = [[NSMutableArray alloc] init];
        errorCallbacks = [[NSMutableArray alloc] init];
        onetimeCallbacks = [[NSMutableArray alloc] init];
        cookies = [[NSMutableArray alloc] init];
        dataChunkCallbacks = [[NSMutableArray alloc] init];
        
        headerFields = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)dataString {
    NSMutableArray *theReturnArgs = [[NSMutableArray alloc] init];
    
    for (NSString *i in dargs) {
        [theReturnArgs addObject: 
         [[NSString alloc] initWithFormat:@"%@=%@", i, [dargs valueForKey:i]]];
    }
    
    return [theReturnArgs componentsJoinedByString:@"&"];
}

- (void)fetch {
    isComplete = NO;
    NSString *newURL = url;
    
    
    if ([requestType isEqual:@"GET"]) {
        if ([dargs count] > 0) {
            newURL = [[NSString alloc] initWithFormat:@"%@?%@", url, [self dataString]];
        } else {
            newURL = [[NSString alloc] initWithFormat:@"%@", url];
        }
    } else {
        newURL = [[NSString alloc] initWithFormat:@"%@", url];
    }
    
    theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:newURL]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:60.0f * 3];
    
    for(NSString *i in headerFields) {
        [theRequest addValue:[headerFields objectForKey:i] forHTTPHeaderField:i];
    }
    
    [theRequest setHTTPMethod:requestType];
    
    if ([cookies count]) {
        for(NSString *i in cookies) {
            [theRequest setValue:i forHTTPHeaderField:@"Cookie"];
        }
    }

    if ([requestType isEqual:@"POST"]) {
        if (httpBody == nil) {
            [theRequest setHTTPBody:[[self dataString] dataUsingEncoding: NSUTF8StringEncoding]];
        } else {
            [theRequest setHTTPBody:httpBody];
        }
    }
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        NSLog(@"Starting %@ Connection To: %@ - %@", requestType, newURL, dargs);
        receivedData = [[NSMutableData data] retain];
    } else {
        [self errorCallback:self];
    }
}

- (void)setHost:(NSString*)h withURL:(NSString*)u {
    url = [[NSString alloc] initWithFormat:@"http://%@%@", h, u];
}

- (void)addUpdateDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [dataChunkCallbacks addObject:cb];
}

- (void)addDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [callbacks addObject:cb];
}

- (void)addErrorDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [errorCallbacks addObject:cb];
}

- (void)addOnetimeDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [onetimeCallbacks addObject:cb];    
}


-(void)setData:(NSString*)s forKey:(NSString*)key {
    [dargs setValue:[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:key];
}

- (void)setPureData:(NSString*)s forKey:(NSString*)key {
    [dargs setValue:s forKey:key];    
}

- (void)setURL:(NSString *)u {
    url = [[NSString alloc] initWithString:u];
}

// UIAlert delegate Methods
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self fetch];
    } else {
        exit(0);
    }
}

// URLConnection DELEGATE methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    theResponse = response;
    expectedLength = response.expectedContentLength;
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    for (BLCallback *i in dataChunkCallbacks) {
        int result = [i call:self];
        if (result == 0) {
            [dataChunkCallbacks removeObject:i];
        }
    }
	if (markForStop) {
		[connection cancel];
	}
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connection release];
    [receivedData release];
    NSLog(@"Connection failed! Error %@ - %@ %@",
		  url,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    [self errorCallback:self];
}

-(void)errorCallback:(id)sender {
    if ([errorCallbacks count] == 0) {
        UIAlertView *myalert = [[UIAlertView alloc]
                                initWithTitle:@"URL Error"
                                message:@"I can't seem to connect to the interwebs."
                                delegate:self
                                cancelButtonTitle:nil otherButtonTitles:@"Retry", @"Quit", nil];
        [myalert show];        
    } else {
        for ( BLCallback *i in errorCallbacks ) {
            id delegate = i.target;
            SEL selector = i.selector;
            
            NSMethodSignature * sig = nil;
            sig = [[delegate class] instanceMethodSignatureForSelector:selector];
            
            NSInvocation * myInvocation = nil;
            myInvocation = [NSInvocation invocationWithMethodSignature:sig];
            [myInvocation setTarget:delegate];
            [myInvocation setSelector:selector];
            
            [myInvocation setArgument:&self atIndex:2];
            
            [myInvocation retainArguments];	
            [myInvocation invoke];        
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    for (BLCallback *i in callbacks) {
        int result = [i call:self];
        if (result == 0) {
            [callbacks removeObject:i];
        }
    }
    
    for (BLCallback *i in onetimeCallbacks) {
        int result = [i call:self];
    }
    
    [onetimeCallbacks removeAllObjects];
    
    // release the connection, and the data object
    [connection release];
    isComplete = YES;
}

-(id)jsonOfData {
    //    NSString *strRep = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    //    
    //    if ([strRep characterAtIndex:0] == '#') {
    //        // We have comments until a blank newline.
    //        NSRange loc = [strRep rangeOfString:@"\n\n"];
    //        strRep = [strRep substringFromIndex:loc.location];
    //    }
    
    id jsonData = [[CJSONDeserializer deserializer] deserialize:receivedData error:nil];
    
    if (jsonData == nil) {
        return nil;
    } else {
        return jsonData;
    }
}

-(NSData *)payload {
    return receivedData;
}

-(NSString *)stringPayload {
    NSString *strRep = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [strRep retain];
    return strRep;
}

-(NSDictionary*)headers {
    return [theRequest allHeaderFields];
}

-(void)setHTTPBody:(NSData *)data { 
    httpBody = data;
    [data retain];
}


- (void)dealloc {
	[dargs release];
	[callbacks release];
	[errorCallbacks release];
	[onetimeCallbacks release];
	[cookies release];
	[dataChunkCallbacks release];
	[headerFields release];
	
    [super dealloc];
}
@end

//
//  BLRequest.m
//  Commodity
//
//  Created by Graham Abbott on 2/14/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
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
@synthesize theResponse;

- (id)init {
    if (self = [super init]) {
        // Get the custom queue object from the app delegate.
        dargs = [[NSMutableDictionary alloc] init];
        requestType = @"GET";
        isComplete = NO;
		expectedLength = 0;

        receivedData = [[NSMutableData alloc] init];
        [receivedData retain];

        theAction = [[BLAction alloc] init];
        updateAction = [[BLAction alloc] init];
        cookies = [[NSMutableArray alloc] init];
        headerFields = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)initWithURL:(NSString *)s {
    if (self = [self init]) {
        url = s;
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

-(void)startNextFetch {
    currentRequestsActive--;
    if (CONCURRENT_REQUESTS_ENABLED) {    
        if (BLREQUEST_REQUEST_QUEUE == nil) {
            BLREQUEST_REQUEST_QUEUE = [[NSMutableArray alloc] init];
        }

        if (currentRequestsActive >= MAX_CONCURRENT_REQUESTS) {

        } else {
            if ([BLREQUEST_REQUEST_QUEUE count]) {
                BLRequest *nextRequest = [BLREQUEST_REQUEST_QUEUE lastObject];
                [nextRequest beginFetch];
                [BLREQUEST_REQUEST_QUEUE removeLastObject];
            }
        }    
    }
}

- (void)fetch {
    if (CONCURRENT_REQUESTS_ENABLED) {
        if (BLREQUEST_REQUEST_QUEUE == nil) {
            BLREQUEST_REQUEST_QUEUE = [[NSMutableArray alloc] init];
        }

        [BLREQUEST_REQUEST_QUEUE insertObject:self atIndex:0];
        
        if (currentRequestsActive >= MAX_CONCURRENT_REQUESTS) {

        } else {
            if ([BLREQUEST_REQUEST_QUEUE count]) {
                BLRequest *nextRequest = [BLREQUEST_REQUEST_QUEUE lastObject];
                [nextRequest beginFetch];
                [BLREQUEST_REQUEST_QUEUE removeLastObject];
            }
        }
    } else {
        [self beginFetch];
    }
}

-(void)beginFetch {
    currentRequestsActive++;
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

    [theRequest retain];
    
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
    [self retain];
    
    if (theConnection) {
        NSLog(@"Starting %@ Connection To: %@ - %@", requestType, newURL, dargs);
    } else {
        [self errorCallback:self withError:nil];
        [self startNextFetch];
    }
}

- (void)setHost:(NSString*)h withURL:(NSString*)u {
    url = [[NSString alloc] initWithFormat:@"http://%@%@", h, u];
}

- (void)addUpdateDelegate:(id)dele withSelector:(SEL)sele {
    [updateAction addDelegate:dele withSelector:sele];
}

- (void)addDelegate:(id)dele withSelector:(SEL)sele {
    [theAction addDelegate:dele withSelector:sele];
}

- (void)addErrorDelegate:(id)dele withSelector:(SEL)sele {
    [theAction addErrorDelegate:dele withSelector:sele];
}

- (void)addOnetimeDelegate:(id)dele withSelector:(SEL)sele {
    [theAction addDelegate:dele withSelector:sele];
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
    [alertView release];
    BL_failedConnectionWarningAlert = nil;
}

// URLConnection DELEGATE methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    theResponse = response;
    [theResponse retain];
    expectedLength = response.expectedContentLength;
    bytesDownloaded = 0;
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    bytesDownloaded += [data length];
    [updateAction fireWithObject:self];
	if (markForStop) {
		[connection cancel];
	}
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error %@ - %@ %@",
		  url,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    
    if (error) {
        if ([error code] == -1009) {
            [self errorCallback:self withError:error];       
        } else {
            // we don't really care because it's probably just a broken link.
        }
    }
    [self startNextFetch];
}

-(void)errorCallback:(id)sender withError:(NSError *)error{
    if (BL_failedConnectionWarningAlert == nil) {
        BL_failedConnectionWarningAlert = [[UIAlertView alloc]
                                initWithTitle:@"Network Error"
                                message:@"A valid internet connection could not be made, make sure you have internet connectivity in order to download new content."
                                delegate:self
                                cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [BL_failedConnectionWarningAlert show];
    }
    [theAction fireError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [theAction fireWithObject:self];
    [self startNextFetch];
    isComplete = YES;
}

-(id)jsonOfData {
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
    [dargs removeAllObjects];
    [cookies removeAllObjects];
    [headerFields removeAllObjects];

    [updateAction removeAllSelectorsForDelegate:self];
	[updateAction release];

    [theAction removeAllSelectorsForDelegate:self];
    [theAction release];
    
    [cookies release];
    [receivedData release];
    [theResponse release];
    [super dealloc];
}

-(float)getPercentDone {
    return ((float)bytesDownloaded / (float)expectedLength);
}

-(void)setURLOpener:(id)opener {
    parentOpener = opener;
}
@end

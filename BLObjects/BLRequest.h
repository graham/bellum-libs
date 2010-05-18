//
//  BLRequest.h
//  Commodity
//
//  Created by Graham Abbott on 2/14/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "BLCallback.h"
#import "BLAction.h"

#define CONCURRENT_REQUESTS_ENABLED NO
#define MAX_CONCURRENT_REQUESTS 2

static NSMutableArray *BLREQUEST_REQUEST_QUEUE = nil;
static int currentRequestsActive = 0;
static UIAlertView *BL_failedConnectionWarningAlert;

@interface BLRequest : NSObject {
    id parentOpener;
    
    NSString *url;
    NSString *requestType;
    
    NSMutableDictionary *dargs;
    NSMutableData *receivedData;
    BOOL isComplete;
    
    BLAction *theAction;
    BLAction *updateAction;
        
    NSMutableURLRequest *theRequest;
    NSMutableArray *cookies;
    NSMutableDictionary *headerFields;
    NSData *httpBody;
    NSURLResponse *theResponse;

    long long expectedLength;
    long long bytesDownloaded;
	
	BOOL markForStop;
}

@property (nonatomic, readwrite, assign) BOOL markForStop;
@property (nonatomic, readonly) BOOL isComplete;
@property (nonatomic, readonly) long long expectedLength;
@property (nonatomic, readwrite) NSString * url;
@property (nonatomic, readwrite) NSString * requestType;
@property (nonatomic, readwrite) NSMutableArray *cookies;
@property (nonatomic, readwrite) NSMutableURLRequest *theRequest;
@property (nonatomic, readwrite) NSMutableDictionary *headerFields;
@property (nonatomic, readonly) NSMutableData *receivedData;
@property (nonatomic, readonly) NSURLResponse *theResponse;

- (void)setURL:(NSString *)u;
- (void)fetch;
- (void)beginFetch;
- (NSString *)dataString;
- (void)setHost:(NSString*)h withURL:(NSString*)u;
- (void)setData:(NSString*)s forKey:(NSString*)key;
- (void)setPureData:(NSString*)s forKey:(NSString*)key;
- (void)addDelegate:(id)dele withSelector:(SEL)sele;
- (void)addErrorDelegate:(id)dele withSelector:(SEL)sele;
- (void)addOnetimeDelegate:(id)dele withSelector:(SEL)sele;
- (void)addUpdateDelegate:(id)dele withSelector:(SEL)sele;
- (void)errorCallback:(id)sender withError:(NSError *)error;
- (id)jsonOfData;
- (NSData *)payload;
- (NSString *)stringPayload;
- (NSDictionary*)headers;

- (void)setHTTPBody:(NSData *)data;
- (float)getPercentDone;
-(void)setURLOpener:(id)opener;



@end

//
//  BLRequest.h
//  Commodity
//
//  Created by Graham Abbott on 2/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "BLCallback.h"

@interface BLRequest : NSObject {
    NSString *url;
    NSString *requestType;
    
    NSMutableDictionary *dargs;
    NSMutableData *receivedData;
    BOOL isComplete;
    
    NSMutableArray *callbacks;
    NSMutableArray *onetimeCallbacks;
    NSMutableArray *errorCallbacks;
    NSMutableArray *dataChunkCallbacks;
    
    NSMutableURLRequest *theRequest;
    NSMutableArray *cookies;
    NSMutableDictionary *headerFields;
    NSData *httpBody;
    NSURLResponse *theResponse;
    long long expectedLength;
	
	BOOL markForStop;
}

@property (nonatomic, readwrite, assign) BOOL markForStop;
@property (nonatomic, readonly) BOOL isComplete;
@property (nonatomic, readonly) long long expectedLength;
@property (nonatomic, readwrite, retain) NSString * url;
@property (nonatomic, readwrite, retain) NSString * requestType;
@property (nonatomic, readwrite, retain) NSMutableArray *cookies;
@property (nonatomic, readwrite, retain) NSMutableURLRequest *theRequest;
@property (nonatomic, readwrite, retain) NSMutableDictionary *headerFields;
@property (nonatomic, readonly) NSMutableData *receivedData;

- (void)setURL:(NSString *)u;
- (void)fetch;
- (NSString *)dataString;
- (void)setHost:(NSString*)h withURL:(NSString*)u;
- (void)setData:(NSString*)s forKey:(NSString*)key;
- (void)setPureData:(NSString*)s forKey:(NSString*)key;
- (void)addDelegate:(id)dele withSelector:(SEL)sele;
- (void)addErrorDelegate:(id)dele withSelector:(SEL)sele;
- (void)addOnetimeDelegate:(id)dele withSelector:(SEL)sele;

- (void)addUpdateDelegate:(id)dele withSelector:(SEL)sele;

- (void)errorCallback:(id)sender;
- (id)jsonOfData;
- (NSData *)payload;
- (NSString *)stringPayload;
-(NSDictionary*)headers;

-(void)setHTTPBody:(NSData *)data;

@end

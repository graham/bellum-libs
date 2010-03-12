//
//  BLCache.h
//  BLTestBed
//
//  Created by Graham Abbott on 6/28/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BLDatabase.h"
#import "FMDatabase.h"
#import "BLRequest.h"
#import "BLImage.h"
#import "BLData.h"

static BOOL BLCACHE_databaseCreated = NO;
static NSMutableDictionary *MEMCACHE_STRING_STORAGE = nil;

@interface BLCache : NSObject {
    BOOL doneLoading;
    id resourceType;
    id target;
    SEL selector;
}

+(NSNumber*)getRowCount;
+(void)prepareDatabase;
+(void)invalidateCacheWithKey:(NSString *)s;
+(void)invalidateCacheOlderThan:(float)i;
+(void)invalidateCacheOlderThan:(float)i ofType:(id)t;
+(void)clearDatabase;
+(void)clearDatabaseOfType:(id)rt;
+(BOOL)keyExists:(NSString *)imageName;
+(void)storeData:(NSData*)i withName:(NSString *)imageName asType:(NSString *)t expiresIn:(int)secondCount;
+(BLRequest*)fetchDataWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector asType:(id)rt;
+(BLRequest*)fetchDataWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector asType:(id)rt forceFresh:(BOOL)forceFresh;
+(BLRequest*)fetchDataWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector asType:(id)rt holdFire:(BOOL)yn forceFresh:(BOOL)forceFresh;
-(void)addDataFromRequest:(BLRequest*)r;

+(void)setString:(NSString *)s forKey:(NSString *)key;
+(NSString *)getStringForKey:(NSString *)key;
+(void)cacheLoadup;

@property (nonatomic, readwrite, assign) BOOL doneLoading;
@property (nonatomic, readwrite, retain) id target;
@property (nonatomic, readwrite, retain) id resourceType;
@property (nonatomic, readwrite, assign) SEL selector;

@end

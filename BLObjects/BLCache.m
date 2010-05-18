//
//  BLCache.m
//  BLTestBed
//
//  Created by Graham Abbott on 6/28/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import "BLCache.h"


@implementation BLCache

@synthesize doneLoading;
@synthesize resourceType;
@synthesize target;
@synthesize selector; 

- (id) init {
    if ((self = [super init])) {
        if (BLCACHE_databaseCreated == NO) {
            [BLCache prepareDatabase];
            doneLoading = NO;
        }
    }
    return self;
}

+(void)invalidateCacheOlderThan:(float)i {
    float d = [[[NSDate alloc] init] timeIntervalSince1970];
    FMDatabase *db = [BLDatabase getDatabase];
    d -= i;
    NSNumber *amount = [NSNumber numberWithFloat:d];    
    [db executeUpdate:@"delete from bl_cache_storage where lastUpdated < ?", amount];
    NSLog(@"Invalidate cache older than %.2f seconds.", i);
}

+(void)invalidateCacheOlderThan:(float)i ofType:(id)t {
    float d = [[[NSDate alloc] init] timeIntervalSince1970];
    FMDatabase *db = [BLDatabase getDatabase];
    d -= i;
    NSNumber *amount = [NSNumber numberWithFloat:d];
    [db executeUpdate:@"delete from bl_cache_storage where lastUpdated < ? and type = ?", amount, [t description]];
    NSLog(@"Invalidate cache of type %@ older than %.2f seconds.", [t description], i);    
}

+(NSNumber*)getRowCount {
    FMDatabase *db = [BLDatabase getDatabase];
    FMResultSet *rs = [db executeQuery:@"select count(*) from bl_cache_storage"];
    if ([rs next]) {
        NSNumber *i = [[NSNumber alloc] initWithInt:[rs intForColumnIndex:0]];
        return i;
    }
    
    return [[NSNumber alloc] initWithInt:0];
}

+(void)prepareDatabase {
    MEMCACHE_STRING_STORAGE = [[NSMutableDictionary alloc] init];
    [MEMCACHE_STRING_STORAGE retain];
    
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate:
     @"create table bl_cache_storage "
     @"(id integer primary key,      "
     @" name varchar(4096),          " 
     @" type varchar(512),           "
     @" keepAround integer,          "
     @" expires integer,             "
     @" lastUpdated float,           "
     @" metainfo blob,               "
     @" kvpair integer,              "
     @" content blob);               "];
    [db commit];
    
    BLCACHE_databaseCreated = YES;
}

+(void)clearDatabase {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate:@"delete from bl_cache_storage;"];
    [db commit];
}

+(void)clearDatabaseOfType:(id)rt {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate:@"delete from bl_cache_storage where type = ?;", [rt description]];
    [db commit];
}

+(BOOL)keyExists:(NSString*)imageName {
    FMDatabase *db = [BLDatabase getDatabase];
    
    NSString *query = [NSString stringWithFormat:@"select content from bl_cache_storage where name = '%@';", imageName];
    FMResultSet *rs = [db executeQuery:query];
    
    if ([rs next]) {
        return YES;
    } else {
        return NO;
    }
    
}

+(void)storeData:(NSData*)i withName:(NSString *)imageName asType:(NSString *)t expiresIn:(int)secondCount {
    FMDatabase *db = [BLDatabase getDatabase];
    float d = [[[NSDate alloc] init] timeIntervalSince1970];
    [db executeUpdate: [NSString stringWithFormat:@"insert into bl_cache_storage (name, content, type, lastUpdated, expires) values(?, ?, ?, ?, ?)"], 
                        imageName, i, t, [NSNumber numberWithFloat:d], [NSNumber numberWithInt:secondCount]
     ];
    
    [db commit];    
}

+(BLRequest*)fetchDataWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector asType:(id)rt {
	return [[self class] fetchDataWithName:imageName andCall:delegate withSelector:selector asType:rt holdFire:NO forceFresh:NO];
}

+(BLRequest*)fetchDataWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector asType:(id)rt forceFresh:(BOOL)forceFresh {
	return [[self class] fetchDataWithName:imageName andCall:delegate withSelector:selector asType:rt holdFire:NO forceFresh:forceFresh];
}

+(BLRequest*)fetchDataWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector asType:(id)rt holdFire:(BOOL)yn forceFresh:(BOOL)forceFresh {    
    FMDatabase *db = [BLDatabase getDatabase];
	
    NSString *query = [NSString stringWithFormat:@"select content from bl_cache_storage where name = '%@';", imageName];
    FMResultSet *rs = [db executeQuery:query];
	
    if ([rs next] && !forceFresh) {
#ifdef BLTESTING
        NSLog(@"Cache hit for %@", imageName);
#endif
        NSData *imageData = [rs dataForColumnIndex:0];
        id image = [[rt alloc] initWithData:imageData];
        
		BLCallback *cb = [[BLCallback alloc] init];
		cb.target = delegate;
		cb.selector = selector;
        //[cb performSelector:@selector(callAndRelease:) withObject:image afterDelay:0.001f];
        [cb call:image];
        [image release];
        [cb release];
		return nil;
    } else {
#ifdef BLTESTING
        NSLog(@"No cache hit going to the web, %@", imageName);        
#endif
		BLCache *ci = [[BLCache alloc] init];
        ci.resourceType = rt;
        
        ci.target = delegate;
        ci.selector = selector;
		
        BLRequest *r = [[BLRequest alloc] init];
        [r setURL:imageName];
        [r addOnetimeDelegate:ci withSelector:@selector(addDataFromRequest:)];
		//[r addErrorDelegate:ci withSelector:@selector(errorDataLoading:)];
        [ci release];
		
		if (!yn) {
			[r fetch];
		}
		return r;
    }
}


-(void)addDataFromRequest:(BLRequest*)r {
	id image = [[resourceType alloc] initWithData:[r payload]];
    
    [[self class] storeData:[r payload] withName:r.url asType:[resourceType description] expiresIn:-1];
    [[r payload] release];
    
    BLCallback *cb = [[BLCallback alloc] init];
    cb.target = self.target;
    cb.selector = self.selector;
    [cb call:image];
    [image release];
    
    [cb release];
    [r release];
}

-(void)errorDataLoading:(BLRequest*)r {
    BLCallback *cb = [[BLCallback alloc] init];
    cb.target = self.target;
    cb.selector = self.selector;
    [cb call:nil];
    [cb release];
    [r release];
}

-(void)dealloc {
#ifdef BLTESTING
    NSLog(@"Dealloc BLCache Object");
#endif
    [target release];
    [super dealloc];
}

+(void)setString:(NSString *)s forKey:(NSString *)key {
    NSLog(@"set key: %@ -> value: %@", key, s);

    FMDatabase *db = [BLDatabase getDatabase];
    float d = [[[NSDate alloc] init] timeIntervalSince1970];
    [db executeUpdate: [NSString stringWithFormat:@"insert into bl_cache_storage (name, content, type, lastUpdated, expires, kvpair) values(?, ?, ?, ?, 0, 1)"], 
      key, [s dataUsingEncoding:NSUTF8StringEncoding], [NSString description], [NSNumber numberWithFloat:d]
     ];
    
    [db commit];        
    
    NSString *r = [[NSString alloc] initWithString:s];
    [r retain];
    [MEMCACHE_STRING_STORAGE setValue:r forKey:key];
    NSLog(@"HERE SET: %@", MEMCACHE_STRING_STORAGE);
}

+(NSString *)getStringForKey:(NSString *)key {
    NSLog(@"HERE GET: %@, %@", key, MEMCACHE_STRING_STORAGE);
    
    if ([MEMCACHE_STRING_STORAGE objectForKey:key] == nil) {
        FMDatabase *db = [BLDatabase getDatabase];
        
        NSString *query = [NSString stringWithFormat:@"select content from bl_cache_storage where name = '%@';", key];
        FMResultSet *rs = [db executeQuery:query];
        
        if ([rs next]) {
            NSData *imageData = [rs dataForColumnIndex:0];
            NSString *theString = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
            [theString retain];
            [MEMCACHE_STRING_STORAGE setObject:theString forKey:key];
            NSLog(@"get key: %@ -> value: %@", key, theString);
            
            return theString;
        } else {
            //NSLog(@"Cache Miss for %@", key);
            return nil;
        }
    } else {
        //NSLog(@"Returning MEMCACHED %@ -> %@", key, [MEMCACHE_STRING_STORAGE objectForKey:key]);
        return [MEMCACHE_STRING_STORAGE objectForKey:key];
    }
}

+(void)cacheLoadup {
    FMDatabase *db = [BLDatabase getDatabase];
    
    NSString *query = [NSString stringWithFormat:@"select name, content from bl_cache_storage where kvpair = 1;"];
    FMResultSet *rs = [db executeQuery:query];
    
    while ([rs next]) {
        NSString *theKey = [rs stringForColumnIndex:0];
        NSData *theData = [rs dataForColumnIndex:1];
        [MEMCACHE_STRING_STORAGE setValue:[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] forKey:theKey];
    }
    
    NSLog(@"Loadup Complete: %@", MEMCACHE_STRING_STORAGE);    
}

@end

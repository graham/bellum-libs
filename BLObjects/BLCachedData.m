//
//  BLCachedData.m
//  CommodityWars2
//
//  Created by Graham Abbott on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLCachedData.h"

@implementation BLCachedData

@synthesize doneLoading;
@synthesize target;
@synthesize selector; 

- (id) init {
    if ((self = [super init])) {
        if (BLDATA_databaseCreated == NO) {
            [BLCachedData prepareDatabase];
            doneLoading = NO;
        }
        
    }
    return self;
}

+(NSNumber*)getRowCount {
    FMDatabase *db = [BLDatabase getDatabase];
    FMResultSet *rs = [db executeQuery:@"select count(*) from bl_data_storage"];
    if ([rs next]) {
        NSNumber *i = [[NSNumber alloc] initWithInt:[rs intForColumnIndex:0]];
        return i;
    }
    
    return [[NSNumber alloc] initWithInt:0];
}

+(void)prepareDatabase {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate:@"create table bl_data_storage "
                      @"(id integer primary key,      "
                      @" name varchar(512),           " 
                      @" type varchar(512),           "
                      @" musthave integer,            "
                      @" expires integer,             "
                      @" lastUpdated integer,         "
                      @" content blob);      "];
    [db commit];
    
    BLDATA_databaseCreated = YES;
}

+(void)clearDatabase {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate:@"delete from bl_data_storage;"];
    [db commit];
}


+(BOOL)keyExists:(NSString*)imageName {
    FMDatabase *db = [BLDatabase getDatabase];

    NSString *query = [NSString stringWithFormat:@"select content from bl_data_storage where name = '%@';", imageName];
    FMResultSet *rs = [db executeQuery:query];

    if ([rs next]) {
        return YES;
    } else {
        return NO;
    }

}

+(void)storeData:(NSData*)i withName:(NSString *)imageName {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate: @"insert into bl_data_storage (name, content) values(?, ?)", imageName, i];
    [db commit];    
}

+(BLRequest*)fetchDataWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector{
    FMDatabase *db = [BLDatabase getDatabase];

    NSString *query = [NSString stringWithFormat:@"select content from bl_data_storage where name = '%@';", imageName];
    FMResultSet *rs = [db executeQuery:query];

    if ([rs next]) {
        //NSLog(@"Cache hit for %@", imageName);
        NSData *imageData = [rs dataForColumnIndex:0];
		[imageData retain];
		
		BLCallback *cb = [[[BLCallback alloc] init] autorelease];
		cb.target = delegate;
		cb.selector = selector;
		[cb call:imageData];
		return nil;
    } else {
        //NSLog(@"No cache hit going to the web, %@", imageName);        
		BLCachedData *ci = [[BLCachedData alloc] init];
		[ci retain];
        ci.target = delegate;
        ci.selector = selector;
		
        BLRequest *r = [[BLRequest alloc] init];
        [r setURL:imageName];
        [r addOnetimeDelegate:ci withSelector:@selector(addImageFromRequest:)];
		[r addErrorDelegate:ci withSelector:@selector(errorImageLoading:)];
		[r fetch];
		
		return r;
    }
}

-(void)addImageFromRequest:(BLRequest*)r {
    [[self class] storeData:[r payload] withName:r.url];
    
    BLCallback *cb = [[BLCallback alloc] init];
    cb.target = self.target;
    cb.selector = self.selector;
    [cb call:[r payload]];
    
	[self release];
}

-(void)errorImageLoading:(BLRequest*)r {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    cb.target = self.target;
    cb.selector = self.selector;
    [cb call:nil];
	[self release];
}

@end

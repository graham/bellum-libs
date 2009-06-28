//
//  BLCachedImage.m
//  CommodityWars2
//
//  Created by Graham Abbott on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLCachedImage.h"

@implementation BLCachedImage

@synthesize doneLoading;
@synthesize target;
@synthesize selector; 

- (id) init {
    if ((self = [super init])) {
        if (BLIMAGE_databaseCreated == NO) {
            [BLCachedImage prepareDatabase];
            doneLoading = NO;
        }
        
    }
    return self;
}

+(NSNumber*)getRowCount {
    FMDatabase *db = [BLDatabase getDatabase];
    FMResultSet *rs = [db executeQuery:@"select count(*) from bl_image_storage"];
    if ([rs next]) {
        NSNumber *i = [[NSNumber alloc] initWithInt:[rs intForColumnIndex:0]];
        return i;
    }
    
    return [[NSNumber alloc] initWithInt:0];
}

+(void)prepareDatabase {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate:@"create table bl_image_storage "
                      @"(id integer primary key,      "
                      @" name varchar(512),           " 
                      @" type varchar(512),           "
                      @" musthave integer,            "
                      @" expires integer,             "
                      @" lastUpdated integer,         "
                      @" content_type varchar(512),   "
                      @" width float,               "
                      @" height float,              "
                      @" content blob);               "];
    [db commit];
    
    BLIMAGE_databaseCreated = YES;
}

+(void)clearDatabase {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate:@"delete from bl_image_storage;"];
    [db commit];
}

+(BOOL)keyExists:(NSString*)imageName {
    FMDatabase *db = [BLDatabase getDatabase];

    NSString *query = [NSString stringWithFormat:@"select content from bl_image_storage where name = '%@';", imageName];
    FMResultSet *rs = [db executeQuery:query];

    if ([rs next]) {
        return YES;
    } else {
        return NO;
    }

}

+(void)storeImageData:(NSData*)i withName:(NSString *)imageName height:(float)h width:(float)w {
    FMDatabase *db = [BLDatabase getDatabase];
    [db executeUpdate: [NSString stringWithFormat:@"insert into bl_image_storage (name, content, content_type, height, width) values(?, ?, 'image/png', %.2f, %.2f)", h, w],  imageName, i ];
    [db commit];    
}

+(BLRequest*)fetchImageWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector{
	[[self class] fetchImageWithName:imageName andCall:delegate withSelector:selector holdFire:NO];
}

+(BLRequest*)fetchImageWithName:(NSString *)imageName andCall:(id)delegate withSelector:(SEL)selector holdFire:(BOOL)yn {
    FMDatabase *db = [BLDatabase getDatabase];
	
    NSString *query = [NSString stringWithFormat:@"select content from bl_image_storage where name = '%@';", imageName];
    FMResultSet *rs = [db executeQuery:query];
	
    if ([rs next]) {
        NSLog(@"Cache hit for %@", imageName);
        NSData *imageData = [rs dataForColumnIndex:0];
        // Image is already here.
        BLImage *image = [BLImage imageWithData:imageData];		
		BLCallback *cb = [[[BLCallback alloc] init] autorelease];
		//NSLog(@"Cached Image: %i", [image retainCount]);
		cb.target = delegate;
		cb.selector = selector;
		[cb call:image];
		return nil;
    } else {
        NSLog(@"No cache hit going to the web, %@", imageName);        
		BLCachedImage *ci = [[BLCachedImage alloc] init];
		[ci retain];
        ci.target = delegate;
        ci.selector = selector;
		
        BLRequest *r = [[BLRequest alloc] init];
        [r setURL:imageName];
        [r addOnetimeDelegate:ci withSelector:@selector(addImageFromRequest:)];
		[r addErrorDelegate:ci withSelector:@selector(errorImageLoading:)];
		
		if (!yn) {
			[r fetch];
		}
		
		return r;
    }
}


-(void)addImageFromRequest:(BLRequest*)r {
	BLImage *image = [BLImage imageWithData:[r payload]];

    [[self class] storeImageData:[r payload] withName:r.url height:image.size.height width:image.size.width];
    
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    cb.target = self.target;
    cb.selector = self.selector;
    [cb call:image];
    
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

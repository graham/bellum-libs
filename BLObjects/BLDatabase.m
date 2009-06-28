//
//  BLDatabase.m
//  Commodity
//
//  Created by Graham Abbott on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLDatabase.h"

@implementation BLDatabase

+(FMDatabase*)getDatabase {
    if (FMDATA_database_instance == nil) {
		NSString *databaseName = nil;
		if (FMDDATA_DB_NAME != nil) {
			databaseName = FMDDATA_DB_NAME;
		} else {
			databaseName = @"database.db";
		}
		
		NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
		
        //NSFileManager *fileManager = [NSFileManager defaultManager];
        //[fileManager removeFileAtPath:filePath handler:nil];
        NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.db", @"database"];
        FMDatabase *db = [FMDatabase databaseWithPath:filePath];
        [db retain];
        [db open];
        [db setShouldCacheStatements:YES];        
        FMDATA_database_instance = db;
        NSLog(@"Database created at: %@", filePath);
        return db;
    }
    return FMDATA_database_instance;
}

+(FMDatabase*)initDatabaseName:(NSString *)s {
	FMDDATA_DB_NAME = [NSString stringWithString:s];
}

@end


//
//  BLDatabase.m
//  Commodity
//
//  Created by Graham Abbott on 2/6/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
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

+(FMDatabase*)getDatabaseWithName:(NSString *)s {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"%@", s];
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    [db retain];
    [db open];
    [db setShouldCacheStatements:YES];        
    NSLog(@"Database created at: %@", filePath);
    return db;
}

+(void)copyAllDataFrom:(NSString *)sourcePath toDatabase:(NSString *)targetPath {
    FMDatabase *shipped = [BLDatabase getDatabaseWithName:sourcePath];
    FMDatabase *target = [BLDatabase getDatabase];  
    
    [shipped setLogsErrors:YES];
    [target setLogsErrors:YES];
    
    FMResultSet *rs = [shipped executeQuery:@"select * from sqlite_master"];
    while([rs next]) {
        NSString *databaseName = [rs stringForColumnIndex:1];
        NSString *databaseSchema = [rs stringForColumnIndex:4];
        
        NSRange start = [[rs stringForColumnIndex:4] rangeOfString:@"("];
        
        NSString *fieldsString = [[rs stringForColumnIndex:4] substringWithRange:
                                  NSMakeRange(start.location, ([[rs stringForColumnIndex:4] length] - (start.location)))];
        fieldsString = [fieldsString stringByReplacingOccurrencesOfString:@"(" withString:@" "];
        fieldsString = [fieldsString stringByReplacingOccurrencesOfString:@")" withString:@" "];
        
        NSArray *fieldsAll = [fieldsString componentsSeparatedByString:@","];
        
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        NSMutableArray *types = [[NSMutableArray alloc] init];
        
        for(int i=0; i < [fieldsAll count]; i++) {
            NSString *s = [fieldsAll objectAtIndex:i];
            s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *parts = [s componentsSeparatedByString:@" "];
            [fields addObject:[parts objectAtIndex:0]];
            
            [types addObject:[parts objectAtIndex:1]];
        }
        
        NSLog(@"Attempting to create table: %@", databaseSchema);
        
        [target beginTransaction];
        [target executeUpdate:[[NSString alloc] initWithFormat:@"drop table %@;", databaseName]];
        [target commit];
        
        [target beginTransaction];
        [target executeUpdate:[[NSString alloc] initWithFormat:@"%@;", databaseSchema]];
        [target commit];
        
        
        FMResultSet *dbRS = [shipped executeQuery:[NSString stringWithFormat:@"select %@ from %@", [fields componentsJoinedByString:@", "], databaseName]];
        
        while([dbRS next]) {
            NSMutableArray *values = [[NSMutableArray alloc] init];
            NSMutableArray *qs = [[NSMutableArray alloc] init];
            
            for(int j = 0; j < [fields count]; j++) {
                NSString *type = [types objectAtIndex:j];
                if ([type isEqual:@"integer"]) {
                    [values addObject:[[NSNumber alloc] initWithInt:[dbRS intForColumnIndex:j]]];
                } else if ([type isEqual:@"float"]) {
                    [values addObject:[[NSNumber alloc] initWithDouble:[dbRS doubleForColumnIndex:j]]];
                } else if ([type isEqual:@"text"]) {
                    [values addObject:[dbRS stringForColumnIndex:j]];
                } else if ([type isEqual:@"varchar"]) {
                    [values addObject:[dbRS stringForColumnIndex:j]];
                } else if ([type isEqual:@"blob"]) {
                    NSData *d = [dbRS dataForColumnIndex:j];
                    if (d == nil) {
                        [values addObject:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
                    } else {
                        [values addObject:d];
                    }
                } else {
                    NSLog(@"Missing type: %@", type);
                }
                
                [qs addObject:@"?"];
            }
            
            NSString *query = [[NSString alloc] initWithFormat:@"insert into %@ (%@) values(%@);", databaseName, [fields componentsJoinedByString:@", "], [qs componentsJoinedByString:@", "]];

            [target beginTransaction];
            [target executeUpdate:query withArgumentsInArray:values];
            [target commit];
            
            if ([target hadError]) {
                NSLog(@"Err %d: %@", [target lastErrorCode], [target lastErrorMessage]);
            }
        }
    }
    
    [shipped close];
    [shipped release];
}

@end


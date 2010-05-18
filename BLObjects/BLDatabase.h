//
//  BLDatabase.h
//  Commodity
//
//  Created by Graham Abbott on 2/6/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

static FMDatabase *FMDATA_database_instance;
static NSString *FMDDATA_DB_NAME;

@interface BLDatabase : NSObject {
}

+(FMDatabase*)getDatabase;
+(FMDatabase*)initDatabaseName:(NSString *)s;
+(void)copyAllDataFrom:(NSString *)sourcePath toDatabase:(NSString *)targetPath;

@end

//
//  BLDatabase.h
//  Commodity
//
//  Created by Graham Abbott on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDatabase.h"

static FMDatabase *FMDATA_database_instance;
static NSString *FMDDATA_DB_NAME;

@interface BLDatabase : NSObject {
}

+(FMDatabase*)getDatabase;
+(FMDatabase*)initDatabaseName:(NSString *)s;

@end

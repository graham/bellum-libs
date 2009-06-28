//
//  BLTable.h
//  Commodity
//
//  Created by Graham Abbott on 2/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface BLTable : NSObject {
    FMDatabase *_db;
    
    BOOL _isFromDatabase;
    int primaryKeyValue;
}

-(BOOL)save:(FMDatabase*)db;

+(NSString*)primaryKey;
+(NSString*)tableName;
+(NSArray*)tableColumn;
+(NSString*)tableSQL;
+(id)objectsFromDb:(FMDatabase*)db forQuery:(NSString*)sql, ...;
+(BOOL)createTable:(FMDatabase*)db;
+(id)firstObjectFromDb:(FMDatabase*)db forQuery:(NSString*)sql, ...;
+(void)deleteAllObjects:(FMDatabase*)db;

@property (readwrite, retain) FMDatabase * _db;
@property (readwrite, assign) BOOL _isFromDatabase;
@property (readwrite, assign) int primaryKeyValue;

@end

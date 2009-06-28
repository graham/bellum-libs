//
//  BLTable.m
//  Commodity
//
//  Created by Graham Abbott on 2/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLTable.h"


@implementation BLTable

@synthesize _db;
@synthesize _isFromDatabase;
@synthesize primaryKeyValue;

-(NSString *)description {
    NSString *ret = [[NSString alloc] initWithFormat:@"<Row of %@ -> %i\n", [[self class] tableName], self.primaryKeyValue];
    for( NSArray *i in [[self class] tableColumn] ) {
        NSString *nameOfColumn = [i objectAtIndex:0];
        NSString *typeOfColumn = [i objectAtIndex:1];
            
        ret = [ret stringByAppendingFormat:@"    %@ : %@ : %@\n", nameOfColumn, typeOfColumn, [self valueForKey:nameOfColumn]];
    }
        return ret;
}

+(NSArray*)tableColumn {
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    
    [columns addObject:
            [[NSArray alloc] initWithObjects:@"name", @"string", nil]
     ];
    
    [columns addObject:
            [[NSArray alloc] initWithObjects:@"age", @"int", nil]
     ];
    
    return columns;
}

+(id)firstObjectFromDb:(FMDatabase*)db forQuery:(NSString*)sql, ... {
    va_list args;
    va_start(args, sql);
    FMResultSet *rs = [db executeQuery:sql arguments:args];
    va_end(args);
    
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSArray *columns = [[self class] tableColumn];
    while( [rs next] ) {
        BLTable *row = [[[self class] alloc] init];
        
        row._isFromDatabase = YES;
        row.primaryKeyValue = [rs intForColumn:[[self class] primaryKey]];
        
        for( NSArray *i in columns ) {
            NSString *nameOfColumn = [i objectAtIndex:0];
            NSString *typeOfColumn = [i objectAtIndex:1];
            
            if ( [typeOfColumn isEqual:@"string"] ) {
                NSString *value = [rs stringForColumn:nameOfColumn];
                [row setValue:value forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"int"] ) {
                int value = [rs intForColumn:nameOfColumn];
                [row setValue:[[NSNumber alloc] initWithInt:value] forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"double"] ) {
                double value = [rs doubleForColumn:nameOfColumn];
                [row setValue:[[NSNumber alloc] initWithFloat:value] forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"data"] ) {
                NSData *value = [rs dataForColumn:nameOfColumn];
                [row setValue:value forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"bool"] ) {
                BOOL value = [rs boolForColumn:nameOfColumn];
                [row setValue:[[NSNumber alloc] initWithBool:value] forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"date"] ) {
                NSDate *value = [rs dateForColumn:nameOfColumn];
                [row setValue:value forKey:nameOfColumn];
            }
        }
        return row;
    }
    return nil;
}

+(id)objectsFromDb:(FMDatabase*)db forQuery:(NSString*)sql, ... {
    va_list args;
    va_start(args, sql);
    FMResultSet *rs = [db executeQuery:sql arguments:args];
    va_end(args);
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSArray *columns = [[self class] tableColumn];
    while( [rs next] ) {
        BLTable *row = [[[self class] alloc] init];
        
        row._isFromDatabase = YES;
        row._db = db;
        row.primaryKeyValue = [rs intForColumn:[[self class] primaryKey]];
        
        for( NSArray *i in columns ) {
            NSString *nameOfColumn = [i objectAtIndex:0];
            NSString *typeOfColumn = [i objectAtIndex:1];
            
            if ( [typeOfColumn isEqual:@"string"] ) {
                NSString *value = [rs stringForColumn:nameOfColumn];
                [row setValue:value forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"int"] ) {
                int value = [rs intForColumn:nameOfColumn];
                [row setValue:[[NSNumber alloc] initWithInt:value] forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"double"] ) {
                double value = [rs doubleForColumn:nameOfColumn];
                [row setValue:[[NSNumber alloc] initWithFloat:value] forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"data"] ) {
                NSData *value = [rs dataForColumn:nameOfColumn];
                [row setValue:value forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"bool"] ) {
                BOOL value = [rs boolForColumn:nameOfColumn];
                [row setValue:[[NSNumber alloc] initWithBool:value] forKey:nameOfColumn];
            } else if ( [typeOfColumn isEqual:@"date"] ) {
                NSDate *value = [rs dateForColumn:nameOfColumn];
                [row setValue:value forKey:nameOfColumn];
            }
        }
        [objects addObject:row];
    }
    
    return objects;
}

+(NSString*)tableName {
    NSLog(@"Error you need to define a tableName method.");
    return @"test";
}

+(NSString*)tableSQL {
    NSLog(@"Error you need to define a tableSQL method.");
    return @"";
}

+(NSString*)primaryKey {
    return @"id";
}

+(BOOL)createTable:(FMDatabase*)db {
    [db beginTransaction];
    [db executeUpdate:[[self class] tableSQL]];
    [db commit];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    return YES;
}

-(BOOL)save:(FMDatabase*)db {
    NSMutableArray *columnNames = [[NSMutableArray alloc] init];
    NSMutableArray *columnValues = [[NSMutableArray alloc] init];
    for ( NSArray *i in [[self class] tableColumn] ) {
        if ([self valueForKey:[i objectAtIndex:0]] != nil) {
            [columnNames addObject:[i objectAtIndex:0]];
            [columnValues addObject:[self valueForKey:[i objectAtIndex:0]]];
        }
    }
    
    NSString *q;
    NSMutableArray *argumentList = [[NSMutableArray alloc] init];
    
    if (_isFromDatabase) {
        // We are creating a new entry in the database.
        NSMutableArray *args = [[NSMutableArray alloc] init];
        for (NSString *i in columnNames) {
            [args addObject:[[NSString alloc] initWithFormat:@"%@=?", i]];
            [argumentList addObject: [self valueForKey:i]];            
        }
        
        q = [[NSString alloc] initWithFormat:@"update %@ set %@ where %@=%i", 
             [[self class] tableName],
             [args componentsJoinedByString:@","],
             [[self class] primaryKey],
             [self primaryKeyValue]
             ];        
    } else {
        // We just need to update with the primary key.
        NSMutableArray *args = [[NSMutableArray alloc] init];
        for (NSString *i in columnNames) {
            [args addObject:@"?"];
            [argumentList addObject: [self valueForKey:i]];
        }
        
        q = [[NSString alloc] initWithFormat:@"insert into %@(%@) values(%@)", 
             [[self class] tableName], 
             [columnNames componentsJoinedByString:@","],
             [args componentsJoinedByString:@","]
             ];
    }
    
    [db beginTransaction];
    [db executeUpdate:q arrayOfArguments:argumentList];
    [db commit];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    
    return YES;
    
}

+(void)deleteAllObjects:(FMDatabase*)db {
    [db beginTransaction];
    [db executeUpdate:
     [[NSString alloc] initWithFormat:@"delete from %@", [[self class] tableName]] ];
    [db commit];
}
@end

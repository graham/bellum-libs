//
//  BLCachedData.h
//  CommodityWars2
//
//  Created by Graham Abbott on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDatabase.h"
#import "FMDatabase.h"
#import "BLRequest.h"

static BOOL BLDATA_databaseCreated = NO;

@interface BLCachedData : NSObject {
    BOOL doneLoading;
    
    id target;
    SEL selector;
}

+(void)prepareDatabase;
+(void)clearDatabase;
+(NSNumber*)getRowCount;

@property (nonatomic, readwrite, assign) BOOL doneLoading;
@property (nonatomic, readwrite, retain) id target;
@property (nonatomic, readwrite, assign) SEL selector;

@end

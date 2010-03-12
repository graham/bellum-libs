//
//  BLREMatcher.h
//  ESPNFantasy
//
//  Created by Graham Abbott on 8/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

@interface BLREMatcher : NSObject {
    NSString *data;
    NSString *startString;
    NSString *endString;
}

-(id)initWithString:(NSString*)data;
-(void)setBoundStart:(NSString *)ss andEndString:(NSString *)es;
-(NSArray *)matchOne:(NSString *)expression;
-(NSMutableArray *)matchAll:(NSString *)expression;

@end

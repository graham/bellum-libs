//
//  BLREMatcher.m
//  ESPNFantasy
//
//  Created by Graham Abbott on 8/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLREMatcher.h"


@implementation BLREMatcher

- (id) initWithString:(NSString*)d {
    if ((self = [super init])) {
        data = [[NSString alloc] initWithString:d];
        startString = nil;
        endString = nil;
    }
    return self;
}

-(void)setBoundStart:(NSString *)ss andEndString:(NSString *)es {
    if (ss == nil) {
        startString = nil;
    } else {
        startString = [[NSString alloc] initWithString:ss];
    }
    
    if (es == nil) {
        endString = nil;
    } else {
        endString = [[NSString alloc] initWithString:es];
    }
}

-(NSArray *)matchOne:(NSString *)expression {
    int startIndex = 0;
    int endIndex = [data length];
    
    if (startString) {
        NSRange start = [data rangeOfString:startString];
        if (start.location != NSNotFound) {
            startIndex = start.location + start.length;
        }
    }

    if (endString) {
        NSRange end = [[data substringWithRange:NSMakeRange(startIndex, [data length] - startIndex)] rangeOfString:endString];
        if (end.location != NSNotFound) {
            endIndex = end.location;
        }
    } else {
        endIndex = endIndex - startIndex;
    }
    
    NSString *newData = [data substringWithRange:NSMakeRange(startIndex, endIndex)];
    
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for(int i = 0; i <= [NSString captureCountForRegex:expression]; i++) {
        id j = [newData stringByMatching:expression capture:i];
        if (j == nil) {
            j = [NSNull null];
        }
        [results addObject:j];
    }
    
    [results retain];
    return results;
}

-(NSArray *)matchAll:(NSString *)expression {
    int startIndex = 0;
    int endIndex = [data length];
    
    if (startString) {
        NSRange start = [data rangeOfString:startString];
        if (start.location != NSNotFound) {
            startIndex = start.location + start.length;
        }
    }
    
    if (endString) {
        NSRange end = [[data substringWithRange:NSMakeRange(startIndex, [data length] - startIndex)] rangeOfString:endString];
        if (end.location != NSNotFound) {
            endIndex = startIndex + end.location;
        }
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    int absoluteEnd = startIndex + endIndex;
    int lengthToEnd = endIndex - startIndex;
    NSLog(@"New Search");
    while( lengthToEnd > 0 ) {
        NSString *newData = [data substringWithRange:NSMakeRange(startIndex, lengthToEnd)];        
        if ([newData stringByMatching:expression]) {
            NSMutableArray *row = [[NSMutableArray alloc] init];
            NSRange capture = [newData rangeOfRegex:expression];
            
            for(int i = 0; i <= [NSString captureCountForRegex:expression]; i++) {
                id j = [newData stringByMatching:expression capture:i];
                if (j == nil) {
                    j = [NSNull null];
                }
                [row addObject:j];
            }
            
            startIndex = startIndex + capture.location + capture.length;
            lengthToEnd = lengthToEnd - (capture.location + capture.length);
            [results addObject:row];
        } else {
            lengthToEnd = -1;
        }
    }
    
    [results retain];
    return results;
}

@end

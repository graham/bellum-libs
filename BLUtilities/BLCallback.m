//
//  BLCallback.m
//  Commodity
//
//  Created by Graham Abbott on 2/17/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import "BLCallback.h"


@implementation BLCallback

@synthesize target;
@synthesize selector;

- (id)initWithTarget:(id)t andSelector:(SEL)s {
    if (self = [super init]) {
        target = t;
        selector = s;
    }
    return self;
}
-(int)call:(id)sender {
    @try {
#ifdef BLTESTING
        NSLog(@"Target: %@ -> %i", target, [target retainCount]);
#endif
        NSMethodSignature * sig = nil;

        if (target == NULL) {
            return 0;
        }
        
        sig = [[target class] instanceMethodSignatureForSelector:selector];

        NSInvocation * myInvocation = nil;
        
        if (sig == nil) {
            return 0;
        } else {
            myInvocation = [NSInvocation invocationWithMethodSignature:sig];
            [myInvocation setTarget:target];
            [myInvocation setSelector:selector];
            
            [myInvocation setArgument:&sender atIndex:2];
            [myInvocation retainArguments];	
            [myInvocation invoke];
        }
    }
    @catch (NSException * e) {
        NSLog(@"CALLBACK ERROR: %@", e);
        return 0;
    }
    @finally {

    }    
    
    return 1;
}

-(void)dealloc {
#ifdef BLTESTING
    NSLog(@"Dealloc BLCALLBACK");
#endif
    [target release];
    [super dealloc];
}

-(int)callAndRelease:(id)sender {
    [self call:sender];
    [sender release];
}

@end

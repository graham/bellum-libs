//
//  BLCallback.m
//  Commodity
//
//  Created by Graham Abbott on 2/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BLCallback.h"


@implementation BLCallback

@synthesize target;
@synthesize selector;

-(int)call:(id)sender {
    //NSLog(@"Target:%@", target);
    @try {
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
        return 0;
    }
    @finally {

    }    
    
    return 1;
}

@end

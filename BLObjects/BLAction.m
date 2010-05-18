//
//  BLAction.m
//  Commodity
//
//  Created by Graham Abbott on 2/19/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import "BLAction.h"

@implementation BLAction

- (id)init {
    if (self = [super init]) {
        callbacks = [[NSMutableArray alloc] init];
        errorCallbacks = [[NSMutableArray alloc] init];
        onetimeCallbacks = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)dealloc {
#ifdef BLTESTING
    NSLog(@"BLACTION DEALLOC %@", self);
#endif
    [callbacks removeAllObjects];
    [errorCallbacks removeAllObjects];
    [onetimeCallbacks removeAllObjects];
    
    [callbacks release];
    [errorCallbacks release];
    [onetimeCallbacks release];
}

- (void)addDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[BLCallback alloc] init];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [callbacks addObject:cb];
    [cb release];
}

- (void)addErrorDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[BLCallback alloc] init];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [errorCallbacks addObject:cb];
    [cb release];
}

- (void)addOnetimeDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[BLCallback alloc] init];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [onetimeCallbacks addObject:cb];   
    [cb release];
}

- (void)fire {
    [self fireWithObject:self];
}

-(void)fireWithObject:(id)sender {
    for (BLCallback *i in callbacks) {
        int result = [i call:sender];
        if (result == 0) {
            [callbacks removeObject:i];
        }
    }
    
    for (BLCallback *i in onetimeCallbacks) {
        int result = [i call:sender];
    }
    
    [onetimeCallbacks removeAllObjects];    
}

-(void)fireError {
    for (BLCallback *i in errorCallbacks) {
        int result = [i call:self];
        if (result == 0) {
            [errorCallbacks removeObject:i];
        }
    }
}

- (void)removeDelegate:(id)dele withSelector:(SEL)sele {
    for (BLCallback *i in callbacks) {
        if (i.target == dele && i.selector == sele) {
            [callbacks removeObject:i];
        }
    }
}

- (void)removeAllSelectorsForDelegate:(id)dele {
    for (BLCallback *i in callbacks) {
        if (i.target == dele) {
            [callbacks removeObject:i];
        }
    }    
}
@end

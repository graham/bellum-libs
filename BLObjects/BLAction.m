//
//  BLAction.m
//  Commodity
//
//  Created by Graham Abbott on 2/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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




- (void)addDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [callbacks addObject:cb];
}

- (void)addErrorDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [errorCallbacks addObject:cb];
}

- (void)addOnetimeDelegate:(id)dele withSelector:(SEL)sele {
    BLCallback *cb = [[[BLCallback alloc] init] autorelease];
    [cb setTarget:dele];
    [cb setSelector:sele];
    [onetimeCallbacks addObject:cb];    
}

- (void)fire {
    for (BLCallback *i in callbacks) {
        int result = [i call:self];
        if (result == 0) {
            [callbacks removeObject:i];
        }
    }
    
    for (BLCallback *i in onetimeCallbacks) {
        int result = [i call:self];
    }
    
    [onetimeCallbacks removeAllObjects];
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

//
//  BLAction.h
//  Commodity
//
//  Created by Graham Abbott on 2/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLCallback.h"

@interface BLAction : NSObject {
    NSMutableArray *callbacks;
    NSMutableArray *onetimeCallbacks;
    NSMutableArray *errorCallbacks;    
}

- (void)addDelegate:(id)dele withSelector:(SEL)sele;
- (void)addOnetimeDelegate:(id)dele withSelector:(SEL)sele;
- (void)removeDelegate:(id)dele withSelector:(SEL)sele;
- (void)removeAllSelectorsForDelegate:(id)dele;
- (void)fire;

@end

//
//  BLCallback.h
//  Commodity
//
//  Created by Graham Abbott on 2/17/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCallback : NSObject {
    id target;
    SEL selector;
}

@property (nonatomic, readwrite, retain) id target;
@property (nonatomic, readwrite, assign) SEL selector;

-(id)initWithTarget:(id)t andSelector:(SEL)s;
-(int)call:(id)sender;
-(int)callAndRelease:(id)sender;

@end

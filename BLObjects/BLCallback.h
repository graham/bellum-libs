//
//  BLCallback.h
//  Commodity
//
//  Created by Graham Abbott on 2/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCallback : NSObject {
    id target;
    SEL selector;
}

@property (nonatomic, readwrite, retain) id target;
@property (nonatomic, readwrite, assign) SEL selector;

-(int)call:(id)sender;

@end

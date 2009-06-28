//
//  BLData.h
//  iNews
//
//  Created by Graham Abbott on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@interface NSData (NSDataAdditions)
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end
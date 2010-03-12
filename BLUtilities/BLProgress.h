//
//  BLProgress.h
//  Commodity
//
//  Created by Graham Abbott on 2/5/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BLProgress : UIViewController {
    NSString *text;
    IBOutlet UITextView *statusText;
}

@property (readwrite, retain) NSString *text;
-(void)setText:(NSString*)t;

@end

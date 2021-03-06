//
//  BLProgress.m
//  Commodity
//
//  Created by Graham Abbott on 2/5/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import "BLProgress.h"


@implementation BLProgress

@synthesize text;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [statusText setText:text];
}

-(void)setText:(NSString*)t {
    text = t;
    [statusText setText:text];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    float screenWidth = [self.view bounds].size.width;
	
	if (screenWidth == 320.0f) {
		[self.view setFrame:CGRectMake(0, 0, 320.0f, 480.0f)];
	} else {
		[self.view setFrame:CGRectMake(0, 0, 480.0f, 320.0f)];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}


@end

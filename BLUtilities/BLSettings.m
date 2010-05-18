//
//  BLSettings.m
//  BLTestBed
//
//  Created by Graham Abbott on 6/28/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import "BLSettings.h"


@implementation BLSettings

@synthesize remoteHostStatus;
@synthesize internetConnectionStatus;
@synthesize localWiFiConnectionStatus;

- (id) init {
    if ((self = [super init])) {
        firstCheckFinished = NO;
        [[Reachability sharedReachability] setHostName:@"i-portfolio.appspot.com"];
        [[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
    }
    return self;
}

-(void)reachabilityChanged:(NSNotification *)note
{
    [self updateStatus];
}

-(void)updateStatus
{
    NSLog(@"Network Status Changed: %i %i %i", self.remoteHostStatus, self.internetConnectionStatus, self.localWiFiConnectionStatus);
	// Query the SystemConfiguration framework for the state of the device's network connections.
	self.remoteHostStatus           = [[Reachability sharedReachability] remoteHostStatus];
	self.internetConnectionStatus	= [[Reachability sharedReachability] internetConnectionStatus];
	self.localWiFiConnectionStatus	= [[Reachability sharedReachability] localWiFiConnectionStatus];
    if (firstCheckFinished == NO) {
        firstCheckFinished = YES;
    }
}

-(int)networkIsActive {
    if (firstCheckFinished == NO) {
        return -1;
    } else {
        return self.remoteHostStatus;
    }
}

+(BLSettings *)sharedInstance {
    if (BL_theSettingsSingleton == nil) {
        BL_theSettingsSingleton = [[BLSettings alloc] init];
    }
    return BL_theSettingsSingleton;
}

@end

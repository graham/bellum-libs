//
//  BLSettings.h
//  BLTestBed
//
//  Created by Graham Abbott on 6/28/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define BLTESTING 1

#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

@interface BLSettings : NSObject {
    NetworkStatus remoteHostStatus;
	NetworkStatus internetConnectionStatus;
	NetworkStatus localWiFiConnectionStatus;
    
    BOOL firstCheckFinished;
    
    
}
 
@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

-(void)reachabilityChanged:(NSNotification *)note;
-(void)updateStatus;
-(int)networkIsActive;

+(void)createSingleton;
+(BLSettings *)sharedInstance;

@end

static BLSettings *BL_theSettingsSingleton;


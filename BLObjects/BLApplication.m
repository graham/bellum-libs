#import "BLApplication.h"

@implementation BLApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after application launch
    //[window makeKeyAndVisible];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Launch Options: %@", launchOptions);    
    [window makeKeyAndVisible];
    //[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    // Override point for customization after application launch
    [window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSUserDefaults *myDefaults = [NSUserDefaults standardUserDefaults];
    
//    BLRequest *r = [[BLRequest alloc] init];
//    [r setURL:@"http://i-beta.appspot.com/inews/register/"];
//    [r setData:[myDefaults objectForKey:@"SBFormattedPhoneNumber"] forKey:@"phone_number"];
//    [r setData:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"uuid"];
//    [r setData:[NSString stringWithFormat:@"%@", [deviceToken description]] forKey:@"push_code"];
//    [r addOnetimeDelegate:self withSelector:@selector(finishLoading:)];
//    [r fetch];
}

-(void)finishLoading:(id)sender {
    NSLog(@"Server Response: %@", [sender jsonOfData]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error: %@", error);    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo { 
    NSLog(@"UserInfo: %@", userInfo);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"HandleURL: %@", url);
}

@end

//
//  YGAppDelegate.m
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 14/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import "YGAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleMaps/GoogleMaps.h>
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "AppSettings.h"

#define kAppVersion @"v1"

static NSString * const kGoogleClientId = @"252408930349-1otbutcank3df2grgcav7djt4o7c6trc.apps.googleusercontent.com";

@implementation YGAppDelegate
@synthesize appSettings = _appSettings;

- (AppSettings *)appSettings {
	return _appSettings;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	// [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
	
	// Start Google Map Services
	[GMSServices provideAPIKey:@"AIzaSyAJ4giY3hjPO4R3IBrXJ0DHDJBTPY9jQZA"];
	
	// Find the App Settings or create a new one
	NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
	// [userdefaults removeObjectForKey:@"appSettings"];
	if ([userdefaults objectForKey:@"appSettings"]) {
		NSData *userData = [userdefaults objectForKey:@"appSettings"];
		self.appSettings = (AppSettings *)[NSKeyedUnarchiver unarchiveObjectWithData:userData];
	} else
		self.appSettings = [[AppSettings alloc] init];
	
	NSLog(@"App Version: %@", kAppVersion);
	
	// Testing data encription / decription
	/*
	NSData *data = [@"Data" dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error;
	NSData *encryptedData = [RNEncryptor encryptData:data
										withSettings:kRNCryptorAES256Settings
											password:kGoogleClientId
											   error:&error];
	NSData *decryptedData = [RNDecryptor decryptData:encryptedData
										withPassword:kGoogleClientId
											   error:&error];
	NSLog(@"encripted string (Data): %@", [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
	*/
	
	self.window.clipsToBounds = YES;
	
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[self saveSettings:self];
	if ([self.appSettings.logmeOut boolValue]) {
		[FBSession.activeSession closeAndClearTokenInformation];
	}
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	
	// Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
	BOOL wasHandledByFB = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
	
	// You can add your app-specific url handling code here if needed
	BOOL wasHandledByZO = [[url scheme] isEqualToString:@"zaporbit"] ? YES : NO;
	BOOL wasHandledByG = [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
	return wasHandledByFB || wasHandledByG || wasHandledByZO ? YES : NO;
}

-(void)saveSettings:(id)sender {
	if (self.appSettings) {
		NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
		NSData *appSettingData = [NSKeyedArchiver archivedDataWithRootObject:self.appSettings];
		[userdefaults setObject:appSettingData forKey:@"appSettings"];
		
	}
}

@end

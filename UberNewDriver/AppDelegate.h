//
//  AppDelegate.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Updated by Adam on 13/12/15
//  Copyright (c) 2015 Hwindi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/SignIn.h>
#import <CoreLocation/CoreLocation.h>

#define NOTIFICATION_LOCATION_UPDATE @"Location updated"
#define APPDELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView   *viewLoading;

- (NSString *)applicationCacheDirectoryString;
- (BOOL)connected;
- (void)showLoadingWithTitle:(NSString *)title;
- (void)hideLoadingView;
- (void)showToastMessage:(NSString *)message;
- (id)setBoldFontDiscriptor:(id)objc;
-(void) showAlert:(NSString *) alertMessage;

//Location Update.
- (void) startLocationUpdate;
- (void) stopLocationUpdate;

@end

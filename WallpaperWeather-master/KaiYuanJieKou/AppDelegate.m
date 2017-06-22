//
//  AppDelegate.m
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/18.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

/*
 写在前面的话：
    我是ManoBoo，非常感谢您下载我的项目，遇到什么问题可以简书私信给我
    简书地址:
 
 */

#import "AppDelegate.h"
#import "WeatherViewController.h"
#import "SelectAddressController.h"
#import "CityManager.h"
#import "OpenPlatformUI.h"
#import <SafariCookieBridge.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window makeKeyAndVisible];
    [self setInitData];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[WeatherViewController alloc] init]];
    self.window.rootViewController = nav;
    
    [[AdmCore sharedInstance] registerPush];
    
    //打开通知处理
    if(launchOptions) {
        [[AdmCore sharedInstance] launchWithLocalNotification:launchOptions];
    }
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    if(deviceToken) {
        
        NSString *device_token =  [[[deviceToken.description stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        [AdmCore sharedInstance].deviceToken = device_token;
    }
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)notification {
    
  
}

//iOS 7 Remote Notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //silent remote notifications
    [[AdmCore sharedInstance] receiveRemoteNotification:notification fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    
    application.applicationIconBadgeNumber = [[AdmCore sharedInstance] showingAlert]?1:0;
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
    } else {
        
        NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970 - notification.fireDate.timeIntervalSince1970;
        if(timeInterval <= 0.05) {
        } else {
            [[AdmCore sharedInstance] launchWithLocalNotification:notification.userInfo];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if(application.applicationIconBadgeNumber == 0)
        application.applicationIconBadgeNumber = [[AdmCore sharedInstance] showingAlert]?1:0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(![AdmCore sharedInstance].started) {
        return;
    }
    
    __block UIBackgroundTaskIdentifier backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        //careyang 新改
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AdmCore sharedInstance] applicationWillTerminate];
            
            [[OpenPlatform platform] notifyTerminate:^(Response *response) {
                
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                backgroundTaskId = UIBackgroundTaskInvalid;
            }];
        });
        
    }];
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
    [[AdmCore sharedInstance] applicationWillTerminate];
}

-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    
    if([url.absoluteString hasPrefix:@"wxf62e2ebf9c72e661"] || [url.absoluteString hasPrefix:@"wxb9e8bb85b528ced9"]) {
        return [WXApi handleOpenURL:url delegate:[WXHelper sharedInstance]];
    }
    
    if([SafariCookieBridge openURL:url]) {
        return YES;
    }
    
    if([[AdmCore sharedInstance] application:application openURL:url options:options]) {
        return YES;
    }
    
    if([OpenRouter openUrl:url.absoluteString]) {
        return YES;
    }
    
    return NO;
}
#pragma mark - Custom

// - MARK: 是否第一次启动，如果是 则配置热门城市列表
- (void)setInitData{
    BOOL isFirstStart;
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:IsFirstStartKey];
    if (obj == nil) {
        isFirstStart = true;
    }else {
        isFirstStart = false;
    }

    if (isFirstStart ) {
        //配置热门城市列表
        [[CityManager shareInstance] setUpHotCityList];
        isFirstStart = false;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isFirstStart] forKey:IsFirstStartKey];
    }
}
@end

//
//  AppDelegate.m
//  ThueXe
//
//  Created by VMio69 on 10/1/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "MapDriverViewController.h"
#import "DataHelper.h"
#import "FilterViewController.h"
#import "ListDataViewController.h"
#import "MapPassengerViewController.h"
#import "FirstViewController.h"
#import "ActiveViewController.h"
#import <UserNotifications/UserNotifications.h>


@import GoogleMaps;
@import GooglePlaces;

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
{
    NSString *userType;
    
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_API_KEY];
    [self updateVersionApp];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    [self registerForRemoteNotifications];
    
    NSDictionary *userInfo = [DataHelper getUserData];
    NSLog(@"%@", userInfo);
    userType = @"";
    if (!userInfo) {
        _window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else{
        switch ([[userInfo objectForKey:@"userType"] intValue] ) {
            case USER_TYPE_DRIVER:
            {
                userType = REG_ID_FOR_DRIVER;
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//                if ([[userInfo objectForKey:@"wasActived"] boolValue]) {
                    NSDate *dateNeedActive = [userInfo objectForKey:@"dateNeedActive"];
                    if ([[NSDate date] compare:dateNeedActive] == NSOrderedDescending) {
                        ActiveViewController *controller = (ActiveViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"activeStoryboardId"];
                        controller.isActiveBuyCode = YES;
                        _window.rootViewController = controller;
                    }
                    else{
                        MapDriverViewController *controller = (MapDriverViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"mapDriverStoryboardId"];
                        
                        _window.rootViewController = controller;
                    }
                /*
                 Bỏ chức năng active sms khi đăng ký tài khoản
                 */
//                }
//                else{
//                    ActiveViewController *controller = (ActiveViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"activeStoryboardId"];
//                    controller.isActiveBuyCode = NO;
//                    _window.rootViewController = controller;
//                }
            }
                break;
            case USER_TYPE_PASSENGER:
            {
                userType = REG_ID_FOR_PASSENGER;
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                NSDictionary *filterData = [DataHelper getFilterData];
                
                if (!filterData) {
                    filterData = @{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""};
                }
               
                UITabBarController *tabbar = [mainStoryboard instantiateViewControllerWithIdentifier: @"listCarStoryboardId"];
                ListDataViewController *listController = [tabbar.viewControllers objectAtIndex:0];
                listController.filterData = [filterData mutableCopy];
                [tabbar setSelectedIndex:0];
                _window.rootViewController = tabbar;
            }
                break;
            default:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                FirstViewController *controller = (FirstViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"firstViewControllerStoryboardId"];
                _window.rootViewController = controller;
            }
                break;
        }
    }
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    view.backgroundColor=[UIColor colorWithRed:1/255. green:156/255. blue:160/255. alpha:1.];
    [self.window.rootViewController.view addSubview:view];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) updateVersionApp{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    [DataHelper GET:LINK_CHECK_VERSION params:nil completion:^(BOOL success, id responseObject){
        if (success && [responseObject[@"resultCount"] integerValue] == 1){
            NSString* appStoreVersion = responseObject[@"results"][0][@"version"];
            NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
            if ([currentVersion compare:appStoreVersion] == NSOrderedAscending) {
                NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
                UIAlertController *alertUpdate = [UIAlertController alertControllerWithTitle:@"Ứng dụng đã có phiên bản mới hơn" message:@"Cập nhật ứng dụng ngay." preferredStyle:UIAlertControllerStyleAlert];
                [alertUpdate addAction:[UIAlertAction actionWithTitle:@"Cập nhật" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LINK_APP_STORE]];
                    exit(0);
                }]];
                [self.window.rootViewController presentViewController:alertUpdate animated:YES completion:nil];
            }
        }
    }];
}

- (void)registerForRemoteNotifications {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    completionHandler();
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        token = [token substringWithRange:NSMakeRange(1, 64)];
        NSLog(@"deviceToken: %@", token);
//        [DataHelper setRegId:token userType:userType];
        [DataHelper setRegId:token];
    });
}


- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
{
    NSLog(@"Registering device for push notifications..."); // iOS 8
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register: %@", error);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)notification completionHandler:(void(^)())completionHandler
{
    NSLog(@"Received push notification: %@, identifier: %@", notification, identifier); // iOS 8
    completionHandler();
}

@end

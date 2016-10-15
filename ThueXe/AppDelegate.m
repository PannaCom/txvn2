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

@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:@"AIzaSyArIGsr8eBKOuQTGwQn8ekDujQpAA_Murg"];
//    [GMSPlacesClient provideAPIKey:@"AIzaSyArIGsr8eBKOuQTGwQn8ekDujQpAA_Murg"];
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    NSLog(@"%@", userInfo);
    if (!userInfo) {
        _window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else{
        switch ([[userInfo objectForKey:@"userType"] intValue] ) {
            case USER_TYPE_DRIVER:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                MapDriverViewController *controller = (MapDriverViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"mapDriverStoryboardId"];
                
                _window.rootViewController = controller;
            }
                break;
            case USER_TYPE_PASSENGER:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                NSDictionary *filterData = [DataHelper getFilterData];
                if (filterData) {
                    UITabBarController *tabbar = [mainStoryboard instantiateViewControllerWithIdentifier: @"listCarStoryboardId"];
                    ListDataViewController *listController = [tabbar.viewControllers objectAtIndex:0];
                    listController.filterData = filterData;
                    [tabbar setSelectedIndex:0];
                    _window.rootViewController = tabbar;
                }
                else{
                    FilterViewController *controller = (FilterViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"filterDataStoryboardId"];
                    controller.filterData = [NSMutableDictionary dictionaryWithDictionary:@{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""}];
                    _window.rootViewController = controller;
                }
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
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

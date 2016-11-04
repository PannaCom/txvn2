//
//  DataHelper.m
//  ThueXe
//
//  Created by VMio69 on 10/4/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "DataHelper.h"
#import "Config.h"

@implementation DataHelper

+(void)POST:(NSString*)url params:(NSDictionary*)params completion:(void(^)(BOOL success, id responseObject))completionHandler{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        completionHandler(YES, string);
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Lỗi kết nối" message:@"Hãy kiểm tra kết nối Internet." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        completionHandler(NO, error);
    }];
}

+(void)GET:(NSString*)url params:(NSDictionary*)params completion:(void(^)(BOOL success, id responseObject))completionHandler{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
         completionHandler(YES, responseObject);
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Lỗi kết nối" message:@"Hãy kiểm tra kết nối Internet." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        completionHandler(NO, error);
    }];
}

+(void)setFilterData:(NSDictionary*)filterData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:filterData forKey:@"filterData"];
    [userDefault synchronize];
}

+(NSDictionary*)getFilterData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault dictionaryForKey:@"filterData"];
}

+(void)setUserData:(NSDictionary*)userData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:userData forKey:@"userInfo"];
    [userDefault synchronize];
}

+(NSDictionary*)getUserData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault dictionaryForKey:@"userInfo"];
}

+(void)clearUserData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"filterData"];
    [userDefault removeObjectForKey:@"userInfo"];
    
    [userDefault synchronize];
}

+(void)activeUser{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[userDefault dictionaryForKey:@"userInfo"]];
    [userInfo setObject:@"YES" forKey:@"wasActived"];
    [userDefault setObject:userInfo forKey:@"userInfo"];
    [userDefault synchronize];
}

@end

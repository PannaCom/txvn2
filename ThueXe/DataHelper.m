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
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    manager.securityPolicy = policy;
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"txvnCert" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    manager.securityPolicy.pinnedCertificates = [NSSet setWithObject:localCertificate];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
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
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    manager.securityPolicy = policy;
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"txvnCert" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    manager.securityPolicy.pinnedCertificates = [NSSet setWithObject:localCertificate];
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

+ (void)GET_NO_POLICY:(NSString*)url params:(NSDictionary*)params completion:(void(^)(BOOL success, id responseObject))completionHandler{
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
    [self setData:filterData forKey:@"filterData"];
}

+(NSDictionary*)getFilterData{
    return [self getDataForKey:@"filterData"];
}

+(void)setUserData:(NSDictionary*)userData{
    [self setData:userData forKey:@"userInfo"];
}

+(NSDictionary*)getUserData{
    return [self getDataForKey:@"userInfo"];
}

+(void)clearUserData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"filterData"];
    [userDefault removeObjectForKey:@"userInfo"];
    
    [userDefault synchronize];
}

+(void)activeUser:(int)daysActive{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[userDefault dictionaryForKey:@"userInfo"]];
    [userInfo setObject:@"YES" forKey:@"wasActived"];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = daysActive;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *dateActive = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    [userInfo setObject:dateActive forKey:@"dateNeedActive"];
    
    [userDefault setObject:userInfo forKey:@"userInfo"];
    [userDefault synchronize];
}

+(void)setData:(NSDictionary*)data forKey:(NSString*)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:data forKey:key];
    [userDefault synchronize];
}

+(NSDictionary*)getDataForKey:(NSString*)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault dictionaryForKey:key];
}

+(void)setRegId:(NSString *)regId{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:regId forKey:@"regIdAPNs"];
    [userDefault synchronize];
}

+(NSString *)getRegId{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"regIdAPNs"];
}

@end

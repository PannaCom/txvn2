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

+(void)POST:(NSString*)url params:(NSDictionary*)params completion:(void(^)(BOOL success, id responseObject, NSError *error))completionHandler{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        completionHandler(YES, string, nil);
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        completionHandler(NO, nil, error);
    }];
}

+(void)GET:(NSString*)url params:(NSDictionary*)params completion:(void(^)(BOOL success, id responseObject, NSError *error))completionHandler{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
         completionHandler(YES, responseObject, nil);
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        completionHandler(NO, nil, error);
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
    [userDefault setObject:userData forKey:@"userData"];
    [userDefault synchronize];
}

+(NSDictionary*)getUserData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault dictionaryForKey:@"userData"];
}

+(void)clearUserData{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"filterData"];
    [userDefault removeObjectForKey:@"userData"];
    [userDefault synchronize];
}

@end

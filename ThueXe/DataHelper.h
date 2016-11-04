//
//  DataHelper.h
//  ThueXe
//
//  Created by VMio69 on 10/4/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHelper : NSObject

+(void)POST:(NSString*)url params:(NSDictionary*)params completion:(void(^)(BOOL success, id responseObject))completionHandler;
+(void)GET:(NSString*)url params:(NSDictionary*)params completion:(void(^)(BOOL success, id responseObject))completionHandler;
+(void)setFilterData:(NSDictionary*)filterData;
+(NSDictionary*)getFilterData;
+(void)setUserData:(NSDictionary*)userData;
+(NSDictionary*)getUserData;
+(void)clearUserData;
+(void)activeUser;
@end

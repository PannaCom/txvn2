//
//  Config.h
//  ThueXe
//
//  Created by VMio69 on 10/1/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#ifndef Config_h
#define Config_h
#import "AFNetworking.h"
#import "LocalizeHelper.h"

//api
#define URL_SERVER @"http://thuexevn.com"

#define API_GET_LIST_ONLINE [NSString stringWithFormat:@"%@/Api/getlistonline", URL_SERVER] // dùng cho hành khách
#define API_REGISTER [NSString stringWithFormat:@"%@/Api/register", URL_SERVER]
#define API_LOCATE [NSString stringWithFormat:@"%@/Api/locate", URL_SERVER]
#define API_GET_AROUND [NSString stringWithFormat:@"%@/Api/getaround", URL_SERVER] // dùng cho lái xe
#define API_GET_MADE_LIST [NSString stringWithFormat:@"%@/Api/getCarMadeList", URL_SERVER]
#define API_GET_ALL_MADE_LIST [NSString stringWithFormat:@"%@/Api/getAllCarMadeList", URL_SERVER]

#define API_GET_MODEL_LIST [NSString stringWithFormat:@"%@/Api/getCarModelListFromMade", URL_SERVER]

#define API_GET_TYPE_LIST [NSString stringWithFormat:@"%@/Api/getAllCarTypeList", URL_SERVER]

#define API_ACTIVE [NSString stringWithFormat:@"%@/Api/acitive", URL_SERVER]
#define API_ACTIVE_BUY [NSString stringWithFormat:@"%@/Api/activecode", URL_SERVER]
#define API_RESEND_ACTIVE [NSString stringWithFormat:@"%@/Api/resendactive", URL_SERVER]

#define API_POST_REG_ID [NSString stringWithFormat:@"%@/Api/PostRegId", URL_SERVER]
#define API_CALL [NSString stringWithFormat:@"%@/Api/cal", URL_SERVER]
#define WIDTH_SCREEN [UIScreen mainScreen].bounds.size.width
#define HEIGHT_SCREEN [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(int, USER_TYPE){
    USER_TYPE_PASSENGER,
    USER_TYPE_DRIVER
};

typedef NS_ENUM(int, TEXT_FIELD){
    TEXT_FIELD_CAR_MADE,
    TEXT_FIELD_CAR_MODEL,
    TEXT_FIELD_CAR_TYPE,
    TEXT_FIELD_CAR_SIZE,
    TEXT_FIELD_CAR_YEAR,
    TEXT_FIELD_CAR_PRICE
};

typedef NS_ENUM(int, CAR_STATUS){
    CAR_STATUS_ENABLE,
    CAR_STATUS_DISABLE
};
#define REG_ID_FOR_DRIVER @"1"
#define REG_ID_FOR_PASSENGER @"2"
#define DEVICE_IOS @"2"

#define CAR_SIZE @[@"4 chỗ", @"5 chỗ", @"7 chỗ", @"12 chỗ", @"16 chỗ", @"24 chỗ", @"40 chỗ", @"50 chỗ"]

#define CAR_YEAR_OLD 10
#define TIME_UPDATE_LOCATE 30 //seconds
#define DISTANCE_MAX_GET_AROUND 100 // kilomet
#define TIME_LIMIT_GET_AROUND 3600 // seconds
#define TIME_LIMIT_RESEND_CODE 60 // seconds

#define DAYS_TRIAL 30

#define LINK_APP_STORE @"https://itunes.apple.com/us/app/thue-xe/id1166862903?l=vi&ls=1&mt=8"
#define LINK_CHECK_VERSION @"http://itunes.apple.com/lookup?id=1166862903"


#endif /* Config_h */

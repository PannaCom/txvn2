//
//  BookingObject.h
//  ThueXe
//
//  Created by VMio69 on 12/7/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookingObject : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *placeFrom;
@property (strong, nonatomic) NSString *placeTo;
@property (strong, nonatomic) NSString *dateFrom;
@property (strong, nonatomic) NSString *dateTo;
@property (strong, nonatomic) NSString *carType;
@property (strong, nonatomic) NSString *carHireType;
@property (strong, nonatomic) NSString *carSize;
@property (strong, nonatomic) NSString *bookingId;

+(NSArray<BookingObject*>*)getDataFromJson:(NSArray*)input;

@end

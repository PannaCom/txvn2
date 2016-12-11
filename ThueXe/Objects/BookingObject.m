//
//  BookingObject.m
//  ThueXe
//
//  Created by VMio69 on 12/7/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "BookingObject.h"

@implementation BookingObject

+(NSArray<BookingObject*>*)getDataFromJson:(NSArray*)input{
    NSMutableArray *bookingList = [NSMutableArray new];
    for (NSDictionary *dict in input) {
        BookingObject *bookingItem = [BookingObject new];
        bookingItem.name = [dict objectForKey:@"name"];
        bookingItem.placeFrom = [dict objectForKey:@"car_from"];
        bookingItem.placeTo = [dict objectForKey:@"car_to"];
        bookingItem.phone = [dict objectForKey:@"phone"];
        bookingItem.carType = [dict objectForKey:@"car_type"];
        bookingItem.carHireType = [dict objectForKey:@"car_hire_type"];
        bookingItem.dateFrom = [dict objectForKey:@"date_from"];
        bookingItem.dateTo = [dict objectForKey:@"date_to"];
        bookingItem.carSize = [[dict objectForKey:@"car_size"] stringValue];
        bookingItem.bookingId = [[dict objectForKey:@"id"] stringValue];
        bookingItem.status = [[dict objectForKey:@"status"] boolValue];
        [bookingList addObject:bookingItem];
    }
    return bookingList;
}

@end

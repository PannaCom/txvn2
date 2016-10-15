//
//  Car.m
//  ThueXe
//
//  Created by VMio69 on 10/2/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "Car.h"

@implementation Car

-(id)init{
    self = [super init];
    return self;
}

+(NSArray<Car*>*)getDataFromJson:(NSArray*)input{
    NSMutableArray *cars = [NSMutableArray new];
    for (NSDictionary *dict in input) {
        Car *car = [Car new];
        car.name = [dict objectForKey:@"name"];
        car.distance = [[dict objectForKey:@"D"] floatValue];
        car.carNumber = [dict objectForKey:@"car_number"];
        car.phone = [dict objectForKey:@"phone"];
        car.carType = [dict objectForKey:@"car_type"];
        car.carMade = [dict objectForKey:@"car_made"];
        car.carModel = [dict objectForKey:@"car_model"];
        car.carSize = [dict objectForKey:@"car_size"];
        car.price = [dict objectForKey:@"car_price"];
        ///--- tinh toa do
        float lon = [[dict objectForKey:@"lon"] floatValue];
        float lat = [[dict objectForKey:@"lat"] floatValue];
        car.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        
        [cars addObject:car];
    }
    return cars;
}

@end

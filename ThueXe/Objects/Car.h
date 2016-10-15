//
//  Car.h
//  ThueXe
//
//  Created by VMio69 on 10/2/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@interface Car : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *carNumber;
@property (strong, nonatomic) NSString *carMade;
@property (strong, nonatomic) NSString *carModel;
@property (strong, nonatomic) NSString *carType;
@property (strong, nonatomic) NSString *carSize;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *price;
@property float distance;
@property (strong, nonatomic) CLLocation *location;

+(NSArray<Car*>*)getDataFromJson:(NSArray*)input;

@end

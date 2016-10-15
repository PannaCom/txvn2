//
//  MapPassengerViewController.h
//  ThueXe
//
//  Created by VMio69 on 10/11/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapPassengerViewController : UIViewController

@property (strong, nonatomic) NSDictionary *filterData;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

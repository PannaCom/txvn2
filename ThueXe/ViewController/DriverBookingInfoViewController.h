//
//  DriverBookingInfoViewController.h
//  ThueXe
//
//  Created by VMio69 on 1/12/17.
//  Copyright © 2017 VMio69. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@protocol DriverBookingDelegate <NSObject>

- (void)didBookingDone;

@end

@interface DriverBookingInfoViewController : UIViewController

@property CLLocationCoordinate2D locationFrom;
@property CLLocationCoordinate2D locationTo;
@property (strong, nonatomic) NSString *phone;

@property (nonatomic, weak) id <DriverBookingDelegate> delegate;
@end

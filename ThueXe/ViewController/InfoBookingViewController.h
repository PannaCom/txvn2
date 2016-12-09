//
//  InfoBookingViewController.h
//  ThueXe
//
//  Created by VMio69 on 12/4/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface InfoBookingViewController : UIViewController

@property CLLocationCoordinate2D locationFrom;
@property CLLocationCoordinate2D locationTo;
@property (strong, nonatomic) NSString *phone;

@end
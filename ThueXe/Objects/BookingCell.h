//
//  BookingCell.h
//  ThueXe
//
//  Created by VMio69 on 12/6/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookingObject.h"
#import "Config.h"

@interface BookingCell : UITableViewCell

-(void)setData:(BookingObject*)bookingObj forUser:(USER_TYPE)userType;

@end

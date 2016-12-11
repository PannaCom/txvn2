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

@protocol BookingCellDelegate <NSObject>

- (void)bookingDidUpdated:(NSString *)bookingId;
- (void)bookingDriverDidCalled:(NSString *)passengerPhone;

@end

@interface BookingCell : UITableViewCell

- (void)setData:(BookingObject*)bookingObj forUser:(USER_TYPE)userType;

@property (nonatomic, weak) id <BookingCellDelegate> delegate;

@end

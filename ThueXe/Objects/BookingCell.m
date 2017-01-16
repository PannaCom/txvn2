//
//  BookingCell.m
//  ThueXe
//
//  Created by VMio69 on 12/6/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "BookingCell.h"
#import "DataHelper.h"
#import "Config.h"

@interface BookingCell()
{
    IBOutlet UILabel *_nameLb;
    IBOutlet UILabel *_placeFromLb;
    IBOutlet UILabel *_dateFromLb;
    IBOutlet UILabel *_placeToLb;
    IBOutlet UILabel *_dateToLb;
    IBOutlet UILabel *_carTypeHirTypeLb;
    IBOutlet UILabel *_carSizeLb;
    NSString *_phone;
    NSString *_bookingId;
    
    IBOutlet NSLayoutConstraint *heightCallBtnConstraint;
    IBOutlet NSLayoutConstraint *heightDoneBtnConstraint;
    IBOutlet UIButton *_callBtn;
    IBOutlet UIButton *_doneBtn;
    IBOutlet UIButton *_cancelBtn;
    
    IBOutlet UIImageView *_completeImage;

}
@end

@implementation BookingCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(BookingObject*)bookingObj forUser:(USER_TYPE)userType{
    switch (userType) {
        case USER_TYPE_DRIVER:
            _nameLb.text = bookingObj.name;
            heightDoneBtnConstraint.constant = 0;
            _doneBtn.hidden = YES;
            _cancelBtn.hidden = YES;
            heightCallBtnConstraint.constant = self.frame.size.width/5;
            _completeImage.hidden = YES;
            break;
        case USER_TYPE_PASSENGER:
            _nameLb.text = [NSString stringWithFormat:@"#%@",bookingObj.bookingId];
           
            heightCallBtnConstraint.constant = 0;
            
            if (!bookingObj.status) {
                _completeImage.hidden = YES;
                _cancelBtn.hidden = NO;
                _doneBtn.hidden = NO;
            }
            else {
                _completeImage.hidden = NO;
                _cancelBtn.hidden = YES;
                _doneBtn.hidden = YES;
            }
            break;
        case USER_TYPE_PASSENGER_GET_DRIVER_BOOKING:
            _nameLb.text = [NSString stringWithFormat:@"#%@",bookingObj.bookingId];
            heightDoneBtnConstraint.constant = 0;
            _doneBtn.hidden = YES;
            _cancelBtn.hidden = YES;
            heightCallBtnConstraint.constant = self.frame.size.width/5;
            _completeImage.hidden = YES;
            break;
        default:
            break;
    }
    _phone = bookingObj.phone;
    _bookingId = bookingObj.bookingId;
    _placeFromLb.text = [NSString stringWithFormat:@"%@", bookingObj.placeFrom];
    _placeToLb.text = [NSString stringWithFormat:@"%@", bookingObj.placeTo];
    _dateFromLb.text = [NSString stringWithFormat:@"%@", bookingObj.dateFrom];
    _dateToLb.text = [NSString stringWithFormat:@"%@", bookingObj.dateTo];
    _carTypeHirTypeLb.text = [NSString stringWithFormat:@"%@ - %@", bookingObj.carType, bookingObj.carHireType];
    _carSizeLb.text = [NSString stringWithFormat:@"%@ chỗ", bookingObj.carSize];
}
- (IBAction)cancelBtnClick:(id)sender {
    [self updateStatusBookingItem];
}

- (IBAction)doneBtnClick:(id)sender {
    [self updateStatusBookingItem];
}

- (void)updateStatusBookingItem{
    [self.delegate bookingDidUpdated:_bookingId];
}
- (IBAction)callBtnClick:(id)sender {
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",_phone]];

    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [self.delegate bookingDriverDidCalled:_phone];
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
    else
     {
        NSLog(@"Error can't call phone.");
     }

}

@end

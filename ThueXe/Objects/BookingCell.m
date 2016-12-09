//
//  BookingCell.m
//  ThueXe
//
//  Created by VMio69 on 12/6/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "BookingCell.h"

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

-(void)setData:(BookingObject*)bookingObj forUser:(USER_TYPE)userType{
    switch (userType) {
        case USER_TYPE_DRIVER:
            _nameLb.text = bookingObj.name;
            heightDoneBtnConstraint.constant = 0;
            _doneBtn.hidden = YES;
            _cancelBtn.hidden = YES;
            heightCallBtnConstraint.constant = self.frame.size.width/5;
            break;
        case USER_TYPE_PASSENGER:
            _nameLb.text = [NSString stringWithFormat:@"#%@",bookingObj.bookingId];
           
            heightCallBtnConstraint.constant = 0;
            
            
            
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

@end

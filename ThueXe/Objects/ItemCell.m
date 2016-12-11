//
//  ItemCell.m
//  ThueXe
//
//  Created by VMio69 on 10/2/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "ItemCell.h"
#import "DataHelper.h"
#import "Config.h"

@interface ItemCell()
{
    IBOutlet UILabel *nameLb;
    IBOutlet UILabel *carMadeLb;
    IBOutlet UILabel *carModelLb;
    IBOutlet UILabel *carSizeLb;
    IBOutlet UILabel *carTypeLb;
    IBOutlet UILabel *priceLb;
    IBOutlet UILabel *phoneLb;
    IBOutlet UILabel *distanceLb;
    IBOutlet UIView *headerView;
}
@end

@implementation ItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setData:(Car*)car{
    nameLb.text = [NSString stringWithFormat:@"%@", car.name];
    carMadeLb.text = [NSString stringWithFormat:@"%@", car.carMade];
    carModelLb.text = [NSString stringWithFormat:@"%@", car.carModel];
    carTypeLb.text = [NSString stringWithFormat:@"%@", car.carType];
    carSizeLb.text = [NSString stringWithFormat:@"%@ chỗ", car.carSize];
    if ([car.price rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
        priceLb.text = [NSString stringWithFormat:@"%@ (đồng/km)", car.price];
    }
    else{
        priceLb.text = [NSString stringWithFormat:@"%@", car.price];
    }
    
    phoneLb.text = [NSString stringWithFormat:@"%@", car.phone];
    if(car.distance < 1){
        distanceLb.text = [NSString stringWithFormat:@"cách %d m", (int)(car.distance*1000)];
    }
    else{
        distanceLb.text = [NSString stringWithFormat:@"cách %.1f km", car.distance];
    }
    
}

- (IBAction)callCar:(id)sender {
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",phoneLb.text]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [DataHelper POST:API_LOG_PASSENGER_CALL_DRIVER params:@{@"phone":phoneLb.text} completion:^(BOOL success, id responseObject){
            NSLog(@"Post Call number: %@", responseObject);
        }];
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
    else
    {
        NSLog(@"Error can't call phone.");
    }
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:(CGPoint){0, 0}];
    [path addLineToPoint:(CGPoint){headerView.frame.size.width, 0}];
    [path addLineToPoint:(CGPoint){headerView.frame.size.width - 40, headerView.frame.size.height}];
    [path addLineToPoint:(CGPoint){0, headerView.frame.size.height}];
    
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.frame = headerView.bounds;
    mask.path = path.CGPath;
    
    headerView.layer.mask = mask;
}

@end

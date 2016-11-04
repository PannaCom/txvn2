//
//  CarTypeItem.m
//  ThueXe
//
//  Created by VMio69 on 10/28/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "CarTypeItem.h"

@interface CarTypeItem()
{
    IBOutlet UIImageView *imageCar;
    IBOutlet UILabel *carTypeLb;
    
}
@end

@implementation CarTypeItem

-(void)setCarType:(NSString*)carType withImage:(NSString*)image{
    [carTypeLb setText:carType];
    [imageCar setImage:[UIImage imageNamed:image]];
    self.layer.borderWidth = 2.f;
    self.layer.cornerRadius = 10.;
    self.layer.borderColor = [UIColor colorWithRed:1/255. green:156/255. blue:160/255. alpha:1.].CGColor;
}

@end

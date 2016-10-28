//
//  ImageHeaderView.m
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/3/29.
//  Copyright © 2016年 pluto-y. All rights reserved.
//
#import "Config.h"
#import "ImageHeaderView.h"

@implementation ImageHeaderView

-(void)awakeFromNib {
    [super awakeFromNib];
    [super layoutIfNeeded];
    self.profileImage.layer.cornerRadius = self.frame.size.height*0.9 * 0.6 / 231 * 191 / 4;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 1;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end

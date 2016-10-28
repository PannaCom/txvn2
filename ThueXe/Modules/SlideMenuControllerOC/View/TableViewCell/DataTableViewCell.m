//
//  DataTableViewCell.m
//  SlideMenuControllerOC
//
//  Created by ChipSea on 16/3/29.
//  Copyright © 2016年 pluto-y. All rights reserved.
//
#import "Config.h"
#import "DataTableViewCell.h"

@implementation DataTableViewCellData

@end

@implementation DataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dataText.font = [UIFont systemFontOfSize:18];
    self.dataText.textColor = [UIColor blackColor];
}

+(CGFloat)height {
    return 50;
}

-(void)setData:(id)data {
    if ([data isKindOfClass:[DataTableViewCellData class]]) {
        [self.dataImage setImage:[UIImage imageNamed:((DataTableViewCellData*)data).imageUrl]];
        
        self.dataText.text = ((DataTableViewCellData *)data).text;
    }
}

@end

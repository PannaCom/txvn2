//
//  TUFTriangleView.m
//
//  Created by Olga Dalton on 11/08/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView

-(void)drawRect:(CGRect)rect {
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.frame = self.layer.bounds;
    
    CGFloat width = self.layer.frame.size.width;
    CGFloat height = self.layer.frame.size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, nil, 0, 0);
    CGPathAddLineToPoint(path, nil, width, 0);
    CGPathAddLineToPoint(path, nil, width-30, height);
    CGPathAddLineToPoint(path, nil, 0, height);
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathCloseSubpath(path);
    
    mask.path = path;
    CGPathRelease(path);
    
    self.layer.mask = mask;
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = self.bounds;
    shape.path = path;
    shape.lineWidth = 3.0f;
    shape.strokeColor = [UIColor whiteColor].CGColor;
    shape.fillColor = [UIColor clearColor].CGColor;
    
    [self.layer insertSublayer: shape atIndex:0];
}

@end

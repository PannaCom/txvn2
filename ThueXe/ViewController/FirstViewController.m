//
//  FirstViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/1/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "FirstViewController.h"
#import "RegisterViewController.h"
#import "ListDataViewController.h"
#import "Config.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
////    label.backgroundColor = [UIColor clearColor];
//    label.numberOfLines = 2;
//    label.font = [UIFont boldSystemFontOfSize: 16.0f];
//    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    label.text = @"Lần đầu sử dụng.\nHãy chọn vai trò của bạn";
//    self.navigationItem.titleView = label;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"driverRegisterSegueId"]) {
        RegisterViewController *controller = [segue destinationViewController];
        controller.isEdit = NO;
    }
}

@end

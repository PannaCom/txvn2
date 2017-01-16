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
#import "DataHelper.h"

@interface FirstViewController ()
{
    IBOutlet UIButton *passengerBtn;
    
    IBOutlet UIButton *driverBtn;
}
@end

@implementation FirstViewController
#pragma mark - LifeCycle View Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    float sizeFont = passengerBtn.frame.size.height/2;
    NSLog(@"%f", WIDTH_SCREEN);
    if (WIDTH_SCREEN > 320) {
        sizeFont = passengerBtn.frame.size.height/2;
    }
    
    passengerBtn.titleLabel.font = [UIFont systemFontOfSize:sizeFont];
    driverBtn.titleLabel.font = [UIFont systemFontOfSize:sizeFont];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self prefersStatusBarHidden];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"driverRegisterSegueId"]) {
        RegisterViewController *controller = [segue destinationViewController];
        controller.isEdit = NO;
    }

    if ([[segue identifier] isEqualToString:@"gotoPassengerMainSegueId"]) {
        [DataHelper setUserData:@{@"userType":[NSString stringWithFormat:@"%d", USER_TYPE_PASSENGER]}];
    }
}

@end

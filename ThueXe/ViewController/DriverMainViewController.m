//
//  DriverMainViewController.m
//  ThueXe
//
//  Created by VMio69 on 12/10/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "DriverMainViewController.h"
#import "CAPSPageMenu.h"
#import "MapDriverViewController.h"
#import "GetBookingViewController.h"
#import "RegisterViewController.h"
#import "DataHelper.h"
#import "FirstViewController.h"
#import "BookingViewController.h"

@interface DriverMainViewController ()
{
    CAPSPageMenu *_pageMenu;
//    GetBookingViewController *infoVc;
//    MapDriverViewController *mapVc;
    IBOutlet UIView *_titleView;
}
@end

@implementation DriverMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *controllers = [NSMutableArray new];
    
    GetBookingViewController *infoVc = (GetBookingViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"getBookingStoryboardId"];
    infoVc.title = @"Hành khách";
    infoVc.userType = USER_TYPE_DRIVER;
    [controllers addObject:infoVc];
    
    MapDriverViewController *mapVc = (MapDriverViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"mapDriverStoryboardId"];
    mapVc.title = @"Xe xung quanh";
    [controllers addObject:mapVc];
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:200/255.0 green:200/255.0 blue:0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor orangeColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:17.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth: @(YES)
                                 };
    CGRect rectTitleView = _titleView.frame;
    CGRect rectSelfView = self.view.frame;
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllers frame:CGRectMake(0.0, CGRectGetMinY(rectTitleView) + CGRectGetHeight(rectTitleView), CGRectGetWidth(rectSelfView), CGRectGetHeight(rectSelfView) -(CGRectGetMinY(rectTitleView) + CGRectGetHeight(rectTitleView))) options:parameters];
    [_pageMenu setMenuItemFont: [UIFont systemFontOfSize:18.0]];
    _pageMenu.viewBackgroundColor = [UIColor clearColor];
    [self.view addSubview:_pageMenu.view];
//    _pageMenu.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editUserBtnClick:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"registerStoryboardId"];
    vc.isEdit = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeUser = [UIAlertAction actionWithTitle:LocalizedString(@"CHANGE_USER") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [DataHelper clearUserData];
        FirstViewController *firstViewController = (FirstViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"firstViewControllerStoryboardId"];

        [self.navigationController pushViewController:firstViewController animated:YES];
    }];

    UIAlertAction *booking = [UIAlertAction actionWithTitle:@"Đăng chuyến Chiều về/Đi chung" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self performSegueWithIdentifier:@"driverBookingSegueId" sender:self];
    }];
    [menu addAction:booking];

    UIAlertAction *bookingThuaKhach = [UIAlertAction actionWithTitle:@"Đăng chuyến thừa khách" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        BookingViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"passengerBookingStoryboardId"];
        vc.userType = USER_TYPE_DRIVER;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [menu addAction:bookingThuaKhach];

    UIAlertAction *share = [UIAlertAction actionWithTitle:@"Mời người sử dụng" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *textToShare = @"Bạn cần thuê xe hay bạn là tài xế/nhà xe/hãng xe có xe riêng, hãy dùng thử ứng dụng thuê xe  trên di động tại: ";
        NSURL *myWebsite = [NSURL URLWithString:@"http://thuexevn.com"];

        NSArray *objectsToShare = @[textToShare, myWebsite];

        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

        [self presentViewController:activityVC animated:YES completion:nil];
    }];
    [menu addAction:share];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:LocalizedString(@"CANCEL") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [menu dismissViewControllerAnimated:YES completion:nil];
    }];
    [menu addAction:changeUser];
    [menu addAction:cancel];
    [self presentViewController:menu animated:YES completion:nil];
}


@end

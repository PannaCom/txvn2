//
//  BookingViewController.m
//  ThueXe
//
//  Created by VMio69 on 12/4/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "BookingViewController.h"
#import "CAPSPageMenu.h"
#import "MapBookingViewController.h"
#import "InfoBookingViewController.h"
#import "GetBookingViewController.h"

@interface BookingViewController ()<CAPSPageMenuDelegate, BookingDelegate>
{
    CAPSPageMenu *_pageMenu;
    IBOutlet UIView *_titleView;
    InfoBookingViewController *infoVc;
    MapBookingViewController *mapVc;
}
@end

@implementation BookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *controllers = [NSMutableArray new];
    
    infoVc = (InfoBookingViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"infoBoogkingStoryboardId"];
    infoVc.title = @"Thông tin";
    [controllers addObject:infoVc];
    
    mapVc = (MapBookingViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"mapBoogkingStoryboardId"];
    mapVc.title = @"Bản đồ";
    [controllers addObject:mapVc];
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:200/255.0 green:200/255.0 blue:0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor orangeColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:23.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth: @(YES)
                                 };
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllers frame:CGRectMake(0.0, _titleView.frame.origin.y+_titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(_titleView.frame.origin.y+_titleView.frame.size.height)) options:parameters];
    _pageMenu.viewBackgroundColor = [UIColor colorWithRed:184./255. green:184./255. blue:184./255. alpha:0.6];
    [self.view addSubview:_pageMenu.view];
    _pageMenu.delegate = self;
    infoVc.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menuAlert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *itemMenu = [UIAlertAction actionWithTitle:@"Danh sách xe đã đặt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self performSegueWithIdentifier:@"getPassengerBookingSegueId" sender:self];
    }];
    UIAlertAction *itemCancel = [UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [menuAlert dismissViewControllerAnimated:YES completion:nil];
    }];
    [menuAlert addAction:itemMenu];
    [menuAlert addAction:itemCancel];
    [self presentViewController:menuAlert animated:YES completion:nil];
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index{
    mapVc.locationFrom = infoVc.locationFrom;
    mapVc.locationTo = infoVc.locationTo;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"getPassengerBookingSegueId"]) {
        GetBookingViewController *getBookingVc = (GetBookingViewController*)[segue destinationViewController];
        getBookingVc.phone = infoVc.phone;
        getBookingVc.userType = USER_TYPE_PASSENGER;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"getPassengerBookingSegueId"]) {
        if ([infoVc.phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            return YES;
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Chưa nhập số điện thoại" message:@"Hãy nhập số điện thoại của bạn" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            return NO;
        }
        
    }
    return YES;
}

- (void)didBookingDone{
     [self performSegueWithIdentifier:@"getPassengerBookingSegueId" sender:self];
}

@end

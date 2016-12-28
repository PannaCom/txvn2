//
//  GetBookingViewController.m
//  ThueXe
//
//  Created by VMio69 on 12/4/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "GetBookingViewController.h"
#import "DataHelper.h"
#import "Config.h"
#import <CoreLocation/CoreLocation.h>
#import "BookingCell.h"
#import "BookingObject.h"
#import "UIScrollView+SVPullToRefresh.h"

@interface GetBookingViewController ()<CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource, BookingCellDelegate>
{
    CLLocationManager *locationManager;
    
    IBOutlet UITableView *_tableView;
    NSArray *_data;
    IBOutlet UIView *_titleView;
    BOOL getBookingNow;
    IBOutlet NSLayoutConstraint *heightTitleViewConstraint;
}
@property CLLocation *currentLocation;
@end

@implementation GetBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *userInfo = [DataHelper getUserData];
    _data = [NSArray new];
    
    
    
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"BookingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"bookingCellId"];
    
    switch (_userType) {
        case USER_TYPE_DRIVER:
        {
            _phone = userInfo[@"data"][@"phone"];
            [DataHelper POST:API_POST_REG_ID_USER params:@{@"os":DEVICE_IOS, @"phone":_phone, @"regId":[DataHelper getRegId]} completion:^(BOOL success, id responseObject){
                NSLog(@"log regID: %@", responseObject);
            }];
            
            heightTitleViewConstraint.constant = 0;
            _titleView.hidden = YES;
            
            
            // init location manager
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
                [locationManager requestAlwaysAuthorization];
            [locationManager startUpdatingLocation];
            _currentLocation = [CLLocation new];
            getBookingNow = YES;
            
            __weak typeof(self) weakSelf = self;
            __weak UITableView *weakTableView = _tableView;
            [_tableView addPullToRefreshWithActionHandler:^{
                [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH") forState:SVPullToRefreshStateAll];
                [weakTableView.pullToRefreshView setTitle:LocalizedString(@"RELEASE_TO_REFRESH") forState:SVPullToRefreshStateTriggered];
                [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH_LOADING") forState:SVPullToRefreshStateLoading];
                NSString *lon = [NSString stringWithFormat:@"%.6f", weakSelf.currentLocation.coordinate.longitude];
                NSString *lat = [NSString stringWithFormat:@"%.6f", weakSelf.currentLocation.coordinate.latitude];
                [DataHelper GET:API_DRIVER_GET_BOOKING params:@{@"lon":lon, @"lat":lat} completion:^(BOOL success, id responseObject){
                    [weakTableView.pullToRefreshView stopAnimating];
                    if (success) {
                        _data = [BookingObject getDataFromJson:responseObject];
                        [weakTableView reloadData];
                    }
                }];
            }];
        }
            break;
        case USER_TYPE_PASSENGER:
        {
            __weak typeof(self) weakSelf = self;
            __weak UITableView *weakTableView = _tableView;
            [_tableView addPullToRefreshWithActionHandler:^{
                [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH") forState:SVPullToRefreshStateAll];
                [weakTableView.pullToRefreshView setTitle:LocalizedString(@"RELEASE_TO_REFRESH") forState:SVPullToRefreshStateTriggered];
                [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH_LOADING") forState:SVPullToRefreshStateLoading];
                [DataHelper GET:API_PASSENGER_GET_BOOKING params:@{@"phone":weakSelf.phone} completion:^(BOOL success, id responseObject){
                    [weakTableView.pullToRefreshView stopAnimating];
                    if (success) {
                        _data = [BookingObject getDataFromJson:responseObject];
                        [weakTableView reloadData];
                    }
                }];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegates 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX(_data.count, 1);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_data.count == 0) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"Chưa có thông tin đặt xe";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    else{
        BookingCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"bookingCellId" forIndexPath:indexPath];
        [cell setData:(BookingObject*)[_data objectAtIndex:indexPath.row] forUser:_userType];
        cell.delegate = self;
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_data.count == 0) {
        return 70;
    }
    return 240;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
#pragma mark - Events
- (IBAction)backBtnClick:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"fromPassengerGetBookingToListDataUnwindSegueId" sender:self];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    _currentLocation = locations.firstObject;
    if (getBookingNow) {
        getBookingNow = NO;
        [self getBooking];
    }
}

-(void)getBooking{
    switch (_userType) {
        case USER_TYPE_DRIVER:
        {
            NSString *lon = [NSString stringWithFormat:@"%.6f", _currentLocation.coordinate.longitude];
            NSString *lat = [NSString stringWithFormat:@"%.6f", _currentLocation.coordinate.latitude];
            [DataHelper GET:API_DRIVER_GET_BOOKING params:@{@"lon":lon, @"lat":lat} completion:^(BOOL success, id responseObject){
                if (success) {
                    _data = [BookingObject getDataFromJson:responseObject];
                    [_tableView reloadData];
                }
            }];
        }
            break;
        case USER_TYPE_PASSENGER:
        {
            [DataHelper GET:API_PASSENGER_GET_BOOKING params:@{@"phone":_phone} completion:^(BOOL success, id responseObject){
                if (success) {
                    _data = [BookingObject getDataFromJson:responseObject];
                    [_tableView reloadData];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)bookingDidUpdated:(NSString *)bookingId{
    [DataHelper POST:API_PASSENGER_UPDATE_BOOKING params:@{@"id_booking":bookingId} completion:^(BOOL success, id responeObject){
        if (success && [responeObject isEqualToString:@"1"]) {
            [self getBooking];
        }
    }];
}

- (void)bookingDriverDidCalled:(NSString *)passengerPhone{
    [DataHelper POST:API_LOG_DRIVER_CALL_PASSENGER params:@{@"from_number":_phone, @"to_number":passengerPhone} completion:^(BOOL success, id responseObject){
        NSLog(@"Log driver call passenger: %@", responseObject);
    }];
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

    
    UIAlertAction *booking = [UIAlertAction actionWithTitle:@"Đặt xe" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"fromPassengerGetBookingToBookingUnwindSegueId" sender:self];
    }];
    [menu addAction:booking];
    
    UIAlertAction *share = [UIAlertAction actionWithTitle:@"Mời người sử dụng" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *textToShare = @"Bạn cần thuê xe hay bạn là tài xế/nhà xe/hãng xe có xe riêng, hãy dùng thử ứng dụng thuê xe  trên di động tại ";
        NSURL *myWebsite = [NSURL URLWithString:@"http://thuexevn.com"];
        
        NSArray *objectsToShare = @[textToShare, myWebsite];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }];
    [menu addAction:share];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:LocalizedString(@"CANCEL") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [menu dismissViewControllerAnimated:YES completion:nil];
    }];
    [menu addAction:cancel];
    [self presentViewController:menu animated:YES completion:nil];
}


@end

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

@interface GetBookingViewController ()<CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    CLLocationManager *locationManager;
    CLLocation *_currentLocation;
    IBOutlet UITableView *_tableView;
    NSArray *_data;
    IBOutlet UIView *_titleView;
    BOOL getBookingNow;
}
@end

@implementation GetBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *userInfo = [DataHelper getUserData];
    if (_userType == USER_TYPE_DRIVER) {
        NSString *phone = userInfo[@"data"][@"phone"];
        [DataHelper POST:API_POST_REG_ID_USER params:@{@"os":DEVICE_IOS, @"phone":phone, @"regId":[DataHelper getRegId]} completion:^(BOOL success, id responseObject){
            NSLog(@"log regID: %@", responseObject);
        }];
    }
    
    _data = [NSArray new];
    
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
    
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"BookingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"bookingCellId"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_userType == USER_TYPE_PASSENGER) {
        [self getBooking];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegates 
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX(_data.count, 1);
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_data.count == 0) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"Chưa có thông tin đặt xe";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    else{
        BookingCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"bookingCellId" forIndexPath:indexPath];
        [cell setData:(BookingObject*)[_data objectAtIndex:indexPath.row] forUser:_userType];
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_data.count == 0) {
        return 70;
    }
    return 240;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
#pragma mark - Events
- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    _currentLocation = locations.firstObject;
//    if (getBookingNow) {
//        getBookingNow = NO;
//        [self getBooking];
//    }
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

@end

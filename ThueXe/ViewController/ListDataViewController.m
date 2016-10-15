//
//  ListDataViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/2/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "ListDataViewController.h"
#import "FirstViewController.h"
#import "DataHelper.h"
#import "Config.h"
#import <CoreLocation/CoreLocation.h>
#import "ItemCell.h"
#import "Car.h"
#import "FilterViewController.h"
#import "MapPassengerViewController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+EmptyDataSet.h"

@interface ListDataViewController ()<CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
{
    CLLocationManager *locationManager;
    
    IBOutlet UITableView *_tableView;
    BOOL getListOnlineNow;
    
}

@property CLLocation *currentLocation;
@end

@implementation ListDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    _currentLocation = [CLLocation new];
    
    _cars = [NSArray new];
    [_tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"carCellId"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@{@"userType":[NSString stringWithFormat:@"%d", USER_TYPE_PASSENGER]} forKey:@"userInfo"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterData:) name:@"filterDataNoti" object:nil];
    if (!_filterData) {
        _filterData = @{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""};
    }
    
    self.tabBarController.delegate = self;
    
//    _tableView.emptyDataSetSource = self;
//    _tableView.emptyDataSetDelegate = self;
    _tableView.tableFooterView = [UIView new];
    
    __weak UITableView *weakTableView = _tableView;
    __weak typeof(self) weakSelf = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        [weakTableView.pullToRefreshView setTitle:@"Kéo để cập nhật" forState:SVPullToRefreshStateAll];
        [weakTableView.pullToRefreshView setTitle:@"Thả ra để cập nhật" forState:SVPullToRefreshStateTriggered];
        [weakTableView.pullToRefreshView setTitle:@"Đang cập nhật" forState:SVPullToRefreshStateLoading];
        
        CLLocationCoordinate2D currCoordinate = weakSelf.currentLocation.coordinate;
        NSString *lon = [NSString stringWithFormat:@"%f", currCoordinate.longitude];
        NSString *lat = [NSString stringWithFormat:@"%f", currCoordinate.latitude];
        NSString *carSize = [weakSelf.filterData objectForKey:@"car_size"];
        if (carSize.length > 1) {
            carSize = [carSize substringToIndex:[carSize rangeOfString:@" "].location];
        }
        [DataHelper GET:API_GET_LIST_ONLINE params:@{@"lon":lon, @"lat":lat, @"car_made":[weakSelf.filterData objectForKey:@"car_made"], @"car_model":[weakSelf.filterData objectForKey:@"car_model"], @"car_size":carSize, @"car_type":[weakSelf.filterData objectForKey:@"car_type"]} completion:^(BOOL success, id responseObject, NSError *error){
            [weakTableView.pullToRefreshView stopAnimating];
            if (success) {
                NSLog(@"list online: %@", responseObject);
                _cars = [Car getDataFromJson:responseObject];
                [weakTableView reloadData];
            }
            else{
                NSLog(@"error: %@, response %@", error, responseObject);
            }
        }];
    }];
}

-(void)filterData:(NSNotification *)noti{
    _filterData = [[noti userInfo] objectForKey:@"filterData"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    getListOnlineNow = YES;
    [_tableView triggerPullToRefresh];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];

}



-(void)getListOnline{
    CLLocationCoordinate2D currCoordinate = _currentLocation.coordinate;
    NSString *lon = [NSString stringWithFormat:@"%f", currCoordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f", currCoordinate.latitude];
    NSString *carSize = [_filterData objectForKey:@"car_size"];
    if (carSize.length > 1) {
        carSize = [carSize substringToIndex:[carSize rangeOfString:@" "].location];
    }
    [DataHelper GET:API_GET_LIST_ONLINE params:@{@"lon":lon, @"lat":lat, @"car_made":[_filterData objectForKey:@"car_made"], @"car_model":[_filterData objectForKey:@"car_model"], @"car_size":carSize, @"car_type":[_filterData objectForKey:@"car_type"]} completion:^(BOOL success, id responseObject, NSError *error){
        if (success) {
            NSLog(@"list online: %@", responseObject);
            _cars = [Car getDataFromJson:responseObject];
            [_tableView reloadData];
        }
        else{
            NSLog(@"error: %@, response %@", error, responseObject);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeUser = [UIAlertAction actionWithTitle:@"Đổi vai trò" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [DataHelper clearUserData];
        FirstViewController *firstViewController = (FirstViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"firstViewControllerStoryboardId"];
        
        [self presentViewController:firstViewController animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [menu dismissViewControllerAnimated:YES completion:nil];
    }];
    [menu addAction:changeUser];
    [menu addAction:cancel];
    [self presentViewController:menu animated:YES completion:nil];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    _currentLocation = locations.firstObject;
    if (getListOnlineNow) {
        getListOnlineNow = NO;
        [self getListOnline];
    }
}

#pragma mark -UITableViewDelegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX(_cars.count, 1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_cars.count == 0) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"Chưa tìm được xe nào";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    else{
        ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"carCellId" forIndexPath:indexPath];
        [cell setData:[_cars objectAtIndex:indexPath.row]];
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_cars.count == 0) {
        return 70;
    }
    return 170;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[MapPassengerViewController class]]) {
        MapPassengerViewController *controller = (MapPassengerViewController*)viewController;
        controller.filterData = _filterData;
        controller.currentLocation = _currentLocation;
    }
    return YES;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_data.png"];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    [self getListOnline];
}

- (IBAction)filterBtnClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FilterViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"filterDataStoryboardId"];
    vc.filterData = [NSMutableDictionary dictionaryWithDictionary:_filterData];
    [self presentViewController:vc animated:YES completion:nil];
}


@end

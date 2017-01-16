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
#import "CarTypeItem.h"
#import "GetBookingViewController.h"
#import "BookingViewController.h"

@interface ListDataViewController ()<CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    CLLocationManager *locationManager;
    
    IBOutlet UITableView *_tableView;
    BOOL getListOnlineNow;
    
    IBOutlet UICollectionView *carTypeCollectionView;
//    NSArray *carTypeNames;
//    NSArray *carTypeImages;
    NSIndexPath *selectedIndexPath;
    NSArray *carTypes;
}

@property CLLocation *currentLocation;
@end

@implementation ListDataViewController
#pragma mark - LifeCycle View Methods
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
    
    carTypes = [NSArray new];
    
    _cars = [NSArray new];
    [_tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"carCellId"];
    
    
    NSDictionary *userInfo = [DataHelper getUserData];
    switch ([userInfo[@"userType"] intValue]) {
        case USER_TYPE_DRIVER:
            [DataHelper setUserData:@{@"userType":[NSString stringWithFormat:@"%d", USER_TYPE_PASSENGER]}];
            break;
        case USER_TYPE_PASSENGER:
            
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterData:) name:@"filterDataNoti" object:nil];
    if (!_filterData) {
        _filterData = [NSMutableDictionary dictionaryWithDictionary:@{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""}];
    }
    
    self.tabBarController.delegate = self;
    
    _tableView.tableFooterView = [UIView new];
    
    __weak UITableView *weakTableView = _tableView;
    __weak typeof(self) weakSelf = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH") forState:SVPullToRefreshStateAll];
        [weakTableView.pullToRefreshView setTitle:LocalizedString(@"RELEASE_TO_REFRESH") forState:SVPullToRefreshStateTriggered];
        [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH_LOADING") forState:SVPullToRefreshStateLoading];
        
        CLLocationCoordinate2D currCoordinate = weakSelf.currentLocation.coordinate;
        NSString *lon = [NSString stringWithFormat:@"%f", currCoordinate.longitude];
        NSString *lat = [NSString stringWithFormat:@"%f", currCoordinate.latitude];
        NSString *carSize = [weakSelf.filterData objectForKey:@"car_size"];
        if (carSize.length > 1) {
            carSize = [carSize substringToIndex:[carSize rangeOfString:@" "].location];
        }
        [DataHelper GET:API_GET_LIST_ONLINE params:@{@"lon":lon, @"lat":lat, @"car_made":[weakSelf.filterData objectForKey:@"car_made"], @"car_model":[weakSelf.filterData objectForKey:@"car_model"], @"car_size":carSize, @"car_type":[weakSelf.filterData objectForKey:@"car_type"], @"order":@"0"} completion:^(BOOL success, id responseObject){
            [weakTableView.pullToRefreshView stopAnimating];
            if (success) {
                _cars = [Car getDataFromJson:responseObject];
                [weakTableView reloadData];
            }
            else{
                NSLog(@"Error: %@", responseObject);
            }
        }];
    }];
    
    [carTypeCollectionView setAllowsMultipleSelection:NO];
    NSString *carType = [_filterData objectForKey:@"car_type"];
    [DataHelper GET:API_GET_TYPE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            carTypes = [responseObject valueForKey:@"name"];
            if (carType.length == 0) {
                selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                [carTypeCollectionView reloadData];
            }
            else{
                selectedIndexPath = [NSIndexPath indexPathForItem:[carTypes indexOfObject:carType]+1 inSection:0];
                [carTypeCollectionView scrollToItemAtIndexPath:selectedIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                [carTypeCollectionView reloadData];
            }
            
        }
    }];
//    [DataHelper sendRegIdUserType:REG_ID_FOR_PASSENGER];
}

-(void)filterData:(NSNotification *)noti{
    _filterData = [[[noti userInfo] objectForKey:@"filterData"] mutableCopy];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    getListOnlineNow = YES;
    [_tableView triggerPullToRefresh];
//    [self prefersStatusBarHidden];
    NSString *carType = [_filterData objectForKey:@"car_type"];
    if (carType.length == 0) {
        selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [carTypeCollectionView reloadData];
    }
    else{
        selectedIndexPath = [NSIndexPath indexPathForItem:[carTypes indexOfObject:carType]+1 inSection:0];
        [carTypeCollectionView scrollToItemAtIndexPath:selectedIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        [carTypeCollectionView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX(_cars.count, 1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_cars.count == 0) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = LocalizedString(@"LISTDATA_EMTY");
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

#pragma mark - UITabbarViewDelegate Methods
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[MapPassengerViewController class]]) {
        MapPassengerViewController *controller = (MapPassengerViewController*)viewController;
        controller.filterData = _filterData;
        controller.currentLocation = _currentLocation;
    }
    return YES;
}

#pragma mark - Events
- (IBAction)filterBtnClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FilterViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"filterDataStoryboardId"];
    vc.filterData = _filterData;
    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

-(void)getListOnline{
    CLLocationCoordinate2D currCoordinate = _currentLocation.coordinate;
    NSString *lon = [NSString stringWithFormat:@"%f", currCoordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f", currCoordinate.latitude];
    NSString *carSize = [_filterData objectForKey:@"car_size"];
    if (carSize.length > 1) {
        carSize = [carSize substringToIndex:[carSize rangeOfString:@" "].location];
    }
    [DataHelper GET:API_GET_LIST_ONLINE params:@{@"lon":lon, @"lat":lat, @"car_made":[_filterData objectForKey:@"car_made"], @"car_model":[_filterData objectForKey:@"car_model"], @"car_size":carSize, @"car_type":[_filterData objectForKey:@"car_type"], @"order":@"0"} completion:^(BOOL success, id responseObject){
        if (success) {
//            NSLog(@"list online: %@", responseObject);
            _cars = [Car getDataFromJson:responseObject];
            [_tableView reloadData];
        }
        else{
            NSLog(@"error: %@", responseObject);
        }
    }];
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeUser = [UIAlertAction actionWithTitle:LocalizedString(@"CHANGE_USER") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [DataHelper clearUserData];
        FirstViewController *firstViewController = (FirstViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"firstViewControllerStoryboardId"];
        
        [self.navigationController pushViewController:firstViewController animated:YES];
    }];
    
    UIAlertAction *booking = [UIAlertAction actionWithTitle:@"Đặt xe" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self performSegueWithIdentifier:@"bookingSegueId" sender:self];
    }];
    [menu addAction:booking];

    UIAlertAction *getBooking = [UIAlertAction actionWithTitle:@"Tìm chuyến chiều về đi chung" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        GetBookingViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"getBookingStoryboardId"];
        vc.userType = USER_TYPE_PASSENGER_GET_DRIVER_BOOKING;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [menu addAction:getBooking];
    
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


#pragma mark - UICollectionView Delegate Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return carTypes.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CarTypeItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"carTypeItemId" forIndexPath:indexPath];
    
    if (indexPath.item == 0) {
        [cell setCarType:@"Tất cả" withImage:@"all_car.png"];
    }
    else{
        NSString *carTypeName = [carTypes objectAtIndex:indexPath.item-1];
        NSString *carTypeImage = @"";
        if ([carTypeName isEqualToString:@""]) {
            carTypeImage = @"";
        }
        else{
            if ([carTypeName isEqualToString:@"xe tự do"]) {
                carTypeImage = @"free_car.png";
            }
            else{
                if ([carTypeName containsString:@"taxi"]) {
                    carTypeImage = @"taxi.png";
                }
                else{
                    if ([carTypeName isEqualToString:@"xe cưới"]) {
                        carTypeImage = @"wedding_car.png";
                    }
                    else{
                        if ([carTypeName isEqualToString:@"xe hợp đồng"]) {
                            carTypeImage = @"contract_car.png";
                        }
                        else{
                            if ([carTypeName isEqualToString:@"xe tự lái"]) {
                                carTypeImage = @"self_driver.png";
                            }
                            else{
                                if ([carTypeName containsString:@"xe tải"]) {
                                    carTypeImage = @"delivery_car.png";
                                }
                                else{
                                    if ([carTypeName containsString:@"container"]) {
                                        carTypeImage = @"container.png";
                                    }
                                    else{
                                        if ([carTypeName containsString:@"xe khách"]) {
                                            carTypeImage = @"coach.png";
                                        }
                                        else{
                                            carTypeImage = @"other_car.png";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        [cell setCarType:carTypeName withImage:carTypeImage];
    }
    
    
    if (indexPath.item == selectedIndexPath.item) {
        [cell.contentView setBackgroundColor:[UIColor yellowColor]];
    }
    else{
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(110, 70);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndexPath = indexPath;
    if (indexPath.item == 0) {
        [_filterData setObject:@"" forKey:@"car_type"];
    }
    else{
        [_filterData setObject:[carTypes objectAtIndex:indexPath.item-1] forKey:@"car_type"];
    }
    [self getListOnline];
    [collectionView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"bookingSegueId"]) {
        BookingViewController *vc = [segue destinationViewController];
        vc.userType = USER_TYPE_PASSENGER;
    }
}

@end

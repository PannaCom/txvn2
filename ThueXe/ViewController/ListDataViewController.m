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

@interface ListDataViewController ()<CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    CLLocationManager *locationManager;
    
    IBOutlet UITableView *_tableView;
    BOOL getListOnlineNow;
    
    IBOutlet UICollectionView *carTypeCollectionView;
    NSArray *carTypeNames;
    NSArray *carTypeImages;
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
    
    
    
    _cars = [NSArray new];
    [_tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"carCellId"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@{@"userType":[NSString stringWithFormat:@"%d", USER_TYPE_PASSENGER]} forKey:@"userInfo"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterData:) name:@"filterDataNoti" object:nil];
    if (!_filterData) {
        _filterData = [NSMutableDictionary dictionaryWithDictionary:@{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""}];
    }
    
    self.tabBarController.delegate = self;
    
//    _tableView.emptyDataSetSource = self;
//    _tableView.emptyDataSetDelegate = self;
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
        [DataHelper GET:API_GET_LIST_ONLINE params:@{@"lon":lon, @"lat":lat, @"car_made":[weakSelf.filterData objectForKey:@"car_made"], @"car_model":[weakSelf.filterData objectForKey:@"car_model"], @"car_size":carSize, @"car_type":[weakSelf.filterData objectForKey:@"car_type"], @"order":@"0"} completion:^(BOOL success, id responseObject, NSError *error){
            [weakTableView.pullToRefreshView stopAnimating];
            if (success) {
//                NSLog(@"list online: %@", responseObject);
                _cars = [Car getDataFromJson:responseObject];
                [weakTableView reloadData];
            }
            else{
                NSLog(@"error: %@, response %@", error, responseObject);
            }
        }];
    }];
    
    carTypeNames = @[@"Tất cả", @"Tự do", @"Taxi", @"Cưới", @"Hợp đồng", @"Tự lái", @"Xe tải", @"Container", @"Xe khách"];
    carTypeImages = @[@"all_car.png", @"free_car.png", @"taxi.png", @"wedding_car.png", @"contract_car.png", @"self_driver.png", @"delivery_car.png", @"container.png", @"coach.png"];
    
    [carTypeCollectionView setAllowsMultipleSelection:NO];
    NSString *carType = [_filterData objectForKey:@"car_type"];
    [DataHelper GET:API_GET_TYPE_LIST params:@{} completion:^(BOOL success, id responseObject, NSError *error){
        if (success) {
            //            NSLog(@"%@", responseObject);
            carTypes = [responseObject valueForKey:@"name"];
            if (carType.length == 0) {
                selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            }
            else{
                selectedIndexPath = [NSIndexPath indexPathForItem:[carTypes indexOfObject:carType]+1 inSection:0];
                [carTypeCollectionView scrollToItemAtIndexPath:selectedIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                [carTypeCollectionView reloadData];
            }
            
            //            NSLog(@"%@", carTypes);
        }
    }];
}

-(void)filterData:(NSNotification *)noti{
    _filterData = [[[noti userInfo] objectForKey:@"filterData"] mutableCopy];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    getListOnlineNow = YES;
    [_tableView triggerPullToRefresh];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];

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
}

-(void)getListOnline{
    CLLocationCoordinate2D currCoordinate = _currentLocation.coordinate;
    NSString *lon = [NSString stringWithFormat:@"%f", currCoordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f", currCoordinate.latitude];
    NSString *carSize = [_filterData objectForKey:@"car_size"];
    if (carSize.length > 1) {
        carSize = [carSize substringToIndex:[carSize rangeOfString:@" "].location];
    }
    [DataHelper GET:API_GET_LIST_ONLINE params:@{@"lon":lon, @"lat":lat, @"car_made":[_filterData objectForKey:@"car_made"], @"car_model":[_filterData objectForKey:@"car_model"], @"car_size":carSize, @"car_type":[_filterData objectForKey:@"car_type"], @"order":@"0"} completion:^(BOOL success, id responseObject, NSError *error){
        if (success) {
//            NSLog(@"list online: %@", responseObject);
            _cars = [Car getDataFromJson:responseObject];
            [_tableView reloadData];
        }
        else{
            NSLog(@"error: %@, response %@", error, responseObject);
        }
    }];
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeUser = [UIAlertAction actionWithTitle:LocalizedString(@"CHANGE_USER") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [DataHelper clearUserData];
        FirstViewController *firstViewController = (FirstViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"firstViewControllerStoryboardId"];
        
        [self presentViewController:firstViewController animated:YES completion:nil];
    }];
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
    return carTypeNames.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CarTypeItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"carTypeItemId" forIndexPath:indexPath];
    [cell setCarType:[carTypeNames objectAtIndex:indexPath.item] withImage:[carTypeImages objectAtIndex:indexPath.item]];
    if (indexPath.item == selectedIndexPath.item) {
        [cell.contentView setBackgroundColor:[UIColor yellowColor]];
    }
    else{
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 70);
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

@end

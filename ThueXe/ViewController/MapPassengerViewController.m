//
//  MapPassengerViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/11/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "MapPassengerViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "DataHelper.h"
#import "Config.h"
#import "FirstViewController.h"
#import "ListDataViewController.h"
#import "Car.h"
#import "FilterViewController.h"
#import "BookingViewController.h"

@interface MapPassengerViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, UITabBarControllerDelegate>
{
    CLLocationManager *locationManager;
    GMSMarker *currentMarker;
    GMSCameraPosition *camera;
    IBOutlet GMSMapView *_mapView;
    NSArray *_cars;
}
@end

@implementation MapPassengerViewController
#pragma mark - LifeCycle View Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    camera = [GMSCameraPosition cameraWithLatitude:20.982879
                                         longitude:105.925522
                                              zoom:6
                                           bearing:0 viewingAngle:0];
    [_mapView setCamera:camera];
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.settings.compassButton = YES;
    [_mapView.settings setAllGesturesEnabled:YES];
    _mapView.delegate = self;
    
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    // Creates a marker in the center of the map.
    currentMarker = [[GMSMarker alloc] init];
    currentMarker.position = CLLocationCoordinate2DMake(20.982879, 105.92552);
    currentMarker.title = LocalizedString(@"MAP_CURRENT_LOCATION");
    currentMarker.map = _mapView;
    
    self.tabBarController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterData:) name:@"filterDataNoti" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getListOnline];
//    [self prefersStatusBarHidden];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Methods
-(void)getListOnline{
    CLLocationCoordinate2D currCoordinate = _currentLocation.coordinate;
    NSString *lon = [NSString stringWithFormat:@"%f", currCoordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f", currCoordinate.latitude];
    NSString *carSize = [_filterData objectForKey:@"car_size"];
    if (carSize.length > 1) {
        carSize = [carSize substringToIndex:[carSize rangeOfString:@" "].location];
    }

    currentMarker.position = _currentLocation.coordinate;
    camera = [GMSCameraPosition cameraWithTarget:_currentLocation.coordinate zoom:15 bearing:0 viewingAngle:0];
    [_mapView setCamera:camera];
    [_mapView animateToLocation:_currentLocation.coordinate];

    [DataHelper GET:API_GET_LIST_ONLINE params:@{@"lon":lon, @"lat":lat, @"car_made":[_filterData objectForKey:@"car_made"], @"car_model":[_filterData objectForKey:@"car_model"], @"car_size":carSize, @"car_type":[_filterData objectForKey:@"car_type"], @"order":@"0"} completion:^(BOOL success, id responseObject){
        if (success) {
//            NSLog(@"list online: %@", responseObject);
            _cars = [Car getDataFromJson:responseObject];
            [self drawCars];
        }
        else{
            NSLog(@"error: %@", responseObject);
        }
    }];
}

-(void)filterData:(NSNotification *)noti{
    _filterData = [[noti userInfo] objectForKey:@"filterData"];
    [self getListOnline];
}

-(void)drawCars{
    [_mapView clear];
    for (Car *car in _cars) {
        float d = car.distance;
        
        currentMarker.position = _currentLocation.coordinate;
        currentMarker.map = _mapView;
        
        float lon = car.location.coordinate.longitude;
        float lat = car.location.coordinate.latitude;
        
        NSString *distance = (d < 1) ? [NSString stringWithFormat:@"%d m", (int)(1000*d)] : [NSString stringWithFormat:@"%.3f km", d] ;
        // Creates a marker in the center of the map.
        GMSMarker *carMaker = [[GMSMarker alloc] init];
        carMaker.position = CLLocationCoordinate2DMake(lat, lon);
        carMaker.icon = [UIImage imageNamed:@"car_small.png"];
        carMaker.title = distance;
        carMaker.map = _mapView;
    }
}

#pragma mark - Events
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    _currentLocation = locations.firstObject;
    //    NSLog(@"%@", _currentLocation);
    
    
}

-(BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView{
    [self getListOnline];
    return YES;
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeUser = [UIAlertAction actionWithTitle:LocalizedString(@"CHANGE_USER") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [DataHelper clearUserData];
        FirstViewController *firstViewController = (FirstViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"firstViewControllerStoryboardId"];

        //        [self presentViewController:firstViewController animated:YES completion:nil];
        [self.navigationController pushViewController:firstViewController animated:YES];
    }];

    UIAlertAction *booking = [UIAlertAction actionWithTitle:@"Đặt xe" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self performSegueWithIdentifier:@"mapToBookingSegueId" sender:self];
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
    [menu addAction:changeUser];
    [menu addAction:cancel];
    [self presentViewController:menu animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"filterSegueId"]) {
        FilterViewController *viewController = [segue destinationViewController];
        viewController.filterData = [NSMutableDictionary dictionaryWithDictionary:_filterData];
    }

    if ([[segue identifier] isEqualToString:@"mapToBookingSegueId"]) {
        BookingViewController *vc = [segue destinationViewController];
        vc.userType = USER_TYPE_PASSENGER;
    }
}

- (IBAction)filterBtnClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FilterViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"filterDataStoryboardId"];
    vc.filterData = [NSMutableDictionary dictionaryWithDictionary:_filterData];
    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

@end

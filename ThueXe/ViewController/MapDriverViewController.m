//
//  MapDriverViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/8/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "MapDriverViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "DataHelper.h"
#import "Config.h"
#import "FirstViewController.h"
#import "RegisterViewController.h"

@interface MapDriverViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    GMSMarker *currentMarker;
   
    GMSCameraPosition *camera;
    NSTimer *timerUpdateLocation;
    IBOutlet GMSMapView *_mapView;
    IBOutlet UIView *headerView;
    BOOL getAroundNow;
    CAR_STATUS carStatus;
    
    IBOutlet UISegmentedControl *changeStatusSeg;
}
@end

@implementation MapDriverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    carStatus = CAR_STATUS_ENABLE;
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
    currentLocation = [CLLocation new];
    
    // Creates a marker in the center of the map.
    currentMarker = [[GMSMarker alloc] init];
    currentMarker.position = CLLocationCoordinate2DMake(20.982879, 105.92552);
    currentMarker.title = @"Vị trí hiện tại";
    currentMarker.map = _mapView;
    
    timerUpdateLocation = [NSTimer scheduledTimerWithTimeInterval:TIME_UPDATE_LOCATE target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    [_mapView bringSubviewToFront:changeStatusSeg];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    getAroundNow = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
}

-(void)updateLocation{
    NSDictionary *userInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"] objectForKey:@"data"];
    
    [DataHelper POST:API_LOCATE params:@{@"car_number":[userInfo objectForKey:@"car_number"], @"lon":[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude], @"lat":[NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude], @"phone":[userInfo objectForKey:@"phone"], @"status":[NSString stringWithFormat:@"%d",carStatus]} completion:^(BOOL success, id responseObject, NSError *error){
        NSLog(@"locate: success: %d, response: %@", success, responseObject);
    }];
    
    [DataHelper GET:API_GET_AROUND params:@{@"lon":[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude], @"lat":[NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude]} completion:^(BOOL success, id responseObject, NSError *error){
        NSLog(@"get around: success: %d, response: %@", success, responseObject);
        NSArray *otherCars = responseObject;
        [_mapView clear];
        for (NSDictionary *car in otherCars) {
            float d = [[car objectForKey:@"D"] floatValue];
            NSString *dateString = [car objectForKey:@"date_time"];
            dateString = [NSString stringWithFormat:@"%@ %@", [dateString substringToIndex:10], [dateString substringFromIndex:11]];
            NSDateFormatter *dateFormat = [NSDateFormatter new];
            dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            NSDate *date = [dateFormat dateFromString:dateString];
            NSTimeInterval time = -[date timeIntervalSinceNow];
            
            currentMarker.position = currentLocation.coordinate;
            currentMarker.map = _mapView;
            
            if (d > 0 && d < DISTANCE_MAX_GET_AROUND && time < TIME_LIMIT_GET_AROUND) {
                float lon = [[car objectForKey:@"lon"] floatValue];
                float lat = [[car objectForKey:@"lat"] floatValue];
                
                NSString *distance = (d < 1) ? [NSString stringWithFormat:@"%d m", (int)(1000*d)] : [NSString stringWithFormat:@"%.3f km", d] ;
                // Creates a marker in the center of the map.
                GMSMarker *carMaker = [[GMSMarker alloc] init];
                carMaker.position = CLLocationCoordinate2DMake(lat, lon);
                carMaker.icon = [UIImage imageNamed:@"car_small.png"];
                carMaker.title = distance;
                carMaker.map = _mapView;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"registerStoryboardId"];
    vc.isEdit = YES;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    currentLocation = locations.firstObject;
//    NSLog(@"%@", currentLocation);
    currentMarker.position = currentLocation.coordinate;
    camera = [GMSCameraPosition cameraWithTarget:currentLocation.coordinate zoom:15 bearing:0 viewingAngle:0];
    [_mapView setCamera:camera];
    [_mapView animateToLocation:currentLocation.coordinate];
    if (getAroundNow) {
        getAroundNow = NO;
        [self updateLocation];
    }
}
- (IBAction)changeStatus:(id)sender {
    switch (changeStatusSeg.selectedSegmentIndex) {
        case CAR_STATUS_ENABLE:
            carStatus = CAR_STATUS_ENABLE;
            timerUpdateLocation = [NSTimer scheduledTimerWithTimeInterval:TIME_UPDATE_LOCATE target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
            [self updateLocation];
            break;
        case CAR_STATUS_DISABLE:
            carStatus = CAR_STATUS_DISABLE;
            [timerUpdateLocation invalidate];
            timerUpdateLocation = nil;
            [self updateLocation];
            break;
        default:
            break;
    }
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeUser = [UIAlertAction actionWithTitle:@"Đổi vai trò" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        carStatus = CAR_STATUS_DISABLE;
        [timerUpdateLocation invalidate];
        timerUpdateLocation = nil;
        [self updateLocation];
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



//-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
//    NSLog(@"didTapMaker");
//    return YES;
//}

@end

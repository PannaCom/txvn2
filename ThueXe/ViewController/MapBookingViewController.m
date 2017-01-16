//
//  MapBookingViewController.m
//  ThueXe
//
//  Created by VMio69 on 12/4/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "MapBookingViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "Config.h"
#import "DataHelper.h"
#import "CoreLocation/CoreLocation.h"

@interface MapBookingViewController ()<GMSMapViewDelegate>
{
    IBOutlet GMSMapView *_mapView;
    GMSMarker *_fromMaker;
    GMSMarker *_toMaker;
    
    GMSCameraPosition *_camera;
    GMSAutocompleteFetcher* _fetcher;
}
@end

@implementation MapBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _camera = [GMSCameraPosition cameraWithLatitude:20.982879
                                          longitude:105.925522
                                               zoom:6
                                            bearing:0 viewingAngle:0];
    [_mapView setCamera:_camera];
    [_mapView.settings setAllGesturesEnabled:YES];
    _mapView.delegate = self;
    
   
    _fromMaker = [GMSMarker new];
    _toMaker = [GMSMarker new];
    _fromMaker.title = @"Điểm đi";
    _toMaker.title = @"Điểm đến";
    _fromMaker.map = _mapView;
    _toMaker.map = _mapView;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self drawDirectionFrom:_locationFrom to:_locationTo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)drawDirectionFrom:(CLLocationCoordinate2D)coordinate1 to:(CLLocationCoordinate2D)coordinate2{

    _fromMaker.map = nil;
    _toMaker.map = nil;
    [_mapView clear];
    
//    if (CLLocationCoordinate2DIsValid(coordinate1) && [self isNotZeroLocation:coordinate1]) {
//        _fromMaker.position = coordinate1;
//        _fromMaker.map = _mapView;
//    }
//
//    if (CLLocationCoordinate2DIsValid(coordinate2) && [self isNotZeroLocation:coordinate2]) {
//        _toMaker.position = coordinate2;
//        _toMaker.map = _mapView;
//    }

    if (CLLocationCoordinate2DIsValid(coordinate1) && CLLocationCoordinate2DIsValid(coordinate2) && [self isNotZeroLocation:coordinate1] && [self isNotZeroLocation:coordinate2]) {
        [DataHelper GET_NO_POLICY:API_GET_DIRECTIONS(coordinate1.latitude, coordinate1.longitude, coordinate2.latitude, coordinate2.longitude) params:nil completion:^(BOOL success, id responseObject){
            if (success) {
                if (![responseObject[@"status"] isEqualToString:@"NOT_FOUND"]) {
                    GMSPath *path =[GMSPath pathFromEncodedPath:responseObject[@"routes"][0][@"overview_polyline"][@"points"]];
                    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
                    singleLine.strokeWidth = 7;
                    singleLine.strokeColor = [UIColor greenColor];
                    singleLine.map = _mapView;

                    _fromMaker.position = coordinate1;
                    _fromMaker.map = _mapView;
                    _fromMaker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
                    _toMaker.position = coordinate2;
                    _toMaker.map = _mapView;
                    _toMaker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
                }
            }
        }];
    }
    
}

-(BOOL)isNotZeroLocation:(CLLocationCoordinate2D)location{
    if (location.latitude == 0 && location.longitude == 0) {
        return NO;
    }
    return YES;
}
@end

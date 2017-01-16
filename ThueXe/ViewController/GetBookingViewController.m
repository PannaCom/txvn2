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
#import "BookingCell.h"
#import "BookingObject.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "INTULocationManager.h"
#import "SCLAlertView.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface GetBookingViewController ()<UITableViewDelegate, UITableViewDataSource, BookingCellDelegate, UIScrollViewDelegate, GMSAutocompleteFetcherDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView *_tableView;
    IBOutlet UIView *_titleView;
    IBOutlet NSLayoutConstraint *heightTitleViewConstraint;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UIButton *filterButton;

    NSArray *_data;
    BOOL getBookingNow;
    INTULocationManager *intLocationManager;
    CGFloat lastContentOffsetY;
    UITextField *placeFromTextField;
    UITextField *placeToTextField;
    CLLocationCoordinate2D placeFromCoordinate;
    CLLocationCoordinate2D placeToCoordinate;
    GMSAutocompleteFetcher *_fetcher;
    NSArray<GMSAutocompletePrediction*> *_resultData;
    UITableView *_resultTableView;
    int textFieldSelected;
    SCLAlertView *alertSearchPlace;

}

@end

@implementation GetBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lastContentOffsetY = 0;

    _data = [NSArray new];
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"BookingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"bookingCellId"];

    intLocationManager = [INTULocationManager sharedInstance];

    [self loadData];
    [self setupAutocompleteTextField];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNoti:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

}

- (void)setupAutocompleteTextField {

    _resultTableView = [UITableView new];
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;
    [_resultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"resultCellId"];
    [self.view addSubview:_resultTableView];

    _resultData = [NSArray new];
    // Set bounds to inner-west Vietnam.
    CLLocationCoordinate2D northEastBoundsCorner = CLLocationCoordinate2DMake(23.393395, 109.468975);
    CLLocationCoordinate2D southWestBoundsCorner = CLLocationCoordinate2DMake(8.412730, 102.144410);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEastBoundsCorner
                                                                       coordinate:southWestBoundsCorner];
    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.country = @"VN";
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds
                                                       filter:filter];
    _fetcher.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - GMSAutocompleteFetcherDelegate
- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    _resultData = predictions;
    [_resultTableView reloadData];
    if (_resultData.count > 0) {
        [_resultTableView setHidden:NO];
    }
    else{
        [_resultTableView setHidden:YES];
    }
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}
#pragma mark - UITableView Delegates 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _resultTableView) {
        if (_resultData.count == 0) {
            switch (textFieldSelected) {
                case TEXT_FIELD_PLACE_FROM:
                    placeFromCoordinate = kCLLocationCoordinate2DInvalid;
                    break;
                case TEXT_FIELD_PLACE_TO:
                    placeToCoordinate = kCLLocationCoordinate2DInvalid;
                    break;
                default:
                    break;
            }
        }
        return _resultData.count;
    }

    return MAX(_data.count, 1);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _resultTableView) {
        UITableViewCell *cell = [_resultTableView dequeueReusableCellWithIdentifier:@"resultCellId" forIndexPath:indexPath];
        [cell.textLabel setText:[[_resultData objectAtIndex:indexPath.row].attributedFullText string]];
        return cell;
    }

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
    if (tableView == _resultTableView) {
        return 44;
    }
    if (_data.count == 0) {
        return 70;
    }
    return 240;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _resultTableView) {
        switch (textFieldSelected) {
            case TEXT_FIELD_PLACE_FROM:
                placeFromTextField.text = [[_resultData objectAtIndex:indexPath.row].attributedFullText string];
                break;
            case TEXT_FIELD_PLACE_TO:
                placeToTextField.text = [[_resultData objectAtIndex:indexPath.row].attributedFullText string];
                break;
            default:
                break;
        }
        [self.view endEditing:YES];

        [_resultTableView setHidden:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSPlacesClient *placeClient = [GMSPlacesClient sharedClient];
            [placeClient lookUpPlaceID:[_resultData objectAtIndex:indexPath.row].placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
                if(!error) {
                    switch (textFieldSelected) {
                        case TEXT_FIELD_PLACE_FROM:
                            placeFromCoordinate = result.coordinate;
                            break;
                        case TEXT_FIELD_PLACE_TO:
                            placeToCoordinate = result.coordinate;
                            break;
                        default:
                            break;
                    }
                } else {
                    NSLog(@"Error : %@",error.localizedDescription);
                    switch (textFieldSelected) {
                        case TEXT_FIELD_PLACE_FROM:
                            placeFromCoordinate = kCLLocationCoordinate2DInvalid;
                            break;
                        case TEXT_FIELD_PLACE_TO:
                            placeToCoordinate = kCLLocationCoordinate2DInvalid;
                            break;
                        default:
                            break;
                    }
                }
            }];

        });
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _tableView && _userType == USER_TYPE_PASSENGER_GET_DRIVER_BOOKING) {
//        NSLog(@"content offset: %f, contentsize: %f", scrollView.contentOffset.y, scrollView.contentSize.height);
        if ((lastContentOffsetY > scrollView.contentOffset.y && scrollView.contentOffset.y < scrollView.contentSize.height - HEIGHT_SCREEN) || scrollView.contentOffset.y <= 0) {
            [UIView animateWithDuration:0.3 animations:^{
                filterButton.frame = CGRectMake(0, HEIGHT_SCREEN - 44, WIDTH_SCREEN, 44);
                [filterButton setHidden:NO];
            }];
        }
        else {
            [UIView animateWithDuration:0.3 animations:^{
                filterButton.frame = CGRectMake(0, HEIGHT_SCREEN, WIDTH_SCREEN, 0);
                [filterButton setHidden:YES];
            }];
        }
        lastContentOffsetY = scrollView.contentOffset.y;
    }
}

#pragma mark - UITextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    if (textField == placeFromTextField || textField == placeToTextField) {
        _resultData = nil;
        [_resultTableView reloadData];
        if (textField == placeFromTextField) {
            textFieldSelected = TEXT_FIELD_PLACE_FROM;
        }
        else {
            textFieldSelected = TEXT_FIELD_PLACE_TO;
        }
    }

    return true;
}

//- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//
//    if ([string isEqualToString:@"\n"]) {
//        [textField resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [_resultTableView setHidden:YES];
}

- (BOOL) textFieldShouldClear:(UITextField *)textField {
    [_resultTableView setHidden:YES];
    return YES;
}

- (void) textFieldDidChange:(UITextField *)textField {
    [_fetcher sourceTextHasChanged:textField.text];
}

#pragma mark - Events
- (IBAction)backBtnClick:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    if (_userType == USER_TYPE_PASSENGER) {
        [self performSegueWithIdentifier:@"fromPassengerGetBookingToListDataUnwindSegueId" sender:self];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

-(void)getBooking{
    MBProgressHUD *progressHudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHudView.label.text = @"Đang tìm xe";
    switch (_userType) {
        case USER_TYPE_DRIVER:
        {
           [intLocationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:5.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
               if (status == INTULocationStatusSuccess) {
                   NSDictionary *params = @{@"lon" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude], @"lat" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude]};
                   [DataHelper GET:API_DRIVER_GET_BOOKING params:params completion:^(BOOL success, id responseObject){
                       [progressHudView hideAnimated:YES];
                       if (success) {
                           _data = [BookingObject getDataFromJson:responseObject];
                           [_tableView reloadData];
                       }
                   }];
               }
               else {

               }
           }];
        }
            break;
        case USER_TYPE_PASSENGER:
        {
            [DataHelper GET:API_PASSENGER_GET_BOOKING params:@{@"phone":_phone} completion:^(BOOL success, id responseObject){
                [progressHudView hideAnimated:YES];
                if (success) {
                    _data = [BookingObject getDataFromJson:responseObject];
                    [_tableView reloadData];
                }
            }];
        }
            break;
        case USER_TYPE_PASSENGER_GET_DRIVER_BOOKING:
        {
           [intLocationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:5.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
               if (status == INTULocationStatusSuccess) {
                   NSString *placeFromLong = [self getLongStringFromCoordinate:placeFromCoordinate];
                   NSString *placeFromLat = [self getLatStringFromCoordinate:placeFromCoordinate];
                   NSString *placeToLong = [self getLongStringFromCoordinate:placeToCoordinate];
                   NSString *placeToLat = [self getLatStringFromCoordinate:placeToCoordinate];

                   NSDictionary *params = @{@"lon" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude], @"lat" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude], @"lon_from" : placeFromLong, @"lat_from" : placeFromLat, @"lon_to" : placeToLong, @"lat_to" : placeToLat};
                   [DataHelper GET:API_GET_CUSTOMER_BOOKING params:params completion:^(BOOL success, id responseObject) {
                       [progressHudView hideAnimated:YES];
                       if (success) {
                           _data = [BookingObject getDataFromJson:responseObject];
                           [_tableView reloadData];
                       }
                   }];
               }
               else {
                    [progressHudView hideAnimated:YES];
               }
           }];
        }
            break;
        default:
            break;
    }
}

- (NSString *)getLongStringFromCoordinate:(CLLocationCoordinate2D) coordinate {
    if (coordinate.latitude > 0 && coordinate.longitude > 0) {
        return [NSString stringWithFormat:@"%.6f", coordinate.longitude];
    }
    return @"";
}

- (NSString *)getLatStringFromCoordinate:(CLLocationCoordinate2D) coordinate {
    if (coordinate.latitude > 0 && coordinate.longitude > 0) {
        return [NSString stringWithFormat:@"%.6f", coordinate.latitude];
    }
    return @"";
}

- (void)bookingDidUpdated:(NSString *)bookingId{
    [DataHelper POST:API_PASSENGER_UPDATE_BOOKING params:@{@"id_booking":bookingId} completion:^(BOOL success, id responeObject){
        if (success && [responeObject isEqualToString:@"1"]) {
            [self getBooking];
        }
    }];
}

- (void)bookingDriverDidCalled:(NSString *)passengerPhone{
    if (_userType == USER_TYPE_DRIVER) {
        [DataHelper POST:API_LOG_DRIVER_CALL_PASSENGER params:@{@"from_number":_phone, @"to_number":passengerPhone} completion:^(BOOL success, id responseObject){
            NSLog(@"Log driver call passenger: %@", responseObject);
        }];
    }
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

    
//    UIAlertAction *booking = [UIAlertAction actionWithTitle:@"Đặt xe" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
////        [self dismissViewControllerAnimated:YES completion:nil];
//        [self performSegueWithIdentifier:@"fromPassengerGetBookingToBookingUnwindSegueId" sender:self];
//    }];
//    [menu addAction:booking];

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

- (IBAction)filterButtonTouched:(id)sender {
    alertSearchPlace = [SCLAlertView new];

    placeFromTextField = [alertSearchPlace addTextField:@"Nhập điểm đi"];
    placeToTextField = [alertSearchPlace addTextField:@"Nhập điểm đến"];
    placeFromTextField.delegate = self;
    placeToTextField.delegate = self;
    [placeFromTextField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    [placeToTextField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];

    __weak typeof(self) weakSelf = self;

    [alertSearchPlace addButton:@"Tìm kiếm" actionBlock:^{
        typeof(self) strongSelf = weakSelf;
        if ([strongSelf->placeFromTextField.text isEqualToString:@""]) {
            placeFromCoordinate = kCLLocationCoordinate2DInvalid;
        }
        if ([strongSelf->placeToTextField.text isEqualToString:@""]) {
            placeToCoordinate = kCLLocationCoordinate2DInvalid;
        }

        [weakSelf getBooking];
    }];

    [alertSearchPlace showEdit:self title:@"" subTitle:@"Tìm xe theo Điểm đi/Điểm đến" closeButtonTitle:@"Hủy" duration:0.0f];
    [self.view bringSubviewToFront:_resultTableView];

}

- (void)keyboardWillShowNoti:(NSNotification*)noti{

    if (textFieldSelected != TEXT_FIELD_PLACE_FROM && textFieldSelected != TEXT_FIELD_PLACE_TO) {
        return;
    }

    NSDictionary* keyboardInfo = [noti userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];


    UIView *tf;

    switch (textFieldSelected) {
        case TEXT_FIELD_PLACE_FROM:
            tf = placeFromTextField;
            break;
        case TEXT_FIELD_PLACE_TO:
            tf = placeToTextField;
            break;
        default:
            break;
    }
    CGRect alertRect = alertSearchPlace.view.bounds;
    CGRect tfRect = tf.frame;
    _resultTableView.frame = CGRectMake(0,alertRect.origin.y + tfRect.origin.y + tfRect.size.height + 50, WIDTH_SCREEN, self.view.frame.size.height - keyboardFrameBeginRect.size.height - tfRect.origin.y - tfRect.size.height - alertRect.origin.y - 50);

    [_resultTableView setHidden:YES];
}

- (void) loadData {
    NSDictionary *userInfo = [DataHelper getUserData];
    switch (_userType) {
        case USER_TYPE_DRIVER:
     {
        [filterButton setHidden:YES];
        filterButton.hidden = YES;
        _phone = userInfo[@"data"][@"phone"];
        NSString *regId = [DataHelper getRegId];
        if (regId == nil) {
            regId = userInfo[@"data"][@"regId"];
        }
        [DataHelper POST:API_POST_REG_ID_USER params:@{@"os":DEVICE_IOS, @"phone":_phone, @"regId":regId
                                                       } completion:^(BOOL success, id responseObject){
                                                           NSLog(@"log regID: %@", responseObject);
                                                       }];

        heightTitleViewConstraint.constant = 0;
        _titleView.hidden = YES;

        getBookingNow = YES;

        __weak typeof(self) weakSelf = self;
        __weak UITableView *weakTableView = _tableView;
        [_tableView addPullToRefreshWithActionHandler:^{
            typeof(self) strongSelf = weakSelf;
            [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH") forState:SVPullToRefreshStateAll];
            [weakTableView.pullToRefreshView setTitle:LocalizedString(@"RELEASE_TO_REFRESH") forState:SVPullToRefreshStateTriggered];
            [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH_LOADING") forState:SVPullToRefreshStateLoading];
            [strongSelf->intLocationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:5.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                if (status == INTULocationStatusSuccess) {
                    NSDictionary *params = @{@"lon" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude], @"lat" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude]};
                    [DataHelper GET:API_DRIVER_GET_BOOKING params:params completion:^(BOOL success, id responseObject){
                        [strongSelf->_tableView.pullToRefreshView stopAnimating];
                        if (success) {
                            _data = [BookingObject getDataFromJson:responseObject];
                            [strongSelf->_tableView reloadData];
                        }
                    }];
                }
                else {
                    [strongSelf->_tableView.pullToRefreshView stopAnimating];
                }
            }];
        }];
     }
            break;
        case USER_TYPE_PASSENGER:
     {
        [filterButton setHidden:YES];
        filterButton.hidden = YES;
        _titleLabel.text = @"Xe đã đặt";
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
        case USER_TYPE_PASSENGER_GET_DRIVER_BOOKING:
     {
        [filterButton setHidden:NO];
        _titleLabel.text = @"Xe quanh đây";
        __weak typeof(self) weakSelf = self;
        __weak UITableView *weakTableView = _tableView;

        [_tableView addPullToRefreshWithActionHandler:^{
            typeof(self) strongSelf = weakSelf;
            [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH") forState:SVPullToRefreshStateAll];
            [weakTableView.pullToRefreshView setTitle:LocalizedString(@"RELEASE_TO_REFRESH") forState:SVPullToRefreshStateTriggered];
            [weakTableView.pullToRefreshView setTitle:LocalizedString(@"PULL_TO_REFRESH_LOADING") forState:SVPullToRefreshStateLoading];
            [strongSelf->intLocationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:5.0 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                if (status == INTULocationStatusSuccess) {
                    NSString *placeFromLong = [weakSelf getLongStringFromCoordinate:strongSelf->placeFromCoordinate];
                    NSString *placeFromLat = [weakSelf getLatStringFromCoordinate:strongSelf->placeFromCoordinate];
                    NSString *placeToLong = [weakSelf getLongStringFromCoordinate:strongSelf->placeToCoordinate];
                    NSString *placeToLat = [weakSelf getLatStringFromCoordinate:strongSelf->placeToCoordinate];

                    NSDictionary *params = @{@"lon" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude], @"lat" : [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude], @"lon_from" : placeFromLong, @"lat_from" : placeFromLat, @"lon_to" : placeToLong, @"lat_to" : placeToLat};
                    [DataHelper GET:API_GET_CUSTOMER_BOOKING params:params completion:^(BOOL success, id responseObject) {
                        [strongSelf->_tableView.pullToRefreshView stopAnimating];
                        if (success) {
                            _data = [BookingObject getDataFromJson:responseObject];
                            [strongSelf->_tableView reloadData];
                        }
                    }];
                }
                else {
                    [strongSelf->_tableView.pullToRefreshView stopAnimating];
                }
            }];
        }];
     }
            break;
        default:
            break;
    }
}

@end

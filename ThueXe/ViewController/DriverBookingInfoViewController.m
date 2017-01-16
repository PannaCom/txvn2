//
//  DriverBookingInfoViewController.m
//  ThueXe
//
//  Created by VMio69 on 1/12/17.
//  Copyright © 2017 VMio69. All rights reserved.
//

#import "DriverBookingInfoViewController.h"
#import "JVFloatLabeledTextField.h"
#import "DataHelper.h"
#import "Config.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface DriverBookingInfoViewController ()<UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, GMSAutocompleteFetcherDelegate>
{
    IBOutlet UIScrollView *_scrollView;
    IBOutlet JVFloatLabeledTextField *_hireTypeTf;
    IBOutlet JVFloatLabeledTextField *_placeFromTf;
    IBOutlet JVFloatLabeledTextField *_placeToTf;
    IBOutlet JVFloatLabeledTextField *_dateFromTf;
    IBOutlet UIButton *_bookingBtn;

    NSArray *hireTypes;
    NSArray *dataTableView;
    int textFieldSelected;
    long carHireTypeSelected;
    long rowSelected;
    UIAlertController *alertController;
    GMSAutocompleteFetcher* _fetcher;
    NSArray<GMSAutocompletePrediction*> *_resultData;
    UITableView *_resultTableView;
    UIDatePicker *datePicker;
    NSDateFormatter *dateFormatter;
    NSDate *_dateFrom;
    NSDate *_dateTo;
    UIFont *fontSearchCell;
}
@end

@implementation DriverBookingInfoViewController
#pragma mark - Life Cycle View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    hireTypes = [NSArray new];

    _hireTypeTf.delegate = self;
    _placeFromTf.delegate = self;
    _placeToTf.delegate = self;
    _dateFromTf.delegate = self;

    dataTableView = [NSArray new];

    [self getInfoCarFromServer];

    _placeFromTf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _placeFromTf.autocorrectionType = UITextAutocorrectionTypeNo;
    _placeFromTf.delegate = self;
    [_placeFromTf addTarget:self
                     action:@selector(textFieldDidChange:)
           forControlEvents:UIControlEventEditingChanged];

    _placeToTf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _placeToTf.autocorrectionType = UITextAutocorrectionTypeNo;
    _placeToTf.delegate = self;
    [_placeToTf addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];

    _resultTableView = [UITableView new];
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;
    [_resultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"resultCellId"];
    [self.view addSubview:_resultTableView];
    _resultData = [NSArray new];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNoti:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNoti:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Set bounds to inner-west Vietnam.
    CLLocationCoordinate2D northEastBoundsCorner = CLLocationCoordinate2DMake(23.393395, 109.468975);
    CLLocationCoordinate2D southWestBoundsCorner = CLLocationCoordinate2DMake(8.412730, 102.144410);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEastBoundsCorner
                                                                       coordinate:southWestBoundsCorner];
    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
//    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
    filter.country = @"VN";
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds
                                                       filter:filter];
    _fetcher.delegate = self;
    dateFormatter = [NSDateFormatter new];

    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    fontSearchCell = [UIFont systemFontOfSize:14];
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
        [_scrollView setScrollEnabled:NO];
    }
    else{
        [_resultTableView setHidden:YES];
    }
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    if (textField == _hireTypeTf) {
        [self.view endEditing:YES];
        UIViewController *controller = [[UIViewController alloc]init];
        UITableView *alertTableView;
        CGRect rect;

        NSString *title = @"";

        if (textField == _hireTypeTf) {
            dataTableView = hireTypes;
            title = @"Chọn hình thức thuê xe";
            textFieldSelected = TEXT_FIELD_CAR_HIRE_TYPE;
            rowSelected = carHireTypeSelected;
        }

        float heightRect = MIN(HEIGHT_SCREEN*2/3, 60.*dataTableView.count);
        rect = CGRectMake(0, 0, WIDTH_SCREEN*3/4, heightRect);
        [controller setPreferredContentSize:rect.size];

        alertTableView  = [[UITableView alloc]initWithFrame:rect];
        alertTableView.delegate = self;
        alertTableView.dataSource = self;
        alertTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [alertTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [alertTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellSelectId"];
        [alertTableView reloadData];

        [controller.view addSubview:alertTableView];
        [controller.view bringSubviewToFront:alertTableView];
        [controller.view setUserInteractionEnabled:YES];
        [alertTableView setUserInteractionEnabled:YES];
        [alertTableView setAllowsSelection:YES];
        alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController setValue:controller forKey:@"contentViewController"];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

        return NO;
    }


    if (textField == _dateFromTf) {

        CGRect rect = CGRectMake(0, 0, WIDTH_SCREEN*3/4, HEIGHT_SCREEN/2);
        UIViewController *controller = [UIViewController new];
        [controller setPreferredContentSize:rect.size];
        datePicker = [[UIDatePicker alloc] initWithFrame:rect];
        datePicker.date = [NSDate date];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;

        [controller.view addSubview:datePicker];
        [controller.view bringSubviewToFront:datePicker];
        [controller.view setUserInteractionEnabled:YES];
        [datePicker setUserInteractionEnabled:YES];

        NSString *title = @"";
        if (textField == _dateFromTf) {
            textFieldSelected = TEXT_FIELD_DATE_FROM;
            title = @"Chọn ngày đi";
        }
        alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController setValue:controller forKey:@"contentViewController"];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *selectAction = [UIAlertAction actionWithTitle:@"Chọn" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            switch (textFieldSelected) {
                case TEXT_FIELD_DATE_FROM:
                    _dateFromTf.text = [dateFormatter stringFromDate:datePicker.date];
                    _dateFrom = datePicker.date;
                    _dateTo = [_dateFrom dateByAddingTimeInterval:3600*24];

                    break;
                default:
                    break;
            }

            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];

        [alertController addAction:selectAction];
        [alertController addAction:cancelAction];

        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    if (textField == _placeFromTf) {
        textFieldSelected = TEXT_FIELD_PLACE_FROM;
        _resultData = nil;
        [_resultTableView reloadData];
    }
    if (textField == _placeToTf){
        textFieldSelected = TEXT_FIELD_PLACE_TO;
        _resultData = nil;
        [_resultTableView reloadData];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }

    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [_resultTableView setHidden:YES];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [_resultTableView setHidden:YES];
    return YES;
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (textFieldSelected == TEXT_FIELD_PLACE_FROM || textFieldSelected == TEXT_FIELD_PLACE_TO) {
        if (_resultData.count == 0) {
            switch (textFieldSelected) {
                case TEXT_FIELD_PLACE_FROM:
                    _locationFrom = kCLLocationCoordinate2DInvalid;
                    break;
                case TEXT_FIELD_PLACE_TO:
                    _locationTo = kCLLocationCoordinate2DInvalid;
                    break;
                default:
                    break;
            }
        }
        return _resultData.count;
    }
    return dataTableView.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (textFieldSelected == TEXT_FIELD_PLACE_TO || textFieldSelected == TEXT_FIELD_PLACE_FROM) {
        UITableViewCell *cell = [_resultTableView dequeueReusableCellWithIdentifier:@"resultCellId" forIndexPath:indexPath];
        cell.textLabel.font = fontSearchCell;
        [cell.textLabel setText:[[_resultData objectAtIndex:indexPath.row].attributedFullText string]];
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSelectId" forIndexPath:indexPath];
        cell.textLabel.text = [dataTableView objectAtIndex:indexPath.row];
        if (indexPath.row == rowSelected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (textFieldSelected == TEXT_FIELD_PLACE_TO || textFieldSelected == TEXT_FIELD_PLACE_FROM) {
        switch (textFieldSelected) {
            case TEXT_FIELD_PLACE_FROM:
                _placeFromTf.text = [[_resultData objectAtIndex:indexPath.row].attributedFullText string];
                break;
            case TEXT_FIELD_PLACE_TO:
                _placeToTf.text = [[_resultData objectAtIndex:indexPath.row].attributedFullText string];
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
                            _locationFrom = result.coordinate;
                            break;
                        case TEXT_FIELD_PLACE_TO:
                            _locationTo = result.coordinate;
                            break;
                        default:
                            break;
                    }
                } else {
                    NSLog(@"Error : %@",error.localizedDescription);
                    switch (textFieldSelected) {
                        case TEXT_FIELD_PLACE_FROM:
                            _locationFrom = kCLLocationCoordinate2DInvalid;
                            break;
                        case TEXT_FIELD_PLACE_TO:
                            _locationTo = kCLLocationCoordinate2DInvalid;
                            break;
                        default:
                            break;
                    }
                }
            }];

        });
    }
    else{
        switch (textFieldSelected) {
            case TEXT_FIELD_CAR_HIRE_TYPE:
                carHireTypeSelected = indexPath.row;
                _hireTypeTf.text = [hireTypes objectAtIndex:carHireTypeSelected];
                break;
            default:
                break;
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}


#pragma mark - Events
- (IBAction)bookingBtnClick:(id)sender {
    if ([self checkInput]) {

        _bookingBtn.enabled = NO;

        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _bookingBtn.enabled = YES;
        });
        NSDictionary *userInfo = [[DataHelper getUserData] objectForKey:@"data"];
        [DataHelper POST:API_BOOKING params:@{@"name":[userInfo objectForKey:@"name"], @"phone":[userInfo objectForKey:@"phone"], @"car_from":_placeFromTf.text, @"car_to":_placeToTf.text, @"car_type":[userInfo objectForKey:@"car_type"], @"car_hire_type":_hireTypeTf.text, @"car_size":[userInfo objectForKey:@"car_size"], @"from_datetime":_dateFromTf.text, @"to_datetime":[dateFormatter stringFromDate:_dateTo], @"lon1":[NSString stringWithFormat:@"%.6f",_locationFrom.longitude], @"lat1":[NSString stringWithFormat:@"%.6f",_locationFrom.latitude], @"lon2":[NSString stringWithFormat:@"%.6f",_locationTo.longitude], @"lat2":[NSString stringWithFormat:@"%.6f",_locationTo.latitude]} completion:^(BOOL success, id reseponseObject){
            if (success) {
                if ([reseponseObject isEqualToString:@"1"]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Đăng chuyến thành công" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [self.delegate didBookingDone];
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
    }
}

- (BOOL)checkInput{
    return ([self checkLength:_hireTypeTf.text withAlert:@"Chưa chọn hình thức thuê"] &&
        [self checkLength:_placeFromTf.text withAlert:@"Chưa nhập điểm đi"] &&
        [self checkLength:_placeToTf.text withAlert:@"Chưa nhập điểm đến"] &&
            [self checkLength:_dateFromTf.text withAlert:@"Chưa chọn ngày giờ đi"]);
}

- (BOOL)checkLength:(NSString *)string withAlert:(NSString *)message{
    if ([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [self showAlertWithString:message];
        return NO;
    }
    return YES;
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
            tf = _placeFromTf;
            break;
        case TEXT_FIELD_PLACE_TO:
            tf = _placeToTf;
            break;
        default:
            break;
    }

    [_scrollView setContentOffset:CGPointMake(0, tf.frame.origin.y + tf.frame.size.height)];
    _resultTableView.frame = CGRectMake(0, tf.bounds.origin.y + tf.bounds.size.height, WIDTH_SCREEN, self.view.frame.size.height - keyboardFrameBeginRect.size.height - tf.bounds.origin.y - tf.bounds.size.height);

    [_resultTableView setHidden:YES];
}

- (void)keyboardWillHideNoti:(NSNotification*)noti {

    [_scrollView setScrollEnabled:YES];
}

#pragma mark - Custom Methods
- (void)textFieldDidChange:(UITextField *)textField {
    [_fetcher sourceTextHasChanged:textField.text];
}

- (void)getInfoCarFromServer{
    [DataHelper GET:API_GET_HIRE_TYPE_LIST params:@{} completion:^(BOOL success, id responseObject){
        hireTypes = [responseObject valueForKey:@"name"];
        hireTypes = [hireTypes subarrayWithRange:NSMakeRange(3, 2)];
    }];
}

- (void)showAlertWithString:(NSString*)string{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:string message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

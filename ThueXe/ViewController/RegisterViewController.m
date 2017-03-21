//
//  RegisterViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/1/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "RegisterViewController.h"
#import "JVFloatLabeledTextView.h"
#import "JVFloatLabeledTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "DataHelper.h"
#import "FirstViewController.h"
#import "ActiveViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>


@interface RegisterViewController ()<UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, GMSMapViewDelegate, GMSAutocompleteFetcherDelegate>
{
    IBOutlet JVFloatLabeledTextField *userNameTf;
    IBOutlet JVFloatLabeledTextField *phoneTf;
    IBOutlet JVFloatLabeledTextField *carMadeTf;
    IBOutlet JVFloatLabeledTextField *carModelTf;
    IBOutlet JVFloatLabeledTextField *carSizeTf;
    IBOutlet JVFloatLabeledTextField *carYearTf;
    IBOutlet JVFloatLabeledTextField *carTypeTf;
    IBOutlet JVFloatLabeledTextField *carPriceTf;
    IBOutlet JVFloatLabeledTextField *carNumberTf;
    IBOutlet JVFloatLabeledTextField *passwordTf;
    IBOutlet JVFloatLabeledTextField *emailTf;
    IBOutlet JVFloatLabeledTextField *passwordConfirmTf;
    IBOutlet JVFloatLabeledTextView *addressTf;

    IBOutlet UILabel *titleController;
    IBOutlet UIView *headerView;
    IBOutlet UIScrollView *_scrollView;

    IBOutlet UIButton *registerBtn;
    IBOutlet UIButton *backBtn;
    IBOutlet UIButton *loginBtn;

    BOOL keyboardIsShow;
    NSArray *carMade;
    NSMutableArray *carModel;
    NSMutableArray *carYear;
    NSArray *carTypes;
    NSArray *carSizes;
    NSArray *dataTableView;
    UIAlertController *alertController;
    NSMutableArray *carPrice;
    NSDictionary *userData;
    long carMadeSelected, carModelSelected, carTypeSelected, carSizeSelected, carYearSelected, carPriceSelected;
    int textFieldSelected;
    long rowSelected;
    CLLocationCoordinate2D addressCoordinate;

    MBProgressHUD *progressHudView;
    GMSAutocompleteFetcher* _fetcher;
    NSArray<GMSAutocompletePrediction*> *_resultData;
    UITableView *_resultTableView;
}
@end

@implementation RegisterViewController
#pragma mark - LifeCycle View Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isEdit) {
        backBtn.hidden = NO;
        titleController.text = LocalizedString(@"REGISTER_TITLE_EDIT");
        [registerBtn setTitle:LocalizedString(@"REGISTER_SAVE_BUTTON") forState:UIControlStateNormal];
        phoneTf.enabled = NO;
        loginBtn.hidden = YES;
    }
    carTypes = [NSArray new];
    
    userData = [NSDictionary new];
    userData = [[DataHelper getUserData] objectForKey:@"data"];
    if (userData) {
        userNameTf.text = [userData objectForKey:@"name"];
        phoneTf.text = [userData objectForKey:@"phone"];
        carNumberTf.text = [userData objectForKey:@"car_number"];
        carMadeTf.text = [userData objectForKey:@"car_made"];
        carModelTf.text = [userData objectForKey:@"car_model"];
        carSizeTf.text = [NSString stringWithFormat:LocalizedString(@"REGISTER_CAR_SIZE"), [userData objectForKey:@"car_size"]];
        carTypeTf.text = [userData objectForKey:@"car_type"];
        NSString *year = [userData objectForKey:@"car_year"];
        if (year == nil) {
            year = [userData objectForKey:@"car_years"];
        }
        carYearTf.text = [NSString stringWithFormat:@"%@", year];
        carPriceTf.text = [NSString stringWithFormat:@"%@", [userData objectForKey:@"car_price"]];
        passwordTf.text = [userData objectForKey:@"pass"];
        passwordConfirmTf.text = [userData objectForKey:@"pass"];
        addressTf.text = [userData objectForKey:@"address"];
        emailTf.text = [userData objectForKey:@"email"];
    }
    
    carMadeSelected = carModelSelected = carTypeSelected = carSizeSelected = carYearSelected = carPriceSelected = -1;

    passwordTf.delegate = self;
    passwordConfirmTf.delegate = self;
    addressTf.delegate = self;
    userNameTf.delegate = self;
    phoneTf.delegate = self;
    carMadeTf.delegate = self;
    carModelTf.delegate = self;
    carSizeTf.delegate = self;
    carYearTf.delegate = self;
    carTypeTf.delegate = self;
    carPriceTf.delegate = self;
    carNumberTf.delegate = self;
    emailTf.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    [self.view bringSubviewToFront:headerView];
    _scrollView.delegate = self;
    
    keyboardIsShow = NO;
    
    carMade = [NSArray new];
    carModel = [NSMutableArray new];
    carSizes = [NSArray new];

    //Get Current Year
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy"];
    int currYear  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    
    //Create Years Array
    carYear = [NSMutableArray new];
    for (int i = 0; i < CAR_YEAR_OLD; i++) {
        [carYear addObject:[NSString stringWithFormat:@"%d", currYear - i]];
    }
    dataTableView = [NSArray new];
    carPrice = [NSMutableArray new];
    // Bỏ giá thoả thuận
//    [carPrice addObject:LocalizedString(@"REGISTER_CAR_PRICE_CUSTOM")];
    for (int i = 6000; i <= 15000; i += 500) {
        [carPrice addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    userNameTf.autocorrectionType = UITextAutocorrectionTypeNo;
    carNumberTf.autocorrectionType = UITextAutocorrectionTypeNo;
    addressTf.placeholder = @"Địa chỉ";

    [self getInfoCarFromServer];

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
    addressTf.layer.cornerRadius = 8.0;
    addressTf.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);

//    userNameTf.content
}

- (void)getInfoCarFromServer{
    
    [DataHelper GET:API_GET_ALL_MADE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            carMade = [responseObject valueForKey:@"name"];
        }
    }];
    
    [DataHelper GET:API_GET_MODEL_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            carModel = [responseObject valueForKey:@"name"];
        }
    }];
    
    [DataHelper GET:API_GET_TYPE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            carTypes = [responseObject valueForKey:@"name"];
        }
    }];
    
    [DataHelper GET:API_GET_SIZE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            carSizes = [responseObject valueForKey:@"name"];
        }
    }];

    _resultTableView = [UITableView new];
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;
    [_resultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"resultCellId"];
    [self.view addSubview:_resultTableView];
    _resultData = [NSArray new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self prefersStatusBarHidden];
    [self.navigationController setNavigationBarHidden:YES];
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

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillBeShown:(NSNotification *)noti
{
    keyboardIsShow = YES;

    if (textFieldSelected == TEXT_FIELD_ADDRESS) {
        NSDictionary* keyboardInfo = [noti userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

        [_scrollView setContentOffset:CGPointMake(0, addressTf.frame.origin.y - 5)];
        _resultTableView.frame = CGRectMake(0, addressTf.bounds.origin.y + 2*addressTf.bounds.size.height+5, WIDTH_SCREEN, self.view.frame.size.height - keyboardFrameBeginRect.size.height - addressTf.bounds.origin.y - 2*addressTf.bounds.size.height);
        
        [_resultTableView setHidden:YES];
    }
    else {
        NSDictionary* info = [noti userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+10, 0.0);
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    keyboardIsShow = NO;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    [_scrollView setScrollEnabled:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _scrollView) {
        float y = scrollView.contentOffset.y;
        if (keyboardIsShow) {
            return;
        }
        if (y > _scrollView.contentSize.height - _scrollView.frame.size.height) {
            [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentSize.height - _scrollView.frame.size.height)];
        }
        if (y < 0) {
            [_scrollView setContentOffset:CGPointMake(0, 0)];
        }
    }
}

#pragma mark - UITextFieldDelegate Methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textFieldSelected = -1;
    if (textField == carMadeTf || textField == carModelTf || textField == carTypeTf || textField == carSizeTf || textField == carYearTf || textField == carPriceTf) {
        [self.view endEditing:YES];
        UIViewController *controller = [[UIViewController alloc]init];
        UITableView *alertTableView;
        CGRect rect;
        
        NSString *title = @"";
        if (textField == carMadeTf) {
            dataTableView = carMade;
            title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_MADE");
            textFieldSelected = TEXT_FIELD_CAR_MADE;
            rowSelected = carMadeSelected;
        }
        if (textField == carModelTf) {
            dataTableView = carModel;
            title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_MODEL");
            textFieldSelected = TEXT_FIELD_CAR_MODEL;
            rowSelected = carModelSelected;
        }
        if (textField == carTypeTf) {
            dataTableView = carTypes;
            title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_TYPE");
            textFieldSelected = TEXT_FIELD_CAR_TYPE;
            rowSelected = carTypeSelected;
        }
        if (textField == carSizeTf) {
            dataTableView = carSizes;
            title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_SIZE");
            textFieldSelected = TEXT_FIELD_CAR_SIZE;
            rowSelected = carSizeSelected;
        }
        if (textField == carYearTf) {
            dataTableView = carYear;
            title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_YEAR");
            textFieldSelected = TEXT_FIELD_CAR_YEAR;
            rowSelected = carYearSelected;
        }
        
        if (textField == carPriceTf) {
            dataTableView = carPrice;
            title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_PRICE");
            textFieldSelected = TEXT_FIELD_CAR_PRICE;
            rowSelected = carPriceSelected;
        }
        
        float heightRect = MIN(HEIGHT_SCREEN*2/3, 40.*dataTableView.count);
        rect = CGRectMake(0, 0, WIDTH_SCREEN*3/4, heightRect);
        [controller setPreferredContentSize:rect.size];
        
        alertTableView  = [[UITableView alloc]initWithFrame:rect];
        alertTableView.delegate = self;
        alertTableView.dataSource = self;
        alertTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [alertTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [alertTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellSelectId"];
        [alertTableView reloadData];
//        [alertTableView setTag:kAlertTableViewTag];
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

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [_resultTableView setHidden:YES];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textFieldSelected = TEXT_FIELD_ADDRESS;
    if (textView == addressTf) {
        _resultData = nil;
        [_resultTableView reloadData];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [_fetcher sourceTextHasChanged:textView.text];
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (textFieldSelected == TEXT_FIELD_ADDRESS) {
        return _resultData.count;
    }
    return dataTableView.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (textFieldSelected == TEXT_FIELD_ADDRESS) {
        UITableViewCell *cell = [_resultTableView dequeueReusableCellWithIdentifier:@"resultCellId" forIndexPath:indexPath];
        [cell.textLabel setText:[[_resultData objectAtIndex:indexPath.row].attributedFullText string]];
        return cell;
    }
    else {
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
    if (textFieldSelected == TEXT_FIELD_ADDRESS) {
        addressTf.text = [[_resultData objectAtIndex:indexPath.row].attributedFullText string];
        [self.view endEditing:YES];

        [_resultTableView setHidden:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSPlacesClient *placeClient = [GMSPlacesClient sharedClient];
            [placeClient lookUpPlaceID:[_resultData objectAtIndex:indexPath.row].placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
                if(!error) {
                    addressCoordinate = result.coordinate;
                } else {
                    NSLog(@"Error : %@",error.localizedDescription);
                    addressCoordinate = kCLLocationCoordinate2DInvalid;
                }
            }];

        });
    }
    else {
        switch (textFieldSelected) {
            case TEXT_FIELD_CAR_MADE:
         {
            if (carMadeSelected != indexPath.row) {
                carModelTf.text = @"";
                carModelSelected = -1;
            }
            carMadeSelected = indexPath.row;
            carMadeTf.text = [carMade objectAtIndex:carMadeSelected];

            progressHudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            progressHudView.label.text = LocalizedString(@"FILTER_LOADING");
            [DataHelper GET:API_GET_MODEL_LIST params:@{@"keyword":carMadeTf.text} completion:^(BOOL success, id responseObject){
                [progressHudView hideAnimated:YES];
                if (success) {
                    carModel = [responseObject valueForKey:@"name"];
                }
            }];
         }
                break;
            case TEXT_FIELD_CAR_MODEL:
                carModelSelected = indexPath.row;
                carModelTf.text = [carModel objectAtIndex:carModelSelected];
                break;
            case TEXT_FIELD_CAR_SIZE:
                carSizeSelected = indexPath.row;
                carSizeTf.text = [carSizes objectAtIndex:carSizeSelected];
                break;
            case TEXT_FIELD_CAR_TYPE:
                carTypeSelected = indexPath.row;
                carTypeTf.text = [carTypes objectAtIndex:carTypeSelected];
                break;
            case TEXT_FIELD_CAR_YEAR:
                carYearSelected = indexPath.row;
                carYearTf.text = [carYear objectAtIndex:carYearSelected];
                break;
            case TEXT_FIELD_CAR_PRICE:
                carPriceSelected = indexPath.row;
                carPriceTf.text = [carPrice objectAtIndex:carPriceSelected];
                break;
            default:
                break;
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Events
- (IBAction)registerBtnClick:(id)sender {
    [registerBtn setHidden:YES];
    if ([self checkInputDataTextField]) {
        NSString *regId = [DataHelper getRegId];
        if (regId == nil) {
            regId = [userData objectForKey:@"regId"];
        }
        NSString *carSize = carSizeTf.text;
        if (carSize.length > 3) {
            carSize = [carSize substringToIndex:[carSize rangeOfString:@" "].location];
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"name":userNameTf.text, @"phone":phoneTf.text, @"car_number":carNumberTf.text, @"car_made":carMadeTf.text, @"car_model":carModelTf.text, @"car_size":carSize, @"car_type":carTypeTf.text, @"car_year":carYearTf.text, @"car_price":carPriceTf.text/*([carPriceTf.text isEqualToString:LocalizedString(@"REGISTER_CAR_PRICE_CUSTOM")] ? @"-1" : carPriceTf.text)*/, @"os":DEVICE_IOS, @"regId":regId, @"address" : addressTf.text, @"email" : emailTf.text, @"pass" : passwordTf.text, @"lon" : [NSString stringWithFormat:@"%.6f", addressCoordinate.longitude], @"lat" : [NSString stringWithFormat:@"%.6f", addressCoordinate.latitude]}];
        if (_isEdit) {
            [params setValue:[userData objectForKey:@"id"] forKey:@"id"];
        }
        [DataHelper POST:API_REGISTER params:params completion:^(BOOL success, id responseObject){
            if (success) {
                if ([responseObject intValue] > 0) {
                    // đăng ký thành công, lưu thông tin người dùng ...
                    if (!_isEdit) {
                        [params setValue:[NSString stringWithFormat:@"%@", responseObject] forKey:@"id"];
                    }
                    [DataHelper setUserData:@{@"data":params, @"userType":[NSString stringWithFormat:@"%d", USER_TYPE_DRIVER], @"wasActived":@"YES"}];
                    
                    [self performSegueWithIdentifier:@"gotoDriverMainSegueId" sender:self];
                    
                }
                else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizedString(@"REGISTER_ERROR") message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [alert dismissViewControllerAnimated:YES completion:nil];
                        [registerBtn setHidden:NO];
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
    }
    else{
        [registerBtn setHidden:NO];
    }
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)loginButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuBtnClick:(id)sender {
    NSString *textToShare = @"Bạn cần thuê xe hay bạn là tài xế/nhà xe/hãng xe có xe riêng, hãy dùng thử ứng dụng thuê xe  trên di động tại ";
    NSURL *myWebsite = [NSURL URLWithString:URL_SERVER];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}
#pragma mark - Custom Methods
- (BOOL)checkInputDataTextField{
    if (userNameTf.text.length == 0) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_NAME")];
        return NO;
    }
    if (phoneTf.text.length == 0) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_PHONE")];
        return NO;
    }
    if (carNumberTf.text.length == 0) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_CAR_NUMBER")];
        return NO;
    }
    if (carMadeTf.text.length == 0) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_CAR_MADE")];
        return NO;
    }
    if (carModelTf.text.length == 0 || [carModelTf.text isEqualToString:@"Nhập Mẫu xe"]) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_CAR_MODEL")];
        return NO;
    }
    if (carYearTf.text.length == 0) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_CAR_YEAR")];
        return NO;
    }
    if (carTypeTf.text.length == 0) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_CAR_TYPE")];
        return NO;
    }
    if (carPriceTf.text.length == 0) {
        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_CAR_PRICE")];
        return NO;
    }

    if (passwordTf.text.length == 0 || passwordConfirmTf.text.length == 0 || ![passwordConfirmTf.text isEqualToString:passwordTf.text]) {
        [self showAlertWithString:@"Bạn chưa nhập mật khẩu, hoặc mật khẩu xác nhận chưa khớp"];
        return NO;
    }

    if (_isEdit == YES) {
        if (emailTf.text.length == 0) {
            [self showAlertWithString:@"Hãy nhập email"];
            return NO;
        }

        if (addressTf.text.length == 0) {
            [self showAlertWithString:@"Hãy nhập địa chỉ đón khách hoặc địa chỉ nhà xe"];
            return NO;
        }

        if (![self isValidEmail:emailTf.text]) {
            [self showAlertWithString:@"Email không hợp lệ"];
            return NO;
        }

        if (!CLLocationCoordinate2DIsValid(addressCoordinate)) {
            [self showAlertWithString:@"Địa chỉ không hợp lệ"];
            return NO;
        }
    }
    return YES;
}

-(BOOL) isValidEmail:(NSString *)email
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:email];
}

- (void)showAlertWithString:(NSString *)string{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:string message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


@end

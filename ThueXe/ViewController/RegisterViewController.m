//
//  RegisterViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/1/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIFloatLabelTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "DataHelper.h"
#import "FirstViewController.h"
#import "ActiveViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIFloatLabelTextField *userNameTf;
    IBOutlet UIFloatLabelTextField *phoneTf;
    IBOutlet UIFloatLabelTextField *carMadeTf;
    IBOutlet UIFloatLabelTextField *carModelTf;
    IBOutlet UIFloatLabelTextField *carSizeTf;
    IBOutlet UIFloatLabelTextField *carYearTf;
    IBOutlet UIFloatLabelTextField *carTypeTf;
    IBOutlet UIFloatLabelTextField *carPriceTf;
    IBOutlet UIFloatLabelTextField *carNumberTf;
    
    IBOutlet UILabel *titleController;
    IBOutlet UIView *headerView;
    IBOutlet UIScrollView *_scrollView;
    BOOL keyboardIsShow;
    NSArray *carMade;
    NSMutableArray *carModel;
    NSMutableArray *carYear;
    NSArray *carTypes;
    long carMadeSelected, carModelSelected, carTypeSelected, carSizeSelected, carYearSelected, carPriceSelected;
    NSArray *dataTableView;
    
    int textFieldSelected;
    UIAlertController *alertController;
    long rowSelected;
    
    IBOutlet UIButton *registerBtn;
    NSMutableArray *carPrice;
    NSDictionary *userData;
    UITableView *tableViewSearch;
    IBOutlet UIButton *backBtn;
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
        carYearTf.text = [userData objectForKey:@"car_year"];
        carPriceTf.text = [userData objectForKey:@"car_price"];
        
    }
    
    carMadeSelected = carModelSelected = carTypeSelected = carSizeSelected = carYearSelected = carPriceSelected = -1;
    
    userNameTf.delegate = self;
    phoneTf.delegate = self;
    carMadeTf.delegate = self;
    carModelTf.delegate = self;
    carSizeTf.delegate = self;
    carYearTf.delegate = self;
    carTypeTf.delegate = self;
    carPriceTf.delegate = self;
    carNumberTf.delegate = self;
    
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

//    carMade = [CAR_MADE_MODEL valueForKey:@"car_made"];

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
    [carPrice addObject:LocalizedString(@"REGISTER_CAR_PRICE_CUSTOM")];
    for (int i = 6000; i <= 15000; i += 500) {
        [carPrice addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    tableViewSearch = [[UITableView alloc] initWithFrame:CGRectMake(4, 200, 320, 120)];
    tableViewSearch.delegate = self;
    tableViewSearch.dataSource = self;
    tableViewSearch.scrollEnabled = YES;
    tableViewSearch.allowsMultipleSelection = NO;
    [tableViewSearch registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellSearchId"];
    [tableViewSearch setHidden:YES];
    [self.view addSubview:tableViewSearch];
    [self.view bringSubviewToFront:tableViewSearch];
    [carModelTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    carModelTf.inputAccessoryView = nil;
    carModelTf.autocorrectionType = UITextAutocorrectionTypeNo;
    userNameTf.autocorrectionType = UITextAutocorrectionTypeNo;
    carNumberTf.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self getInfoCarFromServer];
}

-(void)getInfoCarFromServer{
    
    [DataHelper GET:API_GET_ALL_MADE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            //            NSLog(@"%@", responseObject);
            carMade = [responseObject valueForKey:@"name"];
            //            NSLog(@"%@", carMade);
        }
    }];
    
    [DataHelper GET:API_GET_MODEL_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            //            NSLog(@"%@", responseObject);
            carModel = [responseObject valueForKey:@"name"];
            //            NSLog(@"%@", carModel);
        }
    }];
    
    [DataHelper GET:API_GET_TYPE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            //            NSLog(@"%@", responseObject);
            carTypes = [responseObject valueForKey:@"name"];
            //            NSLog(@"%@", carTypes);
        }
    }];
}

-(void)textFieldDidChange:(NSNotification*)noti{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", carModelTf.text];
    dataTableView = [carModel filteredArrayUsingPredicate:predicate];
//    NSLog(@"ContentOfset:%f", _scrollView.contentOffset.y);
    CGRect rect = carModelTf.frame;
    
    [_scrollView setContentOffset:CGPointMake(0, rect.origin.y - 10) animated:NO];
    rect = carModelTf.frame;
    if (_scrollView.contentOffset.y != rect.origin.y - 10) {
        [tableViewSearch setFrame:CGRectMake(rect.origin.x, rect.size.height + 80, rect.size.width, MIN(70*carModel.count, 150))];
    }
    else{
        [tableViewSearch setFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height+70-_scrollView.contentOffset.y, rect.size.width, MIN(70*carModel.count, 150))];
    }
    
    [tableViewSearch setHidden:NO];
    
    [tableViewSearch reloadData];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    [tableViewSearch setHidden:YES];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(![touch.view isMemberOfClass:[UITextField class]]) {
        [touch.view endEditing:YES];
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillBeShown:(NSNotification*)aNotification
{
    keyboardIsShow = YES;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+10, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    keyboardIsShow = NO;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}
- (IBAction)registerBtnClick:(id)sender {
    [registerBtn setHidden:YES];
    if ([self checkInputDataTextField]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"name":userNameTf.text, @"phone":phoneTf.text, @"car_number":carNumberTf.text, @"car_made":carMadeTf.text, @"car_model":carModelTf.text, @"car_size":[carSizeTf.text substringToIndex:[carSizeTf.text rangeOfString:@" "].location], @"car_type":carTypeTf.text, @"car_year":carYearTf.text, @"car_price":([carPriceTf.text isEqualToString:LocalizedString(@"REGISTER_CAR_PRICE_CUSTOM")] ? @"-1" : carPriceTf.text)}];
        if (_isEdit) {
            [params setValue:[userData objectForKey:@"id"] forKey:@"id"];
        }
        [DataHelper POST:API_REGISTER params:params completion:^(BOOL success, id responseObject){
            if (success) {
                if ([responseObject intValue] > 0) {
                    
                    
                    if (_isEdit) {
                        // đăng ký thành công, lưu thông tin người dùng ...
                        [params setValue:[NSString stringWithFormat:@"%@", responseObject] forKey:@"id"];
//                        [[NSUserDefaults standardUserDefaults] setObject:@{@"data":params, @"userType":[NSString stringWithFormat:@"%d", USER_TYPE_DRIVER], @"wasActived":@"YES"} forKey:@"userInfo"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [DataHelper setUserData:@{@"data":params, @"userType":[NSString stringWithFormat:@"%d", USER_TYPE_DRIVER], @"wasActived":@"YES"}];
                        
                        [self performSegueWithIdentifier:@"goToMapDriveSegueId" sender:self];
                    }
                    else{
                        // đăng ký thành công, lưu thông tin người dùng ...
                        [params setValue:[NSString stringWithFormat:@"%@", responseObject] forKey:@"id"];
//                        [[NSUserDefaults standardUserDefaults] setObject:@{@"data":params, @"userType":[NSString stringWithFormat:@"%d", USER_TYPE_DRIVER]} forKey:@"userInfo"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [DataHelper setUserData:@{@"data":params, @"userType":[NSString stringWithFormat:@"%d", USER_TYPE_DRIVER]}];
                        
                        ActiveViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"activeStoryboardId"];
                        [self presentViewController:vc animated:YES completion:nil];
                    }
                    
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
            else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizedString(@"REGISTER_ERROR") message:@"Kiểm tra lại kết nối internet" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    [registerBtn setHidden:NO];
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    else{
        [registerBtn setHidden:NO];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _scrollView) {
        float y = scrollView.contentOffset.y;
//        NSLog(@"ContentOfset:%f - %f", _scrollView.contentOffset.y, carModelTf.frame.origin.y);
//        CGRect rect = tableViewSearch.frame;
//        [tableViewSearch setFrame:CGRectMake(rect.origin.x, rect.origin.y + 70 - _scrollView.contentOffset.y, rect.size.width, rect.size.height)];
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
    if (textField == carModelTf && [textField.text isEqualToString:@"Nhập Mẫu xe"]) {
        carModelTf.text = @"";
        return YES;
    }
    
    if (textField == carMadeTf /*|| textField == carModelTf*/ || textField == carTypeTf || textField == carSizeTf || textField == carYearTf || textField == carPriceTf) {
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
        if (textField == carTypeTf) {
            dataTableView = carTypes;
            title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_TYPE");
            textFieldSelected = TEXT_FIELD_CAR_TYPE;
            rowSelected = carTypeSelected;
        }
        if (textField == carSizeTf) {
            dataTableView = CAR_SIZE;
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    if (textField == carModelTf) {
        [textField resignFirstResponder];
        [tableViewSearch setHidden:YES];
//    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == carModelTf) {
        [tableViewSearch setHidden:YES];
    }
}


#pragma mark - UITableViewDelegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataTableView.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tableViewSearch) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSearchId" forIndexPath:indexPath];
        cell.textLabel.text = [dataTableView objectAtIndex:indexPath.row];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tableViewSearch) {
        carModelTf.text = [dataTableView objectAtIndex:indexPath.row];
        [tableViewSearch setHidden:YES];
        [carModelTf resignFirstResponder];
    }
    else{
        switch (textFieldSelected) {
            case TEXT_FIELD_CAR_MADE:
            {
                if (carMadeSelected != indexPath.row) {
                    carModelTf.text = @"Nhập Mẫu xe";
                    carModelSelected = -1;
                }
                carMadeSelected = indexPath.row;
//                carModel = [[CAR_MADE_MODEL objectAtIndex:carMadeSelected] objectForKey:@"car_model"];
                carMadeTf.text = [carMade objectAtIndex:carMadeSelected];
                
                [DataHelper GET:API_GET_MODEL_LIST params:@{@"keyword":carMadeTf.text} completion:^(BOOL success, id responseObject){
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
                carSizeTf.text = [CAR_SIZE objectAtIndex:carSizeSelected];
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

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Events
- (IBAction)backBtnClick:(id)sender {
//    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    else {
        [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
//    }
}

- (IBAction)menuBtnClick:(id)sender {
    NSString *textToShare = @"Bạn cần thuê xe hay bạn là tài xế/nhà xe/hãng xe có xe riêng, hãy dùng thử ứng dụng thuê xe  trên di động tại ";
    NSURL *myWebsite = [NSURL URLWithString:@"http://thuexevn.com"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(BOOL)checkInputDataTextField{
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
//    if (carSizeTf.text.length == 0) {
//        [self showAlertWithString:LocalizedString(@"REGISTER_ERROR_CAR_SIZE")];
//        return NO;
//    }
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

    return YES;
}

-(void)showAlertWithString:(NSString*)string{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:string message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

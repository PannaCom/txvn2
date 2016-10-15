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
    
    IBOutlet UIView *headerView;
    IBOutlet UIScrollView *_scrollView;
    BOOL keyboardIsShow;
    NSArray *carMade;
    NSArray *carModel;
    NSMutableArray *carYear;
    int carMadeSelected, carModelSelected, carTypeSelected, carSizeSelected, carYearSelected;
    NSArray *dataTableView;
    
    int textFieldSelected;
    UIAlertController *alertController;
    int rowSelected;
    
    
}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    carMadeSelected = carModelSelected = carTypeSelected = carSizeSelected = carYearSelected = -1;
    
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
    carModel = [NSArray new];

    carMade = [CAR_MADE_MODEL valueForKey:@"car_made"];

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
    NSDictionary *params = @{@"name":userNameTf.text, @"phone":phoneTf.text, @"car_number":carNumberTf.text, @"car_made":carMadeTf.text, @"car_model":carModelTf.text, @"car_size":[carSizeTf.text substringToIndex:[carSizeTf.text rangeOfString:@" "].location], @"car_type":carTypeTf.text, @"car_year":carYearTf.text, @"car_price":carPriceTf.text};
    [DataHelper POST:API_REGISTER params:params completion:^(BOOL success, id responseObject, NSError *error){
        if (success) {
            if ([responseObject isEqualToString:@"1"]) {
                // đăng ký thành công, lưu thông tin người dùng ...
                [[NSUserDefaults standardUserDefaults] setObject:@{@"data":params, @"userType":[NSString stringWithFormat:@"%d", USER_TYPE_DRIVER]} forKey:@"userInfo"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self performSegueWithIdentifier:@"goToMapDriveSegueId" sender:self];
            }
            else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Đăng ký không thành công" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _scrollView) {
        float y = scrollView.contentOffset.y;
        if (keyboardIsShow) {
            return;
        }
        if (y > _scrollView.contentSize.height - _scrollView.frame.size.height) {
            [_scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height - _scrollView.frame.size.height)];
        }
        if (y < 0) {
            [_scrollView setContentOffset:CGPointMake(0, 0)];
        }
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == carMadeTf || textField == carModelTf || textField == carTypeTf || textField == carSizeTf || textField == carYearTf) {
        [self.view endEditing:YES];
        UIViewController *controller = [[UIViewController alloc]init];
        UITableView *alertTableView;
        CGRect rect;
        
        NSString *title = @"";
        if (textField == carMadeTf) {
            dataTableView = carMade;
            title = @"Chọn hãng xe";
            textFieldSelected = TEXT_FIELD_CAR_MADE;
            rowSelected = carMadeSelected;
        }
        else{
            if (textField == carModelTf) {
                if (carMadeSelected == -1) {
                    alertController = [UIAlertController alertControllerWithTitle:@"Chưa chọn hãng xe" message:@"Hãy chọn hãng xe của bạn" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return NO;
                }
                dataTableView = carModel;
                title = @"Chọn mẫu xe";
                textFieldSelected = TEXT_FIELD_CAR_MODEL;
                rowSelected = carModelSelected;
            }
            else{
                if (textField == carTypeTf) {
                    dataTableView = CAR_TYPE;
                    title = @"Chọn loại xe";
                    textFieldSelected = TEXT_FIELD_CAR_TYPE;
                    rowSelected = carTypeSelected;
                }
                else{
                    if (textField == carSizeTf) {
                        dataTableView = CAR_SIZE;
                        title = @"Chọn số chỗ";
                        textFieldSelected = TEXT_FIELD_CAR_SIZE;
                        rowSelected = carSizeSelected;
                    }
                    else{
                        if (textField == carYearTf) {
                            dataTableView = carYear;
                            title = @"Chọn năm sản xuất xe";
                            textFieldSelected = TEXT_FIELD_CAR_YEAR;
                            rowSelected = carYearSelected;
                        }
                    }
                }
            }
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

#pragma mark -UITableViewDelegate Methods
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

//-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]].accessoryType = UITableViewCellAccessoryNone;
//    return indexPath;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (textFieldSelected) {
        case TEXT_FIELD_CAR_MADE:
            if (carMadeSelected != indexPath.row) {
                carModelTf.text = @"";
                carModelSelected = -1;
            }
            carMadeSelected = indexPath.row;
            carModel = [[CAR_MADE_MODEL objectAtIndex:carMadeSelected] objectForKey:@"car_model"];
            carMadeTf.text = [carMade objectAtIndex:carMadeSelected];
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
            carTypeTf.text = [CAR_TYPE objectAtIndex:carTypeSelected];
            break;
        case TEXT_FIELD_CAR_YEAR:
            carYearSelected = indexPath.row;
            carYearTf.text = [carYear objectAtIndex:carYearSelected];
            break;
        default:
            break;
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [alertController dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuBtnClick:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *changeUser = [UIAlertAction actionWithTitle:@"Đổi vai trò" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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


@end

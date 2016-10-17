//
//  FilterViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/9/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "FilterViewController.h"
#import "UIFloatLabelTextField.h"
#import "Config.h"
#import "DataHelper.h"
#import "ListDataViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface FilterViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIFloatLabelTextField *carMadeTf;
    IBOutlet UIFloatLabelTextField *carModelTf;
    IBOutlet UIFloatLabelTextField *carSizeTf;
    IBOutlet UIFloatLabelTextField *carYearTf;
    IBOutlet UIFloatLabelTextField *carTypeTf;
    NSArray *carMade;
    NSArray *carModel;
    NSMutableArray *carYear;
    long carMadeSelected, carModelSelected, carTypeSelected, carSizeSelected, carYearSelected;
    NSArray *dataTableView;
    
    long textFieldSelected;
    UIAlertController *alertController;
    long rowSelected;
    NSMutableArray *allCar;
    MBProgressHUD *progressHudView;
    
    UITableView *tableViewSearch;
    NSArray *carModelAll;
}
@end

@implementation FilterViewController
#pragma mark - LifeCycle View Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    carMadeSelected = carModelSelected = carTypeSelected = carSizeSelected = carYearSelected = -1;
    
    carMadeTf.delegate = self;
    carModelTf.delegate = self;
    carSizeTf.delegate = self;
    carYearTf.delegate = self;
    carTypeTf.delegate = self;
    
    carMade = [NSArray new];
    carModel = [NSArray new];
    carModelAll = [NSArray new];
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
    
    if (!_filterData) {
        _filterData = [NSMutableDictionary dictionaryWithDictionary:@{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""}];
    }
    
    
    carMadeTf.text = [self checkIsAll:[_filterData objectForKey:@"car_made"]];
    carModelTf.text = [self checkIsAll:[_filterData objectForKey:@"car_model"]];
    carSizeTf.text = [self checkIsAll:[_filterData objectForKey:@"car_size"]];
    carTypeTf.text = [self checkIsAll:[_filterData objectForKey:@"car_type"]];
    carYearTf.text = [self checkIsAll:[_filterData objectForKey:@"car_year"]];
    
    allCar = [NSMutableArray new];
    for (NSDictionary *car_made in CAR_MADE_MODEL) {
        [allCar addObjectsFromArray:[car_made objectForKey:@"car_model"]];
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
//    [self getFilterDataFromServer];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getFilterDataFromServer];
}

-(void)getFilterDataFromServer{
    progressHudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHudView.label.text = @"Đang tải dữ liệu";
    
    __block int done = 0;
    [DataHelper GET:API_GET_MADE_LIST params:@{} completion:^(BOOL success, id responseObject, NSError *error){
        if (success) {
            done ++;
            if (done == 2) {
                [progressHudView hideAnimated:YES];
            }
//            NSLog(@"%@", responseObject);
            carMade = [responseObject valueForKey:@"name"];
//            NSLog(@"%@", carMade);
        }
    }];
    
    [DataHelper GET:API_GET_MODEL_LIST params:@{} completion:^(BOOL success, id responseObject, NSError *error){
        if (success) {
            done ++;
            if (done == 2) {
                [progressHudView hideAnimated:YES];
            }
            //            NSLog(@"%@", responseObject);
            carModelAll = [responseObject valueForKey:@"name"];
//            NSLog(@"%@", carModel);
        }
    }];
}

-(NSString *)checkIsAll:(NSString *)input{
    if ([input isEqualToString:@""]) {
        return TEXT_ALL;
    }
    return input;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == tableViewSearch) {
        return carModel.count;
    }
    return dataTableView.count+1;
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
        cell.textLabel.text = [carModel objectAtIndex:indexPath.row];
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSelectId" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = TEXT_ALL;
        }
        else{
            cell.textLabel.text = [dataTableView objectAtIndex:indexPath.row-1];
        }
        
        if (indexPath.row-1 == rowSelected) {
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
        carModelTf.text = [carModel objectAtIndex:indexPath.row];
        [tableViewSearch setHidden:YES];
        [carModelTf resignFirstResponder];
    }
    else{
        
        switch (textFieldSelected) {
            case TEXT_FIELD_CAR_MADE:
                if (carMadeSelected != indexPath.row) {
                    carModelTf.text = TEXT_ALL;
                    carModelSelected = -1;
                    [_filterData setObject:@"" forKey:@"car_model"];
                }
                carMadeSelected = indexPath.row-1;
                if (carMadeSelected > -1) {
    //                carModel = [[CAR_MADE_MODEL objectAtIndex:carMadeSelected] objectForKey:@"car_model"];
                    carMadeTf.text = [carMade objectAtIndex:carMadeSelected];
                    [_filterData setObject:carMadeTf.text forKey:@"car_made"];
                }
                else{
    //                carModel = allCar;
                    carMadeTf.text = TEXT_ALL;
                    carModelTf.text = TEXT_ALL;
                    [_filterData setObject:@"" forKey:@"car_made"];
                    [_filterData setObject:@"" forKey:@"car_model"];
                }
                
                break;
            case TEXT_FIELD_CAR_MODEL:
                carModelSelected = indexPath.row-1;
                if (carModelSelected == -1) {
                    carModelTf.text = TEXT_ALL;
                    [_filterData setObject:@"" forKey:@"car_model"];
                }
                else{
                    carModelTf.text = [carModel objectAtIndex:carModelSelected];
                    [_filterData setObject:carModelTf.text forKey:@"car_model"];
                }
                
                break;
            case TEXT_FIELD_CAR_SIZE:
                carSizeSelected = indexPath.row-1;
                if (carSizeSelected == -1) {
                    carSizeTf.text = TEXT_ALL;
                    [_filterData setObject:@"" forKey:@"car_size"];
                }
                else{
                    carSizeTf.text = [CAR_SIZE objectAtIndex:carSizeSelected];
                    [_filterData setObject:carSizeTf.text forKey:@"car_size"];
                }
                
                break;
            case TEXT_FIELD_CAR_TYPE:
                carTypeSelected = indexPath.row-1;
                if (carTypeSelected == -1) {
                    carTypeTf.text = TEXT_ALL;
                    [_filterData setObject:@"" forKey:@"car_type"];
                }
                else{
                    carTypeTf.text = [CAR_TYPE objectAtIndex:carTypeSelected];
                    [_filterData setObject:carTypeTf.text forKey:@"car_type"];
                }
                
                break;
            case TEXT_FIELD_CAR_YEAR:
                carYearSelected = indexPath.row-1;
                if (carYearSelected == -1) {
                    carTypeTf.text = TEXT_ALL;
                    [_filterData setObject:@"" forKey:@"car_year"];
                }
                else{
                    carYearTf.text = [carYear objectAtIndex:carYearSelected];
                    [_filterData setObject:carYearTf.text forKey:@"car_year"];
                }
                
                break;
            default:
                break;
        }
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]].accessoryType = UITableViewCellAccessoryCheckmark;
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == carMadeTf /*|| textField == carModelTf */|| textField == carTypeTf || textField == carSizeTf || textField == carYearTf) {
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
            //            if (textField == carModelTf) {
            //                dataTableView = carModel;
            //                title = @"Chọn mẫu xe";
            //                textFieldSelected = TEXT_FIELD_CAR_MODEL;
            //                rowSelected = carModelSelected;
            //            }
            //            else{
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
            //            }
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
    if (textField == carModelTf) {
        [textField resignFirstResponder];
        [tableViewSearch setHidden:YES];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == carModelTf) {
        [_filterData setObject:carModelTf.text forKey:@"car_model"];
        [tableViewSearch setHidden:YES];
    }
}

#pragma mark - Events
-(void)textFieldDidChange:(NSNotification*)noti{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", carModelTf.text];
    carModel = [carModelAll filteredArrayUsingPredicate:predicate];
    
    CGRect rect = carModelTf.frame;
    [tableViewSearch setFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height + 2, rect.size.width, MIN(70*carModel.count, 150))];
    [tableViewSearch setHidden:NO];
    
    [tableViewSearch reloadData];
}

- (IBAction)backBtnClick:(id)sender {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (IBAction)clearBtnClick:(id)sender {
    carMadeTf.text = TEXT_ALL;
    carModelTf.text = TEXT_ALL;
    carSizeTf.text = TEXT_ALL;
    carTypeTf.text = TEXT_ALL;
    carYearTf.text = TEXT_ALL;
    carMadeSelected = carModelSelected = carTypeSelected = carSizeSelected = carYearSelected = -1;
    _filterData = [NSMutableDictionary dictionaryWithDictionary:@{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""}];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showListCarSegueId"]) {
        [DataHelper setFilterData:_filterData];
        
        UITabBarController *tabbar = [segue destinationViewController];
        ListDataViewController *listController = [tabbar.viewControllers objectAtIndex:0];
        listController.filterData = _filterData;
        [tabbar setSelectedIndex:0];
    }
}

@end

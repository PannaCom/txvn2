//
//  FilterViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/9/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "FilterViewController.h"
#import "JVFloatLabeledTextField.h"
#import "Config.h"
#import "DataHelper.h"
#import "ListDataViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface FilterViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet JVFloatLabeledTextField *carMadeTf;
    IBOutlet JVFloatLabeledTextField *carModelTf;
    IBOutlet JVFloatLabeledTextField *carSizeTf;
    IBOutlet UISegmentedControl *orderSegment;
    IBOutlet JVFloatLabeledTextField *carTypeTf;
    NSArray *carMade;
    NSArray *carModel;
    NSArray *carTypes;
    NSArray *carSizes;
    NSMutableArray *carYear;
    long carMadeSelected, carModelSelected, carTypeSelected, carSizeSelected, carYearSelected;
    NSArray *dataTableView;
    
    long textFieldSelected;
    UIAlertController *alertController;
    long rowSelected;
//    NSMutableArray *allCar;
    MBProgressHUD *progressHudView;
    
//    UITableView *tableViewSearch;
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
    carTypeTf.delegate = self;
    
    carMade = [NSArray new];
    carModel = [NSArray new];
    carModelAll = [NSArray new];
    carTypes = [NSArray new];
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
    
    if (!_filterData) {
        _filterData = [NSMutableDictionary dictionaryWithDictionary:@{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""}];
    }
    
    
    carMadeTf.text = [self checkIsAll:[_filterData objectForKey:@"car_made"]];
    carModelTf.text = [self checkIsAll:[_filterData objectForKey:@"car_model"]];
    carSizeTf.text = [self checkIsAll:[_filterData objectForKey:@"car_size"]];
    carTypeTf.text = [self checkIsAll:[_filterData objectForKey:@"car_type"]];

    
    NSString *order = [_filterData objectForKey:@"order"];
    if (order != nil && order.length > 0) {
        [orderSegment setSelectedSegmentIndex:[order intValue]];
    }
    else{
        [orderSegment setSelectedSegmentIndex:0];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self prefersStatusBarHidden];
//    [self getFilterDataFromServer];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getFilterDataFromServer];
}

-(void)getFilterDataFromServer{
    progressHudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHudView.label.text = LocalizedString(@"FILTER_LOADING");
    
    __block int done = 0;
    [DataHelper GET:API_GET_MADE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            done ++;
            if (done == 4) {
                [progressHudView hideAnimated:YES];
            }
            carMade = [responseObject valueForKey:@"name"];
        }
    }];
    
    [DataHelper GET:API_GET_MODEL_LIST params:@{@"keyword":[_filterData objectForKey:@"car_made"]} completion:^(BOOL success, id responseObject){
        if (success) {
            done ++;
            if (done == 4) {
                [progressHudView hideAnimated:YES];
            }
            carModelAll = [responseObject valueForKey:@"name"];
        }
    }];
    
    [DataHelper GET:API_GET_TYPE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            done ++;
            if (done == 4) {
                [progressHudView hideAnimated:YES];
            }
            carTypes = [responseObject valueForKey:@"name"];
        }
    }];
    
    [DataHelper GET:API_GET_SIZE_LIST params:@{} completion:^(BOOL success, id responseObject){
        if (success) {
            done ++;
            if (done == 4) {
                [progressHudView hideAnimated:YES];
            }
            carSizes = [responseObject valueForKey:@"name"];
        }
    }];
}

-(NSString *)checkIsAll:(NSString *)input{
    if ([input isEqualToString:@""]) {
        return LocalizedString(@"TEXT_ALL");
    }
    return input;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (tableView == tableViewSearch) {
//        return carModel.count;
//    }
    return dataTableView.count+1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSelectId" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = LocalizedString(@"TEXT_ALL");
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        switch (textFieldSelected) {
            case TEXT_FIELD_CAR_MADE:
            {
                if (carMadeSelected != indexPath.row-1) {
                    carModelTf.text = LocalizedString(@"TEXT_ALL");
                    carModelSelected = -1;
                    [_filterData setObject:@"" forKey:@"car_model"];
                }
                carMadeSelected = indexPath.row-1;
                if (carMadeSelected > -1) {
                    carMadeTf.text = [carMade objectAtIndex:carMadeSelected];
                    [_filterData setObject:carMadeTf.text forKey:@"car_made"];
                }
                else{
                    carMadeTf.text = LocalizedString(@"TEXT_ALL");
                    carModelTf.text = LocalizedString(@"TEXT_ALL");
                    [_filterData setObject:@"" forKey:@"car_made"];
                    [_filterData setObject:@"" forKey:@"car_model"];
                }
                progressHudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                progressHudView.label.text = LocalizedString(@"FILTER_LOADING");
                [DataHelper GET:API_GET_MODEL_LIST params:@{@"keyword":[_filterData objectForKey:@"car_made"]} completion:^(BOOL success, id responseObject){
                    [progressHudView hideAnimated:YES];
                    if (success) {
                        carModelAll = [responseObject valueForKey:@"name"];
                    }
                }];
            }
                break;
            case TEXT_FIELD_CAR_MODEL:
                carModelSelected = indexPath.row-1;
                if (carModelSelected == -1) {
                    carModelTf.text = LocalizedString(@"TEXT_ALL");
                    [_filterData setObject:@"" forKey:@"car_model"];
                }
                else{
                    carModelTf.text = [carModelAll objectAtIndex:carModelSelected];
                    [_filterData setObject:carModelTf.text forKey:@"car_model"];
                }
                
                break;
            case TEXT_FIELD_CAR_SIZE:
                carSizeSelected = indexPath.row-1;
                if (carSizeSelected == -1) {
                    carSizeTf.text = LocalizedString(@"TEXT_ALL");
                    [_filterData setObject:@"" forKey:@"car_size"];
                }
                else{
                    carSizeTf.text = [carSizes objectAtIndex:carSizeSelected];
                    [_filterData setObject:carSizeTf.text forKey:@"car_size"];
                }
                
                break;
            case TEXT_FIELD_CAR_TYPE:
                carTypeSelected = indexPath.row-1;
                if (carTypeSelected == -1) {
                    carTypeTf.text = LocalizedString(@"TEXT_ALL");
                    [_filterData setObject:@"" forKey:@"car_type"];
                }
                else{
                    carTypeTf.text = [carTypes objectAtIndex:carTypeSelected];
                    [_filterData setObject:carTypeTf.text forKey:@"car_type"];
                }
                
                break;
            case TEXT_FIELD_CAR_YEAR:
                carYearSelected = indexPath.row-1;
                if (carYearSelected == -1) {
                    carTypeTf.text = LocalizedString(@"TEXT_ALL");
                    [_filterData setObject:@"" forKey:@"car_year"];
                }
                
                break;
            default:
                break;
        }
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]].accessoryType = UITableViewCellAccessoryCheckmark;
        [alertController dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == carMadeTf || textField == carModelTf || textField == carTypeTf || textField == carSizeTf) {
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
        else{
            if (textField == carModelTf) {
                dataTableView = carModelAll;
                title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_MODEL");
                textFieldSelected = TEXT_FIELD_CAR_MODEL;
                rowSelected = carModelSelected;
            }
            else{
                if (textField == carTypeTf) {
                    dataTableView = carTypes;
                    title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_TYPE");
                    textFieldSelected = TEXT_FIELD_CAR_TYPE;
                    rowSelected = carTypeSelected;
                }
                else{
                    if (textField == carSizeTf) {
                        dataTableView = carSizes;
                        title = LocalizedString(@"REGISTER_TITLE_SELECT_CAR_SIZE");
                        textFieldSelected = TEXT_FIELD_CAR_SIZE;
                        rowSelected = carSizeSelected;
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
    if (textField == carModelTf && [carModelTf.text isEqualToString:LocalizedString(@"TEXT_ALL")]) {
        carModelTf.text = @"";
    }
    return YES;
}


#pragma mark - Events

- (IBAction)backBtnClick:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clearBtnClick:(id)sender {
    carMadeTf.text = LocalizedString(@"TEXT_ALL");
    carModelTf.text = LocalizedString(@"TEXT_ALL");
    carSizeTf.text = LocalizedString(@"TEXT_ALL");
    carTypeTf.text = LocalizedString(@"TEXT_ALL");
    carMadeSelected = carModelSelected = carTypeSelected = carSizeSelected = carYearSelected = -1;
    _filterData = [NSMutableDictionary dictionaryWithDictionary:@{@"car_made":@"", @"car_model":@"", @"car_size":@"", @"car_type":@""}];
}

- (IBAction)changeOrder:(id)sender {
    [_filterData setObject:[NSString stringWithFormat:@"%ld", (long)orderSegment.selectedSegmentIndex] forKey:@"order"];
}
- (IBAction)findCarClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"filterDataNoti" object:nil userInfo:@{@"filterData":_filterData}];
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

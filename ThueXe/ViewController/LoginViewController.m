//
//  LoginViewController.m
//  ThueXe
//
//  Created by VMio69 on 1/10/17.
//  Copyright © 2017 VMio69. All rights reserved.
//

#import "LoginViewController.h"
#import "JVFloatLabeledTextField.h"
#import "DataHelper.h"
#import "Config.h"
#import "TSMessage.h"

@interface LoginViewController ()
{
    IBOutlet UIButton *backBtn;
    IBOutlet UIButton *loginBtn;
    IBOutlet UIButton *registerBtn;
    IBOutlet JVFloatLabeledTextField *phoneTf;
    IBOutlet JVFloatLabeledTextField *passTf;

}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginBtnTouched:(id)sender {
    if (phoneTf.text.length == 0 || passTf.text.length == 0) {
        [TSMessage showNotificationWithTitle:@"Lỗi:" subtitle:@"Hãy nhập đủ thông tin" type:TSMessageNotificationTypeError];
    }
    else {
        [DataHelper POST:API_LOGIN_DRIVER params:@{@"phone" : phoneTf.text, @"pass" : passTf.text} completion:^(BOOL success, id responseObject) {
            if (success) {
//                NSLog(@"%@", responseObject);
                NSError *error;
                NSArray *result = [NSJSONSerialization JSONObjectWithData:[responseObject dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                if (result.count == 1) {
                    NSMutableDictionary *userInfo = [result.firstObject mutableCopy];
                    [userInfo setObject:passTf.text forKey:@"pass"];
                    [userInfo removeObjectForKey:@"geo"];
                    [userInfo removeObjectForKey:@"province"];
                    [userInfo removeObjectForKey:@"total_moneys"];
                    [userInfo removeObjectForKey:@"os"];
                    [DataHelper setUserData:@{@"data" : userInfo, @"userType":[NSString stringWithFormat:@"%d", USER_TYPE_DRIVER], @"wasActived":@"YES"}];
                    
                    [self performSegueWithIdentifier:@"loginToDriverMainSegueId" sender:self];
                }
                else {
                    [TSMessage showNotificationWithTitle:@"Không thể đăng nhập:" subtitle:@"Kiểm tra lại thông tin đăng nhập" type:TSMessageNotificationTypeError];
                }
            }
            else {
                [TSMessage showNotificationWithTitle:@"Lỗi:" subtitle:@"Kiểm tra lại kết nối mạng" type:TSMessageNotificationTypeError];
            }
        }];
    }
}

@end

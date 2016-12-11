//
//  ActiveViewController.m
//  ThueXe
//
//  Created by VMio69 on 10/21/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "ActiveViewController.h"
#import "DataHelper.h"
#import "MapDriverViewController.h"
#import "RegisterViewController.h"

@interface ActiveViewController () <UITextViewDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField *activeCode;
    IBOutlet UIButton *sendBtn;
    IBOutlet UITextView *resendTextView;
    IBOutlet UITextView *reRegisterTextView;
    
    IBOutlet NSLayoutConstraint *widthActiveCode;
    IBOutlet UILabel *headerLb;
    IBOutlet UILabel *textLb;
    NSDictionary *userInfo;
    BOOL wasSend;
}
@end

@implementation ActiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    userInfo = [[DataHelper getUserData] objectForKey:@"data"];
    wasSend = NO;
    [activeCode becomeFirstResponder];
   
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_isActiveBuyCode) {
        headerLb.text = @"Nhập mã kích hoạt";
        [textLb setText:@"Nhập mã kích hoạt bạn đã mua"];
        [resendTextView setHidden:YES];
        [reRegisterTextView setHidden:YES];
        activeCode.keyboardType = UIKeyboardTypeDefault;
        widthActiveCode.constant = 0.75*WIDTH_SCREEN;
        [sendBtn setTitle:@"Kích hoạt" forState:UIControlStateNormal];
    }
    else{
        headerLb.text = @"Nhập mã xác nhận";
        [textLb setText:@"Nhập mã xác nhận trong tin nhắn sms từ số điện thoại bạn đã đăng ký"];
        [resendTextView setHidden:NO];
        [reRegisterTextView setHidden:NO];
        activeCode.keyboardType = UIKeyboardTypeNumberPad;
        widthActiveCode.constant = 0.5*WIDTH_SCREEN;
        [sendBtn setTitle:@"Xác nhận" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (textView == resendTextView) {
        [resendTextView setUserInteractionEnabled:NO];
        if ([self canResendActiveCode] && !wasSend) {
            wasSend = YES;

            [DataHelper POST:API_RESEND_ACTIVE params:@{@"idtaixe":[userInfo objectForKey:@"id"]} completion:^(BOOL success, id responseObject){
                if (success && [responseObject isEqualToString:@"1"]) {
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:[NSDate date] forKey:@"lastSend"];
                    [userDefault synchronize];
                    wasSend = NO;
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mã kích hoạt đã được gửi đến số điện thoại của bạn." message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [alert dismissViewControllerAnimated:YES completion:^(){
                            [activeCode becomeFirstResponder];
                        }];
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else{
                    
                }
                NSLog(@"%@", responseObject);
            }];
        }
    }
    
    if (textView == reRegisterTextView) {
        if ((BOOL)self.presentedViewController) {
            if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            RegisterViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"registerStoryboardId"];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 5 || returnKey || _isActiveBuyCode;
}

- (IBAction)sendBtnClick:(id)sender {
    if (_isActiveBuyCode) {
        [sendBtn setEnabled:NO];
        [DataHelper POST:API_ACTIVE_BUY params:@{@"phone":[userInfo objectForKey:@"phone"], @"code":activeCode.text} completion:^(BOOL success, id responseObject){
            NSLog(@"%@", responseObject);
            if (success) {
                int daysActive = [responseObject intValue];
                if (daysActive > 0) {
                    [DataHelper activeUser:daysActive];
                    MapDriverViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"driverMainStoryboardId"];
                    
                    [self presentViewController:controller animated:YES completion:nil];
                }
                else{
                    [sendBtn setEnabled:YES];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizedString(@"ACTIVE_ERROR_TITLE") message:LocalizedString(@"ACTIVE_ERROR_ACTIVE_FAIL") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [alert dismissViewControllerAnimated:YES completion:^(){
                            
                            [activeCode becomeFirstResponder];
                        }];
                    }];
                    
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
    }
    else{
        if (activeCode.text.length < 5) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizedString(@"ACTIVE_ERROR_TITLE") message:LocalizedString(@"ACTIVE_ERROR_INPUT") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [alert dismissViewControllerAnimated:YES completion:^(){
                    [activeCode becomeFirstResponder];
                }];
            }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            [sendBtn setEnabled:NO];
            
            [DataHelper POST:API_ACTIVE params:@{@"idtaixe":[userInfo objectForKey:@"id"], @"code":activeCode.text} completion:^(BOOL success, id responseObject){
                NSLog(@"%@", responseObject);
                if (success) {
                    
                    if ([responseObject isEqualToString:@"1"]) {
                        [DataHelper activeUser:DAYS_TRIAL];
                        MapDriverViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapDriverStoryboardId"];
                        
                        [self presentViewController:controller animated:YES completion:nil];
                    }
                    else{
                        [sendBtn setEnabled:YES];
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Lỗi kích hoạt" message:@"Kiểm tra lại mã kích hoạt" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                            [alert dismissViewControllerAnimated:YES completion:^(){
                                
                                [activeCode becomeFirstResponder];
                            }];
                        }];
                        
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }
            }];
        }
    }
}

- (BOOL)canResendActiveCode{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDate *lastSend = [userDefault objectForKey:@"lastSend"];
    
    if (lastSend != nil && -[lastSend timeIntervalSinceNow] < TIME_LIMIT_RESEND_CODE) {
        return NO;
    }

    return YES;
}

@end

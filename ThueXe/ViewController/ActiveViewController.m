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
    NSDictionary *userInfo;
}
@end

@implementation ActiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    userInfo = [[DataHelper getUserData] objectForKey:@"data"];
    
    [activeCode becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (textView == resendTextView) {
        if ([self canResendActiveCode]) {
            [DataHelper POST:API_RESEND_ACTIVE params:@{@"idtaixe":[userInfo objectForKey:@"id"]} completion:^(BOOL success, id responseObject, NSError *error){
                if (success && [responseObject isEqualToString:@"1"]) {
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:[NSDate date] forKey:@"lastSend"];
                    [userDefault synchronize];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mã kích hoạt đã được gửi đến số điện thoại của bạn." message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [alert dismissViewControllerAnimated:YES completion:^(){
                            [activeCode becomeFirstResponder];
                        }];
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 5 || returnKey;
}

- (IBAction)sendBtnClick:(id)sender {
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
        [DataHelper POST:API_ACTIVE params:@{@"idtaixe":[userInfo objectForKey:@"id"], @"code":activeCode.text} completion:^(BOOL success, id responseObject, NSError *error){
            NSLog(@"%@", responseObject);
            if (success) {
                [sendBtn setEnabled:YES];
                if ([responseObject isEqualToString:@"1"]) {
                    [DataHelper activeUser];
                    MapDriverViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapDriverStoryboardId"];
                    
                    [self presentViewController:controller animated:YES completion:nil];
                }
                else{
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
}

-(BOOL)canResendActiveCode{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDate *lastSend = [userDefault objectForKey:@"lastSend"];
    
    if (lastSend != nil && -[lastSend timeIntervalSinceNow] < TIME_LIMIT_RESEND_CODE) {
        return NO;
    }

    return YES;
}

@end

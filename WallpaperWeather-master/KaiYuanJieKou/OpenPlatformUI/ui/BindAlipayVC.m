//
//  BindAlipayVC.m
//  DailyEnglish
//
//  Created by mkoo on 2017/4/21.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import "BindAlipayVC.h"
#import "OpenPlatform.h"
#import "AdmConfig.h"

@interface BindAlipayVC ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *codeButton;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *errorMsgLabel;

@property (strong, nonatomic) NSTimer *codeTimer;
@property (assign, nonatomic) NSInteger fetchCodeTick;


@end

@implementation BindAlipayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"支付宝";
    
    [self updatePaymentInfo];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapClick) name:UIKeyboardWillHideNotification object:nil];
}
-(void) tapClick
{
    [self.view endEditing:YES];
    NSTimeInterval animationDuration = 0.20f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
}
- (void) updatePaymentInfo {
    
    Paymentinfo *info = [OpenPlatform platform].selectPaymentInfo;
    if(info) {
        
        _nameTF.text = info.name;
        _accountTF.text = info.account;
        _phoneTF.text = info.phone;
        _codeTF.hidden = YES;
        _codeLabel.hidden = YES;
        _codeButton.hidden = YES;
        [_submitButton setTitle:@"解除绑定" forState:UIControlStateNormal];
        _errorMsgLabel.hidden = YES;
        
        _nameTF.enabled = NO;
        _accountTF.enabled = NO;
        _phoneTF.enabled = NO;
    } else {
        
        _nameTF.enabled = YES;
        _accountTF.enabled = YES;
        _phoneTF.enabled = YES;
        _codeLabel.hidden = NO;
        _codeTF.hidden = NO;
        _codeButton.hidden = NO;
        [_submitButton setTitle:@"绑定支付宝" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action_send_code:(id)sender {
    
    self.errorMsgLabel.hidden = YES;
    
    if(_phoneTF.text.length==0) {
        [self showError:@"请输入手机号"];
        return;
    }
    
    @weakify(self)
    [[OpenPlatform platform]requestBindPaymentPhoneCode:_phoneTF.text complete:^(Response *response) {
        @strongify(self)
        
        if(response.code == 200) {
            
            self.fetchCodeTick = 30;
            //self.codeTF.text = @"888888";
            self.codeButton.enabled = NO;
            if(self.codeTimer) {
                [self.codeTimer invalidate];
            }
            self.codeTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                
                self.fetchCodeTick --;
                if(self.fetchCodeTick <= 0) {
                    self.codeButton.enabled = YES;
                    [timer invalidate];
                    [self.codeButton setTitle:@"获取" forState:UIControlStateNormal];
                } else {
                    self.codeButton.enabled = NO;
                    [self.codeButton setTitle:[NSString stringWithFormat:@"%ld S", self.fetchCodeTick] forState:UIControlStateNormal];
                }
            }];
            
        } else if(response.msg) {
            [self showError:response.msg];
        } else {
            [self showError:NET_ERROR_TEXT];
        }
    }];
}

- (IBAction)action_submit:(id)sender {
    
    self.errorMsgLabel.hidden = YES;
    
    if([OpenPlatform platform].selectPaymentInfo.id_) {
        
        [[OpenPlatform platform]unbind:[OpenPlatform platform].selectPaymentInfo.id_ complete:^(PaymentinfoListResponse *response) {
            if(response.code == 200) {
                [OpenPlatform platform].paymentInfoList = response.body;
                [OpenPlatform platform].selectPaymentInfo = nil;
            } else if(response.msg) {
                [self showError:response.msg];
            } else {
                [self showError:NET_ERROR_TEXT];
            }
            
            [self updatePaymentInfo];
        }];
        
    } else {
        
        if(_nameTF.text.length == 0) {
            [self showError:@"请输入姓名"];
            return;
        }
        if(_accountTF.text.length==0) {
            [self showError:@"请输入支付宝账号"];
            return;
        }
        if(_phoneTF.text.length == 0) {
            [self showError:@"请输入手机号"];
            return;
        }
        if(_codeTF.text.length == 0) {
            [self showError:@"请输入验证码"];
            return;
        }
        
        [[OpenPlatform platform] bindAliPayAccount:_accountTF.text name:_nameTF.text /*phone:_phoneTF.text code:_codeTF.text*/ complete:^(PaymentinfoResponse *response) {
           
            if(response.code == 200) {
                
                [OpenPlatform platform].selectPaymentInfo = response.body;
                if(response.body) {
                    if([OpenPlatform platform].paymentInfoList == nil) {
                        [OpenPlatform platform].paymentInfoList = [NSMutableArray new];
                        [[OpenPlatform platform].paymentInfoList addObject:response.body];
                    }
                }
                [self updatePaymentInfo];
            } else if(response.msg) {
                [self showError:response.msg];
            } else {
                [self showError:NET_ERROR_TEXT];
            }
        }];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    
    CGFloat heights = self.view.frame.size.height;
    
    // 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = frame.origin.y + 42- ( heights - 216.0- 85.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
    
}


- (void) showError:(NSString*)msg {
    self.errorMsgLabel.text = msg;
    self.errorMsgLabel.hidden = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

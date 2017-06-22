//
//  OpenSigninVC.m
//  Pods
//
//  Created by mkoo on 2017/4/18.
//
//

#import "OpenSigninVC.h"
#import "OpenPlatform.h"
#import "WXApi.h"
#import "WXHelper.h"
#import "SVProgressHUD.h"
#import "AdmConfig.h"


@interface OpenSigninVC ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *codeButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UILabel *wechatLabel;
@property (weak, nonatomic) IBOutlet UIButton *wechatButton;

@property (strong, nonatomic) NSTimer *codeTimer;
@property (assign, nonatomic) NSInteger fetchCodeTick;
@property (weak, nonatomic) IBOutlet UIView *moreLoginTypeView;

@property (assign, nonatomic) BOOL needRegisterPhone;
@end

@implementation OpenSigninVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]]) {
//        _wechatLabel.hidden = NO;
//        _wechatButton.hidden = NO;
//        _moreLoginTypeView.hidden = NO;
        _wechatLabel.hidden = YES;
        _wechatButton.hidden = YES;
        _moreLoginTypeView.hidden = YES;
        
    } else {
        _wechatLabel.hidden = YES;
        _wechatButton.hidden = YES;
        _moreLoginTypeView.hidden = YES;
    }
  UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    
    if([OpenPlatform platform].token.length>0 && [OpenPlatform platform].userInfo.phone.length==0) {
        
        self.title = @"请绑定手机";
        
        _needRegisterPhone = YES;
        
        [_signinButton setTitle:@"绑定" forState:UIControlStateNormal];
        _wechatLabel.hidden = YES;
        _wechatButton.hidden = YES;
    }
    
}
-(void)tapClick
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action_signin:(id)sender {
    
    _msgLabel.hidden  = YES;
    
    if(_phoneTF.text.length<11) {
        [self showError:@"请输入正确手机号"];
    } else if(_codeTF.text.length==0) {
        [self showError:@"请输入验证码"];
    } else {
        
        if(_needRegisterPhone) {
            
            [[OpenPlatform platform] bindPhone:_phoneTF.text code:_codeTF.text complete:^(UserResponse *response) {
                if(response && response.code == 200) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    if(response.msg) {
                        [self showError:response.msg];
                    } else {
                        [self showError:NET_ERROR_TEXT];
                    }
                }
            }];

            
        } else {
            
            [[OpenPlatform platform] signinByPhone:_phoneTF.text code:_codeTF.text complete:^(UserResponse *response) {
                if(response && response.code == 200) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    if(response.msg) {
                        [self showError:response.msg];
                    } else {
                        [self showError:NET_ERROR_TEXT];
                    }
                }
            }];
        }
    }
}

- (IBAction)action_cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)action_fetch_code:(id)sender {
    if(_phoneTF.text.length<11) {
        [self showError:@"请输入正确手机号"];
        return;
    }
    @weakify(self)
    [[OpenPlatform platform]requestSigninPhoneCode:_phoneTF.text complete:^(Response *response) {
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
                    [self.codeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [self.codeButton setTitle:@"获取" forState:UIControlStateNormal];
                } else {
                    self.codeButton.enabled = NO;
                    [self.codeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
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

- (IBAction)action_wechat:(id)sender {
    
    [[WXHelper sharedInstance] loginIn:self complete:^(UserResponse *response) {
       
        if(response && response.code == 200) {
            
            if(response.body.needRegisterPhone) {
                
                _needRegisterPhone = YES;
                
                [_signinButton setTitle:@"绑定" forState:UIControlStateNormal];
                _wechatLabel.hidden = YES;
                _wechatButton.hidden = YES;
                
                [SVProgressHUD showSuccessWithStatus:@"请绑定手机号"];
                
                self.title = @"请绑定手机";
                
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
        }
    }];
}

- (void) showError:(NSString*)msg {
    
    _msgLabel.text = msg;
    _msgLabel.hidden = NO;
}



@end

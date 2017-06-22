//
//  OpenLoginInVC.m
//  AdmoreSDKCore
//
//  Created by careyang on 2017/5/26.
//  Copyright © 2017年 wanglin.sun. All rights reserved.
//

#import "OpenLoginInVC.h"
#import "SVProgressHUD.h"
#import "OpenRegisterVC.h"
#import "OpenPlatformUI.h"

@interface OpenLoginInVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneTextF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

//更多登录方式，微信账号
@property (weak, nonatomic) IBOutlet UIView *moreLoginTypeView;
@property (weak, nonatomic) IBOutlet UILabel *wechatLabel;
@property (weak, nonatomic) IBOutlet UIButton *wechatButton;
@property(nonatomic , strong) UIButton * rightBtn;
@end

@implementation OpenLoginInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textchangeEvent) name:UITextFieldTextDidChangeNotification object:nil];
    
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
    [self textchangeEvent];
    [self initPassWordTextField];
}
- (IBAction)cancelBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) initPassWordTextField
{
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [self.rightBtn setImage:[UIImage imageNamed:@"icon_eye_hidden"] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    self.passwordTextF.rightView = self.rightBtn;
    self.passwordTextF.rightViewMode = UITextFieldViewModeAlways;
}
-(void) buttonClick
{
    self.passwordTextF.secureTextEntry = ! self.passwordTextF.secureTextEntry;
    if (self.passwordTextF.secureTextEntry) {
        [self.rightBtn setImage:[UIImage imageNamed:@"icon_eye_hidden"] forState:UIControlStateNormal];
    }else{
        [self.rightBtn setImage:[UIImage imageNamed:@"icon_eye_show"] forState:UIControlStateNormal];
    }
}
#pragma mark 文字发生改变的
-(void)textchangeEvent
{
    if (self.phoneTextF.text.length >= 1 && self.passwordTextF.text.length >= 1) {
        self.loginBtn.enabled = YES;
        self.loginBtn.alpha = 1;
    }else{
        self.loginBtn.enabled = NO;
        self.loginBtn.alpha = 0.5;
    }
}

- (IBAction)loginBtnClick:(UIButton *)sender{
    if (self.phoneTextF.text.length < 1) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号码"];
        return;
    }
    if (self.passwordTextF.text.length < 1) {
        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
        return;
    }
    [SVProgressHUD show];
    [[OpenPlatform platform] loginByPhone:self.phoneTextF.text password:self.passwordTextF.text complete:^(UserResponse *response) {
        [SVProgressHUD dismiss];
        if (response.code == 200) {
            // 登录成功，进入用户中心
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else
        {
            [SVProgressHUD showErrorWithStatus:response.msg];
        }
        
    }];
}
- (IBAction)registerBtnClick:(UIButton *)sender {
    OpenRegisterVC * vc  = [OpenRegisterVC new];
    vc.isRegisterMode = YES;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}
- (IBAction)forgetPswdBtnClick:(UIButton *)sender {
    OpenRegisterVC * vc  = [OpenRegisterVC new];
    vc.isRegisterMode = NO;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}
- (IBAction)wechatBtnClick:(UIButton *)sender {
}
#pragma mark 界面操作
-(void)tapClick
{
    [self.view endEditing:YES];
}

// 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    NSLog(@"textFieldDidBeginEditing");
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

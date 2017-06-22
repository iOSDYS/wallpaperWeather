//
//  OpenRegisterVC.m
//  AdmoreSDKCore
//
//  Created by careyang on 2017/5/26.
//  Copyright © 2017年 wanglin.sun. All rights reserved.
//

#import "OpenRegisterVC.h"
#import "OpenPlatformUI.h"
#import "OpenTextField.h"
@interface OpenRegisterVC ()<UIScrollViewDelegate , OpenTextFieldDelegate , UITextFieldDelegate , UIGestureRecognizerDelegate>
{
    NSInteger width;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet OpenTextField *textF1;
@property (weak, nonatomic) IBOutlet OpenTextField *textF2;
@property (weak, nonatomic) IBOutlet OpenTextField *textF3;
@property (weak, nonatomic) IBOutlet OpenTextField *textF4;
@property (weak, nonatomic) IBOutlet OpenTextField *textF5;
//显示标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//输入手机号码
@property (weak, nonatomic) IBOutlet UITextField *phoneTextF;
@property (weak, nonatomic) IBOutlet UIButton *phoneNextBtn;
//显示手机号码
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;

@property (weak, nonatomic) IBOutlet UITextField *passWordTextF;
@property (nonatomic , strong) UIButton * rightBtn;
@end

@implementation OpenRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    width = [UIScreen mainScreen].bounds.size.width;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

    [self initView];
    //更新按钮颜色
    [self updatePhoneTextF];
    [self updateViewWithIndex:0];
    
    [self initPassWordTextField];
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)tapClick
{
    [self.view endEditing:YES];
}
#pragma mark 返回上级页面
- (IBAction)backBtnClick:(UIButton *)sender {
    NSInteger index = self.scrollview.contentOffset.x / width;
    if (index) {
        [self.scrollview setContentOffset:CGPointMake(width * (index - 1), 0) animated:YES];
        
        [self updateViewWithIndex:index-1];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark 输入手机号码页面的下一步，
- (IBAction)phoneNextBtnClick:(UIButton *)sender
{
    if(self.phoneTextF.text.length<11) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确手机号"];
        return;
    }
        [self.scrollview setContentOffset:CGPointMake(width, 0) animated:YES];
    [self updateViewWithIndex:1];
    
    [self reSendSmsCodeClick:nil];
}
#pragma mark 输入用户短信验证码
- (IBAction)smsCodeNextBtnClick:(UIButton *)sender {
    [self.scrollview setContentOffset:CGPointMake(width * 2, 0) animated:YES];
    [self updateViewWithIndex:2];
}
- (IBAction)reSendSmsCodeClick:(UIButton *)sender {
    if(self.phoneTextF.text.length<11) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确手机号"];
        return;
    }
    if (self.isRegisterMode)
    {
        [[OpenPlatform platform] requestSigninPhoneCode:self.phoneTextF.text complete:^(Response *response) {
            if (response.code == 200) {
                [SVProgressHUD showInfoWithStatus:@"注册验证码发送成功"];
            }else{
                [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
            }
        }];
    }
    else
    {
        //找回密码
        [[OpenPlatform platform] requestResetPasswordPhoneCode:self.phoneTextF.text complete:^(Response *response) {
            if (response.code == 200) {
                [SVProgressHUD showInfoWithStatus:@"重置密码验证码已发送"];
            }else{
                 [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
            }
        }];
    }
    
}
#pragma mark 提交信息
- (IBAction)comfirmBtnClick:(UIButton *)sender {
    
    if (self.passWordTextF.text.length < 6 ) {
        [SVProgressHUD showInfoWithStatus:@"密码长度至少6位"];
        return;
    }
    if (self.textF1.text.length < 1 || self.textF2.text.length < 1 || self.textF3.text.length < 1 || self.textF4.text.length < 1 || self.textF5.text.length < 1 ) {
        [SVProgressHUD showInfoWithStatus:@"验证码不完整"];
        return;
    }
    NSString * smsCodeStr = [NSString stringWithFormat:@"%@%@%@%@%@",self.textF1.text , self.textF2.text, self.textF3.text , self.textF4.text , self.textF5.text ];
    
    if (self.isRegisterMode)
    {
        [SVProgressHUD show];
        [[OpenPlatform platform] registerByPhone:self.phoneTextF.text code:smsCodeStr password:self.passWordTextF.text complete:^(UserResponse *response) {
            [SVProgressHUD dismiss];
            if (response.code == 200) {
                [SVProgressHUD showSuccessWithStatus:@"注册成功,请登录"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }else{
                 [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
            }
        }];
        
    }
    else
    {
        [SVProgressHUD show];
        //找回密码
        [[OpenPlatform platform] resetPassword:self.phoneTextF.text code:smsCodeStr password:self.passWordTextF.text complete:^(Response *response) {
            [SVProgressHUD dismiss];
            if (response.code == 200) {
                [SVProgressHUD showSuccessWithStatus:@"重置密码成功,请重新登录"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }else{
                [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
            }
            
        }];
    }
}
#pragma mark 对标题进行更新
-(void) updateViewWithIndex:(NSInteger ) index
{
    [self.view endEditing:YES];
    
    switch (index) {
        case 0:
        {
            if (self.isRegisterMode)
                self.titleLabel.text = @"新用户注册";
            else
                self.titleLabel.text = @"输入手机号";
            
        }
            break;
        case 1:
        {
            self.titleLabel.text = @"填写验证码";
            self.phoneNumLabel.text = self.phoneTextF.text;
            [self updateTextFieldRespon];
        }
            break;
        case 2:
            self.titleLabel.text = @"设置登录密码";
            break;
            
        default:
            break;
    }
    
}
-(void)updateTextFieldRespon
{
    if (self.textF1.text.length < 1 || self.textF2.text.length < 1 || self.textF3.text.length < 1 || self.textF4.text.length < 1 || self.textF5.text.length < 1 ) {
       
        [self.textF1 becomeFirstResponder];
    }else{
        [self.textF5 becomeFirstResponder];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / width;
    
    [self updateViewWithIndex:index];
    
}

//self.textF1.layer.borderColor = [UIColor colorWithRed:98/255.0 green:194/255.0 blue:255/255.0 alpha:1].CGColor;
#pragma mark 初始化界面
-(void) initView
{
    self.textF1.layer.cornerRadius = 6;
    self.textF1.layer.borderColor = [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1].CGColor;
    self.textF1.my_delegate = self;
    self.textF1.layer.borderWidth = 1;
    
    self.textF2.layer.cornerRadius = 6;
    self.textF2.layer.borderColor = [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1].CGColor;
    self.textF2.my_delegate = self;
    self.textF2.layer.borderWidth = 1;
    
    self.textF3.layer.cornerRadius = 6;
    self.textF3.layer.borderColor = [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1].CGColor;
    self.textF3.my_delegate = self;
    self.textF3.layer.borderWidth = 1;
    
    self.textF4.layer.cornerRadius = 6;
    self.textF4.layer.borderColor = [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1].CGColor;
    self.textF4.my_delegate = self;
    self.textF4.layer.borderWidth = 1;
    
    self.textF5.layer.cornerRadius = 6;
    self.textF5.layer.borderColor = [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1].CGColor;
    self.textF5.my_delegate = self;
    self.textF5.layer.borderWidth = 1;
    
}
-(void)updatePhoneTextF
{
    if (self.phoneTextF.text.length >= 1) {
        self.phoneNextBtn.enabled = YES;
        self.phoneNextBtn.alpha = 1;
    }else{
        self.phoneNextBtn.enabled = NO;
        self.phoneNextBtn.alpha = 0.5f;
    }
}
-(void)textDidChange:(NSNotification *)notification
{
    UITextField * textF = notification.object;
    if (textF == self.phoneTextF) {
        [self updatePhoneTextF];
    }
    if (textF.tag >= 1000) {
        if ( [textF hasText]) {
            [self updateTextFWithTag:textF.tag];
        }
    }
}
-(void) updateTextFWithTag:(NSInteger) tag
{
    switch (tag) {
        case 1001:
        {
            UITextField * textF = [self.view viewWithTag:tag+1];
            [textF becomeFirstResponder];
        }
            break;
        case 1002:
        {
            UITextField * textF = [self.view viewWithTag:tag+1];
            [textF becomeFirstResponder];
        }
            break;
        case 1003:
        {
            UITextField * textF = [self.view viewWithTag:tag+1];
            [textF becomeFirstResponder];
        }
            break;
        case 1004:
        {
            UITextField * textF = [self.view viewWithTag:tag+1];
            [textF becomeFirstResponder];
        }
            break;
        case 1005:
        {
//            [self.view endEditing:YES];
        }
            break;
            
        default:
            break;
    }
}
-(void) my_textFieldDeleteBackward:(OpenTextField *)textField
{
    
    switch (textField.tag) {
        case 1001:
        {
        
        }
            break;
        case 1002:
        {
            UITextField * textF = [self.view viewWithTag:textField.tag-1];
            [textF becomeFirstResponder];
        }
            break;
        case 1003:
        {
            UITextField * textF = [self.view viewWithTag:textField.tag-1];
            [textF becomeFirstResponder];
        }
            break;
        case 1004:
        {
            UITextField * textF = [self.view viewWithTag:textField.tag-1];
            [textF becomeFirstResponder];
        }
            break;
        case 1005:
        {
            UITextField * textF = [self.view viewWithTag:textField.tag-1];
            [textF becomeFirstResponder];
        }
            break;
            
        default:
            break;
    }

    textField.text = nil;
}

#pragma mark textField 代理方法

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location == 1) {
        UITextField * textF = [self.view viewWithTag:textField.tag+1];
        [textF becomeFirstResponder];
        return NO;
    }
    return YES;
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSInteger index = self.scrollview.contentOffset.x / width;
    if (index == 1) {
        return  NO;
    }else{
        return YES;
    }
}
-(void) initPassWordTextField
{
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [self.rightBtn setImage:[UIImage imageNamed:@"icon_eye_hidden"] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    self.passWordTextF.rightView = self.rightBtn;
    self.passWordTextF.rightViewMode = UITextFieldViewModeAlways;
}
-(void) buttonClick
{
    self.passWordTextF.secureTextEntry = ! self.passWordTextF.secureTextEntry;
    if (self.passWordTextF.secureTextEntry) {
        [self.rightBtn setImage:[UIImage imageNamed:@"icon_eye_hidden"] forState:UIControlStateNormal];
    }else{
        [self.rightBtn setImage:[UIImage imageNamed:@"icon_eye_show"] forState:UIControlStateNormal];
    }
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

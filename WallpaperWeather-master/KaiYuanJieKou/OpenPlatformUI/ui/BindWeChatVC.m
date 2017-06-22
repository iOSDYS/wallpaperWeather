//
//  BindWeChatVC.m
//  AdmoreSDKCore
//
//  Created by careyang on 2017/5/31.
//  Copyright © 2017年 wanglin.sun. All rights reserved.
//

#import "BindWeChatVC.h"
#import "WXHelper.h"
#import "SVProgressHUD.h"
#import "OpenPlatformUI.h"

@interface BindWeChatVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *wechatNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *bindingBtn;
@property (weak, nonatomic) IBOutlet UITextField *accountTextF;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation BindWeChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"微信绑定";
//    self.view.layer.cornerRadius
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    
    
    [self updateView];
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


-(void) updateView
{
    Paymentinfo *info = [OpenPlatform platform].selectPaymentInfo;
    if (info) {
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.text = @"已绑定微信";
        self.accountTextF.hidden = NO;
        self.accountTextF.text = info.name;
        [self.bindingBtn setTitle:@"解除绑定" forState:UIControlStateNormal];
    }else{
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"是否绑定微信";
        self.accountTextF.hidden = YES;
        
        [self.bindingBtn setTitle:@"前往绑定" forState:UIControlStateNormal];
    }

}
- (IBAction)action_button_click:(UIButton *)sender {
    
   
        //解绑
        if([OpenPlatform platform].selectPaymentInfo.id_) {
            
            [[OpenPlatform platform]unbind:[OpenPlatform platform].selectPaymentInfo.id_ complete:^(PaymentinfoListResponse *response) {
                if(response.code == 200) {
                    [OpenPlatform platform].paymentInfoList = response.body;
                    [OpenPlatform platform].selectPaymentInfo = nil;
                } else if(response.msg) {
                    [SVProgressHUD showInfoWithStatus:response.msg];
                } else {
                    [SVProgressHUD showInfoWithStatus:NET_ERROR_TEXT];
                }
                
                [self updateView];
            }];
            
        }
    else
    {
        //打开微信绑定
        [[WXHelper sharedInstance] bindWechat:self bindComplete:^(PaymentinfoResponse * response) {
            
            if (response && response.code == 200) {
                [SVProgressHUD showInfoWithStatus:@"绑定成功"];
                [OpenPlatform platform].selectPaymentInfo = response.body;
                [self updateView];
            }else {
                [SVProgressHUD showInfoWithStatus:response.msg];
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

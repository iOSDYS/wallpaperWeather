//
//  OpenRequestCashVC.m
//  DailyEnglish
//
//  Created by mkoo on 2017/4/21.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import "OpenRequestCashVC.h"
#import "OpenPlatform.h"
#import "BindAlipayVC.h"
#import "OpenOrderListVC.h"
#import "SVProgressHUD.h"
#import "BindWeChatVC.h"

@interface OpenRequestCashVC () <UIPickerViewDataSource, UIPickerViewDelegate , UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *curMoneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *moneyButton;
@property (weak, nonatomic) IBOutlet UIButton *accountButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

@property (nonatomic, assign) NSInteger requestMoney;
@property (nonatomic, strong) NSString *account;

@property (nonatomic, strong) UIView* moneyPickerDialog;
@property (nonatomic, strong) UIPickerView* moneyPickerView;

//默认体现方式支付宝
@property (nonatomic ,assign) OpenRequestCashType reqType;
@property (weak, nonatomic) IBOutlet UILabel *requestCashTypeLabel;

@end

@implementation OpenRequestCashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"提现";
    
    self.reqType = OpenRequestCashTypeAlipay;
    self.curMoneyLabel.text = [NSString stringWithFormat:@"%.2f元", [OpenPlatform platform].curMoney / 100.f];
    
    [[OpenPlatform platform] bindPaymentList:^(PaymentinfoListResponse *response) {
        if(response.code == 200) {
            [OpenPlatform platform].paymentInfoList = response.body;
            
            for(Paymentinfo *info in [OpenPlatform platform].paymentInfoList) {
                if([info.type isEqualToString:@"alipay"]) {
                    [OpenPlatform platform].selectPaymentInfo = info;
                    break;
                }
            }
        }
    }];
    
    [[OpenPlatform platform] addObserver:self forKeyPath:@"selectPaymentInfo" options:NSKeyValueObservingOptionPrior context:nil];
}

- (void) dealloc {
    [[OpenPlatform platform] removeObserver:self forKeyPath:@"selectPaymentInfo"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (IBAction)action_select_request_type:(UIControl *)sender {
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"请选择提现方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"支付宝", nil];
    sheet.delegate = self;
    [sheet showInView:self.view];
}
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            self.reqType = OpenRequestCashTypeWeChat;
            
            [self updateSelectCashInfo];
        }
            break;
        case 1:
        {
            self.reqType = OpenRequestCashTypeAlipay;
            [self updateSelectCashInfo];
        }
            break;
        case 2:
        {
    
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)action_select_money:(id)sender {
    if ([OpenPlatform platform].curMoney <= 0) {
        [SVProgressHUD showInfoWithStatus:@"您的账户余额不足,无法提现"];
        return;
    }
    
    _moneyPickerDialog = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2)];
    _moneyPickerDialog.backgroundColor = [UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, 0, 60, 40)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.tintColor = [UIColor blackColor];
    button.backgroundColor = [UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1];
    [button addTarget:self action:@selector(action_select_money_sure:) forControlEvents:UIControlEventTouchUpInside];
    [_moneyPickerDialog addSubview:button];
    
    _moneyPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height/2 - 50)];
    _moneyPickerView.delegate = self;
    _moneyPickerView.dataSource =  self;

    [_moneyPickerDialog addSubview:_moneyPickerView];
    [self.view addSubview:_moneyPickerDialog];
}

- (IBAction)action_select_money_sure:(id)sender {
    [_moneyPickerDialog removeFromSuperview];
    _moneyPickerDialog = nil;
}

- (IBAction)action_select_account:(id)sender {
    if (self.reqType == OpenRequestCashTypeWeChat) {
        BindWeChatVC * vc = [BindWeChatVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (self.reqType == OpenRequestCashTypeAlipay){
        BindAlipayVC *vc = [BindAlipayVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        BindAlipayVC *vc = [BindAlipayVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)action_submit:(id)sender {
    
    if(self.requestMoney<=0 || self.requestMoney > [OpenPlatform platform].curMoney)
    {
        [SVProgressHUD showInfoWithStatus:@"请检查您申请提现的金额"];
        return;
    }
    [[OpenPlatform platform]requestCash:self.requestMoney paymentId:[OpenPlatform platform].selectPaymentInfo.id_ complete:^(WalletResponse *response) {
        
        self.curMoneyLabel.text = [NSString stringWithFormat:@"%.2f元", [OpenPlatform platform].curMoney / 100.f];
        
        if(response.code == 200) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"申请提现成功" message:response.msg?response.msg:@"预计一个工作日后到账" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
            
            
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"申请提现失败，请稍后再试" message:response.msg?response.msg:@"网络忙，请稍后再试" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (IBAction)action_history:(id)sender {
    OpenOrderListVC *vc = [OpenOrderListVC new];
    vc.orderType = @"requestCash";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - setter & getter

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"selectPaymentInfo"]) {
        if([OpenPlatform platform].selectPaymentInfo) {
            if ([[OpenPlatform platform].selectPaymentInfo.type isEqualToString:@"wechat"]) {
                [self.accountButton setTitle:[OpenPlatform platform].selectPaymentInfo.name forState:UIControlStateNormal];
            }else{
                [self.accountButton setTitle:[OpenPlatform platform].selectPaymentInfo.account forState:UIControlStateNormal];
            }
            
        } else {
            [self.accountButton setTitle:@"去绑定 >" forState:UIControlStateNormal];
        }
    }
}

//- (void) setSelectPaymentInfo:(Paymentinfo *)selectPaymentInfo {
//    _selectPaymentInfo = selectPaymentInfo;
//    if(self.selectPaymentInfo) {
//        [self.accountButton setTitle:self.selectPaymentInfo.account forState:UIControlStateNormal];
//    } else {
//        [self.accountButton setTitle:@"去绑定 >" forState:UIControlStateNormal];
//    }
//}

- (void) setRequestMoney:(NSInteger)requestMoney {
    
    if(requestMoney <= [OpenPlatform platform].curMoney) {
        _requestMoney = requestMoney;
        [self.moneyButton setTitle:[NSString stringWithFormat:@"%.2f元", self.requestMoney / 100.f] forState:UIControlStateNormal];
    }else{
        [SVProgressHUD showInfoWithStatus:@"您的账户余额不足!"];
    }
}

-(void) updateSelectCashInfo
{
    if (self.reqType == OpenRequestCashTypeAlipay) {
        self.requestCashTypeLabel.text = @"支付宝";
        BOOL isBinding = NO;

        for(Paymentinfo *info in [OpenPlatform platform].paymentInfoList) {
            if([info.type isEqualToString:@"alipay"]) {
                [OpenPlatform platform].selectPaymentInfo = info;
                isBinding = YES;
                break;
            }
        }
        if (!isBinding) {
            [OpenPlatform platform].selectPaymentInfo = nil;
        }
    }else if (self.reqType == OpenRequestCashTypeWeChat){
        self.requestCashTypeLabel.text = @"微信";
        BOOL isBinding = NO;

        for(Paymentinfo *info in [OpenPlatform platform].paymentInfoList) {
            if([info.type isEqualToString:@"wechat"]) {
                [OpenPlatform platform].selectPaymentInfo = info;
                isBinding = YES;
                break;
            }
        }
        if (!isBinding) {
            [OpenPlatform platform].selectPaymentInfo = nil;
        }
    }else{
        self.requestCashTypeLabel.text= @"支付宝";
        BOOL isBinding = NO;

        for(Paymentinfo *info in [OpenPlatform platform].paymentInfoList) {
            if([info.type isEqualToString:@"alipay"]) {
                [OpenPlatform platform].selectPaymentInfo = info;
                isBinding = YES;
                break;
            }
        }
        if (!isBinding) {
            [OpenPlatform platform].selectPaymentInfo = nil;
        }
    }
}
#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSArray* texts = @[@"请选择", @"8元",  @"30元", @"50元", @"100元", @"500元", @"1000元", @"2000元", @"3000元", @"5000元"];
    
    return [texts objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSArray* texts = @[@"请选择", @"8元",  @"30元", @"50元", @"100元", @"500元", @"1000元", @"2000元", @"3000元", @"5000元"];
    
    self.requestMoney = [texts[row] intValue] * 100;
}


@end

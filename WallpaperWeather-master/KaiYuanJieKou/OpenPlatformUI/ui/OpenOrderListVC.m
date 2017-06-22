//
//  OpenOrderListVC.m
//  DailyEnglish
//
//  Created by mkoo on 2017/4/21.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import "OpenOrderListVC.h"
#import "OpenPlatform.h"
#import "SVProgressHUD.h"
#import "Order.h"
#import "Masonry.h"

@interface OpenOrderListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<Order*> *orderList;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation OpenOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [UITableView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
    
    [SVProgressHUD show];
    [[OpenPlatform platform] myOrderList:self.orderType complete:^(OrderListResponse *response) {
    
        [SVProgressHUD dismiss];
        
        if(response.code == 200) {
            self.orderList = response.body;
            
            if(response.body.count==0) {
                
                [SVProgressHUD showInfoWithStatus:@"暂无提现记录"];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orderList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"orderCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Order *order = _orderList[indexPath.row];
    
    if([order.accountType isEqualToString:@"alipay"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"提现%.2f元 - 支付宝账号<%@>", order.money / 100.f, order.account];
    } else if([order.accountType isEqualToString:@"wechat"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"提现%.2f元 - 微信账号<%@>", order.money / 100.f, order.accountName];
    } else if([order.accountType isEqualToString:@"bank"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"提现%.2f元 - 银行卡<%@>", order.money / 100.f, order.account];
    } else if([order.accountType isEqualToString:@"phone"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"提现%.2f元 - 话费<%@>", order.money / 100.f, order.accountPhone];
    } else if([order.accountType isEqualToString:@"phoneDataFlow"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"提现%.2f元 - 流量<%@>", order.money / 100.f, order.accountPhone];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"提现%.2f元 - <%@>", order.money / 100.f, order.account];
    }
    
    if([order.state isEqualToString:@"success"]) {
        cell.detailTextLabel.text = @"成功";
    } else if([order.state isEqualToString:@"request"]) {
        cell.detailTextLabel.text = @"提现中";
    } else if([order.state isEqualToString:@"review"]) {
        cell.detailTextLabel.text = @"提现中";
    } else if([order.state isEqualToString:@"reject"] || [order.state isEqualToString:@"fail"]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"失败 (%@)", order.description];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - setter & getter

- (void) setOrderList:(NSMutableArray<Order *> *)orderList {
    _orderList = orderList;
    [self.tableView reloadData];
}

@end

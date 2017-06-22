//
//  OpenPlayListVC.m
//  DailyEnglish
//
//  Created by mkoo on 2017/4/21.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import "OpenPlayListVC.h"
#import "OpenPlatform.h"
#import "SVProgressHUD.h"
#import "Masonry.h"
#import "OpenPlayCell.h"

@interface OpenPlayListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<App*> *appList;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation OpenPlayListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"记录";
    
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
    
    [[OpenPlatform platform] taskHistoryList:^(TaskListResponse *response) {
        
        [SVProgressHUD dismiss];
        
        if(response.code == 200) {
            self.appList = response.body;
            
            if(response.body.count==0) {
                [SVProgressHUD showInfoWithStatus:@"暂无试玩记录"];
            }
        }else {
            [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
        }
        
    }];
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _appList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 50;
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell"];
//    if(cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"orderCell"];
//    }
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    App *app = _appList[indexPath.row];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"关键词:%@ 奖励:%.2f元", app.searchWord, app.price / 100.f];
//    
//    if([app.state isEqualToString:@"pass"]) {
//        cell.detailTextLabel.text = @"试玩成功";
//    } else if([app.state isEqualToString:@"request"] || [app.state isEqualToString:@"downloaded"] || [app.state isEqualToString:@"playing"])
//        cell.detailTextLabel.text = @"试玩中";
//    else if([app.state isEqualToString:@"giveup"] || [app.state isEqualToString:@"fail"]) {
//        cell.detailTextLabel.text = @"试玩失败";
//    } else {
//        cell.detailTextLabel.text = @"状态未知";
//    }
    OpenPlayCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OpenPlayCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OpenPlayCell" owner:nil options:nil] firstObject];
    }
    App * app = _appList[indexPath.row];
    [cell updateView:app];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - setter & getter

- (void) setAppList:(NSMutableArray<App *> *)appList {
    _appList = appList;
    [self.tableView reloadData];
}

@end

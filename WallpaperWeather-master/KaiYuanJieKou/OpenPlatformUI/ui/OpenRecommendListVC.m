//
//  OpenRecommendListVC.m
//  DailyEnglish
//
//  Created by mkoo on 2017/4/23.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import "OpenRecommendListVC.h"
#import "Masonry.h"
#import "SVProgressHUD.h"
#import "OpenPlatform.h"
#import "Recommend.h"

@interface OpenRecommendListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<Recommend*> *recommendList;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL stoped;

@end

@implementation OpenRecommendListVC

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
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self.refreshControl beginRefreshing];
    
    [self loadData];
}

- (void) loadData {
    
    self.loading = YES;
    
    [SVProgressHUD show];
    
    int64_t preId = -1;
    
    if(self.recommendList.count>0) {
        Recommend *lastRecommend = self.recommendList.lastObject;
        preId = lastRecommend.id_;
    }
    
    [[OpenPlatform platform] recommendList:preId count:20 complete:^(RecommendListResponse *response) {
        
        [SVProgressHUD dismiss];
        
        self.loading = NO;
        
        if(response.code == 200) {
            if(self.recommendList == nil) {
                self.recommendList = response.body;
            } else {
                [self.recommendList addObjectsFromArray:response.body];
                [self.tableView reloadData];
            }
            
            if(response.body.count<20) {
                self.stoped = YES;
            }
            
            if(self.recommendList.count==0) {
                
                [SVProgressHUD showSuccessWithStatus:@"暂无邀请记录"];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
        }
    }];
}



- (void)refresh{
    
    if (self.refreshControl.isRefreshing){
        
        [self.recommendList removeAllObjects];//清除旧数据，每次都加载最新的数据
        
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"加载中..."];
        [self loadData];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recommendList.count;
}

//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 50;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"orderCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Recommend *recommend = _recommendList[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"推荐 %@ 成功注册", recommend.recommenderName ? recommend.recommenderName : recommend.recommenderPhone];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"+ %.2f元", recommend.money / 100.f];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - setter & getter

- (void) setRecommendList:(NSMutableArray<Recommend *> *)recommendList {
    _recommendList = recommendList;
    [self.tableView reloadData];
}

#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(self.loading || self.stoped) {
        return;
    }
    
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    if ( currentOffsetY + scrollView.frame.size.height  > scrollView.contentSize.height){
        [self loadData];
    }
    
}

@end

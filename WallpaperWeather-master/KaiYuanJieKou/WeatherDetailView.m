//
//  WeatherDeatailView.m
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/28.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//  点击首页中的城市 即可显示出 天气的详细数据  包括 预测天气 和 历史天气等  ，其中 '今日天气' 包括 '感冒指数' 、 '提示文字'等

#import "WeatherDetailView.h"
#import "WeatherDetailCollectionViewCell.h"
#import "WeatherDetailTableViewCell.h"
#import "WeatherModel.h"
#import "DailyCell.h"

@interface WeatherDetailView()<UITableViewDataSource,UITableViewDelegate>

/// 城市姓名
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;

/// 当前温度
@property (weak, nonatomic) IBOutlet UILabel *curTempLabel;

/// 天气对应的时间
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UITableView *tablwView;

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,assign) NSInteger todayIndex;

@property (nonatomic,strong)WeatherModel *model;
@end

@implementation WeatherDetailView

+ (void)showWithWeatherData:(WeatherModel *)data{
    WeatherDetailView *detailView = [[[NSBundle mainBundle] loadNibNamed:@"WeatherDetailView" owner:nil options:nil] lastObject];
    detailView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [detailView buildUIWithWeatherData:data];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:detailView];
    
    [UIView animateWithDuration:0.4 animations:^{
        detailView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

- (void)buildUIWithWeatherData:(WeatherModel *)data{
    _model = data;
    _cityNameLabel.text = data.city;
    _curTempLabel.text = [NSString stringWithFormat:@"当前温度：%@",data.temp];
    _currentIndex = 0 ;
    _timeLabel.text = [NSString stringWithFormat:@"%@  %@",data.date,data.week];
    _tablwView.delegate = self;
    _tablwView.dataSource = self;
    _tablwView.backgroundColor = [UIColor clearColor];
    _tablwView.tableFooterView = [UIView new];
    _tablwView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.daily.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DailyModel *model = _model.daily[indexPath.row];
    DailyCell *cell = [DailyCell cellWithTableview:tableView WeatherData:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

// - MARK: 事件处理
- (IBAction)return:(id)sender {
    [self removeFromSuperview];
}

@end

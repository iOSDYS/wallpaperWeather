//
//  WeatherViewController.m
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/25.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import "WeatherViewController.h"
#import "NullDataView.h"
#import "CityManager.h"
#import "WeatherCell.h"
#import "SelectAddressController.h"
#import "SettingViewController.h"
#import "AboutMeViewController.h"
#import "WaveButton.h"
#import "WeatherDetailView.h"
#import "NSObject+Model.h"
#import "WeatherModel.h"
#import "CS_Location.h"
#import "WeatherHeadView.h"
#import "DailyModel.h"
#import "DailyCell.h"
#import "OpenBannerView.h"
#import <SafariCookieBridge.h>
#import "OpenPlatformUI.h"

#define RandomChangeImageCount 10
#define DragStength 40

@interface WeatherViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NullDataView *nullView;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (nonatomic,strong) UITableView *tableView;

//天气数据列表
@property (nonatomic,strong) NSMutableArray *weatherList;

//操作按钮数组
@property (nonatomic,strong) NSMutableArray *operationBtnArr;

//显示按钮 列表
@property (nonatomic,assign) BOOL showOperationBtns;
@property (nonatomic,strong) UIButton *operationBtn;;

@property (nonatomic,strong) UITableView *bottomView;
@property (nonatomic,copy) NSString *currentCity;

@property (nonatomic,strong)WeatherHeadView *headView;//底部tableview 头部
@property (nonatomic,strong)WeatherModel *currentCityWeatherModel;//当前城市天气model
@property (nonatomic,strong)OpenBannerView *bannerView;
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,strong)UILabel *topInfoLabel;
@property (nonatomic,strong)UILabel *bottomInfoLabel;
@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateBackGroundImage];
    _weatherList = [[NSMutableArray alloc] init];
    _showOperationBtns = false;
    _backView.backgroundColor = [UIColor colorWithHex:0x707070 alpha:0.6];
    _status = 0;
    [self setupTableView];
    [self.view addSubview:self.bottomView];
    [self setupAnimationOperationBtn];
    
    CS_Location *location = [CS_Location shareInstance];
    [location startLocate];
    location.block = ^(NSString *city) {
        _currentCity = city;
    };
    
    
    if([OpenPlatform platform].userInfo && [OpenPlatform platform].userInfo.id_ >0) {
        [self start];
    } else {
        [SafariCookieBridge getCookieWithName:@"recommender" scheme:@"duodianWeather" url:@"https://open.admore.com.cn/cookie.html" viewController:self timeout:10 block:^(BOOL success, NSString *value) {
            if(success && value)
                [OpenPlatform platform].recommender = value;
            [self start];
        }];
    }
}

- (void) start {
    [OpenPlatform startWithAppKey:@"JHOg3gF8DHmM53US" playAudio:YES checkNotification:YES netType:DataByHttp shikeMode:NO complete:^(UserResponse *response) {
        
        if(response.code == 200) {
            
            BOOL showShikeAdv = [OpenPlatform platform].shikeMode;
            
            if(showShikeAdv) {
                [AdmCore sharedInstance].checkNotification = YES;
                [AdmCore sharedInstance].playAudio = YES;
                [self.bottomView reloadData];
            }
        }
    }];
}


//隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return true;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
    //
    //    [self updateBackGroundImage];
    [self setUpNullDataView];
    //
    [_operationBtn.layer setNeedsDisplay];
}

/// 随机更改壁纸
- (void)updateBackGroundImage{
    int index = arc4random() % RandomChangeImageCount;
    //    int index = ceilf(a) == 0 ? 1 : ceilf(a);
    NSString *imageName = [NSString stringWithFormat:@"BG%d",index];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _backImageView.image = [UIImage imageNamed: imageName];
    });
}

// -MARK: 设置没有选择城市的页面
- (void)setUpNullDataView{
    if (![[CityManager shareInstance] isExistHasSelectedCity]) {
        if (!_nullView) {
            _nullView = [NullDataView show];
            WeakSelf;
            _nullView.selectAddressBlock = ^(){
                SelectAddressController *selectAddressVC = [[SelectAddressController alloc] init];
                [weakSelf.navigationController pushViewController:selectAddressVC animated:true];
            };
            [self.view addSubview:_nullView];
        }
        _nullView.hidden = false;
        _tableView.hidden = true;
    }else{
        _nullView.hidden = true;
        _tableView.hidden = false;
        //获取天气数据
        [self loadData];
    }
    
}

// -MARK: build UITabelView
- (void)setupTableView{
    self.automaticallyAdjustsScrollViewInsets = false;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    _tableView.tag = 100;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 120;
    _tableView.hidden = true;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView addSubview:self.topInfoLabel];
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:_operationBtn];
}

// UITableViewDelegate DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 100) {
        return _weatherList.count;
    }else{
        if (_currentCityWeatherModel) {
            return _currentCityWeatherModel.daily.count;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *baseCell = nil;
    if (tableView.tag == 100) {
        if (_weatherList.count != 0) {
            WeatherModel *data = [_weatherList objectAtIndex:indexPath.row];
            WeatherCell *cell = [WeatherCell cellWithTableview:tableView WeatherData:data];
            baseCell = cell;
        }else {
            baseCell = [[UITableViewCell alloc] init];
        }
    } else {
        DailyModel *model = [_currentCityWeatherModel.daily objectAtIndex:indexPath.row];
        DailyCell *cell = [DailyCell cellWithTableview:tableView WeatherData:model];
        baseCell = cell;
    }
    return baseCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 100) {
        return 120;
    } else{
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView.tag == 100) {
        return 0;
    } else{
        if ([OpenPlatform platform].started) {
            return 70;
        }return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    _bannerView = [[OpenBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 10, 70)];
    return _bannerView;
}


//点击cell 执行动画
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WeatherModel *data = [_weatherList objectAtIndex:indexPath.row];
    [WeatherDetailView showWithWeatherData:data];
    
    
    
    //TODO: TableView 3D变换  但是感觉好丑。 所以暂时不用这个
    //    tableView.layer.anchorPoint = CGPointMake(0.5, 1);
    //
    //    [UIView animateWithDuration:0.3 animations:^{
    //        tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //    } completion:^(BOOL finished) {
    //        [UIView animateWithDuration:0.4 animations:^{
    //            tableView.layer.transform = CATransform3DPerspect( CATransform3DMakeRotation(M_PI/10, -1, 0, 0), CGPointMake(0, 0),-200);
    //        } completion:^(BOOL finished) {
    //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                tableView.layer.transform = CATransform3DIdentity;
    //            });
    //        }];
    //    }];
}

//3D 变化，不好看 ，暂时不用
//CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
//{
//    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
//    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
//    CATransform3D scale = CATransform3DIdentity;
//    scale.m34 = -1.0f/disZ;
//    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
//}
//
//CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
//{
//    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
//}

#pragma mark - 获取数据
- (void)loadData{
    [_weatherList removeAllObjects];
    [SVProgressHUD show];
    //先获取用户已经选择的城市
    NSArray *arr = [[CityManager shareInstance] savedCityList];
    if (arr && arr.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            WeakSelf;
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CityModel *city = obj;
                [CMNetworkManager requestDataWithCityID:city.citycode cityName:nil Complete:^(id obj) {
                    NSDictionary *resultDict = obj[@"result"];
                    WeatherModel *model = [WeatherModel modelWithDict:resultDict];
                    NSMutableArray *dailyArray = [NSMutableArray array];
                    for (NSDictionary *dict in obj[@"result"][@"daily"]) {
                        DailyModel *dailyModel = [DailyModel modelWithDict:dict];
                        [dailyArray addObject:dailyModel];
                    }
                    model.daily = dailyArray;
                    [weakSelf.weatherList addObject:model];
                    if (arr.count == weakSelf.weatherList.count ) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView reloadData];
                            [SVProgressHUD dismiss];
                        });
                    }
                }];
            }];
        });
    }else{
        [TipView showTitle:@"没有选择的城市😀，去添加一个吧"];
    }
}

#pragma mark - 事件处理

//操作按钮 动画效果: 水波纹
- (void)setupAnimationOperationBtn{
    _operationBtn = [[WaveButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 32, SCREEN_HEIGHT - 40 - 32, 64, 64)];
    _operationBtn.backgroundColor = [UIColor clearColor];
    _operationBtn.clearsContextBeforeDrawing = true;
    [_operationBtn setImage:[UIImage imageNamed:@"Circle"] forState:UIControlStateNormal];
    [_operationBtn addTarget:self action:@selector(showThreeButtons) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_operationBtn];
}

//懒加载 操作按钮数组
- (NSMutableArray *)operationBtnArr{
    if (!_operationBtnArr) {
        _operationBtnArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 3; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:_operationBtn.frame];
            btn.imageView.contentMode = UIViewContentModeScaleToFill;
            [btn setImage:[UIImage imageNamed:@"AddCity"] forState:UIControlStateNormal];
            btn.alpha = 0.0;
            [self.view addSubview:btn];
            [_operationBtnArr addObject:btn];
            
            UIImage *image = nil;
            
            switch (i) {
                case 0:
                    [btn addTarget:self action:@selector(addCity) forControlEvents:UIControlEventTouchUpInside];
                    image = [UIImage imageNamed:@"AddCity"];
                    break;
                case 1:
                    [btn addTarget:self action:@selector(openSetting) forControlEvents:UIControlEventTouchUpInside];
                    image = [UIImage imageNamed:@"Setting"];
                    break;
                default:
                    [btn addTarget:self action:@selector(aboutMe) forControlEvents:UIControlEventTouchUpInside];
                    image = [UIImage imageNamed:@"AboutMe"];
                    break;
            }
            [btn setImage:image forState:UIControlStateNormal];
        }
        
    }
    return _operationBtnArr;
}

//显示 三个操作按钮

- (void)showThreeButtons {
    WeakSelf;
    if (_showOperationBtns) {
        _showOperationBtns = false;
        [self.operationBtnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            //更改后 frame
            CGRect frame = weakSelf.operationBtn.frame;
            //延时
            float duration = 0.0;
            [UIView animateWithDuration:0.4 delay:duration options:UIViewAnimationOptionCurveEaseInOut animations:^{
                btn.alpha = 0.0;
                btn.frame = frame;
                btn.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }else{
        _showOperationBtns = true;
        [self.operationBtnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            //更改后 frame
            CGRect frame = btn.frame;
            frame.size.width = frame.size.height = 44;
            //延时
            float duration = 0.0;
            switch (idx) {
                case 0:
                    frame.origin.x -= 50 * sqrt(2);
                    frame.origin.y -= 50 * sqrt(2);
                    break;
                case 1:
                    frame.origin.y -= 100;
                    duration = 0.1;
                    break;
                default:
                    frame.origin.x += 50 * sqrt(2);
                    frame.origin.y -= 50 * sqrt(2);
                    duration = 0.25;
                    break;
            }
            //按延迟 将三个button 按顺序依次弹出
            [UIView animateWithDuration:0.4 delay:duration options:UIViewAnimationOptionCurveEaseInOut animations:^{
                btn.alpha = 1.0;
                btn.frame = frame;
                btn.transform = CGAffineTransformMakeRotation(M_PI * 2);
            } completion:^(BOOL finished) {
                
            }];
        }];
        
    }
}

//添加城市
- (void)addCity {
    [self showThreeButtons];
    SelectAddressController *selectAddressVC = [[SelectAddressController alloc] init];
    [self.navigationController pushViewController:selectAddressVC animated:true];
}

// 打开设置 页面
- (void)openSetting {
    [self showThreeButtons];
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:true];
}

// 关于作者
- (void)aboutMe {
    [self showThreeButtons];
    AboutMeViewController *aboutMeVC = [[AboutMeViewController alloc] init];
    [self.navigationController pushViewController:aboutMeVC animated:true];
}

#pragma -mark 懒加载
- (UITableView *)bottomView {
    if (!_bottomView) {
        _bottomView.tag = 200;
        _bottomView = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,SCREEN_HEIGHT)];
        _bottomView.delegate = self;
        _bottomView.dataSource = self;
        _bottomView.tableHeaderView = self.headView;
        _bottomView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _bottomView.backgroundColor = [UIColor clearColor];
        [_bottomView addObserver: self forKeyPath:@"contentOffset" options: NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context: nil];
        [_bottomView addSubview:self.bottomInfoLabel];
        [self loadNowWeather];
    }
    return _bottomView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGFloat offset = self.bottomView.contentOffset.y;
    if (offset < 0) {
        if (offset > -20) {
            self.bottomInfoLabel.text = @"上拉回到当前界面";
            self.bottomInfoLabel.alpha = ABS(offset)/60;
        } else{
            self.bottomInfoLabel.text = @"继续下拉回到第一页";
            if (offset > -40) {
                self.bottomInfoLabel.alpha = ABS(offset)/60;
            }else {
                self.bottomInfoLabel.alpha = 0.7;
            }
        }
        
    }
}

- (WeatherHeadView *)headView{
    if (!_headView) {
        _headView = [[[NSBundle mainBundle] loadNibNamed:@"WeatherHeadView" owner:nil options:nil] lastObject];
    }
    return _headView;
}

- (void)loadNowWeather {
    [CMNetworkManager requestDataWithCityID:nil cityName:_currentCity Complete:^(id obj) {
        if ([obj[@"status"] integerValue] != 0) {
            _status = [obj[@"status"] integerValue];
            return;
        }
        _currentCityWeatherModel = [WeatherModel modelWithDict:obj[@"result"]];
        NSMutableArray *dailyArray = [NSMutableArray array];
        for (NSDictionary *dict in obj[@"result"][@"daily"]) {
            DailyModel *dailyModel = [DailyModel modelWithDict:dict];
            [dailyArray addObject:dailyModel];
        }
        _currentCityWeatherModel.daily = dailyArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headView.model = _currentCityWeatherModel;
            [self.bottomView reloadData];
        });
    }];
}

#pragma -mark scrollView

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat topViewHeight = self.tableView.contentSize.height;
    if (scrollView.tag == 100) {
        if (topViewHeight < SCREEN_HEIGHT) {
            if (scrollView.contentOffset.y > DragStength) {
                [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.tableView.frame = CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                    self.bottomView.frame = self.view.bounds;
                } completion:^(BOOL finished) {
                    if (_status != 0) {
                        [SVProgressHUD showInfoWithStatus:@"暂时不支持该城市"];
                    }
                }];
            }
        } else {
            
        }
    }else {
        if (scrollView.contentOffset.y < -DragStength) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                self.tableView.frame = self.view.bounds;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (UILabel *)topInfoLabel {
    if (!_topInfoLabel) {
        _topInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 30)];
        _topInfoLabel.text = @"上拉查看当前城市天气信息";
        _topInfoLabel.font = [UIFont systemFontOfSize:14];
        _topInfoLabel.textColor = [UIColor whiteColor];
        _topInfoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _topInfoLabel;
}

- (UILabel *)bottomInfoLabel {
    if (!_bottomInfoLabel) {
        _bottomInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _bottomInfoLabel.text = @"继续下拉回到第一页";
        _bottomInfoLabel.font = [UIFont systemFontOfSize:14];
        _bottomInfoLabel.alpha = 0;
        _bottomInfoLabel.textColor = [UIColor whiteColor];
        _bottomInfoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomInfoLabel;
}

@end

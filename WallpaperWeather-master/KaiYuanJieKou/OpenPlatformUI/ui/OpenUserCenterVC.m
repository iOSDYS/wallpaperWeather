//
//  OpenUserCenterVC.m
//  Pods
//
//  Created by mkoo on 2017/4/18.
//
//

#import "OpenUserCenterVC.h"
#import "OpenPlatformUI.h"

@interface OpenUserCenterVC () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSString *headerViewToken;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *blueView;

@property (nonatomic, strong) UIImageView *headerImaegView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;

@property (nonatomic, strong) UILabel *curMoneyLabel;
@property (nonatomic, strong) UILabel *curMoneyDesLabel;

@property (nonatomic, strong) UILabel *playTotalMoneyLabel;
@property (nonatomic, strong) UILabel *playTotalMoneyDesLabel;

@property (nonatomic, strong) UILabel *recommendTotalMoneyLabel;
@property (nonatomic, strong) UILabel *recommendTotalMoneyDesLabel;
@property (nonatomic , assign) BOOL isHidden;
@end

@implementation OpenUserCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户中心";
    
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify_signin:) name:OPEN_EVENT_SIGNIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify_signin:) name:OPEN_EVENT_SIGNOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notify_refresh) name:OPEN_EVENT_REFRESH object:nil];
    
    if([OpenPlatform platform].token && [OpenPlatform platform].userInfo.phone.length==0) {
        [SVProgressHUD showSuccessWithStatus:@"请先绑定手机号"];
        [OpenRouter openUrl:ROUTE_SIGNIN];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBar.hidden) {
        self.isHidden = YES;
        self.navigationController.navigationBar.hidden = NO;
    }else{
        self.isHidden = NO;
    }
    [self requestData];
}

-(void) requestData
{
    if([OpenPlatform platform].token) {
        [[OpenPlatform platform] myWallet:^(WalletResponse *response) {
            
            _headerViewToken = nil;
            
            [self.tableView reloadData];
        }];
    }
}
- (void) notify_signin:(NSNotification*)notification {
    [self.tableView reloadData];
}
-(void)notify_refresh
{
    [self requestData];
}

- (UIView*) headerView {
    
    if([OpenPlatform platform].token) {
        
        if(_headerView && [_headerViewToken isEqualToString:[OpenPlatform platform].token]) {
            return _headerView;
        }
        _headerViewToken = [OpenPlatform platform].token;
        
        _headerView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
        _headerView.backgroundColor = [UIColor whiteColor];
        //_headerView.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        
        UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        blueView.backgroundColor = COLOR(0x1567ff);
        [_headerView addSubview:blueView];
        
        _headerImaegView = [[UIImageView alloc]initWithFrame:CGRectMake(26, blueView.frame.size.height/2 - 30, 60, 60)];
        _headerImaegView.backgroundColor = [UIColor grayColor];
        _headerImaegView.layer.cornerRadius = 30;
        _headerImaegView.clipsToBounds = YES;
        if([OpenPlatform platform].userInfo.headImgUrl) {
            [_headerImaegView setImageWithURL:[NSURL URLWithString:[OpenPlatform platform].userInfo.headImgUrl]];
        }
        [blueView addSubview:_headerImaegView];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(100,
                                                              blueView.frame.size.height*0.4 - 10,
                                                              self.view.frame.size.width - 100, 20)];
        if([OpenPlatform platform].userInfo.nickName.length>0)
            _nameLabel.text = [OpenPlatform platform].userInfo.nickName;
        else if([OpenPlatform platform].userInfo.phone.length>0){
            _nameLabel.text = [OpenPlatform platform].userInfo.phone;
        }
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [blueView addSubview:_nameLabel];
        
        _idLabel = [[UILabel alloc]initWithFrame:CGRectMake(100,
                                                            blueView.frame.size.height*0.6 - 10,
                                                            self.view.frame.size.width - 100, 20)];
        _idLabel.text = [NSString stringWithFormat:@"ID: %lld", [OpenPlatform platform].userInfo.id_];
        
        _idLabel.font = [UIFont systemFontOfSize:16];
        _idLabel.textColor = COLORA(0xaaffffff);
        _idLabel.textAlignment = NSTextAlignmentLeft;
        [blueView addSubview:_idLabel];
        
        
        _curMoneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100 + 16, self.view.frame.size.width/3, 20)];
        _curMoneyLabel.text = [NSString stringWithFormat:@"¥%.2f", [OpenPlatform platform].curMoney/100.f];
        _curMoneyLabel.font = [UIFont systemFontOfSize:18];
        _curMoneyLabel.textColor = COLOR(0x1567ff);
        _curMoneyLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_curMoneyLabel];
        
        _curMoneyDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100 + 35, self.view.frame.size.width/3, 20)];
        _curMoneyDesLabel.text = @"可提现收入";
        _curMoneyDesLabel.font = [UIFont systemFontOfSize:12];
        _curMoneyDesLabel.textColor = [UIColor grayColor];
        _curMoneyDesLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_curMoneyDesLabel];
        
        
        
        _playTotalMoneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, 100 + 16, self.view.frame.size.width/3, 20)];
        _playTotalMoneyLabel.text = [NSString stringWithFormat:@"¥%.2f", [OpenPlatform platform].totalPlayMoney/100.f];
        _playTotalMoneyLabel.font = [UIFont systemFontOfSize:18];
        _playTotalMoneyLabel.textColor = COLOR(0x1567ff);
        _playTotalMoneyLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_playTotalMoneyLabel];
        
        _playTotalMoneyDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, 100 + 35, self.view.frame.size.width/3, 20)];
        _playTotalMoneyDesLabel.text = @"试玩收入";
        _playTotalMoneyDesLabel.font = [UIFont systemFontOfSize:12];
        _playTotalMoneyDesLabel.textColor = [UIColor grayColor];
        _playTotalMoneyDesLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_playTotalMoneyDesLabel];
        
        
        
        _recommendTotalMoneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width*2/3, 100 + 16, self.view.frame.size.width/3, 20)];
        _recommendTotalMoneyLabel.text = [NSString stringWithFormat:@"¥%.2f", [OpenPlatform platform].totalRecommendMoney/100.f];
        _recommendTotalMoneyLabel.font = [UIFont systemFontOfSize:18];
        _recommendTotalMoneyLabel.textColor = COLOR(0x1567ff);
        _recommendTotalMoneyLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_recommendTotalMoneyLabel];
        
        _recommendTotalMoneyDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width*2/3, 100 + 35, self.view.frame.size.width/3, 20)];
        _recommendTotalMoneyDesLabel.text = @"邀请收入";
        _recommendTotalMoneyDesLabel.font = [UIFont systemFontOfSize:12];
        _recommendTotalMoneyDesLabel.textColor = [UIColor grayColor];
        _recommendTotalMoneyDesLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_recommendTotalMoneyDesLabel];
        
    } else {
        
        if(_headerView && _headerViewToken == nil) {
            return _headerView;
        }
        _headerViewToken = nil;
        
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        _headerView.backgroundColor = COLOR(0x1567ff);
        //_headerView.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        
        UIControl *blueView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        blueView.backgroundColor = COLOR(0x1567ff);
        [blueView addTarget:self action:@selector(action_signin:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:blueView];
        
        _headerImaegView = [[UIImageView alloc]initWithFrame:CGRectMake(26, _headerView.frame.size.height/2 - 30, 60, 60)];
        _headerImaegView.backgroundColor = [UIColor grayColor];
        _headerImaegView.layer.cornerRadius = 30;
        _headerImaegView.clipsToBounds = YES;
        [blueView addSubview:_headerImaegView];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(100,
                                                              _headerView.frame.size.height*0.4 - 10,
                                                              self.view.frame.size.width - 100, 20)];
        _nameLabel.text = @"未登录";
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [blueView addSubview:_nameLabel];
        
        _idLabel = [[UILabel alloc]initWithFrame:CGRectMake(100,
                                                            _headerView.frame.size.height*0.6 - 10,
                                                            self.view.frame.size.width - 100, 20)];
        _idLabel.text = @"点击登录";
        _idLabel.font = [UIFont systemFontOfSize:12];
        _idLabel.textColor = COLORA(0x55ffffff);
        _idLabel.textAlignment = NSTextAlignmentLeft;
        [blueView addSubview:_idLabel];
    }
    
    return _headerView;
}

- (IBAction)action_signin:(id)sender {
    
    if([OpenPlatform platform].token == nil) {
        if ([OpenRouter router].loginType == OpenPlatformLoginTypeSign) {
            OpenSigninVC *vc = [OpenSigninVC new];
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            OpenLoginInVC * vc = [OpenLoginInVC new];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (IBAction)action_signout:(id)sender {
    [[OpenPlatform platform] signout:nil];
    //将本地保存的删除
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"shikeMode"];
    [defaults synchronize];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    if([OpenPlatform platform].token) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 1;
    } else if(section ==1) {
        return 5;
    } else {
        return 1;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        
        if([OpenPlatform platform].token) {
            return 160;
        }
        return 100;
        
    } else if(indexPath.section == 1) {
        
    } else if(indexPath.section == 2) {
    }
    
    return 50;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        
        if(_headerView) {
            [_headerView removeFromSuperview];
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCenterHeader"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCenterHeader"];
        }
        
        [cell.contentView addSubview:self.headerView];
        
        return cell;
        
    } else if(indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCenterCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCenterCell"];
        }
        
        if(indexPath.row == 0) {
            cell.textLabel.text = @"申请提现";
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"邀请";
        } else if(indexPath.row == 2) {
            cell.textLabel.text = @"提现记录";
        } else if(indexPath.row == 3) {
            cell.textLabel.text = @"邀请记录";
        } else if(indexPath.row == 4) {
            cell.textLabel.text = @"试玩记录";
        }
        return cell;
        
    } else if(indexPath.section == 2) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCenterCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCenterCell"];
        }
        cell.textLabel.text = @"退出";
        
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        if([OpenPlatform platform].token == nil) {
            [self action_signin:nil];
        }
    } else if(indexPath.section == 1) {
        //后台结束请求失败后token = nil
        if([OpenPlatform platform].token == nil) {
            [self action_signin:nil];
            return;
        }
        if(indexPath.row == 0) {
            if ([AdmCore sharedInstance].userId == nil) {
                [SVProgressHUD showErrorWithStatus:@"正在请求服务器..."];
                return;
            }
            OpenRequestCashVC *vc = [OpenRequestCashVC new];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if(indexPath.row == 1) {
            
            if([OpenPlatform platform].shareInfo == nil) {
                
                [SVProgressHUD show];
                
                [[OpenPlatform platform] share:^(ShareResponse *response) {
                    
                    [SVProgressHUD dismiss];
                    
                    if(response.code == 200) {
                        [OpenPlatform platform].shareInfo = response.body;
                        [self openShare];
                    } else {
                        [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
                    }
                }];
            } else {
                [self openShare];
            }
        } else if(indexPath.row == 2) {
            
            OpenOrderListVC *vc = [OpenOrderListVC new];
            vc.orderType = @"requestCash";
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if(indexPath.row == 3) {
            
            OpenRecommendListVC *vc = [OpenRecommendListVC new];
            [self.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 4) {
            
            OpenPlayListVC *vc = [OpenPlayListVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if(indexPath.section == 2) {
        [self action_signout:nil];
    }
}

- (void) openShare {
    
    if([OpenPlatform platform].shareInfo == nil)
        return;
    
    [OpenShareVC ShareWithVC:self sharInfo:[OpenPlatform platform].shareInfo callBack:^(UIViewController *vc, NSInteger index) {
        
    }];
    
    //    NSMutableArray *items = [NSMutableArray new];
    //
    //    if ([OpenPlatform platform].shareInfo.text) {
    //        [items addObject:[OpenPlatform platform].shareInfo.text];
    //    }
    //    if ([OpenPlatform platform].shareInfo.url) {
    //        [items addObject:[OpenPlatform platform].shareInfo.url];
    //    }
    //
    //    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items
    //                                                                                         applicationActivities:nil];
    //    activityViewController.modalPresentationStyle = UIModalPresentationPopover;
    //    UIPopoverPresentationController *popvc = activityViewController.popoverPresentationController;
    //    popvc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    //    popvc.sourceRect = CGRectMake(0, self.view.frame.size.height - 20, self.view.frame.size.width, 20);
    //    popvc.sourceView = self.view;
    //    [self presentViewController:activityViewController animated:YES completion:nil];
    //
    //    activityViewController.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
    //    };
}
- ( id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop) {
        if (self.isHidden) {
            self.navigationController.navigationBar.hidden = self.isHidden;
        }
    }
    return nil;
}

@end

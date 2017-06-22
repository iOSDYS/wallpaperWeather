//
//  OpenBannerView.m
//  Pods
//
//  Created by mkoo on 2017/4/18.
//
//

#import "OpenBannerView.h"
#import "OpenPlatformUI.h"
#import "MSWeakTimer.h"

static const char *MSSampleViewControllerTimerQueueContext = "MSSampleViewControllerTimerQueueContext";

@interface OpenBannerView()
{
    MSWeakTimer * backgroundTimer;
    dispatch_queue_t privateQueue;
}
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray<App *> *taskList;
@property (nonatomic, strong) App   *doingTask;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UIButton *button;

@end

@implementation OpenBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(action_click:) forControlEvents:UIControlEventTouchUpInside];
        
//        self.backgroundColor = [UIColor clearColor];
        
        if([OpenPlatform platform].token == nil) {
            self.openState = Open_Guest;
            
        } else {
            self.openState = Open_Free;
        }
        
        {
            _backgroundImageView = [UIImageView new];
//            _backgroundImageView.image = [UIImage imageNamed:@"bar_background_small"];
            _backgroundImageView.layer.cornerRadius = 6;
            _backgroundImageView.layer.shadowColor = [UIColor blackColor].CGColor;
            _backgroundImageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
            _backgroundImageView.layer.borderColor = COLORA(0x33000000).CGColor;
            _backgroundImageView.clipsToBounds = YES;
            [self addSubview:_backgroundImageView];
        }
        self.layer.opacity = 0.6;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.5f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        self.layer.borderColor = COLORA(0x33000000).CGColor;
        self.clipsToBounds = YES;
        
        
        //[self updateView];
        
//        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(heartBeat:) userInfo:nil repeats:YES];
        privateQueue = dispatch_queue_create("com.mindsnacks.private_queue", DISPATCH_QUEUE_CONCURRENT);
        
        backgroundTimer = [MSWeakTimer MSWeakTimer_scheduledTimerWithTimeInterval:5
                                                                           target:self
                                                                         selector:@selector(heartBeat:)
                                                                         userInfo:nil
                                                                          repeats:YES
                                                                    dispatchQueue:privateQueue];
        
        dispatch_queue_set_specific(privateQueue, (__bridge const void *)(self), (void *)
                                    MSSampleViewControllerTimerQueueContext, NULL);
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notify_signin:) name:OPEN_EVENT_SIGNIN object:nil];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateView];
}
#pragma mark 获取是否有正在做的任务
- (void) syncState {
    
    [[OpenPlatform platform] doingTaskList:^(TaskListResponse *response) {
        if(response.body.count>0) {
            App *app = response.body[0];
            if([app.state isEqualToString:@"request"]
               || [app.state isEqualToString:@"downloaded"]
               || [app.state isEqualToString:@"playing"]) {
                
                self.doingTask = app;
                self.openState = Open_Doing;
                
            } else if([app.state isEqualToString:@"pass"]) {
                self.openState = Open_Pass;
            } else if([app.state isEqualToString:@"fail"] || [app.state isEqualToString:@"giveup"]) {
                self.openState = Open_Fail;
            }
        }
    }];
}

- (void) notify_signin:(NSNotification*)notify {
    
    if(self.openState == Open_Guest && [OpenPlatform platform].token) {
        self.openState = Open_Free;
        [self heartBeat:nil];
    }
}

- (void) addTitle:(NSString*)title {
    
    CGFloat buttonWidth = 30;
    
    if(_titleLabel == nil) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 0;
    }
    _titleLabel.frame = CGRectMake(10, 0, self.frame.size.width - 20 - buttonWidth, self.frame.size.height);
    [self addSubview:_titleLabel];
    //    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(self);
    //        make.height.mas_equalTo(self.mas_height);
    //    }];
    
    _titleLabel.text = title;
}

- (void) addTitle:(NSString*)title andDetail:(NSString*)detail {
    
    CGFloat buttonWidth = 30;
    
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20 - buttonWidth, self.frame.size.height/2)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 0;
    }
    _titleLabel.frame = CGRectMake(10, 0, self.frame.size.width - 20 - buttonWidth, self.frame.size.height/2);
    [self addSubview:_titleLabel];
    //    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(self);
    //        make.height.mas_equalTo(self.mas_height).dividedBy(2);
    //    }];
    _titleLabel.text = title;
    
    if(_detailLabel == nil) {
        _detailLabel = [UILabel new];
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.numberOfLines = 0;
    }
    _detailLabel.frame = CGRectMake(10, self.frame.size.height/2, self.frame.size.width - 20 - buttonWidth, self.frame.size.height/2);
    [self addSubview:_detailLabel];
    //    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(self.mas_height).dividedBy(2);
    //        make.width.mas_equalTo(self);
    //        make.height.mas_equalTo(self.mas_height).dividedBy(2);
    //    }];
    _detailLabel.text = detail;
}

- (void) addTitle:(NSString*)title andDetail:(NSString*)detail andIcon:(NSString*)icon {
    
    CGFloat buttonWidth = 30;
    
    if(icon.length == 0) {
        [self addTitle:title andDetail:detail];
        return;
    }
    
    CGFloat size = self.frame.size.height * 0.5f;
    
    if(_titleLabel == nil) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 0;
    }
    _titleLabel.frame = CGRectMake(size + 5, 0, self.frame.size.width - size - 10 - buttonWidth, self.frame.size.height/2);
    [self addSubview:_titleLabel];
    //    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(0);
    //        make.right.mas_equalTo(self.mas_width).mas_offset(size + interval);
    //        make.height.mas_equalTo(self.mas_height).dividedBy(2);
    //    }];
    
    _titleLabel.text = title;
    
    if(_detailLabel == nil) {
        _detailLabel = [UILabel new];
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.numberOfLines = 0;
    }
    _detailLabel.frame = CGRectMake(size + 5, self.frame.size.height/2, self.frame.size.width - size - 10 - buttonWidth, self.frame.size.height/2);
    
    [self addSubview:_detailLabel];
    //    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(0);
    //        make.right.mas_equalTo(self.mas_width).mas_offset(size + interval);
    //        make.top.mas_equalTo(self.mas_height).dividedBy(2);
    //        make.height.mas_equalTo(self.mas_height).dividedBy(2);
    //    }];
    _detailLabel.text = detail;
    
    if(_iconImageView == nil) {
        _iconImageView = [UIImageView new];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.layer.cornerRadius = 6;
        _iconImageView.clipsToBounds = YES;
    }
    _iconImageView.frame = CGRectMake(3, self.frame.size.height * 0.1, size, size);
    
    [self addSubview:_iconImageView];
    //    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(interval);
    //        make.right.mas_equalTo(self.mas_width).mas_offset(interval);
    //        make.width.height.mas_equalTo(size);
    //    }];
    [_iconImageView setImageWithURL:[NSURL URLWithString:icon]];
}


- (void) updateView {
    
    [self removeAllSubviews];
    _stateTime = [NSDate date].timeIntervalSince1970;

    _backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:_backgroundImageView];
    
    if(_button == nil) {
        _button = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 42, self.frame.size.height/2 - 15, 45, 36)];
        [_button addTarget:self action:@selector(action_button:) forControlEvents:UIControlEventTouchUpInside];
        _button.titleLabel.font = [UIFont systemFontOfSize:15];
        _button.layer.cornerRadius = 6;
        _button.clipsToBounds = YES;
        [_button setBackgroundColor:[UIColor redColor]];
    }
    _button.frame = CGRectMake(self.frame.size.width - 48, self.frame.size.height/2 - 15, 45, 36);
    
    if(self.openState == Open_Guest) {
        
        [self addTitle:@"学习好累啊" andDetail:@"玩个游戏放松下，赚取2.6元"];
        
    } else if(self.openState == Open_Free) {
        
        [self addTitle:@"来晚啦" andDetail:@"没有可做任务"];
        
        [_button setTitle:@"钱包" forState:UIControlStateNormal];
        [self addSubview:_button];
        
    } else if(self.openState == Open_HaveTask) {
        
        App *maxApp = nil;
        for(App* app in self.taskList) {
            if(app.price > maxApp.price)
                maxApp = app;
        }
        
        NSString *str = [NSString stringWithFormat:@"玩个游戏放松下，赚取%.2f元", maxApp.price / 100.f];
        [self addTitle:@"学习好累啊" andDetail:str];
        
        [_button setTitle:@"钱包" forState:UIControlStateNormal];
        [self addSubview:_button];
        
    } else if(self.openState == Open_Accessing) {
        
        [self addTitle:@"抢任务中..."];
        
        [_button setTitle:@"钱包" forState:UIControlStateNormal];
        [self addSubview:_button];
        
    } else if(self.openState == Open_Doing) {
        
        NSString *title = [NSString stringWithFormat:@"打开AppStore, 搜索\"%@\", 大概在第%ld名", _doingTask.searchWord, _doingTask.rank];
        NSString *detail = [NSString stringWithFormat:@"打开试玩5分钟,即可领取%.2f元奖励", _doingTask.price / 100.f];
        [self addTitle:title andDetail:detail andIcon:_doingTask.icon];
        
        [_button setTitle:@"放弃" forState:UIControlStateNormal];
        [self addSubview:_button];
        
    } else if(self.openState == Open_Pass) {
        
        NSString *title = [NSString stringWithFormat:@"试玩通过,获取奖励%.2f元", _doingTask.price / 100.f];
        [self addTitle:title andDetail:@"点击查看余额"];
        
        [_button setTitle:@"钱包" forState:UIControlStateNormal];
        [self addSubview:_button];
        
    } else if(self.openState == Open_Fail) {
        
        [self addTitle:@"试玩失败" andDetail:@"点击查看余额"];
        
        [_button setTitle:@"钱包" forState:UIControlStateNormal];
        [self addSubview:_button];
    }
}

- (IBAction)action_button:(id)sender {
    
    if(self.openState == Open_Doing) {
        [[OpenPlatform platform] giveupTask:self.doingTask.sign complete:^(Response *response) {
            self.doingTask = nil;
            [self.taskList removeObject:self.doingTask];
            if(self.taskList.count>0) {
                self.openState = Open_HaveTask;
            } else {
                self.openState = Open_Free;
            }
        }];
    } else {
        [OpenRouter openUrl:ROUTE_USER_CENTER];
    }
}
#pragma mark 点击banner事件
- (IBAction)action_click:(id)sender {
    
    if(self.openState == Open_Guest) {
        
        [OpenRouter openUrl:ROUTE_USER_CENTER];
        
        if([OpenPlatform platform].token == nil) {
            [OpenRouter openUrl:ROUTE_SIGNIN];
        }
        
    } else if(self.openState == Open_Free) {
        
    } else if(self.openState == Open_HaveTask) {
        
        App *maxApp = [self.taskList objectAtIndex:0];
        
        for(App* app in self.taskList) {
            if(app.price > maxApp.price || maxApp == nil)
                maxApp = app;
        }
        
        self.openState = Open_Accessing;
        
        [AdmCore sharedInstance].checkNotification = YES;
        [[AdmCore sharedInstance] checkNotificationSetting];
        
        [[OpenPlatform platform] accessTask:maxApp.sign complete:^(Response *response) {
            
            if(response.code == 200) {
                self.doingTask = maxApp;
                self.openState = Open_Doing;
            } else if(response.code != 0) {
                
                [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
                
                [self.taskList removeObject:maxApp];
                if(self.taskList.count >0) {
                    self.openState = Open_HaveTask;
                } else {
                    self.openState = Open_Free;
                    [self heartBeat:nil];
                }
                
                if(response.code == 403) {
                    [SVProgressHUD showInfoWithStatus:response.msg];
                    [OpenRouter openUrl:ROUTE_SIGNIN];
                }
                
            } else {
                [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
                self.openState = Open_HaveTask;
            }
        }];
        
    } else if(self.openState == Open_Accessing) {
        
    } else if(self.openState == Open_Doing) {
        
        NSString *url = [OpenPlatform platform].searchUrl;
        if(url.length == 0) {
            url = @"https://open.admore.com.cn/search.html";
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=10) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                }];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        });
        
    } else if(self.openState == Open_Pass) {
        
        self.openState = Open_Free;
        
        [OpenRouter openUrl:ROUTE_USER_CENTER];
        
    } else if(self.openState == Open_Fail) {
        
        self.openState = Open_Free;
        
        [OpenRouter openUrl:ROUTE_USER_CENTER];
    }
}

- (void) heartBeat:(NSTimer*)timer {
    
    //    if(self.openState != Open_Guest && [OpenPlatform platform].token == nil) {
    //        self.openState = Open_Free;
    //    }
    
    if(self.openState == Open_Guest) {
        
        if([OpenPlatform platform].token) {
            self.openState = Open_Free;
        }
        
    } else if(self.openState == Open_Free) {
        
        NSTimeInterval curTime = [NSDate date].timeIntervalSince1970;
        if(curTime - _requestTime > 30) {
            _requestTime = curTime;
            
            [[OpenPlatform platform] taskList:^(TaskListResponse *response) {
                if(response.code == 200 && response.body.count>0) {
                    self.taskList = response.body;
                    
                    
                    for(App *app in self.taskList) {
                        if(app.playing) {
                            self.doingTask = app;
                            self.openState = Open_Doing;
                            break;
                        }
                    }
                    
                    if(self.openState == Open_Free) {
                        self.openState = Open_HaveTask;
                    }
                    
                } else if(response.code == 403) {
                    [SVProgressHUD showInfoWithStatus:response.msg];
                    [OpenRouter openUrl:ROUTE_SIGNIN];
                }
            }];
        }
        
    } else if(self.openState == Open_HaveTask) {
        
        NSTimeInterval curTime = [NSDate date].timeIntervalSince1970;
        if(curTime - _requestTime > 30) {
            _requestTime = curTime;
            
            [[OpenPlatform platform] taskList:^(TaskListResponse *response) {
                if(response.code == 200 && response.body.count>0) {
                    self.taskList = response.body;
                    
                    for(App *app in self.taskList) {
                        if(app.playing) {
                            self.doingTask = app;
                            self.openState = Open_Doing;
                            break;
                        }
                    }
                    
                    if(self.openState == Open_Free) {
                        self.openState = Open_HaveTask;
                    }

                } else {
                    self.taskList = nil;
                    self.openState = Open_Free;
                }
                
                if(response.code == 403) {
                    [SVProgressHUD showInfoWithStatus:response.msg];
                    [OpenRouter openUrl:ROUTE_SIGNIN];
                }
            }];
        }
        
    } else if(self.openState == Open_Accessing) {
        
        NSTimeInterval curTime = [NSDate date].timeIntervalSince1970;
        if(curTime - _stateTime > 30) {
            self.openState = Open_Free;
        }
        
    } else if(self.openState == Open_Doing) {
        
        NSTimeInterval curTime = [NSDate date].timeIntervalSince1970;
        if(curTime - _requestTime > 30) {
            _requestTime = curTime;
            [self syncState];
        }
        
    } else if(self.openState == Open_Pass) {
        
        NSTimeInterval curTime = [NSDate date].timeIntervalSince1970;
        if(curTime - _stateTime > 30) {
            self.openState = Open_Free;
        }
        
    } else if(self.openState == Open_Fail) {
        
        NSTimeInterval curTime = [NSDate date].timeIntervalSince1970;
        if(curTime - _stateTime > 30) {
            self.openState = Open_Free;
        }
    }
}

- (void) setOpenState:(OpenState)openState {
    _openState = openState;
    _stateTime = [NSDate date].timeIntervalSince1970;
    [self updateView];
    
    if(openState == Open_Free) {
        [self heartBeat:nil];
    }
}

- (void) removeAllSubviews {
    for (int i=0; i<self.subviews.count; i++) {
        UIView *view = [self.subviews objectAtIndex:i];
        [view removeFromSuperview];
        i--;
    }
}

@end

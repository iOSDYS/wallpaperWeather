//
//  OpenOrderListVC.h
//  DailyEnglish
//
//  Created by mkoo on 2017/4/21.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenOrderListVC : UIViewController

/*
 play,//试玩收入
 percentage, //提成
 recommend,  //推荐
 requestCash, //取款
 */
@property (nonatomic, strong) NSString *orderType;

@end

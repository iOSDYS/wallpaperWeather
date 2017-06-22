//
//  WalletResponse.h
//  Pods
//
//  Created by mkoo on 2017/4/6.
//
//

#import <Foundation/Foundation.h>


@interface WalletResponseBody : NSObject
@property (nonatomic, assign) NSInteger curMoney;           //当前余额
@property (nonatomic, assign) NSInteger requestCashMoney;   //当前正在提现
@property (nonatomic, assign) NSInteger totalMoney;         //总收入
@property (nonatomic, assign) NSInteger totalPlayMoney;     //试玩总收入
@property (nonatomic, assign) NSInteger totalRecommendMoney;//推荐总收入
@property (nonatomic, assign) NSInteger totalRequestMoney;  //总共提现金额
@property (nonatomic, assign) NSInteger totalPercentage;    //提成总收入
@end

@interface WalletResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) WalletResponseBody *body;
@property (nonatomic, strong) NSString *msg;
@end


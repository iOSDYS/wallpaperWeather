//
//  OpenPlatform.h
//  Pods
//
//  Created by mkoo on 2017/3/23.
//
//

#import <Foundation/Foundation.h>
#import "AdmCore.h"
#import "Response.h"
#import "WalletResponse.h"
#import "OrderListResponse.h"
#import "TaskListResponse.h"
#import "UserResponse.h"
#import "User.h"
#import "PaymentinfoResponse.h"
#import "ShareResponse.h"
#import "RecommendListResponse.h"


#define OPEN_EVENT_SIGNIN   @"open.signin"
#define OPEN_EVENT_SIGNOUT  @"open.signout"
#define OPEN_EVENT_REFRESH  @"open.refresh"

#define NET_ERROR_TEXT       @"网络忙，请稍后重试"
#define OPEN_SDK_VERSION       @"1.1"


@interface OpenPlatform : NSObject

@property (nonatomic, strong) NSString  *appKey;
@property (nonatomic, strong) NSString  *token;
@property (nonatomic, strong) NSString  *deviceSession;
@property (nonatomic, strong) NSString  *secretKey;
@property (nonatomic, strong) NSString  *searchUrl;
@property (nonatomic, strong) NSString  *secretInfo;
@property (nonatomic, assign) BOOL  shikeMode;              //是否开启试客模式
@property (nonatomic, strong) User  *userInfo;              //用户基本信息
@property (nonatomic, strong) NSString *recommender;        //推荐人
@property (nonatomic, strong) ShareInfo *shareInfo;         //分享信息
@property (nonatomic, strong) UIImageView *shareIconImageView;
@property (nonatomic, strong) UIImage *shareIcon;           //分享图标
@property (nonatomic, assign) NSInteger curMoney;           //当前余额
@property (nonatomic, assign) NSInteger requestCashMoney;   //当前正在提现
@property (nonatomic, assign) NSInteger totalMoney;         //总收入
@property (nonatomic, assign) NSInteger totalPlayMoney;     //试玩总收入
@property (nonatomic, assign) NSInteger totalRecommendMoney;//推荐总收入
@property (nonatomic, assign) NSInteger totalRequestMoney;  //总共提现金额
@property (nonatomic, assign) NSInteger totalPercentage;    //提成总收入
@property (nonatomic, strong) NSMutableArray<Paymentinfo*> *paymentInfoList;    //绑定账号列表
@property (nonatomic, strong) Paymentinfo *selectPaymentInfo;                   //当前提现账户


@property (assign, nonatomic) BOOL started;

@property (nonatomic , assign) BOOL isRegisterMode;
+ (OpenPlatform*) platform;

+ (BOOL) startWithAppKey:(NSString*)appKey playAudio:(BOOL)playAudio checkNotification:(BOOL)checkNotification netType:(NET_TYPE)netType shikeMode:(BOOL)shikeMode complete:(void(^)(UserResponse*))complete;

#pragma mark - user (type1: signin with sms code)

- (void) requestSigninPhoneCode:(NSString*)phone complete:(void(^)(Response *response))complete;

- (void) signinByPhone:(NSString*)phone code:(NSString*)code complete:(void(^)(UserResponse *response))complete;

- (void) bindPhone:(NSString*)phone code:(NSString*)code complete:(void(^)(UserResponse *response))complete;

- (void) signinByWechat:(NSString*)wxCode complete:(void(^)(UserResponse *response))complete;

- (void) signinByThird:(NSString*)accessToken complete:(void(^)(UserResponse *response))complete;

- (void) signout:(void(^)(UserResponse *response))complete;

- (void) notifyTerminate:(void(^)(Response *response))complete;

#pragma mark - user (type 2: login by password)

- (void) registerByPhone:(NSString*)phone code:(NSString*)code password:(NSString*)password complete:(void(^)(UserResponse *response))complete;

- (void) loginByPhone:(NSString*)phone password:(NSString*)password complete:(void(^)(UserResponse *response))complete;

- (void) requestResetPasswordPhoneCode:(NSString*)phone complete:(void(^)(Response *response))complete;

- (void) resetPassword:(NSString*)phone code:(NSString*)code password:(NSString*)password complete:(void(^)(Response *response))complete;

#pragma mark - order

- (void) myWallet:(void(^)(WalletResponse *response))complete;

- (void) myOrderList:(NSString*)orderType complete:(void(^)(OrderListResponse *response))complete;

- (void) requestCash:(NSInteger)money paymentId:(int64_t)paymentId complete:(void(^)(WalletResponse *response))complete;

- (void) requestBindPaymentPhoneCode:(NSString*)phone complete:(void(^)(Response *response))complete;

- (void) bindPaymentList:(void(^)(PaymentinfoListResponse *response))complete;

- (void) bindAliPayAccount:(NSString*)account name:(NSString*)name /*phone:(NSString*)phone code:(NSString*)code*/ complete:(void(^)(PaymentinfoResponse *response))complete;

- (void) bindBankCard:(NSString*)card name:(NSString*)name /*phone:(NSString*)phone code:(NSString*)code*/ complete:(void(^)(PaymentinfoResponse *response))complete;

- (void) bindWechatAccount:(NSString*)wxCode complete:(void(^)(PaymentinfoResponse *response))complete;

- (void) unbind:(int64_t)paymentId complete:(void(^)(PaymentinfoListResponse *response))complete;

#pragma mark - task

- (void) taskList:(void(^)(TaskListResponse *response))complete;

- (void) accessTask:(NSString*)sign complete:(void(^)(Response *response))complete;

- (void) doingTaskList:(void(^)(TaskListResponse *response))complete;

- (void) giveupTask:(NSString*)sign complete:(void(^)(Response *response))complete;

- (void) taskHistoryList:(void(^)(TaskListResponse *response))complete;

#pragma mark - recommend

- (void) share:(void(^)(ShareResponse *response))complete;

- (void) recommendList:(int64_t)preRecommendId count:(int)count complete:(void(^)(RecommendListResponse *response))complete;


@end

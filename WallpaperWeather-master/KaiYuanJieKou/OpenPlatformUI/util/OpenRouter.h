//
//  OpenRouter.h
//  DailyEnglish
//
//  Created by mkoo on 2017/4/19.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import <Foundation/Foundation.h>
//枚举 注册方式登录 签到式登录
typedef NS_ENUM(NSInteger, OpenPlatformLoginType)
{
    OpenPlatformLoginTypeRegister,
    OpenPlatformLoginTypeSign,
};

#define ROUTE_USER_CENTER @"admoresdk://route.usercenter"
#define ROUTE_SIGNIN @"admoresdk://route.signin"
#define ROUTE_SHARE @"admoresdk://route.share"
#define ROUTE_REQUEST_CASH @"admoresdk://route.requestcash"
#define ROUTE_REQUEST_CASH_HISTORY @"admoresdk://route.requestcash.history"
#define ROUTE_RECOMMEND_HISTORY @"admoresdk://route.orderhistory"

@interface OpenRouter : NSObject

+ (OpenRouter*) router;

+ (void) registerUrl:(NSString*)url block:(void(^)())block;

+ (BOOL) openUrl:(NSString*)url;

@property (nonatomic , assign) OpenPlatformLoginType loginType;
@end

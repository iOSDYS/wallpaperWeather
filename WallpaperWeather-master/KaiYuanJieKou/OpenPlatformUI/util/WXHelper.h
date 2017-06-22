//
//  WXHelper.h
//  DailyEnglish
//
//  Created by mkoo on 2017/4/19.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WXApi.h>
#import "UserResponse.h"
#import "PaymentinfoResponse.h"

@interface WXHelper : NSObject <WXApiDelegate>

@property (nonatomic, strong) void(^complete)(UserResponse *response);

@property (nonatomic, strong) void(^bindComplete)(PaymentinfoResponse *response);

+ (WXHelper*) sharedInstance;

- (void) loginIn:(UIViewController*)vc complete:(void(^)(UserResponse*)) complete;

- (void) bindWechat:(UIViewController*)vc bindComplete:(void(^)(PaymentinfoResponse*)) bindComplete;
@end

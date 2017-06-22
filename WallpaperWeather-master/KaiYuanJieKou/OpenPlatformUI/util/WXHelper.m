//
//  WXHelper.m
//  DailyEnglish
//
//  Created by mkoo on 2017/4/19.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import "WXHelper.h"
#import "SVProgressHUD.h"
#import "OpenPlatform.h"

@implementation WXHelper

+ (WXHelper*) sharedInstance {
    static WXHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WXHelper new];
    });
    return instance;
}

- (void) loginIn:(UIViewController*)vc complete:(void(^)(UserResponse*)) complete {
//    if ([AdmCore sharedInstance].userId == nil) {
//        UserResponse * response = [UserResponse new];
//        response.code = 400;
//        response.msg = @"正在请求服务器...";
//        complete(response);
//        return;
//    }
//    
//    self.complete = complete;
//    
//    [WXApi registerApp:@"wxf62e2ebf9c72e661"];
//    SendAuthReq *req = [[SendAuthReq alloc] init];
//    req.scope = @"snsapi_userinfo";
//    req.state = @"dailyenglish_login";
//    [WXApi sendAuthReq:req viewController:vc delegate:self];
}

- (void) bindWechat:(UIViewController*)vc bindComplete:(void(^)(PaymentinfoResponse*)) bindComplete {
    if ([AdmCore sharedInstance].userId == nil) {
        PaymentinfoResponse * response = [PaymentinfoResponse new];
        response.code = 400;
        response.msg = @"正在请求服务器...";
        bindComplete(response);
        return;
    }
    
    self.bindComplete = bindComplete;
    
    [WXApi registerApp:@"wxb9e8bb85b528ced9"];
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"pay_login";
    [WXApi sendAuthReq:req viewController:vc delegate:self];

//        [WXApi registerApp:@"wxf62e2ebf9c72e661"];
//        SendAuthReq *req = [[SendAuthReq alloc] init];
//        req.scope = @"snsapi_userinfo";
//        req.state = @"dailyenglish_login";
//        [WXApi sendAuthReq:req viewController:vc delegate:self];
}

#pragma mark - WXApiDelegate

-(void) onResp:(BaseResp*)resp {
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *sendAuth = (SendAuthResp *)resp;
        
        if ([sendAuth.state isEqualToString:@"dailyenglish_login"]) {
            
            if(sendAuth.code){
                NSString *wxCodeStr = sendAuth.code;
                
                [SVProgressHUD show];
                
                [[OpenPlatform platform]signinByWechat:wxCodeStr complete:^(UserResponse *response) {
                    
                    [SVProgressHUD dismiss];
                    if(self.complete)
                        self.complete(response);
                    
                    self.complete = nil;
                }];
            } else {
                if(self.complete)
                    self.complete(nil);
                
                self.complete = nil;
            }
        }
        else if ([sendAuth.state isEqualToString:@"pay_login"])
        {
            if(sendAuth.code){
                NSString *wxCodeStr = sendAuth.code;
                
                [SVProgressHUD show];
                
                [[OpenPlatform platform] bindWechatAccount:wxCodeStr complete:^(PaymentinfoResponse *response) {
                    [SVProgressHUD dismiss];
                    if(self.bindComplete)
                        self.bindComplete(response);
                    
                    self.bindComplete = nil;
                }];

            } else {
                if(self.bindComplete)
                    self.bindComplete(nil);
                
                self.bindComplete = nil;
            }

        }
    }
}


@end

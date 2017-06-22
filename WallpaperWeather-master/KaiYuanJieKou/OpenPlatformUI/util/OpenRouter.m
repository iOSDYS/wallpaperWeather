//
//  OpenRouter.m
//  DailyEnglish
//
//  Created by mkoo on 2017/4/19.
//  Copyright © 2017年 mkoo. All rights reserved.
//

#import "OpenRouter.h"
#import "OpenPlatformUI.h"
#import "AppDelegate.h"

@interface OpenRouter()

@property (nonatomic, strong) void (^complete)(UserResponse* response);

@property (nonatomic, strong) NSMutableDictionary *blockList;
@end

@implementation OpenRouter

+ (OpenRouter*) router {
    static OpenRouter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [OpenRouter new];
        //可以修改登录方式
        instance.loginType = OpenPlatformLoginTypeRegister;
    });
    return instance;
}

+ (void) registerUrl:(NSString*)url block:(void(^)())block{
    
    if([OpenRouter router].blockList == nil) {
        [OpenRouter router].blockList = [NSMutableDictionary new];
    }
    [[OpenRouter router].blockList setObject:block forKey:url];
}

+ (BOOL) openUrl:(NSString*)url {
    
    if([OpenRouter router].blockList) {
        
        void(^block)() = [[OpenRouter router].blockList objectForKey:url];
        if(block) {
            block();
            return YES;
        }
    }
    
    UINavigationController *navVC = (UINavigationController*)[UIApplication sharedApplication].windows.firstObject.rootViewController;
    UIViewController *curVC = navVC.topViewController;
    
    if([url isEqualToString:ROUTE_SIGNIN]) {
        
        if ([OpenRouter router].loginType == OpenPlatformLoginTypeSign) {
            OpenSigninVC *vc = [OpenSigninVC new];
            [curVC presentViewController:vc animated:YES completion:nil];
        }else{
            OpenLoginInVC *vc = [OpenLoginInVC new];
            [curVC presentViewController:vc animated:YES completion:nil];
        }
        return YES;
        
    } else if([url isEqualToString:ROUTE_USER_CENTER]) {
        
        OpenUserCenterVC *vc = [OpenUserCenterVC new];
        [navVC pushViewController:vc animated:YES];
        return YES;
        
    } else if([url isEqualToString:ROUTE_SHARE]) {
        
        if([OpenPlatform platform].token == nil) {
            [SVProgressHUD showErrorWithStatus:@"请先登录"];
            return YES;
        }
        
        if([OpenPlatform platform].shareInfo == nil) {
            
            [SVProgressHUD show];
            
            [[OpenPlatform platform] share:^(ShareResponse *response) {
                
                [SVProgressHUD dismiss];
                
                if(response.code == 200) {
                    [OpenPlatform platform].shareInfo = response.body;
                    [OpenShareVC ShareWithVC:curVC sharInfo:[OpenPlatform platform].shareInfo callBack:^(UIViewController *vc, NSInteger index) {
                        
                    }];
                } else {
                    [SVProgressHUD showErrorWithStatus:response.msg?response.msg:NET_ERROR_TEXT];
                }
            }];
            
        } else {
            
            [OpenShareVC ShareWithVC:curVC sharInfo:[OpenPlatform platform].shareInfo callBack:^(UIViewController *vc, NSInteger index) {
            }];
        }
        
        return YES;
        
    } else if([url isEqualToString:ROUTE_REQUEST_CASH]) {
        
        if([OpenPlatform platform].token == nil) {
            [SVProgressHUD showErrorWithStatus:@"请先登录"];
            return YES;
        }
        
        OpenRequestCashVC *vc = [OpenRequestCashVC new];
        [navVC pushViewController:vc animated:YES];
        return YES;
        
    } else if([url isEqualToString:ROUTE_REQUEST_CASH_HISTORY]) {
        
        if([OpenPlatform platform].token == nil) {
            [SVProgressHUD showErrorWithStatus:@"请先登录"];
            return YES;
        }
        
        OpenOrderListVC *vc = [OpenOrderListVC new];
        vc.orderType = @"requestCash";
        [navVC pushViewController:vc animated:YES];
        return YES;
        
    } else if([url isEqualToString:ROUTE_RECOMMEND_HISTORY]) {
        
        if([OpenPlatform platform].token == nil) {
            [SVProgressHUD showErrorWithStatus:@"请先登录"];
            return YES;
        }
        
        OpenRecommendListVC *vc = [OpenRecommendListVC new];
        [navVC pushViewController:vc animated:YES];
        return YES;
    }
    
    return NO;
}

@end

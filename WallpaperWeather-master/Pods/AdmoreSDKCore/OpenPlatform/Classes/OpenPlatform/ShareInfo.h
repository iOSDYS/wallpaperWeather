//
//  ShareInfo.h
//  Pods
//
//  Created by mkoo on 2017/4/24.
//
//

#import <Foundation/Foundation.h>

@interface ShareInfo : NSObject
@property(nonatomic, strong) NSString       *url;
@property(nonatomic, strong) NSString       *icon;
@property(nonatomic, strong) NSString       *title;
@property(nonatomic, strong) NSString       *detail;

@property(nonatomic, strong) NSString       *linkCopy;
@property(nonatomic, strong) NSString       *smsText;

@property(nonatomic, strong) NSString       *weiboTitle;
@property(nonatomic, strong) NSString       *weiboDetail;
@property(nonatomic, strong) NSString       *weiboUrl;

@property(nonatomic, strong) NSString       *wechatTitle;
@property(nonatomic, strong) NSString       *wechatDetail;
@property(nonatomic, strong) NSString       *wechatUrl;

@property(nonatomic, strong) NSString       *wechatAppId;

@end

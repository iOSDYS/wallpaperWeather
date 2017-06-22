//
//  OpenShareVC.h
//  BetweenTheLines
//
//  Created by XU on 16/1/5.
//  Copyright © 2016年 ASOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareInfo.h"

@protocol shareProtocol <NSObject>

- (UIView *)shareAnimationBegin;

- (void)shareAnimationFinish;

@end


@interface OpenShareVC : UIViewController

@property (nonatomic, strong) UIView *WebBrowserView;

@property (nonatomic, strong) NSString* defaultShareIcon;

+(OpenShareVC *)ShareWithVC:(UIViewController *)VC
               sharInfo:(ShareInfo*)shareInfo
               callBack:(void (^)(UIViewController* vc, NSInteger))callBack;



@end

//
//  OpenPlatformUIConfig.h
//  Pods
//
//  Created by mkoo on 2017/4/26.
//
//

#ifndef OpenPlatformUIConfig_h
#define OpenPlatformUIConfig_h

#import "OpenPlatform.h"
#import "BindAlipayVC.h"
#import "OpenBannerView.h"
#import "OpenShareView.h"
#import "OpenRegisterVC.h"
#import "OpenLoginInVC.h"
#import "OpenSigninVC.h"
#import "OpenUserCenterVC.h"
#import "OpenOrderListVC.h"
#import "OpenPlayListVC.h"
#import "OpenRecommendListVC.h"
#import "OpenRequestCashVC.h"
#import "OpenShareVC.h"

#import "OpenRouter.h"
#import "SVProgressHUD.h"
#import "WXHelper.h"
#import "Masonry.h"
#import "UIImageView+AFNetworking.h"
#import "AdmConfig.h"


#define W_DEVICE  [UIScreen mainScreen].bounds.size.width
#define H_DEVICE [UIScreen mainScreen].bounds.size.height




NS_INLINE CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

NS_INLINE CGRect POPPixelsToRect(CGFloat progress, CGRect startRect, CGRect endRect){
    float x = POPTransition(progress, startRect.origin.x, endRect.origin.x);
    float y = POPTransition(progress, startRect.origin.y, endRect.origin.y);
    float w = POPTransition(progress, startRect.size.width, endRect.size.width);
    float h = POPTransition(progress, startRect.size.height, endRect.size.height);
    
    return CGRectMake(x, y, w, h);
}


#ifndef YY_CLAMP // return the clamped value
#define YY_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif


#endif /* OpenPlatformUIConfig_h */

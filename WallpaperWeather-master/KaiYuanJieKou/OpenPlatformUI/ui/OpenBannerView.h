//
//  OpenBannerView.h
//  Pods
//
//  Created by mkoo on 2017/4/18.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    Open_Guest,
    Open_Free,
    Open_HaveTask,
    Open_Accessing,
    Open_Doing,
    Open_Pass,
    Open_Fail,
} OpenState;


@interface OpenBannerView : UIControl

@property (nonatomic, assign) OpenState openState;

@property (nonatomic, assign) NSTimeInterval stateTime;

@property (nonatomic, assign) NSTimeInterval requestTime;

@end

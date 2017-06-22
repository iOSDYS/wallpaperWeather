//
//  WeatherDeatailView.h
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/28.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeatherModel;

@interface WeatherDetailView : UIView

+ (void)showWithWeatherData:(WeatherModel *)data;
@end

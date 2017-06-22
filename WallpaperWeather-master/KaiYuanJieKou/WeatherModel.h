//
//  TodayWeatherModel.h
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/18.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherModel : NSObject
@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *cityid;
@property (nonatomic,copy)NSString *week;
@property (nonatomic,copy)NSString *weather;
@property (nonatomic,copy)NSString *temp;
@property (nonatomic,copy)NSString *temphigh;
@property (nonatomic,copy)NSString *templow;
@property (nonatomic,copy)NSString *date;
@property (nonatomic,strong)NSArray *hourly;
@property (nonatomic,strong)NSArray *daily;
@end

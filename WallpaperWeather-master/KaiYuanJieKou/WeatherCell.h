//
//  WeatherCell.h
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/26.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeatherModel;

@interface WeatherCell : UITableViewCell

+ (instancetype)cellWithTableview:(UITableView *)tableView WeatherData:(WeatherModel *)data;

@end

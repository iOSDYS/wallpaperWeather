//
//  DailyCell.h
//  KaiYuanJieKou
//
//  Created by duodian on 2017/6/18.
//  Copyright © 2017年 jiachenmu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DailyModel;

@interface DailyCell : UITableViewCell
+ (instancetype)cellWithTableview:(UITableView *)tableView WeatherData:(DailyModel*)data;
@end

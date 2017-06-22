//
//  DailyModel.h
//  KaiYuanJieKou
//
//  Created by duodian on 2017/6/18.
//  Copyright © 2017年 jiachenmu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DailyModel : NSObject
@property (nonatomic,copy)NSString *date;
@property (nonatomic,copy)NSString *week;
@property (nonatomic,copy)NSString *sunrise;
@property (nonatomic,copy)NSString *sunset;
@property (nonatomic,strong)NSDictionary *night;
@property (nonatomic,strong)NSDictionary *day;
@end

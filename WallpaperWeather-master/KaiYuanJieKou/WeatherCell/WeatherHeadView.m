//
//  WeatherHeadView.m
//  KaiYuanJieKou
//
//  Created by duodian on 2017/6/17.
//  Copyright © 2017年 jiachenmu. All rights reserved.
//

#import "WeatherHeadView.h"
#import "WeatherModel.h"
#import "UIImage+ReturnWeatherImage.h"

@interface WeatherHeadView ()
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *quiltyLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImg;

@end

@implementation WeatherHeadView

- (void)setModel:(WeatherModel *)model {
    _cityLabel.text = model.city;
    _tempLabel.text = [NSString stringWithFormat:@"%@℃",model.temp];
    _quiltyLabel.text = model.weather;
    _weatherImg.image = [UIImage returnImageWithWeatherType:model.weather];
    _dateLabel.text = [NSString stringWithFormat:@"%@ %@",model.date,model.week];
}

@end

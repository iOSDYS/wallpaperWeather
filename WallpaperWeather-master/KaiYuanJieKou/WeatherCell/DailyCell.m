//
//  DailyCell.m
//  KaiYuanJieKou
//
//  Created by duodian on 2017/6/18.
//  Copyright © 2017年 jiachenmu. All rights reserved.
//

#import "DailyCell.h"
#import "DailyModel.h"
#import "UIImage+ReturnWeatherImage.h"
@interface DailyCell ()
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *temLabel;

@property (weak, nonatomic) IBOutlet UIImageView *weatherImg;
@end

@implementation DailyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableview:(UITableView *)tableView WeatherData:(DailyModel*)data{
    static NSString *cellID = @"dailyCell";
    DailyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DailyCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.weekLabel.text = data.week;
    cell.temLabel.text = [NSString stringWithFormat:@"%@~%@℃",data.day[@"temphigh"],data.night[@"templow"]];
    cell.weatherImg.image = [UIImage returnImageWithWeatherType:data.day[@"weather"]];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

@end

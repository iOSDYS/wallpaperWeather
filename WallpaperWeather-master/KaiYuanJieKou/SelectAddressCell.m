//
//  SelectAddressCell.m
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/25.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import "SelectAddressCell.h"

@implementation SelectAddressCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//朝阳

+ (instancetype)cellWithUITableView:(UITableView *)tableView CityModel:(CityModel *)model{
    NSString *cellID = @"SelectAddressCellID";
    SelectAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:@"SelectAddressCell" owner:nil options:nil];
        cell = [nibArr lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.titleLabel.text = model.city;
    return cell;
}

@end

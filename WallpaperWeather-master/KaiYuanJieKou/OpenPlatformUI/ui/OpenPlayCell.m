//
//  OpenPlayCell.m
//  AdmoreSDKCore
//
//  Created by careyang on 2017/6/5.
//  Copyright © 2017年 wanglin.sun. All rights reserved.
//

#import "OpenPlayCell.h"
#import "OpenPlatformUI.h"

@implementation OpenPlayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void) updateView:(App *)app
{
    if (app.icon) {
        self.iconImg.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:app.icon]]];
    }
    if (app.trackName) {
        self.nameLabel.text = app.trackName;
    }
    
    if([app.state isEqualToString:@"pass"]) {
        self.playStateLabel.text = @"试玩成功";
    } else if([app.state isEqualToString:@"request"] || [app.state isEqualToString:@"downloaded"] || [app.state isEqualToString:@"playing"])
        self.playStateLabel.text = @"试玩中";
    else if([app.state isEqualToString:@"giveup"] || [app.state isEqualToString:@"fail"]) {
        self.playStateLabel.text = @"试玩失败";
    } else {
        self.playStateLabel.text = @"状态未知";
    }
    
    self.keyWordLabel.text = [NSString stringWithFormat:@"关键词:%@ 奖励:%.2f元", app.searchWord, app.price / 100.f];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

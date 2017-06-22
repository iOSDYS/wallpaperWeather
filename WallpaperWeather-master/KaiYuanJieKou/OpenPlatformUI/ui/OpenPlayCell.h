//
//  OpenPlayCell.h
//  AdmoreSDKCore
//
//  Created by careyang on 2017/6/5.
//  Copyright © 2017年 wanglin.sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class App;
@interface OpenPlayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *keyWordLabel;

-(void) updateView:(App *)app;

@end

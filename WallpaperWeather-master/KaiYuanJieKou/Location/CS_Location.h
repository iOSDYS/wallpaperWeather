//
//  CS_Location.h
//  CarServant
//
//  Created by macbook on 16/3/3.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
 typedef void(^LocationBlock)(NSString *city);

@interface CS_Location : NSObject
+ (instancetype)shareInstance;
@property (nonatomic,strong) LocationBlock block;
- (void)startLocate;
@end

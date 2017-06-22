//
//  CityModel.h
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/22.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject <NSCoding>
@property (nonatomic,strong) NSString  *cityid;
@property (nonatomic,strong) NSString *parentid;
@property (nonatomic,strong) NSString *citycode;
@property (nonatomic,strong) NSString *city;
@end

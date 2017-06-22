//
//  CityModel.m
//  KaiYuanJieKou
//
//  Created by jiachen on 16/4/22.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import "CityModel.h"

#define CityId    @"cityid"
#define ParentId    @"parentid"
#define CityCode  @"citycode"
#define City @"city"

@implementation CityModel

//- MARK:自定义类 无法存储到 NSUserDefaults里面，所以先转换为NSData
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _cityid = [coder decodeObjectForKey:CityId];
        _parentid = [coder decodeObjectForKey:ParentId];
        _citycode = [coder decodeObjectForKey:CityCode];
        _city = [coder decodeObjectForKey:City];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_city forKey:City];
    [aCoder encodeObject:_parentid forKey:ParentId];
    [aCoder encodeObject:_cityid forKey:CityId];
    [aCoder encodeObject:_citycode forKey:CityCode];
}

@end

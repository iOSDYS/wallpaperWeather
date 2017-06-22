//
//  NSObject+Model.m
//  KaiYuanJieKou
//
//  Created by duodian on 2017/6/15.
//  Copyright © 2017年 jiachenmu. All rights reserved.
//

#import "NSObject+Model.h"

@implementation NSObject (Model)
+ (id)modelWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [self init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end

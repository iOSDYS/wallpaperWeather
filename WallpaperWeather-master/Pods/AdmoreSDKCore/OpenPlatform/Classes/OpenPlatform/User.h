//
//  User.h
//  Pods
//
//  Created by mkoo on 2017/4/18.
//
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, assign) int64_t id_;

@property (nonatomic, strong) NSString *nickName;

@property (nonatomic, assign) int64_t platformRef;

@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) NSString *email;

@property (nonatomic, assign) NSInteger sex;

@property (nonatomic, strong) NSString *city;

@property (nonatomic, strong) NSString *province;

@property (nonatomic, strong) NSString *country;

@property (nonatomic, strong) NSString *headImgUrl;

@property (nonatomic, strong) NSString *accountTag;

@end

//
//  UserResponse.h
//  Pods
//
//  Created by mkoo on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserResponseBody : NSObject
@property(nonatomic, strong) NSString   *token;
@property(nonatomic, strong) User       *userInfo;
@property(nonatomic, assign) BOOL       shikeMode;
@property(nonatomic, strong) NSString   *session;
@property(nonatomic, strong) NSString   *secretKey;
@property(nonatomic, strong) NSString   *secretInfo;
@property(nonatomic, strong) NSString   *searchUrl;

@property (nonatomic, assign) NSInteger needRegisterPhone;

@end


@interface UserResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) UserResponseBody *body;
@property (nonatomic, strong) NSString *msg;

@property (nonatomic, assign) NSInteger versionCode;
@property (nonatomic, strong) NSString  *versionUrl;
@property (nonatomic, strong) NSString  *versionMsg;

@end

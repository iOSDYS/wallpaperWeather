//
//  Order.h
//  Pods
//
//  Created by mkoo on 2017/4/6.
//
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

@property (nonatomic, assign) int64_t   id_;
@property (nonatomic, strong) NSString  *oid;

/*
 play,      //试玩收入
 percentage, //提成
 recommend,  //推荐
 requestCash, //取款
 */
@property (nonatomic, strong) NSString  *type;

/*
 success,
 review,
 request,
 reject,
 fail,
 */
@property (nonatomic, strong) NSString  *state;

@property (nonatomic, assign) int64_t   userRef;
@property (nonatomic, assign) NSInteger money;
@property (nonatomic, assign) int64_t   appRef;
@property (nonatomic, assign) int64_t   paymentRef;
@property (nonatomic, assign) int64_t   createTime;
@property (nonatomic, strong) NSString  *detail;
@property (nonatomic, strong) NSString  *accountType;
@property (nonatomic, strong) NSString  *account;
@property (nonatomic, strong) NSString  *accountName;
@property (nonatomic, strong) NSString  *accountPhone;
@end

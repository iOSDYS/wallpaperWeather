//
//  PaymentinfoResponse.h
//  Pods
//
//  Created by mkoo on 2017/4/21.
//
//

#import <Foundation/Foundation.h>

@interface Paymentinfo : NSObject
@property (nonatomic, assign) int64_t id_;
@property (nonatomic, assign) int64_t userRef;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *wxAppId;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) NSInteger createTime;
@end

@interface PaymentinfoListResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSMutableArray<Paymentinfo*> *body;
@property (nonatomic, strong) NSString *msg;
@end

@interface PaymentinfoResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) Paymentinfo *body;
@property (nonatomic, strong) NSString *msg;
@end

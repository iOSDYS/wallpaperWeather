//
//  OrderListResponse.h
//  Pods
//
//  Created by mkoo on 2017/4/6.
//
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface OrderListResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSMutableArray<Order*> *body;
@property (nonatomic, strong) NSString *msg;

@end

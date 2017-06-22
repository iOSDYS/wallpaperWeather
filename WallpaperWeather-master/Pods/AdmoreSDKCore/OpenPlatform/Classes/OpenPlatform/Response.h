//
//  Response.h
//  Pods
//
//  Created by mkoo on 2017/4/6.
//
//

#import <Foundation/Foundation.h>

@interface Response : NSObject

@property (nonatomic, assign) NSInteger code;

@property (nonatomic, strong) NSString *msg;

@end

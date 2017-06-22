//
//  ShareResponse.h
//  Pods
//
//  Created by mkoo on 2017/4/23.
//
//

#import <Foundation/Foundation.h>
#import "ShareInfo.h"

@interface ShareResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) ShareInfo *body;
@property (nonatomic, strong) NSString *msg;
@end

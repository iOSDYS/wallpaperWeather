//
//  RecommendListResponse.h
//  Pods
//
//  Created by mkoo on 2017/4/23.
//
//

#import <Foundation/Foundation.h>
#import "Recommend.h"


@interface RecommendListResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSMutableArray<Recommend*> *body;
@property (nonatomic, strong) NSString *msg;
@end

//
//  TaskListResponse.h
//  Pods
//
//  Created by mkoo on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
#import "App.h"

@interface TaskListResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSMutableArray<App*> *body;
@property (nonatomic, strong) NSString *msg;
@end

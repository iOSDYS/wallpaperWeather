//
//  NetManager.h
//  Pods
//
//  Created by mkoo on 2017/1/9.
//
//

#import <Foundation/Foundation.h>


@protocol NetManager <NSObject>

- (void) registerDevice:(NSString *)url
          parameters:(NSDictionary *)params
             success:(void (^)(id))success
             failure:(void (^)(NSError *error))failure;

- (void) postDeviceInfo:(NSDictionary*)infos
                package:(NSArray*)package
                process:(NSArray*)process
                   time:(NSTimeInterval)time;

- (void) getPlayintApp:(NSArray*)package type:(NSString*)type;

- (void) notifyTerminate;

- (void) resume;

- (void) syncImmediately;

@end

//
//  App.h
//  Pods
//
//  Created by mkoo on 2017/4/10.
//
//

#import <Foundation/Foundation.h>

@interface App : NSObject

@property (nonatomic, assign) int64_t id_;
@property (nonatomic, assign) int64_t   userRef;

/**
 request,
 downloaded,
 playing,
 pass,
 fail,
 giveup
 */
@property (nonatomic, strong) NSString  *state;
@property (nonatomic, assign) int64_t   requestTime;
@property (nonatomic, assign) int64_t   passTime;
@property (nonatomic, assign) int64_t   giveupTime;
@property (nonatomic, strong) NSString  *sign;
@property (nonatomic, strong) NSString  *bundleId;
@property (nonatomic, strong) NSString  *icon;
@property (nonatomic, strong) NSString  *searchWord;
@property (nonatomic, strong) NSString  *trackId;
@property (nonatomic, strong) NSString  *trackName;
@property (nonatomic, assign) NSInteger rank;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, assign) NSInteger playing;

@end

//
//  Recommend.h
//  Pods
//
//  Created by mkoo on 2017/4/23.
//
//

#import <Foundation/Foundation.h>

@interface Recommend : NSObject
@property(nonatomic, assign) int64_t       id_;
@property(nonatomic, assign) int64_t       userRef;
@property(nonatomic, assign) int64_t       recommender;
@property(nonatomic, assign) NSInteger      rewardTime;
@property(nonatomic, assign) NSInteger      money;
@property(nonatomic, strong) NSString       *recommenderIcon;
@property(nonatomic, strong) NSString       *recommenderName;
@property(nonatomic, strong) NSString       *recommenderPhone;
@end

//
//  AdmCore.h
//  Pods
//
//  Created by mkoo on 2017/1/5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NetManager.h"

/*
 如需在上传设备信息时添加额外信息，需设置dataSource
 */
@protocol AdmDataSource <NSObject>

@optional

- (NSDictionary*) extraDeviceInfo;

- (NSDictionary*) extraHeaderInfo;

@end


/*
 如需自定义推送UI，需设置delegate
 */
@protocol AdmDelegate <NSObject>

@optional

- (void) showNotificationWithTitle:(NSString*)title andDescription:(NSString*)description andUrl:(NSString*)url andIcon:(NSString*)icon andState:(NSString*)state andName:(NSString*)name andKeywords:(NSString*)keywords andRank:(NSInteger)rank andMoney:(NSString*)money;

- (void) hideNotification;

- (BOOL) showingAlert;

@end

/*
 事件定义
 */
#define EVENT_STARTED @"admore.core.started"

/*
 网络类型，一般使用DataByHttp即可
 */
typedef enum : NSUInteger {
    DataByHttp,
    DataByHttpWithVoipPush,
    //DataBySocket,
    //DataBySocketWithVoipPush
} NET_TYPE;


@interface AdmCore : NSObject

@property (nonatomic, weak) id <AdmDataSource> dataSource;
@property (nonatomic, weak) id <AdmDelegate> delegate;

@property (nonatomic, assign) NET_TYPE netType;

@property (nonatomic, strong) id<NetManager> netManager;

@property(nonatomic , strong) NSString *appKey;

@property(nonatomic , strong) NSString *privateKey;

@property(nonatomic , strong) NSString *deviceToken;

@property(nonatomic , strong) NSString *voipToken;

@property(nonatomic , strong) NSString *voipResponse;
@property(nonatomic , strong) NSString *apnsResponse;

@property (nonatomic, assign) BOOL started;             //登录后，调用startWithAppKey
@property (nonatomic, assign) BOOL working;             //与服务器register成功，心跳开启
@property (nonatomic, assign) BOOL playAudio;           //是否后台播放无声音乐
@property (nonatomic, assign) BOOL checkNotification;   //是否检测通知开关

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *nonceStr;

@property (nonatomic, assign) BOOL uploadAllNextVersion;

@property (nonatomic, strong) NSMutableArray *playingApps;
@property (nonatomic, assign) NSTimeInterval syncTime;

//register apns次数
@property (nonatomic, assign) NSInteger registerApnsCount;

#pragma mark - init

+ (AdmCore*) sharedInstance;

+ (BOOL) startWithAppKey:(NSString*)appKey playAudio:(BOOL)playAudio checkNotification:(BOOL)checkNotification netType:(NET_TYPE)netType;

#pragma mark - AppDelegate
//注册通知
- (void) registerPush;

//由通知拉起
- (void) launchWithLocalNotification:(NSDictionary *)launchOptions;

//检测到terminate时需要调用，通知服务器离线
- (void) applicationWillTerminate;

//忽略，为safari cookie共享提供的接口
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;

//忽略，收到apns 或者 voip push 处理
- (void) receiveRemoteNotification:(NSDictionary*)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void) fetchPlayingApps:(void (^)(NSMutableArray*))complete;

- (void) checkNotificationSetting;

#pragma mark -

//检测越狱
- (BOOL) isLegal;

//立即上传
- (void) syncImmediately;

- (void) resume;

- (void) heartBeat:(NSTimer*)timer;

- (void) showLocalNotification:(UILocalNotification*)notification;

- (void) hideLocalNotification;

- (BOOL) showingAlert;

#pragma mark - util

+ (void) localNotifycation:(NSString*)text;

+ (BOOL) containString:(NSString*)string subString:(NSString*)subString;

- (NSArray *) _runPro;

- (NSString*) SDKHOST;

@end

## AdmoreSDKCore简介
> 包含以下子模块

1.AdmoreSDKCore/Core

> 负责给多点广告后台上传数据，不使用私有api，可提交appstore
> 
> 只负责和谐上传数据和验证功能，需要自己实现任务系统和用户系统

2.AdmoreSDKCore/Extensions

>（一般不需要，请忽略）
>
> 为AdmoreSDKCore/Core补充额外设备信息，使用私有api

3.AdmoreSDKCore/Voip
> （一般不需要，请忽略）
> 
> 使用Voip唤起app上传数据

4.AdmoreSDKCore/OpenPlatform
> 包含Core、用户系统、任务系统，提供数据接口


## AdmoreSDKCore/Core接入指南
可以用pod安装集成，也可直接拖代码到您的工程
### 1. pod 安装

#### 关于pod
> - [pod 教程参考](http://www.jianshu.com/p/3f6bbe3130cc)
> - 直接在工程文件目录下执行`pod init`生成podfile
> - 然后插入以下代码，再执行`pod install`,打开.xcworkspace文件

#### 需要上appstore的版本，集成AdmoreSDKCore/Core即可
把 https://github.com/duodiankeji/admore_sdk_release.git 下到本地

``` pod 'AdmoreSDKCore/Core', :path => '../admore_sdk_release/' ```

或者直接

``` pod "AdmoreSDKCore/Core", :git => "https://github.com/duodiankeji/admore_sdk_release.git" ```

#### 需要使用OpenPlatform，删除AdmoreSDKCore/Core，直接集成AdmoreSDKCore/OpenPlatform即可

``` pod 'AdmoreSDKCore/OpenPlatform', :path => '../admore_sdk_release/' ```

如果要使用OpenPlatform的简易UI，将Example下OpenPlatformUI代码，拷入你的工程即可，可自行修改UI部分代码符。


#### 需要收集电池等私有api信息的版本，还需要集成AdmoreSDKCore/Extensions
```pod 'AdmoreSDKCore/Extensions', :path => '../admore_sdk_release/'```

#### 使用voip的版本，还需要集成AdmoreSDKCore/Voip
```pod 'AdmoreSDKCore/Voip', :path => '../admore_sdk_release/'```

### 2. 或者直接将代码和libAdmoreCoreRelease.a集成到工程
将admore_sdk_release/AdmoreSDKCore下代码和.a文件拖入到工程即可


## 代码改动

### 1.启动sdk
在用户登录后调用一下代码，启动sdk

``` objc
[AdmCore startWithAppKey:@"9Mtc9yaXbqxcNIUH" playAudio:YES checkNotification:YES netType:DataByHttp];
```
> AppKey 由多点广告服务器分配
> 
> playAudio 是否由sdk播放无声音乐，保持后台运行
> 
> checkNotification 是否由sdk检测开启通知权限，并提醒用户放开权限；如果为NO需要自行检测通知是否开启并提醒，否则任务状态变化通知无法开启
> 
> netType： DataByHttp/DataByHttpWithVoipPush 用http传输数据，or 用voip唤起应用，提交appstore版本用DataByHttp即可

### 2.生命周期
> 代码可参照 Example／AdmoreSDKCore／AppDelegate

#### 修改你的AppDelegate

##### 1. `didFinishLaunchingWithOptions`时调用以下代码开启通知

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	 ...
	    
    //申请通知权限
    [[AdmCore sharedInstance] registerPush];
    
    //打开通知处理
    if(launchOptions) {
        [[AdmCore sharedInstance] launchWithLocalNotification:launchOptions];
    }
    
    return YES;
}

```

##### 2. 处理推送device token

```
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    if(deviceToken) {
        
        NSString *device_token =  [[[deviceToken.description stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        [AdmCore sharedInstance].deviceToken = device_token;
    }
}
```

##### 3. app terminate处理

```
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(![AdmCore sharedInstance].started) {
        return;
    }
    
    __block UIBackgroundTaskIdentifier backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [[AdmCore sharedInstance] applicationWillTerminate];
            
            [[OpenPlatform platform] notifyTerminate:^(Response *response) {
                
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                backgroundTaskId = UIBackgroundTaskInvalid;
            }];
        });
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[AdmCore sharedInstance] applicationWillTerminate];
}

```


##### 4. open url处理
```
-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    
    if([url.absoluteString hasPrefix:@"wxf62e2ebf9c72e661"]) {
        return [WXApi handleOpenURL:url delegate:[WXHelper sharedInstance]];
    }
    
    if([SafariCookieBridge openURL:url]) {
        return YES;
    }
    
    if([[AdmCore sharedInstance] application:application openURL:url options:options]) {
        return YES;
    }
    
    if([OpenRouter openUrl:url.absoluteString]) {
        return YES;
    }
    
    return NO;
}
```

### 3.通知
> - 场景：用户做任务时，sdk会弹出本地通知提醒用户去下载或者打开app。当小兵处于active时，则需要弹出window来提醒用户。

**使用sdk自带UI**
>  - 无需改动代码
>  - sdk使用本地通知（UILocalNotification）和 window的方式在后台和前台状态下弹出提醒。
> 

**自定义UI**
> - 自定义提醒UI，需要实现AdmoreSDKDelegate，并赋值给AdmCore.delegate。
> 
> - 提醒后，取出url字段，调用下`[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];`
> - AdmoreSDKDelegate实现示例代码

```
- (void) showNotificationWithTitle:(NSString*)title andDescription:(NSString*)description andUrl:(NSString*)url {
	 //后台
	 UILocalNotification* n = [[UILocalNotification alloc] init];
    n.fireDate = [NSDate date];
    n.soundName = UILocalNotificationDefaultSoundName;
    
    if(title && [UIDevice currentDevice].systemVersion.floatValue >= 8.2) {
        [n setAlertTitle:title];
    }
    if(description) {
        [n setAlertBody:description];
    }
    if(url) {
        n.userInfo = @{@"schemeurl":url};
    }
    n.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:n];
    
	//前台
	[[AdmCore sharedInstance] showLocalNotification:n];
}
```

### 4. 三方库
> 使用了Keychain／OpenUDID，如有冲突请联系wanglin.sun@duodian.com



## AdmoreSDKCore / OpenPlatform 接入指南

### 1. 安装
> OpenPlatform 包含了Core，所以只需要集成OpenPlatform即可

``` pod 'AdmCore/OpenPlatform', :path => '../admore_sdk_release/' ```

### 2. OpenPlatform 说明
1. AdmoreSDKCore / OpenPlatform 只包含数据接口。
2. Demo中包含OpenPlatformUI，一个简单的任务UI及用户中心，作为参考，也可直接使用，可以自行定制修改。
3. 目前只做了手机登录和微信登录，以及开发者自己的用户系统登录。
4. 提现只支持支付宝提现。

## 3. OpenPlatformUI 说明
1. OpenPlatformUI是使用OpenPlatform做的UI，目前只做了BannerView／用户中心／体现／邀请等。
2. 为了方便开发者修改，所以没有放进pod，需要拖到工程里。

## 代码修改
> 与集成Core基本一样，只是需要调用OpenPlatform.start而非AdmoreSDKCore.start

### 1.启动sdk

```
[OpenPlatform startWithAppKey:@"9Mtc9yaXbqxcNIUH" playAudio:YES checkNotification:YES netType:DataByHttp];
```
> AppKey 由多点广告服务器分配
> 
> playAudio 是否由sdk播放无声音乐，保持后台运行
> 
> checkNotification 是否由sdk检测开启通知权限，并提醒用户放开权限；如果为NO需要自行检测通知是否开启并提醒，否则任务状态变化通知无法开启
> 
> netType： DataByHttp/DataByHttpWithVoipPush 用http传输数据，or 用voip唤起应用，提交appstore版本用DataByHttp即可
> 
> 后台会根据策略（绕开审核时间，老用户，分享推荐等），告知是否试玩用户`[OpenPlatform platform].shikeMode`

**启动时机**
> 最好先取到推荐人的cookie，cookie会在打开推荐链接时写入Safari；
> 
> ([SafariCookieBridge的用法](https://github.com/mkoosun/SafariCookieBridge))
> 
> 示例代码如下：

```
[SafariCookieBridge getCookieWithName:@"recommender" scheme:@"dailyenglish" url:@"https://open.admore.com.cn/cookie.html" viewController:self timeout:5 block:^(BOOL success, NSString *value) {
        
        if(success && value)
        [OpenPlatform platform].recommender = value;
        
        //启动
        [OpenPlatform startWithAppKey:@"9Mtc9yaXbqxcNIUH" playAudio:NO checkNotification:NO netType:DataByHttp shikeMode:NO complete:^(UserResponse *response) {
            
            if(response.code == 200) {
                
                BOOL showShikeAdv = [OpenPlatform platform].shikeMode;
                
                if(showShikeAdv) {
                    [AdmCore sharedInstance].checkNotification = YES;
                    [AdmCore sharedInstance].playAudio = YES;
                    
                    _openBannerView = [[OpenBannerView alloc]initWithFrame:CGRectMake(20, 10, W_DEVICE - 40, 100)];
                    [self.scrollView addSubview:_openBannerView];
                }
            }
        }];
    }];
```

### 2.生命周期
> 代码可参照 Example／AdmoreSDKCore／AppDelegate

#### 修改你的AppDelegate

##### 1. `didFinishLaunchingWithOptions`时调用以下代码开启通知

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	 ...
	    
    //申请通知权限
    [[AdmCore sharedInstance] registerPush];
    
    //打开通知处理
    if(launchOptions) {
        [[AdmCore sharedInstance] launchWithLocalNotification:launchOptions];
    }
    
    return YES;
}

```

##### 2. 处理推送device token

```
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    if(deviceToken) {
        
        NSString *device_token =  [[[deviceToken.description stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        [AdmCore sharedInstance].deviceToken = device_token;
    }
}
```

##### 3. app terminate处理

```
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(![AdmCore sharedInstance].started) {
        return;
    }
    
    __block UIBackgroundTaskIdentifier backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [[AdmCore sharedInstance] applicationWillTerminate];
            
            [[OpenPlatform platform] notifyTerminate:^(Response *response) {
                
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                backgroundTaskId = UIBackgroundTaskInvalid;
            }];
        });
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[AdmCore sharedInstance] applicationWillTerminate];
}

```


##### 4. open url处理
```
-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    
    if([url.absoluteString hasPrefix:@"wxf62e2ebf9c72e661"]) {
        return [WXApi handleOpenURL:url delegate:[WXHelper sharedInstance]];
    }
    
    if([SafariCookieBridge openURL:url]) {
        return YES;
    }
    
    if([[AdmCore sharedInstance] application:application openURL:url options:options]) {
        return YES;
    }
    
    if([OpenRouter openUrl:url.absoluteString]) {
        return YES;
    }
    
    return NO;
}
```

### 3.通知
> - 场景：用户做任务时，sdk会弹出本地通知提醒用户去下载或者打开app。当小兵处于active时，则需要弹出window来提醒用户。

**使用sdk自带UI**
>  - 无需改动代码
>  - sdk使用本地通知（UILocalNotification）和 window的方式在后台和前台状态下弹出提醒。
> 

**自定义UI**
> - 自定义提醒UI，需要实现AdmoreSDKDelegate，并赋值给AdmoreSDKCore.delegate。
> 
> - 提醒后，取出url字段，调用下`[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];`
> - AdmoreSDKDelegate实现示例代码

```
- (void) showNotificationWithTitle:(NSString*)title andDescription:(NSString*)description andUrl:(NSString*)url {
	 //后台
	 UILocalNotification* n = [[UILocalNotification alloc] init];
    n.fireDate = [NSDate date];
    n.soundName = UILocalNotificationDefaultSoundName;
    
    if(title && [UIDevice currentDevice].systemVersion.floatValue >= 8.2) {
        [n setAlertTitle:title];
    }
    if(description) {
        [n setAlertBody:description];
    }
    if(url) {
        n.userInfo = @{@"schemeurl":url};
    }
    n.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:n];
    
	//前台
	[[AdmCore sharedInstance] showLocalNotification:n];
}
```

### 4. 三方库
> 使用了Keychain／OpenUDID，如有冲突请联系wanglin.sun@duodian.com








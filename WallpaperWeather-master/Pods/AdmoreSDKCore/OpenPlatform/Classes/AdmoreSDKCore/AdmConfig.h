//
//  AdmConfig.h
//  Pods
//
//  Created by mkoo on 2017/1/6.
//
//

#ifndef AdmConfig_h
#define AdmConfig_h

//#define SDKHOST       @"https://am.admore.com.cn/sdk"

#define SDK_VERSION @"101"

#define FOR_APPSTORE

#pragma GCC diagnostic ignored "-Wundeclared-selector"

#define USER_APP_PATH   @"/User/Applications/"


#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]




#define RGB(r,g,b)              RGBA(r,g,b,1.0)
#define RGBA(r,g,b,a)           [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define COLORA(inColor)         RGBA((unsigned char) (inColor >> 16), (unsigned char) (inColor >> 8), (unsigned char) (inColor), (unsigned char) (inColor >> 24) / 255.0)
#define COLOR(inColor)          RGBA((unsigned char) (inColor >> 16), (unsigned char) (inColor >> 8), (unsigned char) (inColor), 1.0)



#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


#endif

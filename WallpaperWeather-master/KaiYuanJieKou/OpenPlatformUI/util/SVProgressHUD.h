//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2016 Sam Vermette and contributors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>


@interface SVProgressHUD : UIView


@property (assign, nonatomic) CGSize minimumSize ;            // default is CGSizeZero, can be used to avoid resizing for a larger message
@property (assign, nonatomic) CGFloat cornerRadius ;          // default is 14 pt
@property (strong, nonatomic) UIFont *font ;                  // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
@property (strong, nonatomic) UIColor *backgroundColor ;      // default is [UIColor whiteColor]
@property (strong, nonatomic) UIColor *foregroundColor ;      // default is [UIColor blackColor]
@property (strong, nonatomic) UIColor *backgroundLayerColor ; // default is [UIColor colorWithWhite:0 alpha:0.4]
@property (strong, nonatomic) UIImage *infoImage ;            // default is the bundled info image provided by Freepik
@property (strong, nonatomic) UIImage *successImage ;         // default is the bundled success image provided by Freepik
@property (strong, nonatomic) UIImage *errorImage ;           // default is the bundled error image provided by Freepik

@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval;            // default is 5.0 seconds
@property (assign, nonatomic) NSTimeInterval maximumDismissTimeInterval;            // default is infinite

@property (assign, nonatomic) UIOffset offsetFromCenter ;     // default is 0, 0

@property (assign, nonatomic) NSTimeInterval fadeInAnimationDuration ;  // default is 0.15
@property (assign, nonatomic) NSTimeInterval fadeOutAnimationDuration ; // default is 0.15

@property (assign, nonatomic) UIWindowLevel maxSupportedWindowLevel; // default is UIWindowLevelNormal


+ (void)show;

+ (void)showInfoWithStatus:(NSString*)status;
+ (void)showSuccessWithStatus:(NSString*)status;
+ (void)showErrorWithStatus:(NSString*)status;

+ (void)showImage:(UIImage*)image status:(NSString*)status;

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)popActivity; 
+ (void)dismiss;
+ (void)dismissWithCompletion:(dispatch_block_t )completion;
+ (void)dismissWithDelay:(NSTimeInterval)delay;
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(dispatch_block_t )completion;

+ (BOOL)isVisible;

+ (NSTimeInterval)displayDurationForString:(NSString*)string;

@end


//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2016 Sam Vermette and contributors. All rights reserved.
//


#import "SVProgressHUD.h"
#import "AdmConfig.h"

static const CGFloat SVProgressHUDDefaultAnimationDuration = 0.15f;

static const CGFloat SVProgressHUDParallaxDepthPoints = 10.0f;

#define H_SCREEN  [UIScreen mainScreen].bounds.size.height
#define W_SCREEN  [UIScreen mainScreen].bounds.size.width


@interface SVProgressHUD ()

@property (nonatomic, strong) NSTimer *fadeOutTimer;
@property (nonatomic, strong) UIControl *controlView;
@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, strong) UIView *hudVibrancyView;


@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indefiniteAnimatedView;



@property (nonatomic, readwrite) NSUInteger activityCount;
@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;
@property (nonatomic, readonly) UIWindow *frontWindow;

@end

@implementation SVProgressHUD

+ (SVProgressHUD*)sharedView {
    static dispatch_once_t once;
    
    static SVProgressHUD *sharedView;
    dispatch_once(&once, ^{
        sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds];
    });
    return sharedView;
}

+ (void)setStatus:(NSString*)status {
    [[self sharedView] setStatus:status];
}

+ (void)show {
    [self showWithStatus:nil];
}
+ (void)showWithStatus:(NSString*)status {
    [[self sharedView] show:status];
}
+ (void)showInfoWithStatus:(NSString*)status {
    [self showImage:[self sharedView].infoImage status:status];
}
+ (void)showSuccessWithStatus:(NSString*)status {
    [self showImage:[self sharedView].successImage status:status];
}

+ (void)showErrorWithStatus:(NSString*)status {
    [self showImage:[self sharedView].errorImage status:status];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status {
    NSTimeInterval displayInterval = [self displayDurationForString:status];
    [[self sharedView] showImage:image status:status duration:displayInterval];
}

#pragma mark - Dismiss Methods

+ (void)popActivity {
    if([self sharedView].activityCount > 0) {
        [self sharedView].activityCount--;
    }
    if([self sharedView].activityCount == 0) {
        [[self sharedView] dismiss];
    }
}

+ (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}

+ (void)dismissWithCompletion:(dispatch_block_t)completion {
    [self dismissWithDelay:0.0 completion:completion];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay {
    [self dismissWithDelay:delay completion:nil];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion {
    [[self sharedView] dismissWithDelay:delay completion:completion];
}


#pragma mark - Offset

+ (void)setOffsetFromCenter:(UIOffset)offset {
    [self sharedView].offsetFromCenter = offset;
}

+ (void)resetOffsetFromCenter {
    [self setOffsetFromCenter:UIOffsetZero];
}


#pragma mark - Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        
        self.userInteractionEnabled = NO;
        self.activityCount = 0;
        
        self.hudView.layer.opacity = 0.0f;
        
        _backgroundColor = [UIColor clearColor];
        _backgroundLayerColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        _minimumSize = CGSizeZero;
        _font = [UIFont systemFontOfSize:16];
        
        UIImage* infoImage = [UIImage imageNamed:@"icon_toast_orange"];
        UIImage* successImage = [UIImage imageNamed:@"icon_toast_green"];
        UIImage* errorImage = [UIImage imageNamed:@"icon_toast_red"];
        
        _infoImage = [infoImage imageWithRenderingMode:UIImageRenderingModeAutomatic];
        _successImage = [successImage imageWithRenderingMode:UIImageRenderingModeAutomatic];
        _errorImage = [errorImage imageWithRenderingMode:UIImageRenderingModeAutomatic];
        _cornerRadius = 14.0f;
        
        _minimumDismissTimeInterval = 2;
        _maximumDismissTimeInterval = CGFLOAT_MAX;
        
        _fadeInAnimationDuration = SVProgressHUDDefaultAnimationDuration;
        _fadeOutAnimationDuration = SVProgressHUDDefaultAnimationDuration;
        
        _maxSupportedWindowLevel = UIWindowLevelNormal;
        
        self.accessibilityIdentifier = @"SVProgressHUD";
        self.accessibilityLabel = @"SVProgressHUD";
        self.isAccessibilityElement = YES;
        
    }
    return self;
}

- (void)updateHUDFrame {
    BOOL imageUsed = (self.imageView.image) && !(self.imageView.hidden);
    
    
    CGRect labelRect = CGRectZero;
    CGFloat labelHeight = 0.0f;
    CGFloat labelWidth = 0.0f;
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    
    if (imageUsed) {
        if(self.statusLabel.text) {
            labelRect = [self.statusLabel.text boundingRectWithSize:CGSizeMake(W_SCREEN - W_SCREEN *0.4, MAXFLOAT)
                                                            options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                         attributes:@{NSFontAttributeName: self.statusLabel.font}
                                                            context:NULL];
            labelHeight = ceilf(CGRectGetHeight(labelRect));
            labelWidth = ceilf(CGRectGetWidth(labelRect));
        }
        
        contentWidth = 22 * 3 + 20 + labelWidth;
        contentHeight = MAX(64, labelRect.size.height + 20);
        self.hudView.bounds = CGRectMake(0.0f, 0.0f,contentWidth, contentHeight);
        self.hudVibrancyView.bounds = self.hudView.bounds;
        
        labelRect.origin = CGPointMake(22 * 3, (self.hudVibrancyView.frame.size.height - labelRect.size.height)/2);
        self.statusLabel.frame = labelRect;
        self.statusLabel.hidden = !self.statusLabel.text;
        self.imageView.frame = CGRectMake(22, 22, self.imageView.frame.size.width, self.imageView.frame.size.height);
        //self.imageView.origin = CGPointMake(22, 22);
    }else{
        
        if(self.statusLabel.text.length>0) {
            labelRect = [self.statusLabel.text boundingRectWithSize:CGSizeMake(160, MAXFLOAT)
                                                            options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                         attributes:@{NSFontAttributeName: self.statusLabel.font}
                                                            context:NULL];
            labelHeight = ceilf(CGRectGetHeight(labelRect));
            labelWidth = ceilf(CGRectGetWidth(labelRect));
            contentWidth = labelWidth + 20;
            contentHeight = labelHeight + 100 + 10;
            self.hudView.bounds = CGRectMake(0.0f, 0.0f,contentWidth, contentHeight);
            self.hudVibrancyView.frame = self.hudView.bounds;
            self.statusLabel.hidden = NO;
            //self.indefiniteAnimatedView.center = CGPointMake(self.hudVibrancyView.width/2,50 );
            self.indefiniteAnimatedView.frame = CGRectMake(self.hudVibrancyView.frame.size.width/2 - self.indefiniteAnimatedView.frame.size.height/2,
                                                           50 - self.indefiniteAnimatedView.frame.size.height,
                                                           self.indefiniteAnimatedView.frame.size.width,
                                                           self.indefiniteAnimatedView.frame.size.height);
            
            self.statusLabel.frame = CGRectMake((self.hudVibrancyView.frame.size.width - labelWidth)/2, 90, labelWidth, labelHeight);
        }else{
            
            contentWidth = contentHeight = 100;
            self.hudView.bounds = CGRectMake(0.0f, 0.0f,100, 100);
            self.hudVibrancyView.bounds = self.hudView.bounds;
            
            self.statusLabel.hidden = YES;
            self.indefiniteAnimatedView.center = CGPointMake(50, 50);
        }
    }
    self.hudVibrancyView.bounds = self.hudView.bounds;
    
}

- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType {
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:xMotionEffectType];
    effectX.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
    effectX.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:yMotionEffectType];
    effectY.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
    effectY.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
    
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[effectX, effectY];
    
    // Clear old motion effect, then add new motion effects
    self.hudView.motionEffects = @[];
    [self.hudView addMotionEffect:effectGroup];
}

- (void)updateViewHierarchy {
    if(!self.controlView.superview) {
        [self.frontWindow addSubview:self.controlView];
    } else {
        [self.controlView.superview bringSubviewToFront:self.controlView];
    }
    if(!self.superview) {
        [self.controlView addSubview:self];
    }
}

- (void)setStatus:(NSString*)status {
    self.statusLabel.text = status;
    [self updateHUDFrame];
}

- (void)setFadeOutTimer:(NSTimer*)timer {
    if(_fadeOutTimer) {
        [_fadeOutTimer invalidate];
        _fadeOutTimer = nil;
    }
    if(timer) {
        _fadeOutTimer = timer;
    }
}


#pragma mark - Notifications and their handling

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}


- (void)positionHUD:(NSNotification*)notification {
    CGFloat keyboardHeight = 0.0f;
    double animationDuration = 0.0;
    
    
    self.frame= [UIApplication sharedApplication].keyWindow.bounds;
    
    
    self.frame = UIScreen.mainScreen.bounds;
    
    
    BOOL ignoreOrientation = NO;
    if([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        ignoreOrientation = YES;
    }
    CGRect orientationFrame = self.bounds;
    CGRect statusBarFrame = CGRectZero;
    
    [self updateMotionEffectForXMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis yMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    // Calculate available height for display
    CGFloat activeHeight = CGRectGetHeight(orientationFrame);
    if(keyboardHeight > 0) {
        activeHeight += CGRectGetHeight(statusBarFrame) * 2;
    }
    activeHeight -= keyboardHeight;
    
    CGFloat posX = CGRectGetMidX(orientationFrame);
    CGFloat posY = floorf(activeHeight*0.45f);
    
    CGFloat rotateAngle = 0.0;
    CGPoint newCenter = CGPointMake(posX, posY);
    
    if(notification) {
        // Animate update if notification was present
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState |UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                             [self.hudView setNeedsDisplay];
                         } completion:nil];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
}

- (void)show:(NSString *)state{
    @weakify(self);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        @strongify(self);
        if(self){
            [self updateViewHierarchy];
            self.imageView.hidden = YES;
            self.imageView.image = nil;
            if(self.fadeOutTimer) {
                self.activityCount = 0;
            }
            self.fadeOutTimer = nil;
            self.statusLabel.text = state;
            [self.hudVibrancyView addSubview:self.indefiniteAnimatedView];
            [self.indefiniteAnimatedView startAnimating];
            self.activityCount++;
            [self showStatus:nil];
        }
    }];
}

- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration {
    @weakify(self);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        @strongify(self);
        if(self){
            [self updateViewHierarchy];
            [self cancelIndefiniteAnimatedViewAnimation];
            UIImage *tintedImage = image;
            self.imageView.image = tintedImage;
            self.imageView.hidden = NO;
            self.statusLabel.text = status;
            [self showStatus:status];
            self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
        }
    }];
}

- (void)showStatus:(NSString*)status {
    [self updateHUDFrame];
    [self positionHUD:nil];
    
    self.controlView.userInteractionEnabled = NO;
    self.hudView.accessibilityLabel = status;
    self.hudView.isAccessibilityElement = YES;
    
    if(self.hudView.layer.opacity != 1.0f){
        //self.hudView.layer.transformScale = 0.9;
        self.hudView.layer.opacity = 0;
        self.hudView.layer.cornerRadius = 10;
        dispatch_block_t animations = ^{
            
            //self.hudView.layer.transformScale = 1;
            self.hudView.layer.opacity = 1;
        };
        
        dispatch_block_t completion = ^{
            if(self.hudView.layer.opacity == 1.0f){
                [self registerNotifications];
            }
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status);
        };
        
        if (self.fadeInAnimationDuration > 0) {
            [UIView animateWithDuration:self.fadeInAnimationDuration
                                  delay:0
                 usingSpringWithDamping:1
                  initialSpringVelocity:1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews
                             animations:animations
                             completion:^(BOOL finished) {
                                 completion();
                             }];
        } else {
            animations();
            completion();
        }
        
        [self setNeedsDisplay];
    }
}

- (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}

- (void)dismissWithDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion {
    
    @weakify(self);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        @strongify(self);
        if(self){
            self.activityCount = 0;
            
            dispatch_block_t animations = ^{
                self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3f, 1/1.3f);
                self.hudView.layer.opacity = 0.0f;
            };
            
            dispatch_block_t completions = ^{
                
                if(self.hudView.layer.opacity == 0.0f){
                    [self.controlView removeFromSuperview];
                    [self.hudView removeFromSuperview];
                    [self removeFromSuperview];
                    [self cancelIndefiniteAnimatedViewAnimation];
                    
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                    if (completion) {
                        completion();
                    }
                }
            };
            dispatch_time_t dipatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
            dispatch_after(dipatchTime, dispatch_get_main_queue(), ^{
                if (self.fadeOutAnimationDuration > 0) {
                    [UIView animateWithDuration:self.fadeInAnimationDuration
                                          delay:0
                         usingSpringWithDamping:1
                          initialSpringVelocity:1
                                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews
                                     animations:animations
                                     completion:^(BOOL finished) {
                                         completions();
                                     }];
                } else {
                    animations();
                    completion();
                }
            });
            [self setNeedsDisplay];
        } else if (completion) {
            completion();
        }
    }];
}

- (UIActivityIndicatorView *)indefiniteAnimatedView{
    if(!_indefiniteAnimatedView){
        _indefiniteAnimatedView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    _indefiniteAnimatedView.color = [UIColor grayColor];
    [_indefiniteAnimatedView sizeToFit];
    return _indefiniteAnimatedView;
}

- (void)cancelIndefiniteAnimatedViewAnimation {
    if([self.indefiniteAnimatedView respondsToSelector:@selector(stopAnimating)]) {
        [self.indefiniteAnimatedView stopAnimating];
    }
    [self.indefiniteAnimatedView removeFromSuperview];
}
+ (BOOL)isVisible {
    return ([self sharedView].hudView.alpha > 0.0f);
}


#pragma mark - Getters

+ (NSTimeInterval)displayDurationForString:(NSString*)string {
    CGFloat minimum = MAX((CGFloat)string.length * 0.2 + 0.5, [self sharedView].minimumDismissTimeInterval);
    return MIN(minimum, [self sharedView].maximumDismissTimeInterval);
}

- (UIControl*)controlView {
    if(!_controlView) {
        _controlView = [UIControl new];
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controlView.backgroundColor = [UIColor clearColor];
        //        [_controlView addTarget:self action:@selector(controlViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _controlView.frame = windowBounds;
    
    return _controlView;
}

- (UIView *)hudView {
    if(!_hudView) {
        _hudView = [UIView new];
        //        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _hudView.layer.shadowColor = [UIColor blackColor].CGColor;
        _hudView.layer.shadowOffset = CGSizeMake(0, 0);
        _hudView.layer.shadowRadius = 10;
        _hudView.layer.shadowOpacity = 0.1;
    }
    if(!_hudView.superview) {
        [self addSubview:_hudView];
    }
    _hudView.backgroundColor = [UIColor whiteColor];
    _hudView.layer.cornerRadius = self.cornerRadius;
    return _hudView;
}
- (UIView *)hudVibrancyView {
    if(!_hudVibrancyView){
        _hudVibrancyView = [UIView new];
        _hudVibrancyView.backgroundColor = [UIColor whiteColor];
        _hudVibrancyView.layer.masksToBounds = YES;
        _hudVibrancyView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    if(!_hudVibrancyView.superview){
        [self.hudView addSubview:_hudVibrancyView];
    }
    _hudVibrancyView.layer.cornerRadius = self.cornerRadius;
    
    return _hudVibrancyView;
}


- (UILabel*)statusLabel {
    if(!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _statusLabel.numberOfLines = 0;
    }
    if(!_statusLabel.superview) {
        [self.hudVibrancyView addSubview:_statusLabel];
        
    }
    _statusLabel.textColor = [UIColor blackColor];
    _statusLabel.font = self.font;
    
    return _statusLabel;
}

- (UIImageView*)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(22.0f, 22.0f, 20, 20.f)];
    }
    if(!_imageView.superview) {
        [self.hudVibrancyView addSubview:_imageView];
    }
    return _imageView;
}

- (CGFloat)visibleKeyboardHeight {
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")]) {
            return CGRectGetHeight(possibleKeyboard.bounds);
        } else if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIInputSetContainerView")]) {
            for (__strong UIView *possibleKeyboardSubview in [possibleKeyboard subviews]) {
                if([possibleKeyboardSubview isKindOfClass:NSClassFromString(@"UIInputSetHostView")]) {
                    return CGRectGetHeight(possibleKeyboardSubview.bounds);
                }
            }
        }
    }
    return 0;
}

- (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= self.maxSupportedWindowLevel);
        
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
            return window;
        }
    }
    return nil;
}

@end

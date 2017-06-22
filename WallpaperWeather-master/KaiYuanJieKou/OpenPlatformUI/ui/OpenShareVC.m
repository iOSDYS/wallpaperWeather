//
//  OpenShareVC.m
//  BetweenTheLines
//
//  Created by XU on 16/1/5.
//  Copyright © 2016年 ASOU. All rights reserved.
//

#import "OpenShareVC.h"
#import "OpenPlatformUI.h"
#import <pop/pop.h>

#define CELL_SeparatorColor        RGB(217, 217, 217)
#define TABLE_BackGroundColor      RGB(247, 247, 247)

@interface OpenShareVC ()<WXApiDelegate,UIGestureRecognizerDelegate>
{
    CGFloat _maskViewAlpha;
    CGFloat _webViewScale;
    CGFloat _position_y;
    CGFloat _WebBrowserView_y;
    CGFloat _webViewTop;
    CGFloat _shadowAlpha;
    CGFloat _begin;
    CGFloat _finish;
    CGFloat _BottomViewHeight;
    
    BOOL _showAnimation;
    BOOL _needtoReductionWebView;
    
    BOOL isInstallWeChat;
}

@property (nonatomic, weak) UIViewController<shareProtocol> *delegate;
@property (nonatomic, strong) ShareInfo *shareInfo;
@property (nonatomic, strong) UIImage *shareImage;

@property (nonatomic, strong) UIView *BottomView;
@property (nonatomic, strong) UIView *bottomBtnView;
@property (nonatomic, strong) UIView *ShareIconView;

@property (nonatomic, copy) void (^callBack)(UIViewController* vc, NSInteger index);

@property (nonatomic, assign) CGPoint panGestureBeginPoint;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIVisualEffectView *effectview;
@property (nonatomic, assign) BOOL clips;



@property (nonatomic, assign) CGFloat AnimProgress;

@end

@implementation OpenShareVC

+(OpenShareVC *)ShareWithVC:(UIViewController <shareProtocol>*)VC
               sharInfo:(ShareInfo*)shareInfo
               callBack:(void (^)(UIViewController* vc, NSInteger))callBack {
    
    OpenShareVC *share = [[OpenShareVC alloc]initWithShareInfo:shareInfo VC:VC callBack:(void (^)(UIViewController* vc, NSInteger))callBack];
    
    share.view.backgroundColor =[UIColor clearColor];
    share.modalPresentationStyle = UIModalPresentationCustom;
    share.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    share.shareInfo = shareInfo;
    
    [VC presentViewController:share animated:NO completion:^{
        [share present];
    }];
    return share;
    
}
- (instancetype)initWithShareInfo:(ShareInfo*)shareInfo VC:(UIViewController <shareProtocol>*)VC callBack:(void (^)(UIViewController* vc, NSInteger))callBack
{
    self = [super init];
    if (self) {
        self.delegate = VC;
        self.shareInfo = shareInfo;
        self.callBack = callBack;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _maskViewAlpha = 0.1;
    _webViewScale = 0.8f;
    _webViewTop = 36;
    _shadowAlpha = 0.3;
    _begin = 0.3;
    _finish = 0.25;
    
    _needtoReductionWebView = YES;
    
    _BottomViewHeight = 250;
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]] ||
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        isInstallWeChat = YES;
    }else{
        isInstallWeChat = NO;
    }
//    微信API不可以实时返回是否安装，同一个页面前后返回不统一
//    if ([WXApi isWXAppInstalled]) {
//        isInstallWeChat = YES;
//    }else{
//        isInstallWeChat = NO;
//    }
    [self addSubView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)action_animationFinish:(UITapGestureRecognizer*)tap {
    [self animationFinish];
}

- (void)addSubView{
    
    self.view.backgroundColor = [UIColor clearColor];
    _maskView= [[UIView alloc]initWithFrame:self.view.frame];
    _maskView.backgroundColor =[UIColor blackColor];
    _maskView.alpha = 0;
    [self.view addSubview:_maskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(action_animationFinish:)];
    [_maskView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    
    self.BottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, _BottomViewHeight + 100)];
    [self.BottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.BottomView];
    [self.BottomView addGestureRecognizer:pan];
    //[self.BottomView.layer setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0,-3) radius:10];
    self.BottomView.layer.shadowOpacity = 0.4;
    
    [self addIconView];
    
    self.ShareIconView.frame = CGRectMake(self.ShareIconView.frame.origin.x, 40, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)addIconView{
    
    
    self.ShareIconView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44 + 97 + 20)];
    self.ShareIconView .backgroundColor = [UIColor whiteColor];
    
    NSArray *arr = @[@"微信",@"朋友圈",@"复制链接",@"更多"];
    NSArray *iconArr = @[@"icon_wechat", @"icon_circle", @"icon_copy", @"icon_more"];
    
    if (!isInstallWeChat) {
        arr = @[@"复制链接",@"更多"];
        iconArr = @[@"icon_copy", @"icon_more"];
    }
    
    for (int i = 0; i < arr.count ; i++) {
        
        float Hinterval = (self.view.frame.size.width - (44 * 3))/4;
        float x = i > 2 ? Hinterval + ((i - 3) * (44 + Hinterval)) : Hinterval+(i * (44 + Hinterval));
        float y = i > 2 ? (44 + 20 + 7) + 19 : 0;
        UIView *control = [[UIView alloc]initWithFrame:CGRectMake(x, y, 44, 44+20+7)];
        [self.ShareIconView  addSubview:control];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
//        NSString *iconString = iconArr[i];
//        if ([iconString isEqualToString:@"icon_circle"]) {
//            [button setImage:[[UIImage imageNamed:iconString] imageByTintColor:RGB(61, 68, 82)] forState:UIControlStateNormal];
//            [button setImage:[[UIImage imageNamed:iconString] imageByTintColor:RGB(61, 68, 82)]  forState:UIControlStateHighlighted];
//        }else{
            [button setImage:[UIImage imageNamed:iconArr[i]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:iconArr[i]] forState:UIControlStateHighlighted];
//        }

        
        [button addTarget:self action:@selector(controlSelected:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 100 + i;
        [control addSubview:button];
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(-10, button.frame.origin.y + button.frame.size.height + 7, 44 + 20, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = arr[i];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = RGB(119, 119, 119);
        [control addSubview:label];
    }
    
    [self.BottomView addSubview:self.ShareIconView];
}

- (void)addButtonWith:(NSArray <id>*)array{
    
    if (!self.bottomBtnView) {
        self.bottomBtnView = [[UIView alloc]initWithFrame:CGRectMake(0,self.BottomView.frame.size.height - 100 - 60, self.view.frame.size.width, 60)];
        self. bottomBtnView.backgroundColor = [UIColor whiteColor];
        [self.BottomView addSubview:self.bottomBtnView];
        
        CALayer *lineLayer = [CALayer new];
        lineLayer.frame = CGRectMake(0,0, self.view.frame.size.width, 1);
        lineLayer.backgroundColor = CELL_SeparatorColor.CGColor;
        [self.bottomBtnView.layer addSublayer:lineLayer];
    }
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        float width = self.view.frame.size.width/array.count;
        
        if (idx != 0 && idx != array.count) {
            
            CALayer *middleLine = [CALayer new];
            middleLine.frame = CGRectMake(width *idx, 0,1,60);
            middleLine.backgroundColor = CELL_SeparatorColor.CGColor;
            [self.bottomBtnView.layer addSublayer:middleLine];
        }
        
        UIButton *Button = [[UIButton alloc]initWithFrame:CGRectMake(width *idx ,0, width,self.bottomBtnView.frame.size.height )];
        Button.titleLabel.font = [UIFont systemFontOfSize:17];
        [Button setTitleColor:RGB(0, 118, 255) forState:UIControlStateNormal];
        
        if ([obj isKindOfClass:[NSString class]]) {
            [Button setTitle:(NSString *)obj forState:UIControlStateNormal];
            
        }else if([obj isKindOfClass:[NSAttributedString class]]){
            [Button setAttributedTitle:(NSAttributedString *)obj forState:UIControlStateNormal];
        }
        Button.tag = idx + 100;
        [self.bottomBtnView addSubview:Button];
        [Button addTarget:self action:@selector(seletedButton:) forControlEvents:UIControlEventTouchUpInside];
        
    }];
}

- (void)seletedButton:(UIButton *)btn{
    
    [self animationFinish];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.callBack) {
            self.callBack(self, btn.tag - 100);
        }
    });
}

- (void)present{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareAnimationBegin)]) {
        self.WebBrowserView =  [self.delegate shareAnimationBegin];
    }
    _needtoReductionWebView = YES;
    [self beginAnimationWithoutChange:YES];
    
    
}

- (POPSpringAnimation *)beginAnimationWithoutChange:(BOOL)on{
    
    _showAnimation = on;
    
    if (on) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(shareAnimationBegin)]) {
            self.WebBrowserView =  [self.delegate shareAnimationBegin];
        }
        
//        if ([self.WebBrowserView isKindOfClass:[UIWebView class]]) {
//            self.scrollViewOffset = ((UIWebView *)self.WebBrowserView).scrollView.contentOffset;
//        }else if ([self.WebBrowserView isKindOfClass:[WKWebView class]]){
//            self.scrollViewOffset = ((WKWebView *)self.WebBrowserView).scrollView.contentOffset;
//            
//        }else if ([self.WebBrowserView isKindOfClass:[UIScrollView class]]){
//            self.scrollViewOffset = ((UIScrollView *)self.WebBrowserView).contentOffset;
//            
//        }
//        self.clips = self.WebBrowserView.clipsToBounds;
//        
//        self.WebBrowserView.clipsToBounds = NO;
//        
        
//        _WebBrowserView_y = self.WebBrowserView.layer.position.y;
        _position_y = self.BottomView.layer.position.y;
        
        
//        self.WebBrowserView.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.WebBrowserView.layer.shadowOffset = CGSizeMake(0,-3);
//        self.WebBrowserView.layer.shadowRadius = 10;
//        self.WebBrowserView.layer.shadowOpacity = 0;
//        self.WebBrowserView.layer.shouldRasterize = YES;
//        self.WebBrowserView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        self.WebBrowserView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.WebBrowserView.bounds].CGPath;
        
        self.BottomView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.BottomView.layer.shadowOffset = CGSizeMake(0,-3);
        self.BottomView.layer.shadowRadius = 10;
        self.BottomView.layer.shadowOpacity = 0;
        self.BottomView.layer.shouldRasterize = YES;
        self.BottomView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.BottomView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.BottomView.bounds].CGPath;
        
    }
    
    return [self beginAnimation:on];
    
}

- (POPSpringAnimation *)beginAnimation:(BOOL)on {
    
    _showAnimation = on;
    
    POPSpringAnimation *animation = [self pop_animationForKey:@"AnimationProgress"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        animation.dynamicsTension = 600;
        animation.dynamicsFriction = 60;
        animation.velocity = 0;
        animation.property = [POPAnimatableProperty propertyWithName:@"AnimProgress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(OpenShareVC *obj, CGFloat values[]) {
                values[0] = obj.AnimProgress;
            };
            prop.writeBlock = ^(OpenShareVC *obj, const CGFloat values[]) {
                obj.AnimProgress = values[0];
            };
            prop.threshold = 0.001;
        }];
        
        [self pop_addAnimation:animation forKey:@"AnimationProgress"];
        
        @weakify(self)
        [animation setCompletionBlock:^(POPAnimation *anim, BOOL completion) {
            @strongify(self)
            if (_showAnimation) {
                
            }else{
//                if (_needtoReductionWebView) {
//                    self.WebBrowserView.clipsToBounds = self.clips;
//                }
                [self dissMiss];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(shareAnimationFinish)]) {
                    [self.delegate shareAnimationFinish];
                }
            }
        }];
    }
    
    animation.toValue = on ? @(1.0) : @(0.0);
    
    return animation;
}

- (void)setAnimProgress:(CGFloat)AnimationProgress{
    _AnimProgress = AnimationProgress;
    
    if (_needtoReductionWebView) {
//        self.WebBrowserView.layer.shadowOpacity = POPTransition(AnimationProgress, 0, _shadowAlpha);
//        
//        CGFloat x = self.WebBrowserView.layer.position.x;
//        CGFloat y = POPTransition(AnimationProgress, _WebBrowserView_y, _WebBrowserView_y - _webViewTop);
//        
//        
//        self.WebBrowserView.layer.position = CGPointMake(x, y);
//        
//        self.WebBrowserView.layer.transformScale = POPTransition(AnimationProgress, 1, _webViewScale);
//        
//        float offset = POPTransition(AnimationProgress, _scrollViewOffset.y, 0);
//        
//        
//        if (self.scrollViewOffset.y > 0) {
//            
//            [self setWebBrowserViewOffset:offset];
//            
//        }
//        
    }
    
    
    CGFloat bottomX = self.BottomView.layer.position.x;
    CGFloat bottomY = POPTransition(AnimationProgress, _position_y, _position_y - _BottomViewHeight);
    self.BottomView.layer.position = CGPointMake(bottomX, bottomY);
    self.BottomView.layer.shadowOpacity = POPTransition(AnimationProgress, 0, _shadowAlpha);
    
    
    self.maskView.layer.opacity = POPTransition(AnimationProgress, 0, _maskViewAlpha);
    
}
//- (void)setWebBrowserViewOffset:(CGFloat)offset{
//    if (self.scrollViewOffset.y > 0) {
//        
//        if ([self.WebBrowserView isKindOfClass:[UIWebView class]]) {
//            ((UIWebView *)self.WebBrowserView).scrollView.contentOffset = CGPointMake(0, offset);
//        }else if ([self.WebBrowserView isKindOfClass:[WKWebView class]]){
//            ((WKWebView *)self.WebBrowserView).scrollView.contentOffset = CGPointMake(0, offset);
//        }else if ([self.WebBrowserView isKindOfClass:[UIScrollView class]]){
//            ((UIScrollView *)self.WebBrowserView).contentOffset = CGPointMake(0, offset);
//        }
//        
//    }
//    
//}
- (void)animationFinish{
    _needtoReductionWebView = YES;
    [self beginAnimationWithoutChange:NO];
}

- (UIImage*)getShareImage:(NSString*)url {
    
    return nil;
}

- (void)controlSelected:(UIButton *)control{
    
    [WXApi registerApp:@"wxb9e8bb85b528ced9"];//注册微信。。
    switch (control.tag) {
        case 100:{
            if (!isInstallWeChat) {
                [self copyEvent];
            }else{
                //wechat
                [self animationFinish];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIImage *image = [OpenPlatform platform].shareIcon;
                    if(image == nil) {
                        image = [OpenPlatform platform].shareIconImageView.image;
                    }
                    
                    [self shareToWexin:WXSceneSession url:self.shareInfo.url iconImage:[OpenPlatform platform].shareIconImageView.image title:self.shareInfo.wechatTitle
                           description:self.shareInfo.wechatDetail];
                });

            }
        }
            break;
        case 101:{
            //朋友圈
            if (!isInstallWeChat) {
                 [self moreEvent:control];
            }else{
                [self animationFinish];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    UIImage *image = [OpenPlatform platform].shareIcon;
                    if(image == nil) {
                        image = [OpenPlatform platform].shareIconImageView.image;
                    }
                    
                    [self shareToWexin:WXSceneTimeline url:self.shareInfo.url iconImage:[OpenPlatform platform].shareIconImageView.image title:self.shareInfo.wechatTitle
                           description:self.shareInfo.wechatDetail];
                });
            }
           
        }
            break;
//        case 102:{
//            
//            //WEIBO
//            [self animationFinish];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//            });
//            
//        }
//            break;
        case 102:{
            //copy
            [self copyEvent];
        }
            break;
        case 103:{
            [self moreEvent:control];
        }
            break;
        case 105:{
            _needtoReductionWebView = NO;
            [self beginAnimationWithoutChange:NO];
            if (self.callBack) {
                self.callBack(self, 104);
                control.enabled = NO;
            }
        }
            break;
        default:
            break;
    }
    
    
    if(control.tag == 0 || control.tag == 1)
    {
        /*
        [UserInformation sharedInformation].shareBlock = ^(NSInteger type, bool success, NSString* wxId){
            if(success)
            {
                NSMutableDictionary* params = [NSMutableDictionary new];
                [params setObject:[UserInformation sharedInformation].userModel.customerId forKey:@"customerId"];
                [params setObject:@"ios" forKey:@"device"];
                [params setObject:self.article.articleId forKey:@"articleId"];
                [params setObject:[NSNumber numberWithInteger:control.tag] forKey:@"target"];
                
                
                // 0 好友 1朋友圈 2 微博
                
                [[HttpRequest_AFNet sharedClient]requestPOST_JSONwithURLstring:SHARE_ARTICLE_CALL parameters:params success:^(id JsonInfo) {
                    NSLog(@"SHARE_USER_CALL:%@", JsonInfo);
                } failure:^(NSError *error) {
                    
                }];
            }
            
            
        };
         */
    }
    
}

-(void) copyEvent
{
    NSString *copyString = self.shareInfo.linkCopy;
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    [pab setString:copyString];
    
    if(pab) {
        [SVProgressHUD showSuccessWithStatus:@"复制成功"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"复制失败"];
    }
    [self animationFinish];
}
-(void) moreEvent:(UIControl *) control
{
    //more
    NSMutableArray *items = [NSMutableArray new];
    if (self.shareInfo.linkCopy.length > 0) {
        [items addObject:self.shareInfo.linkCopy];
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                         applicationActivities:nil];
    
    activityViewController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popvc = activityViewController.popoverPresentationController;
    popvc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popvc.sourceView = control;
    [self presentViewController:activityViewController animated:YES completion:nil];
    
    activityViewController.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
    };
}
- (void)pan:(UIPanGestureRecognizer *)g {
    
    switch (g.state) {
            
            
        case UIGestureRecognizerStateBegan: {
            _panGestureBeginPoint = [g locationInView:self.view];
        } break;
        case UIGestureRecognizerStateChanged: {
            
            CGPoint p = [g locationInView:self.view];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            CGFloat alphaDelta = _BottomViewHeight;
            //            CGFloat alpha = (alphaDelta - fabs(deltaY)) / alphaDelta;
            CGFloat alpha = (alphaDelta - deltaY) / alphaDelta;
            
            alpha = YY_CLAMP(alpha, 0, 1);
            
//            self.WebBrowserView.layer.transformScale =1 - (1 - _webViewScale) *alpha;
//            self.WebBrowserView.layer.position = CGPointMake(self.WebBrowserView.layer.position.x,
//                                                             (_WebBrowserView_y - _webViewTop) + _webViewTop* (1 -alpha));
//            self.WebBrowserView.layer.shadowOpacity = alpha * _shadowAlpha;
            self.maskView.alpha = _maskViewAlpha *alpha;
            self.BottomView.layer.shadowOpacity = alpha * _shadowAlpha;
            if ((H_DEVICE - _BottomViewHeight + deltaY) >= H_DEVICE - _BottomViewHeight) {
                self.BottomView.frame = CGRectMake(self.BottomView.frame.origin.x, (self.view.frame.size.height - _BottomViewHeight) + deltaY, self.BottomView.frame.size.width, self.BottomView.frame.size.height);
            }
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self.view];
            CGPoint p = [g locationInView:self.view];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if ((v.y) > 1000 ||(deltaY) > _BottomViewHeight* 0.3) {
                
                [self setAnimProgress:(self.view.frame.size.height - self.BottomView.frame.origin.y)/_BottomViewHeight];
                [self beginAnimation:NO];
            } else {
                [self setAnimProgress:(self.view.frame.size.height - self.BottomView.frame.origin.y)/_BottomViewHeight];
                [self beginAnimation:YES];
                
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            //            NSInteger currentPage = self.currentPage;
            //            PhotoCell *cell = [self cellForPage:currentPage];
            //            cell.top = 0;
            //            _blurBackground.alpha = 1;
            //            self.navigationController.navigationBar.alpha = 0;
            //            [self setPhotoDescribeAlpha:1];
            
        }
        default:break;
    }
}

- (void)dissMiss{
    
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
        
    _maskView.frame = CGRectMake(0, 0, W_DEVICE, H_DEVICE);
    
    self.BottomView.frame = CGRectMake(0, H_DEVICE - _BottomViewHeight, W_DEVICE,_BottomViewHeight);
    
    self.ShareIconView.frame = CGRectMake(0, 40, W_DEVICE, 44 + 97 + 20);
    
    self.bottomBtnView.frame = CGRectMake(0,self.BottomView.frame.size.height - 60, self.view.frame.size.width, 60);
    
    [self.bottomBtnView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        float width = W_DEVICE/self.bottomBtnView.subviews.count;
        
        obj.frame = CGRectMake(width *idx ,0, width,self.bottomBtnView.frame.size.height );
        
    }];
    
    [self.ShareIconView.subviews enumerateObjectsUsingBlock:^(UIView *control, NSUInteger i, BOOL * _Nonnull stop) {
        
        float Hinterval = (W_DEVICE - (44 * 3))/4;
        float x = i > 2 ? Hinterval + ((i - 3) * (44 + Hinterval)) : Hinterval+(i * (44 + Hinterval));
        float y = i > 2 ? (44 + 20 + 7) + 19 : 0;
        control.frame = CGRectMake(x, y, 44, 44+20+7);
    }];
    
    [self.bottomBtnView.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(idx == 0)
        {
            obj.frame = CGRectMake(0,0, W_DEVICE, 1);
        }
        else if(obj.frame.size.width <=1)
        {
            float width = W_DEVICE/self.bottomBtnView.subviews.count;
            obj.frame = CGRectMake(width *(idx-1), 0,1,60);
        }
    }];
}

- (BOOL)shareToWexin:(int)scene url:(NSString *)shareUrl iconImage:(UIImage*)iconImage title:(NSString *)title description:(NSString *)desc{
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    
    if (shareUrl && shareUrl.length > 0) {
        webObj.webpageUrl = shareUrl;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    if (title && title.length > 0) {
        message.title = title;
    }
    if (desc && desc.length > 0) {
        if (desc.length > 100) {
            message.description = [desc substringWithRange:NSMakeRange(0, 100)];
        }else{
            message.description = desc;
        }
    }
    
    
    message.mediaObject = webObj;
    if(iconImage)
    {
        message.thumbData = [self thumbImageLimitSize:iconImage limitSize:CGSizeMake(120, 120)];
    }else{
        UIImage *defaultIcon = nil;
        if(_defaultShareIcon.length>0) {
            defaultIcon = [UIImage imageNamed:_defaultShareIcon];
        } else {
//            defaultIcon = [UIImage imageNamed:@"AppIcon"];
            NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
            NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
            defaultIcon = [UIImage imageNamed:icon];
        }
        if(defaultIcon) {
            message.thumbData = UIImageJPEGRepresentation(defaultIcon, 1);
        }
    }
    
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    
    req.scene = scene;
    req.bText = NO;
    req.message = message;
    
    return [WXApi sendReq:req];
}

#pragma mark - image tool

- (NSData*)thumbImageLimitSize:(UIImage*)image limitSize:(CGSize)size
{
    if(size.width < 20 || size.height < 20){
        return nil;
    }
    
    UIImage* smallImg = [self thumbImageWithImage:image limitSize:size];
    
    NSData* data = UIImageJPEGRepresentation(smallImg, 0.6);
    
    if(data.length > 10 * 1024)
    {
        return [self thumbImageLimitSize:image limitSize:CGSizeMake(size.width-20, size.height-20)];
    }
    
    return data;
}

- (UIImage *)thumbImageWithImage:(UIImage*)image limitSize:(CGSize)size
{
    CGFloat scaleX = size.width / image.size.width;
    CGFloat scaleY = size.height / image.size.height;
    CGFloat scale = MAX(scaleX, scaleY);
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(size.width/2 - image.size.width * scale /2,
                                 size.height/2 - image.size.height * scale /2,
                                 image.size.width * scale, image.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end

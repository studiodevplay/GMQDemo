//
//  AdmobBannerManager.m
//

#import "AdmobBannerManager.h"
#import "AdmobBannerView.h"



const char* UNITY_BANNER_METHOD                 = "Yodo1U3dSDKCallBackResult";

typedef enum {
    BannerAdEventClose 		= 0,//关闭
    BannerAdEventFinish 	= 1,//播放完成
    BannerAdEventClick 		= 2,//用户点击广告
    BannerAdEventLoaded 	= 3,//加载完毕
    BannerAdEventDisplay	= 4,//广告已成功展示
    BannerAdEventPurchase	= 5,//广告购买
    BannerAdEventError 		= -1,//广告回调出现异常!
}BannerAdEvent;

@interface UnityBannerAd : NSObject <AdmobBannerDelegate>

@property (nonatomic,copy)NSString* delegateObject;

+ (UnityBannerAd*)sharedInstance;

@end

@implementation UnityBannerAd

+ (UnityBannerAd*)sharedInstance {
    
    static UnityBannerAd* _instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[UnityBannerAd alloc]init];
    });
    return _instance;
}

#pragma mark-BannerAdDelegate

- (void)bannerDidLoad {
    
}

- (void)bannerDidFailToLoadWithError:(NSError *)error {
    
}

- (void)bannerWillPresentScreen {
    
}

- (void)didClickBanner {
    
}

@end

#pragma mark Unity 接口

@interface AdmobBannerManager() {
    id<AdmobBannerDelegate> admobBannerDelegate;
    UIView* providerAd;
    int beforeX;
    int beforeY;
}

@property (nonatomic,strong)AdmobBannerView* bannerView;
@property (nonatomic)int lastAlign;

- (void)adjustFrame:(UIView*)bgView;

- (CGPoint)BannerAdjust:(int)align offset:(CGPoint)offset bgView:(UIView*)bgView;

- (BOOL)biPhoneX;

@end

@implementation AdmobBannerManager


+ (AdmobBannerManager*)sharedInstance {
    
    static AdmobBannerManager* _instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[AdmobBannerManager alloc]init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        if (_bannerView == nil) {
            _bannerView = [[AdmobBannerView alloc]initWithAdapter];
            _bannerView.frame = CGRectMake(0, 0, 320, 50);
            if ([AdmobBannerManager isIpad]) {
                _bannerView.frame = CGRectMake(0, 0, 728, 90);
            }
            [_bannerView setContentMode:UIViewContentModeScaleAspectFill];
            [_bannerView setClipsToBounds:YES];
            _bannerView.backgroundColor = [UIColor clearColor];
        }
    }
    return self;
}

- (void)dealloc {
    
}

- (void)setDelegate:(id<AdmobBannerDelegate>)delegate {
    admobBannerDelegate = delegate;
}

- (BOOL)bannerAdReady {
    return YES;
}

- (BOOL)biPhoneX {
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)]) {
        if (CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size)) {
            return YES;
        }
    }
    return NO;
}

- (void)setBannerAlign:(BannerAlign)align {
    if (self.bannerView == nil) {
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bannerView) {
            [AdmobBannerManager sharedInstance].lastAlign = align;
            [self.bannerView setPause:YES];
        }
    });
}

- (void)setAdView:(UIView *)adview {
    if (adview) {
        providerAd = adview;
    }
    if (![[self.bannerView subviews]containsObject:providerAd]) {
        [self.bannerView addSubview:providerAd];
        [self hideBanner];
    }
}

- (void)removeAdView:(UIView*)adview {
    if ([[self.bannerView subviews]containsObject:adview]) {
        [adview removeFromSuperview];
        [self.bannerView removeFromSuperview];
    }
}

- (void)showBanner:(UIView*)bgView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->providerAd && ![[self.bannerView subviews]containsObject:self->providerAd]) {
            [self.bannerView addSubview:self->providerAd];
        }
        if ([[bgView subviews]containsObject:self.bannerView]) {
            [self.bannerView removeFromSuperview];
        }
        if (self.bannerView) {
            [bgView addSubview:self.bannerView];//添加到当前viewcontroller的view上
            [self.bannerView setPause:NO];
            [self adjustFrame:bgView];
            [self.bannerView showBanner];
        }
	});
}

- (void)hideBanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bannerView) {
            [self.bannerView setPause:YES];
            [self.bannerView setAlpha:0.0f];
        }
    });
}

- (void)removeBanner {
    if (self.bannerView == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //3.4.3
        //self.bannerView.hidden = YES;
        [self.bannerView removeFromSuperview];
    });
}

- (void)adjustFrame:(UIView*)bgView {
    if (self.bannerView == nil) {
        return;
    }
    beforeX = [self.bannerView frame].origin.x;
    beforeY = [self.bannerView frame].origin.y;
    
    AdmobBannerManager * bannerAdAdapter = [AdmobBannerManager sharedInstance];
    CGPoint point = [self BannerAdjust:bannerAdAdapter.lastAlign
                                offset:CGPointMake(bannerAdAdapter.lastOffsetX,bannerAdAdapter.lastOffsetY)
                                bgView:bgView];
    CGRect rect = [self.bannerView frame];
    if (point.x < 0) {
        point.x = beforeX;
    }
    if (point.y < 0) {
        point.y = beforeY;
    }
    
    rect.origin.x = point.x;
    rect.origin.y = point.y;
    self.bannerView.frame = rect;
    
}

- (CGPoint)BannerAdjust:(int)align offset:(CGPoint)offset bgView:(UIView *)bgView {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    UIView * parentView = bgView?bgView:rootView;
    CGSize adSize = self.bannerView.frame.size;
    CGSize viewSize = parentView.bounds.size;
    CGPoint point;
    CGFloat x = 0;
    CGFloat y = 0;

    if ((align & BannerAlignLeft) == BannerAlignLeft){
        x = x + offset.x;
    } else if((align & BannerAlignRight) == BannerAlignRight){
        x = viewSize.width - adSize.width - offset.x;
    } else if((align & BannerAlignHorizontalCenter) == BannerAlignHorizontalCenter){
        x = (viewSize.width - adSize.width) / 2 + offset.x;
        
        if (x == 0 || x < 0) {
            x = beforeX;
        }
    }
    
    if ((align & BannerAlignTop) == BannerAlignTop) {
        y = y + offset.y + [[UIApplication sharedApplication] statusBarFrame].size.height;
        if ([self biPhoneX] && ![AdmobBannerManager isOrientationLandscape] && [UIApplication sharedApplication].statusBarHidden) {
            y = y + 44;
        }
    } else if((align & BannerAlignBottom) == BannerAlignBottom){
        y = viewSize.height - adSize.height - offset.y;
        if ([self biPhoneX] && ![AdmobBannerManager isOrientationLandscape]) {
            y = y - 34;
        }
    } else if((align & BannerAlignVerticalCenter) == BannerAlignVerticalCenter){
        y = (viewSize.height - adSize.height) / 2 + offset.y;
    }
    
    point.x = x;
    point.y = y;
    return point;
}



+ (BOOL)isOrientationLandscape {
    UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    return screenOrientation == UIDeviceOrientationLandscapeLeft || screenOrientation == UIDeviceOrientationLandscapeRight;
}

+ (BOOL)isIpad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

@end

//
//  AdmobBannerManager.h
//

#import <UIKit/UIKit.h>
#import "AdmobBannerDelegate.h"
#import "JPCConst.h"


@interface AdmobBannerManager: NSObject

@property (nonatomic)int lastOffsetX;
@property (nonatomic)int lastOffsetY;

@property(nonatomic, strong) UIButton *buttonContent;
@property(nonatomic, strong) UIButton *buttonClose;

@property(nonatomic, strong) NSArray *crossArray;
@property(nonatomic, assign) NSInteger crossIndex;
@property(nonatomic, strong) NSString *crossAppUrl;
@property(nonatomic, strong) UIView *crossBGView;

///Yodo1BannerAdManager单例
+ (AdmobBannerManager*)sharedInstance;

- (void)setDelegate:(id<AdmobBannerDelegate>)delegate;

///设置广告显示位置 @param align banner广告位置
- (void)setBannerAlign:(BannerAlign)align;

- (void)setAdView:(UIView*)adview;

- (void)removeAdView:(UIView*)adview;

///显示Banner广告
- (void)showBanner:(UIView*)bgView;

///隐藏广告:不移除
- (void)hideBanner;

///移除广告
- (void)removeBanner;

///是否有广告准备好
- (BOOL)bannerAdReady;


@end

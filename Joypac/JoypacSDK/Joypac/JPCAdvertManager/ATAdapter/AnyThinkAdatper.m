//
//  JPCASDKAdatper.m

//
//  Created by 洋吴 on 2019/3/21.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "AnyThinkAdatper.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AnyThinkNative/AnyThinkNative.h>
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import "AdmobBannerManager.h"
#import "ATNavtiveDMAdView.h"
#import "JPCDataReportManager.h"
#import "JPCSearchManager.h"
#import "JoypacNativeHelper.h"
#import "JPCCheckList.h"


@interface AnyThinkAdatper ()<
ATNativeADDelegate,
ATInterstitialDelegate,
ATRewardedVideoDelegate,
ATNativeBannerDelegate,
ATNativeSplashDelegate>

@property(nonatomic,copy)void(^callBack)(void);

@property(nonatomic, strong)NSString *bannerPlacementID;

@property(nonatomic, strong)NSString *rewardVideoPlacementID;

@property(nonatomic, strong)NSString *nativePlacementID;

@property(nonatomic, strong)NSString *interstitialPlacementID;

@property(nonatomic, strong)NSString *splashPlacementID;

@property(nonatomic, strong)ATNativeBannerView *banner;

@property(nonatomic, strong)ATNativeADView *nativeView;

@property(nonatomic, strong)UIViewController *rootViewController;

@property(nonatomic, strong)UIView *backgroundView;

@property(nonatomic, assign)BOOL onReward;

@property(nonatomic,strong)UIView *nativeAnimateView;

@property(nonatomic,strong)NSString *nativeStyle;


@end

@implementation AnyThinkAdatper

#pragma - mark init SDK
- (void)initSDKWithAppId:(NSString *)appId appKey:(NSString *)appKey{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [dic setValue:[[JPCHTTPParameter parameter] JPID] forKey:@"JPID"];
    
    NSDictionary *segment = [kUserDefault objectForKey:kJoypacSegment];
    
    if ([segment isKindOfClass:[NSDictionary class]]) {
        if (segment.count) {
            
            [dic addEntriesFromDictionary:segment];
        }
        
    }else{
        
        [dic addEntriesFromDictionary:@{@"cohort_id":@"setting_timeout_default"}];
    }
    
    NSDictionary *selfCheckList = [JPCCheckList checkInstallList];
    
    if (selfCheckList.count && [selfCheckList isKindOfClass:[NSDictionary class]]) {
        
        [dic addEntriesFromDictionary:selfCheckList];
        
    }
    
    [ATAPI sharedInstance].customData = dic;
    
    NSInteger statusCode = [kUserDefault integerForKey:kJoypacGDPRStatus];
    
    if (statusCode == 2) {
        
        [[ATAPI sharedInstance]setDataConsentSet:ATDataConsentSetNonpersonalized consentString:nil];
        
    }else{
        
        [[ATAPI sharedInstance]setDataConsentSet:ATDataConsentSetPersonalized consentString:nil];
    }
    
    
    [[ATAPI sharedInstance] startWithAppID:appId appKey:appKey error:nil];
    
    [ATAPI setLogEnabled:YES];
    
}

- (void)refreshSegmentWithDictionary:(NSDictionary *)customData{
    
    NSString *topOnVersion = [ATAPI sharedInstance].version;
    topOnVersion = [topOnVersion substringWithRange:NSMakeRange(3,5)];
    if ([self compareVersion:topOnVersion toVersion:@"5.5.1"] == -1) {
        return;
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSDictionary *selfCheckList = [JPCCheckList checkInstallList];
        
        if (selfCheckList.count && [selfCheckList isKindOfClass:[NSDictionary class]]) {
            
            [dic addEntriesFromDictionary:selfCheckList];
            
        }
        [dic addEntriesFromDictionary:customData];
        [ATAPI sharedInstance].customData = dic;
    }
}

#pragma mark - load ads
- (void)loadADWithPlacementId:(NSString *)placementId adType:(ADType)type nativeFrame:(CGRect)frame {
    
    if (type == kADTypeNative) {
        
        self.nativePlacementID = placementId;
        CGRect frameF = [self transformationToOCCoordinates:frame];
        [[ATAdManager sharedManager] loadADWithPlacementID:placementId extra:@{kExtraInfoNativeAdTypeKey:@(ATGDTNativeAdTypeSelfRendering), kATExtraNativeImageSizeKey:kATExtraNativeImageSize690_388,kExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(frameF.size.width, frameF.size.height)]} delegate:self];
        
    }else if(type == kADTypeIterstital){
        
        self.interstitialPlacementID = placementId;
        [[ATAdManager sharedManager]loadADWithPlacementID:placementId extra:nil delegate:self];
        
    }else if (type == kADTypeVideo){
        
        self.rewardVideoPlacementID = placementId;
        NSString *idfv = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [[ATAdManager sharedManager]loadADWithPlacementID:placementId extra:@{kATAdLoadingExtraUserIDKey:idfv} delegate:self];
        
    }else if(type == kADTypeNativeSplash){
        
        self.splashPlacementID = placementId;
        [ATNativeSplashWrapper loadNativeSplashAdWithPlacementID:placementId extra:@{kExtraInfoNativeAdTypeKey:@(ATGDTNativeAdTypeSelfRendering), kExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) -30.0f, 400.0f)], kATExtraNativeImageSizeKey:kATExtraNativeImageSize690_388} customData:nil delegate:self];
        
    }else{
        
        self.bannerPlacementID = placementId;
        [ATNativeBannerWrapper loadNativeBannerAdWithPlacementID:placementId extra:@{kExtraInfoNativeAdTypeKey:@(ATGDTNativeAdTypeSelfRendering), kATExtraNativeImageSizeKey:kATExtraNativeImageSize690_388} customData:nil delegate:self];
        
    }
}

#pragma mark - isReady ads
- (BOOL)isReadyADWithADType:(ADType)type {
    
    if (type == kADTypeBanner) {
        if (self.bannerPlacementID) {
            return [ATNativeBannerWrapper nativeBannerAdReadyForPlacementID:self.bannerPlacementID];
        }else{
            return NO;
        }
        
    }else if (type == kADTypeIterstital){
        if (self.interstitialPlacementID) {
            return [[ATAdManager sharedManager] interstitialReadyForPlacementID:self.interstitialPlacementID];
        }else{
            return NO;
        }
    }else if (type == kADTypeVideo){
        if (self.rewardVideoPlacementID) {
            return [[ATAdManager sharedManager] rewardedVideoReadyForPlacementID:self.rewardVideoPlacementID];
        }else{
            return NO;
        }
        
    }else if (type == kADTypeNativeSplash){
        if (self.splashPlacementID) {
            return [ATNativeSplashWrapper splashNativeAdReadyForPlacementID:self.splashPlacementID];
        }else{
            return NO;
        }
    }else{
        if (self.nativePlacementID) {
            return [[ATAdManager sharedManager] nativeAdReadyForPlacementID:self.nativePlacementID];
        }else{
            
            return NO;
        }
    }
}

#pragma mark - show ads
- (void)showADWithADType:(ADType)type {
    
    [self rootViewController];
    
    if (type == kADTypeBanner) {
        [self showBanner];
    }else if (type == kADTypeIterstital){
        
        [[ATAdManager sharedManager] showInterstitialWithPlacementID:self.interstitialPlacementID
                                                    inViewController:self.rootViewController
                                                            delegate:self];
        
    }else if (type == kADTypeVideo){
        
        [[ATAdManager sharedManager]showRewardedVideoWithPlacementID:self.rewardVideoPlacementID
                                                    inViewController:self.rootViewController
                                                            delegate:self];
        
    }else if (type == kADTypeNativeSplash){
        
        [ATNativeSplashWrapper showNativeSplashAdWithPlacementID:self.splashPlacementID
                                                           extra:@{kATNativeSplashShowingExtraContainerViewKey:[self getJoypacLogoView]}
                                                        delegate:self];
        
    }else if (type == kADTypeNative){
        
        [self showNative];
    }
}


- (UIView *)getJoypacLogoView{
    
    UIView *JPCView = [[UIView alloc]init];
    JPCView.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,79);
    JPCView.backgroundColor = [UIColor whiteColor];
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"joypacSplash" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.app.gohome"]) {
        NSString *iconImage_path = [bundle pathForResource:@"splashIcon" ofType:@"png"];
        UIImage *iconImage = [UIImage imageNamed:iconImage_path];
        UIImageView *iconImageView = [[UIImageView alloc]initWithImage:iconImage];
        iconImageView.contentMode = UIViewContentModeCenter;
        iconImageView.center = JPCView.center;
        [JPCView addSubview:iconImageView];
    }else{
        NSString *img_path = [bundle pathForResource:@"jplogo" ofType:@"png"];
        UIImage *image_1=[UIImage imageWithContentsOfFile:img_path];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image_1];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.center = JPCView.center;
        [JPCView addSubview:imageView];
    }
    
    return JPCView;
}


#pragma mark - native
- (void)layoutNativeWithX:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w H:(CGFloat)h{
//    ATNativeADConfiguration *config = [[ATNativeADConfiguration alloc] init];
//    config.delegate = self;
//    config.renderingViewClass = [ATNavtiveDMAdView class];
//    CGFloat wid = w * [UIScreen mainScreen].bounds.size.width;
//    CGFloat hig;
//    if (SCREENSIZE_IS_XR||SCREENSIZE_IS_X||SCREENSIZE_IS_XS_MAX||IS_IPhoneX_All) {
//        hig = h * ([UIScreen mainScreen].bounds.size.height - 78) ;
//    }else{
//
//        hig = h * [UIScreen mainScreen].bounds.size.height ;
//    }
//    CGFloat halfWidth = [UIScreen mainScreen].bounds.size.width/2;
//    CGFloat halfHeight = [UIScreen mainScreen].bounds.size.height/2;
//    config.ADFrame = CGRectMake(x, y, wid, hig);
//    //防止重复添加AdView
//    if (self.nativeView) {
//        return;
//    }
//    self.nativeView = [[ATAdManager sharedManager] retriveAdViewWithPlacementID:self.nativePlacementID configuration:config];
//    CGFloat centY = self.rootViewController.view.center.y - y * halfHeight;
//    CGFloat centX = self.rootViewController.view.center.x + x * halfWidth;
//    self.nativeView.center = CGPointMake(centX, centY);
//    self.nativeView.mediaView.frame = self.nativeView.bounds;
//    self.nativeView.hidden = YES;
    
    ATNativeADConfiguration *config = [[ATNativeADConfiguration alloc] init];
    config.delegate = self;
    config.renderingViewClass = [ATNavtiveDMAdView class];
    config.ADFrame = [self transformationToOCCoordinates:CGRectMake(x, y, w, h)];
    //防止重复添加AdView
    if (self.nativeView) {
        return;
    }
    self.nativeView = [[ATAdManager sharedManager] retriveAdViewWithPlacementID:self.nativePlacementID configuration:config];
    self.nativeView.mediaView.frame = self.nativeView.bounds;
    self.nativeView.hidden = YES;
    
}

- (void)showNative{
    
    if ([self.nativeStyle isEqualToString:@"cycleStyle"]) {
        
        if (!self.nativeAnimateView) {
    
            self.nativeAnimateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.nativeView.frame)+10, CGRectGetHeight(self.nativeView.frame)+10)];
    
            self.nativeAnimateView.center = CGPointMake(self.nativeView.center.x, self.nativeView.center.y);
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.nativeAnimateView];
    
            [self setUpAnimateWithSuperView:self.nativeAnimateView];
    
        }
        
    }

    
    self.nativeView.hidden = NO;
            
    [self.rootViewController.view addSubview:self.nativeView];
        
    

}

- (void)hideNative {
    
    [self removeNative];
    
}

- (void)removeNative {
    
    if (self.nativeView) {
        self.nativeView.hidden = YES;
        [self.nativeView removeFromSuperview];
        self.nativeView = nil;
    }
    
    if ([self.nativeStyle isEqualToString:@"cycleStyle"]) {
        if (self.nativeAnimateView) {
            self.nativeAnimateView.hidden = YES;
            [self.nativeAnimateView removeFromSuperview];
            self.nativeAnimateView = nil;
        }
    }

}

#pragma mark  transforma native coordinate
- (CGRect)transformationToOCCoordinates:(CGRect)frame{
    
    CGFloat scales = [UIScreen mainScreen].scale;
    CGRect finalFrame = CGRectZero;
    if ([self.nativeStyle isEqualToString:@"cycleStyle"]) {
        if (SCREENSIZE_IS_6SP) {

            finalFrame = CGRectMake(frame.origin.x/0.92/scales+5, frame.origin.y/0.9/scales+5, frame.size.width/scales-10, frame.size.height/scales-10);

        }else if (SCREENSIZE_IS_8P){

            finalFrame = CGRectMake(frame.origin.x/0.87/scales+5, frame.origin.y/0.87/scales+5, frame.size.width/0.87/scales-10, frame.size.height/0.87/scales-10);

        }else if (SCREENSIZE_IS_XR && scales == 2){

            finalFrame = CGRectMake(frame.origin.x/scales+5, frame.origin.y/scales+5-44, frame.size.width/2.2-10, frame.size.height/2.2-10);
        }else{

            finalFrame = CGRectMake(frame.origin.x/scales+5, frame.origin.y/scales+5, frame.size.width/scales-10, frame.size.height/scales-10);

        }
    }else{
        
        if (SCREENSIZE_IS_6SP) {

            finalFrame = CGRectMake(frame.origin.x/0.92/scales, frame.origin.y/0.9/scales, frame.size.width/scales, frame.size.height/scales);

        }else if (SCREENSIZE_IS_8P){

            finalFrame = CGRectMake(frame.origin.x/0.87/scales, frame.origin.y/0.87/scales, frame.size.width/0.87/scales,  frame.size.height/0.87/scales);

        }else if (SCREENSIZE_IS_XR && scales == 2){

            finalFrame = CGRectMake(frame.origin.x/scales, frame.origin.y/scales-44, frame.size.width/2.2, frame.size.height/2.2);
        }else{

            finalFrame = CGRectMake(frame.origin.x/scales, frame.origin.y/scales, frame.size.width/scales, frame.size.height/scales);

        }
    }
    return finalFrame;
}

- (void)nativeStyle:(NSString *)nativeStyle {
    
    self.nativeStyle = nativeStyle;
}

#pragma mark - banner
- (void)showBanner{
    
    if (self.bannerPlacementID) {
        
        if (self.banner.superview && self.banner.superview.alpha == 0) {
            
            self.banner.superview.alpha = 1;
        }else{
            
            self.banner = [ATNativeBannerWrapper retrieveNativeBannerAdViewWithPlacementID:self.bannerPlacementID extra:@{kATNativeBannerAdShowingExtraBackgroundColorKey:[UIColor whiteColor],kATNativeBannerAdShowingExtraHideCloseButtonFlagKey:@YES,kATNativeBannerAdShowingExtraAdSizeKey:[NSValue valueWithCGSize:CGSizeMake([self adSize].size.width, [self adSize].size.height)]} delegate:self];
            [self.banner setFrame:[self adSize]];
            if (self.banner) {
                [[AdmobBannerManager sharedInstance]removeAdView:self.banner];
                [[AdmobBannerManager sharedInstance]setAdView:self.banner];
            }else{
            }
            [[AdmobBannerManager sharedInstance]showBanner:self.rootViewController.view];
            
        }
    }
    
}

- (void)hideBanner {
    
    if (self.banner) {
        [[AdmobBannerManager sharedInstance]hideBanner];
    }
}

- (void)removeBanner {
    
    if (self.banner) {
        [[AdmobBannerManager sharedInstance]removeAdView:self.banner];
    }
}

- (void)setBannerAlign:(BannerAlign)align offset:(CGPoint)offset {
    
    [[AdmobBannerManager sharedInstance]setLastOffsetX:offset.x];
    [[AdmobBannerManager sharedInstance]setLastOffsetY:offset.y];
    [[AdmobBannerManager sharedInstance]setBannerAlign:align];
}

- (CGRect)adSize {
    CGRect gadSize = CGRectMake(0, 0, 320, 50);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        gadSize = CGRectMake(0, 0, 728, 90);;
    }
    return gadSize;
}

#pragma mark - ads delegete
#pragma mark Loading Delegate
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSString *type;
    
    if ([self.bannerPlacementID isEqualToString:placementID]) {
        type = @"banner";
    }else if ([self.interstitialPlacementID isEqualToString:placementID]){
        type = @"interstitial";
        UnitySendMessage("AdObject", "JoypacIntersititalAdLoadFail", "");
    }else if ([self.rewardVideoPlacementID isEqualToString:placementID]){
        type = @"rewardVideo";
        UnitySendMessage("AdObject", "JoypacVideoAdLoadFail", "");
    }else if ([self.nativePlacementID isEqualToString:placementID]){
        type = @"native";
        UnitySendMessage("AdObject", "JoypacNativeAdLoadFail", "");
    }else{
        type = @"NULL";
    }
    
    [[JPCDataReportManager manager] reportWithType:kLoadAdCallBack
                                       placementId:placementID
                                             reson:[NSString stringWithFormat:@"%@",error]
                                            result:@"Fail"
                                            adType:type
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID {
    
    NSString *type;
    if ([self.bannerPlacementID isEqualToString:placementID]) {
        type = @"banner";
    }else if ([self.interstitialPlacementID isEqualToString:placementID]){
        type = @"interstitial";
        UnitySendMessage("AdObject", "JoypacIntersititalAdLoad", "");
        
    }else if ([self.rewardVideoPlacementID isEqualToString:placementID]){
        type = @"rewardVideo";
        UnitySendMessage("AdObject", "JoypacVideoAdLoaded", "");
        
    }else if ([self.nativePlacementID isEqualToString:placementID]){
        type = @"native";
        UnitySendMessage("AdObject", "JoypacNativeAdLoaded", "");
    }else{
        type = @"NULL";
    }
    
    [[JPCDataReportManager manager]reportWithType:kLoadAdCallBack
                                      placementId:placementID
                                            reson:@"SuccessCallBack"
                                           result:@"Success"
                                           adType:type
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
}

#pragma mark - rv
-(void) rewardedVideoDidStartPlayingForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacVideoAdPlayStart", "");
    
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:@"didStartPlayingRewardVideo"
                                            result:@"Success"
                                            adType:@"rewardVideo"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) rewardedVideoDidEndPlayingForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    
    UnitySendMessage("AdObject", "JoypacVideoAdPlayEnd", "");
    
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:@"didEndPlayingRewardVideo"
                                            result:@"Success"
                                            adType:@"rewardVideo"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) rewardedVideoDidFailToPlayForPlacementID:(NSString*)placementID error:(NSError*)error extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacVideoAdPlayFail", "");
    
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:[NSString stringWithFormat:@"%@",error]
                                            result:@"Fail"
                                            adType:@"rewardVideo"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) rewardedVideoDidCloseForPlacementID:(NSString*)placementID rewarded:(BOOL)rewarded extra:(NSDictionary *)extra{
    
    if (self.onReward) {
        UnitySendMessage("AdObject", "JoypacVideoAdPlayClosed", [@"True" UTF8String]);
        
        self.onReward = NO;
        
        [[JPCDataReportManager manager]reportWithType:kRewardedInfo
                                          placementId:placementID
                                                reson:@"didReceiveReward"
                                               result:@""
                                               adType:@"rewardVideo"
                                               extra1:@""
                                               extra2:@""
                                               extra3:@""];
        
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.onReward) {
                UnitySendMessage("AdObject", "JoypacVideoAdPlayClosed", [@"True" UTF8String]);
                [[JPCDataReportManager manager]reportWithType:kRewardedInfo
                                                  placementId:placementID
                                                        reson:@"didReceiveReward"
                                                       result:@""
                                                       adType:@"rewardVideo"
                                                       extra1:@""
                                                       extra2:@""
                                                       extra3:@""];
            }else{
                UnitySendMessage("AdObject", "JoypacVideoAdPlayClosed", [@"False" UTF8String]);
            }
            self.onReward = NO;
        });
    }
    
    
    [[JPCDataReportManager manager]reportWithType:kRewardedInfo
                                      placementId:placementID
                                            reson:@"didClose"
                                           result:@""
                                           adType:@"rewardVideo"
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
}

-(void) rewardedVideoDidRewardSuccessForPlacemenID:(NSString*)placementID extra:(NSDictionary*)extra{
    
    self.onReward = YES;
    
}

-(void) rewardedVideoDidClickForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacVideoAdPlayClicked", "");
    
    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacRVUnitID];
    
    [[JPCDataReportManager manager]reportWithType:kDidClickAd
                                      placementId:placementID
                                            reson:jpUnitID
                                           result:@""
                                           adType:@"rewardVideo"
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
    
    
}

#pragma mark - iv
-(void) interstitialDidShowForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacIntersititalAdShow", "");
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:@"didShow"
                                            result:@"Success"
                                            adType:@"interstitial"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) interstitialFailedToShowForPlacementID:(NSString*)placementID error:(NSError*)error extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacIntersititalAdsShowFail", "");
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:[NSString stringWithFormat:@"%@",error]
                                            result:@"Fail"
                                            adType:@"interstitial"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
}

-(void) interstitialDidStartPlayingVideoForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacIntersititalAdsStartPlayVideo", "");
}

-(void) interstitialDidEndPlayingVideoForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacIntersititalAdsEndPlaying", "");
    
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:@"didEndPlayingVideo"
                                            result:@"Success"
                                            adType:@"interstitial"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) interstitialDidFailToPlayVideoForPlacementID:(NSString*)placementID error:(NSError*)error extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacIntersititalAdFailedToPlay", "");
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:[NSString stringWithFormat:@"%@",error]
                                            result:@"Fail"
                                            adType:@"interstitial"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
    
    
}

-(void) interstitialDidCloseForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacIntersititalAdClose", "");
    
}

-(void) interstitialDidClickForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacIntersititalAdClick", "");
    
    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacIVUnitID];
    
    [[JPCDataReportManager manager]reportWithType:kDidClickAd
                                      placementId:placementID
                                            reson:jpUnitID
                                           result:@""
                                           adType:@"interstitial"
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
}

#pragma mark - banner
-(void) didFinishLoadingNativeBannerAdWithPlacementID:(NSString *)placementID{
    
    UnitySendMessage("AdObject", "JoypacBannerAdLoad", "");
}

-(void) didFailToLoadNativeBannerAdWithPlacementID:(NSString*)placementID error:(NSError*)error{
    
    UnitySendMessage("AdObject", "JoypacBannerAdLoadFail", "");
}

-(void) didShowNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacBannerAdDidShow", "");
    
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:@"didShowNativeBanner"
                                            result:@"Success"
                                            adType:@"banner"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
}

-(void) didClickNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacBannerAdDidClick", "");
    
    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacBannerUnitID];
    
    [[JPCDataReportManager manager]reportWithType:kDidClickAd
                                      placementId:placementID
                                            reson:jpUnitID
                                           result:@""
                                           adType:@"banner"
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
    
}

-(void) didClickCloseButtonInNativeBannerAdView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacBannerAdDidClickCloseButton", "");
    
}

-(void) didAutorefreshNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacBannerUnitID];
    
    [[JPCDataReportManager manager] reportWithType:kTriggerShowAd
                                       placementId:placementID
                                             reson:jpUnitID
                                            result:@""
                                            adType:@"banner"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) didFailToAutorefreshNativeBannerAdInView:(ATNativeBannerView*)bannerView placementID:(NSString*)placementID extra:(NSDictionary *)extra error:(NSError*)error{
    
}

#pragma mark - native
-(void) didShowNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacNativeAdDidShow", "");
    adView.mainImageView.hidden = [adView isVideoContents];
    
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:@"didShowNative"
                                            result:@"Success"
                                            adType:@"native"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) didClickNativeAdInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacNativeAdDidClick", "");
    
    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacNativeUnitID];
    
    [[JPCDataReportManager manager]reportWithType:kDidClickAd
                                      placementId:placementID
                                            reson:jpUnitID
                                           result:@""
                                           adType:@"native"
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
    
}

-(void) didStartPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    
}

-(void) didEndPlayingVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    
}

-(void) didEnterFullScreenVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
}

-(void) didExitFullScreenVideoInAdView:(ATNativeADView*)adView placementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    
}

- (void)didLoadSuccessDrawWith:(NSArray *)views placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    
}


- (void)didTapCloseButtonInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra {
    
}


#pragma mark - nativeSplash
-(void) finishLoadingNativeSplashAdForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    UnitySendMessage("AdObject", "JoypacSplashAdLoaded", "");
    
    [[JPCDataReportManager manager]reportWithType:kLoadAdCallBack
                                      placementId:placementID
                                            reson:@"SuccessCallBack"
                                           result:@"Success"
                                           adType:@"splash"
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
}

-(void) failedToLoadNativeSplashAdForPlacementID:(NSString*)placementID error:(NSError*)error extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacSplashAdLoadFail", "");
    
    [[JoypacNativeHelper helper]failToLoadSplash];
    
    [[JPCDataReportManager manager] reportWithType:kLoadAdCallBack
                                       placementId:placementID
                                             reson:[NSString stringWithFormat:@"%@",error]
                                            result:@"Fail"
                                            adType:@"splash"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}

-(void) didShowNativeSplashAdForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacSplashAdDidShow", "");
    
    [[JPCDataReportManager manager] reportWithType:kShowAdResult
                                       placementId:placementID
                                             reson:@"didshowNativeSplash"
                                            result:@"Success"
                                            adType:@"splash"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
}

-(void) didClickNaitveSplashAdForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    UnitySendMessage("AdObject", "JoypacSplashAdDidClick", "");
    
    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacSplashUnitID];
    
    [[JPCDataReportManager manager]reportWithType:kDidClickAd
                                      placementId:placementID
                                            reson:jpUnitID
                                           result:@""
                                           adType:@"splash"
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
}

-(void) didCloseNativeSplashAdForPlacementID:(NSString*)placementID extra:(NSDictionary *)extra{
    
    [[JoypacNativeHelper helper]failToLoadSplash];
    
    [ATNativeSplashWrapper loadNativeSplashAdWithPlacementID:placementID extra:@{kExtraInfoNativeAdTypeKey:@(ATGDTNativeAdTypeSelfRendering), kExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) -30.0f, 400.0f)], kATExtraNativeImageSizeKey:kATExtraNativeImageSize690_388} customData:nil delegate:[AnyThinkAdatper adatper]];
    
    UnitySendMessage("AdObject", "JoypacSplashAdDidClose", "");
    
}


#pragma mark - lazyingLoading
- (UIViewController *)rootViewController{
    
    if (!_rootViewController) {
        _rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return _rootViewController;
}


#pragma mark - nativeAnimation
- (UIImageView *)createAnimationWithSuperView:(UIView *)superView image:(UIImage *)image alpha:(CGFloat) alpha originPoint:(CGPoint)point toPoint:(CGPoint) point1 toPoint:(CGPoint)point2 toPoint:(CGPoint)point3 toPoint:(CGPoint)point4 animateKey:(NSString *)key{
    
    UIImageView *circleView = [[UIImageView alloc] initWithImage:image];

    circleView.alpha = 255.0*alpha/255.0;
    [superView addSubview:circleView];

    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    pathAnimation.calculationMode = kCAAnimationPaced;

    pathAnimation.fillMode = kCAFillModeForwards;

    pathAnimation.removedOnCompletion = NO;

    pathAnimation.duration = 2.3;

    pathAnimation.repeatCount = MAXFLOAT;
        
    CGMutablePathRef curvedPath = CGPathCreateMutable();

    CGPathMoveToPoint(curvedPath, NULL, point.x, point.y);

    CGPathAddQuadCurveToPoint(curvedPath, NULL, point.x, point.y,point1.x, point1.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, point1.x, point1.y, point2.x, point2.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, point2.x, point2.y, point3.x, point3.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, point3.x, point3.y, point4.x, point4.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, point4.x, point4.y, point.x, point.y);
    pathAnimation.path = curvedPath;

    CGPathRelease(curvedPath);

    [circleView.layer addAnimation:pathAnimation forKey:key];
    
    return circleView;
}

- (void)setUpAnimateWithSuperView:(UIView *)superView{

    UIImage *image01 = [self getNativeAnimateImageWithName:@"01"];
    [self createAnimationWithSuperView:superView image:image01 alpha:1 originPoint:CGPointMake(0, 1.4*image01.size.height) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) toPoint:CGPointMake(0,0) animateKey:@"moveTheSquare01"];
    
    
    UIImage *image02 = [self getNativeAnimateImageWithName:@"02"];
    [self createAnimationWithSuperView:superView image:image02 alpha:1 originPoint:CGPointMake(0, 1.05*image02.size.height) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) toPoint:CGPointMake(0,0) animateKey:@"moveTheSquare02"];
    
    
    UIImage *image03 = [self getNativeAnimateImageWithName:@"03"];
    [self createAnimationWithSuperView:superView image:image03 alpha:1 originPoint:CGPointMake(0, 0.7*image03.size.height) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) toPoint:CGPointMake(0,0) animateKey:@"moveTheSquare03"];
    
    UIImage *image04 = [self getNativeAnimateImageWithName:@"04"];
    [self createAnimationWithSuperView:superView image:image04 alpha:1 originPoint:CGPointMake(0, 0.35*image04.size.height) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) toPoint:CGPointMake(0,0) animateKey:@"moveTheSquare04"];
    
    UIImage *image05 = [self getNativeAnimateImageWithName:@"05"];
    [self createAnimationWithSuperView:superView image:image05 alpha:1 originPoint:CGPointMake(0, 0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) toPoint:CGPointMake(0,0) animateKey:@"moveTheSquare05"];
    
    UIImage *image06 = [self getNativeAnimateImageWithName:@"06"];
    [self createAnimationWithSuperView:superView image:image06 alpha:1 originPoint:CGPointMake(0.35*image06.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare06"];
    
    UIImage *image07 = [self getNativeAnimateImageWithName:@"07"];
    [self createAnimationWithSuperView:superView image:image07 alpha:1 originPoint:CGPointMake(0.7*image07.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare07"];
    
    UIImage *image08 = [self getNativeAnimateImageWithName:@"08"];
    [self createAnimationWithSuperView:superView image:image08 alpha:1 originPoint:CGPointMake(1.05*image08.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare08"];
    
    UIImage *image09 = [self getNativeAnimateImageWithName:@"09"];
    [self createAnimationWithSuperView:superView image:image09 alpha:0.9 originPoint:CGPointMake(1.4*image09.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare09"];
    
    UIImage *image09_10 = [self getNativeAnimateImageWithName:@"10"];
    [self createAnimationWithSuperView:superView image:image09_10 alpha:0.8 originPoint:CGPointMake(1.75*image09_10.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare10"];
    
    UIImage *image09_11 = [self getNativeAnimateImageWithName:@"11"];
    [self createAnimationWithSuperView:superView image:image09_11 alpha:0.7 originPoint:CGPointMake(2.1*image09_11.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare11"];
    
    UIImage *image09_12 = [self getNativeAnimateImageWithName:@"12"];
    [self createAnimationWithSuperView:superView image:image09_12 alpha:0.6 originPoint:CGPointMake(2.45*image09_12.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare12"];
    
    UIImage *image09_13 = [self getNativeAnimateImageWithName:@"13"];
    [self createAnimationWithSuperView:superView image:image09_13 alpha:0.5 originPoint:CGPointMake(2.8*image09_13.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare13"];
    
    UIImage *image09_14 = [self getNativeAnimateImageWithName:@"14"];
    [self createAnimationWithSuperView:superView image:image09_14 alpha:0.4 originPoint:CGPointMake(3.15*image09_14.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare14"];
    
    UIImage *image09_15 = [self getNativeAnimateImageWithName:@"15"];
    [self createAnimationWithSuperView:superView image:image09_15 alpha:0.3 originPoint:CGPointMake(3.5*image09_15.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare15"];
    
    UIImage *image09_16 = [self getNativeAnimateImageWithName:@"16"];
    [self createAnimationWithSuperView:superView image:image09_16 alpha:0.2 originPoint:CGPointMake(3.85*image09_16.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare16"];
    
    UIImage *image09_17 = [self getNativeAnimateImageWithName:@"17"];
    [self createAnimationWithSuperView:superView image:image09_17 alpha:0.1 originPoint:CGPointMake(4.2*image09_17.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare17"];
    
    UIImage *image09_18 = [self getNativeAnimateImageWithName:@"18"];
    [self createAnimationWithSuperView:superView image:image09_18 alpha:0.1 originPoint:CGPointMake(4.55*image09_18.size.width, 0) toPoint:CGPointMake(0,0) toPoint:CGPointMake(0,CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame),0) animateKey:@"moveTheSquare18"];
    
    
    UIImage *image10 = [self getNativeAnimateImageWithName:@"01"];
    [self createAnimationWithSuperView:superView image:image10 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)-1.4*image10.size.height) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare10"];
    
    UIImage *image11 = [self getNativeAnimateImageWithName:@"02"];
    [self createAnimationWithSuperView:superView image:image11 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)-1.05*image11.size.height) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare11"];
    
    UIImage *image12 = [self getNativeAnimateImageWithName:@"03"];
    [self createAnimationWithSuperView:superView image:image12 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)-0.7*image12.size.height) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare12"];
    
    UIImage *image13 = [self getNativeAnimateImageWithName:@"04"];
    
    [self createAnimationWithSuperView:superView image:image13 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)-0.35*image13.size.height) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare13"];

    UIImage *image14 = [self getNativeAnimateImageWithName:@"05"];
    [self createAnimationWithSuperView:superView image:image14 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare14"];
    
    UIImage *image15 = [self getNativeAnimateImageWithName:@"06"];
    [self createAnimationWithSuperView:superView image:image15 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame)-0.35*image15.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare15"];

    UIImage *image16 = [self getNativeAnimateImageWithName:@"07"];
    [self createAnimationWithSuperView:superView image:image16 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 0.7*image16.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare16"];

    UIImage *image17 = [self getNativeAnimateImageWithName:@"08"];
    [self createAnimationWithSuperView:superView image:image17 alpha:1 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 1.05*image17.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare17"];

    UIImage *image18 = [self getNativeAnimateImageWithName:@"09"];
    [self createAnimationWithSuperView:superView image:image18 alpha:0.9 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 1.4*image18.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18"];
    
    UIImage *image18_10 = [self getNativeAnimateImageWithName:@"10"];
    [self createAnimationWithSuperView:superView image:image18_10 alpha:0.8 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 1.75*image18_10.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_10"];
    
    UIImage *image18_11 = [self getNativeAnimateImageWithName:@"11"];
    [self createAnimationWithSuperView:superView image:image18_11 alpha:0.7 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 2.1*image18_11.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_11"];
    
    UIImage *image18_12 = [self getNativeAnimateImageWithName:@"12"];
    [self createAnimationWithSuperView:superView image:image18_12 alpha:0.6 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 2.45*image18_12.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_12"];
    
    UIImage *image18_13 = [self getNativeAnimateImageWithName:@"13"];
    [self createAnimationWithSuperView:superView image:image18_13 alpha:0.5 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 2.8*image18_13.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_13"];
    
    UIImage *image18_14 = [self getNativeAnimateImageWithName:@"14"];
    [self createAnimationWithSuperView:superView image:image18_14 alpha:0.4 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 3.15*image18_14.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_14"];
    
    UIImage *image18_15 = [self getNativeAnimateImageWithName:@"15"];
    [self createAnimationWithSuperView:superView image:image18_15 alpha:0.3 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 3.5*image18_15.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_15"];
    
    UIImage *image18_16 = [self getNativeAnimateImageWithName:@"16"];
    [self createAnimationWithSuperView:superView image:image18_16 alpha:0.2 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 3.85*image18_16.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_16"];
    
    UIImage *image18_17 = [self getNativeAnimateImageWithName:@"17"];
    [self createAnimationWithSuperView:superView image:image18_17 alpha:0.1 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 4.2*image18_17.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_17"];
    
    UIImage *image18_18 = [self getNativeAnimateImageWithName:@"18"];
    [self createAnimationWithSuperView:superView image:image18_18 alpha:0.1 originPoint:CGPointMake(CGRectGetWidth(superView.frame)- 4.55*image18_18.size.width, CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), CGRectGetHeight(superView.frame)) toPoint:CGPointMake(CGRectGetWidth(superView.frame), 0) toPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, CGRectGetHeight(superView.frame)) animateKey:@"moveTheSquare18_18"];
    
}

- (UIImage *) getNativeAnimateImageWithName:(NSString *)imageName{
    
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"joypacSplash" ofType :@"bundle"];
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *img_path = [bundle pathForResource:imageName ofType:@"png"];
    
    return [UIImage imageWithContentsOfFile:img_path];
    
}

#pragma mark - compare version
- (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2
{
    NSArray *list1 = [version1 componentsSeparatedByString:@"."];
    NSArray *list2 = [version2 componentsSeparatedByString:@"."];
    for (int i = 0; i < list1.count || i < list2.count; i++)
    {
        NSInteger a = 0, b = 0;
        if (i < list1.count) {
            a = [list1[i] integerValue];
        }
        if (i < list2.count) {
            b = [list2[i] integerValue];
        }
        if (a > b) {
            return 1;//version1大于version2
        } else if (a < b) {
            return -1;//version1小于version2
        }
    }
    return 0;//version1等于version2
    
}

#pragma mark - instance
+ (AnyThinkAdatper *)adatper{
    static AnyThinkAdatper *adatper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adatper = [[AnyThinkAdatper alloc]init];
    });
    return adatper;
}

@end

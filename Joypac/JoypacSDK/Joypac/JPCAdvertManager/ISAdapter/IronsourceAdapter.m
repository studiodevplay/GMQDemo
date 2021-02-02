//
//  IronsourceAdapter.m
//  Unity-iPhone
//
//  Created by 洋吴 on 2019/9/17.
//

#import "IronsourceAdapter.h"
//#import <IronSource/IronSource.h>
#import "JPCDataReportManager.h"
#import "JPCSearchManager.h"
#import "AnyThinkAdatper.h"



@interface IronsourceAdapter ()
//<
//ISRewardedVideoDelegate,
//ISInterstitialDelegate
//>

@property (nonatomic,strong)UIViewController *rootViewController;

@property (nonatomic,strong)NSString *intersititalUnitId;

@property (nonatomic,strong)NSString *bannerUnitId;

@property (nonatomic,strong)NSString *rewardVideoUnitId;

@property (nonatomic,strong)NSString *nativeUnitId;

@property (nonatomic,assign)BOOL isOnReward;


@end

@implementation IronsourceAdapter

+ (IronsourceAdapter *)adatper{
    static IronsourceAdapter *adatper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adatper = [[IronsourceAdapter alloc]init];
    });
    return adatper;
}


//- (void)initSDKWithAppId:(NSString *)appId appKey:(NSString *)appKey {
//    
////    [IronSource initWithAppKey:appId adUnits:@[IS_REWARDED_VIDEO,IS_INTERSTITIAL]];
////
////
////    [IronSource setRewardedVideoDelegate:self];
////
////    [IronSource setInterstitialDelegate:self];
//    
//    //初始化anyThink banner和native使用anyThink
//    NSString *upAppId = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"UparpuAppId"];
//    NSString *upAppKey = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"UparpuAppKey"];
//    [[AnyThinkAdatper adatper] initSDKWithAppId:upAppId appKey:upAppKey];
//    
//}
//
//
//- (void)loadADWithPlacementId:(NSString *)placementId adType:(ADType)type {
//    
//    if (type == kADTypeVideo) {
//        self.rewardVideoUnitId = placementId;
//    }else if (type == kADTypeBanner){
//        self.bannerUnitId = placementId;
//        [self loadISBanner];
//    }else if (type == kADTypeIterstital){
//        self.intersititalUnitId = placementId;
////        [IronSource loadInterstitial];
//    }else if (type == kADTypeNative){
//        self.nativeUnitId = placementId;
//        [self loadATNativeWithUnitId:placementId];
//    }else{
//        
//    }
//}
//
//- (void)loadISBanner{
//    
//    [[AnyThinkAdatper adatper] loadADWithPlacementId:self.bannerUnitId adType:kADTypeBanner nativeFrame:CGRectZero];
//    
//}
//
//
//- (BOOL)isReadyADWithADType:(ADType)type {
//    
//    if (type == kADTypeVideo) {
////        return [IronSource hasRewardedVideo];
//    }else if (type == kADTypeBanner){
//        return [[AnyThinkAdatper adatper] isReadyADWithADType:kADTypeBanner];
//    }else if (type == kADTypeIterstital){
////        return [IronSource hasInterstitial];
//    }else if (type == kADTypeNative){
//        return [[AnyThinkAdatper adatper] isReadyADWithADType:kADTypeNative];
//    }else{
//        return false;
//    }
//}
//
//- (void)showADWithADType:(ADType)type {
//    
//    if (type == kADTypeVideo) {
//        
////        [IronSource showRewardedVideoWithViewController:self.rootViewController placement:self.rewardVideoUnitId];
//        
//    }else if (type == kADTypeBanner){
//        
//        [[AnyThinkAdatper adatper] showADWithADType:kADTypeBanner];
//        
//    }else if (type == kADTypeIterstital){
//        
////        [IronSource showInterstitialWithViewController:self.rootViewController placement:self.intersititalUnitId];
//        
//        
//    }else if (type == kADTypeNative){
//        
//        [[AnyThinkAdatper adatper] showNative];
//        
//    }else{
//        
//    }
//}
//
//#pragma mark native
//- (void)layoutNativeWithX:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w H:(CGFloat)h {
//    
//    [[AnyThinkAdatper adatper]layoutNativeWithX:x Y:y W:w H:h];
//    
//}
//
//- (void)showNative {
//    
//    [[AnyThinkAdatper adatper]showNative];
//    
//}
//
//- (void)removeNative {
//    
//    [[AnyThinkAdatper adatper]removeNative];
//    
//}
//
//- (void)hideNative {
//    
//    [[AnyThinkAdatper adatper]hideNative];
//}
//
//#pragma mark banner
//
//- (void)setBannerAlign:(BannerAlign)align offset:(CGPoint)offset {
//    
//    [[AnyThinkAdatper adatper] setBannerAlign:align offset:offset];
//}
//
//- (void)hideBanner {
//    
//    [[AnyThinkAdatper adatper]hideBanner];
//}
//
//- (void)removeBanner {
//    
//    [[AnyThinkAdatper adatper]removeBanner];
//}
//
//- (void)loadADWithPlacementId:(NSString *)placementId adType:(ADType)type nativeFrame:(CGRect)frame {
//    
//}
//
//- (void)nativeStyle:(NSString *)nativeStyle {
//    
//}
//
//
//
//- (void)setNativeStyle {
//    
//}


#pragma mark rewardvideoDelegate
//- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
//
//    UnitySendMessage("AdObject", "JoypacVideoAdPlayClicked", "");
//
//    if (self.rewardVideoUnitId)return;
//
//    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacRVUnitID];
//
//    [[JPCDataReportManager manager]reportWithType:kDidClickAd
//                                      placementId:self.rewardVideoUnitId
//                                            reson:jpUnitID
//                                           result:@""
//                                           adType:@"rewardVideo"
//                                           extra1:@""
//                                           extra2:@""
//                                           extra3:@""];
//
//
//}
//
//- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
//
//    self.isOnReward = YES;
//
//
//}

//- (void)rewardedVideoDidClose {
//
//    if (self.isOnReward) {
//
//        UnitySendMessage("AdObject", "JoypacVideoAdPlayClosed", [@"True" UTF8String]);
//
//        [[JPCDataReportManager manager]reportWithType:kRewardedInfo
//                                          placementId:self.rewardVideoUnitId
//                                                reson:@"didReceiveReward"
//                                               result:@""
//                                               adType:@"rewardVideo"
//                                               extra1:@""
//                                               extra2:@""
//                                               extra3:@""];
//
//    }else{
//        UnitySendMessage("AdObject", "JoypacVideoAdPlayClosed", [@"False" UTF8String]);
//    }
//    self.isOnReward = NO;
//
//    [[JPCDataReportManager manager]reportWithType:kRewardedInfo
//                                      placementId:self.rewardVideoUnitId
//                                            reson:@"didClose"
//                                           result:@""
//                                           adType:@"rewardVideo"
//                                           extra1:@""
//                                           extra2:@""
//                                           extra3:@""];
//
//
//
//}
//
//- (void)rewardedVideoDidEnd {
//
//    UnitySendMessage("AdObject", "JoypacVideoAdPlayEnd", "");
//
//    [[JPCDataReportManager manager] reportWithType:kShowAdResult
//                                       placementId:self.rewardVideoUnitId
//                                             reson:@"didEndPlayingRewardVideo"
//                                            result:@"Success"
//                                            adType:@"rewardVideo"
//                                            extra1:@""
//                                            extra2:@""
//                                            extra3:@""];
//
//
//}
//
//- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
//
//    UnitySendMessage("AdObject", "JoypacVideoAdPlayFail", "");
//
//    [[JPCDataReportManager manager] reportWithType:kShowAdResult
//                                       placementId:self.rewardVideoUnitId
//                                             reson:[NSString stringWithFormat:@"%@",error]
//                                            result:@"Fail"
//                                            adType:@"rewardVideo"
//                                            extra1:@""
//                                            extra2:@""
//                                            extra3:@""];
//
//
//}
//
//- (void)rewardedVideoDidOpen {
//
//    UnitySendMessage("AdObject", "JoypacVideoAdPlayStart", "");
//
//    [[JPCDataReportManager manager] reportWithType:kShowAdResult
//                                       placementId:self.rewardVideoUnitId
//                                             reson:@"didStartPlayingRewardVideo"
//                                            result:@"Success"
//                                            adType:@"rewardVideo"
//                                            extra1:@""
//                                            extra2:@""
//                                            extra3:@""];
//
//}
//
//- (void)rewardedVideoDidStart {
//
//
//
//
//}
//
//- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
//
//    if (available) {
//
//        UnitySendMessage("AdObject", "JoypacVideoAdLoaded", "");
//
//    }else{
//
//        UnitySendMessage("AdObject", "JoypacVideoAdLoadFail", "");
//    }
//
//    NSString *loadResult = available ? @"Success" : @"Fail";
//    [[JPCDataReportManager manager] reportWithType:kLoadAdCallBack
//                                       placementId:self.rewardVideoUnitId
//                                             reson:@"Not Return Reson"
//                                            result:loadResult
//                                            adType:@"rewardVideo"
//                                            extra1:@""
//                                            extra2:@""
//                                            extra3:@""];
//
//}
//
//
//#pragma mark interstital
//- (void)didClickInterstitial {
//
//    if (!self.intersititalUnitId)return;
//
//    UnitySendMessage("AdObject", "JoypacIntersititalAdClick", "");
//
//    NSString *jpUnitID = [[JPCSearchManager shareManager]jp_getJPUnitIDWithKey:kJoypacIVUnitID];
//
//
//    [[JPCDataReportManager manager]reportWithType:kDidClickAd
//                                        placementId:self.intersititalUnitId
//                                            reson:jpUnitID
//                                            result:@""
//                                            adType:@"interstitial"
//                                           extra1:@""
//                                           extra2:@""
//                                           extra3:@""];
//
//}
//
//- (void)interstitialDidClose {
//
//    UnitySendMessage("AdObject", "JoypacIntersititalAdClose", "");
//}
//
//- (void)interstitialDidFailToLoadWithError:(NSError *)error {
//
//    UnitySendMessage("AdObject", "JoypacIntersititalAdLoadFail", "");
//
//    [[JPCDataReportManager manager] reportWithType:kLoadAdCallBack
//                                       placementId:self.intersititalUnitId
//                                             reson:[NSString stringWithFormat:@"%@",error]
//                                            result:@"Fail"
//                                            adType:@"interstitial"
//                                            extra1:@""
//                                            extra2:@""
//                                            extra3:@""];
//}
//
//- (void)interstitialDidFailToShowWithError:(NSError *)error {
//
//    UnitySendMessage("AdObject", "JoypacIntersititalAdsShowFail", "");
//
//    [[JPCDataReportManager manager] reportWithType:kShowAdResult
//                                       placementId:self.intersititalUnitId
//                                             reson:[NSString stringWithFormat:@"%@",error]
//                                            result:@"Fail"
//                                            adType:@"interstitial"
//                                            extra1:@""
//                                            extra2:@""
//                                            extra3:@""];
//}
//
//- (void)interstitialDidLoad {
//
//    UnitySendMessage("AdObject", "JoypacIntersititalAdLoad", "");
//
//    [[JPCDataReportManager manager]reportWithType:kLoadAdCallBack
//                                      placementId:self.intersititalUnitId
//                                            reson:@"SuccessCallBack"
//                                           result:@"Success"
//                                           adType:@"interstitial"
//                                           extra1:@""
//                                           extra2:@""
//                                           extra3:@""];
//}
//
//- (void)interstitialDidOpen {
//
//    UnitySendMessage("AdObject", "JoypacIntersititalAdsStartPlayVideo", "");
//}
//
//- (void)interstitialDidShow {
//
//    UnitySendMessage("AdObject", "JoypacIntersititalAdShow", "");
//
//    [[JPCDataReportManager manager] reportWithType:kShowAdResult
//                                       placementId:self.intersititalUnitId
//                                             reson:@"didShow"
//                                            result:@"Success"
//                                            adType:@"interstitial"
//                                            extra1:@""
//                                            extra2:@""
//                                            extra3:@""];
//
//}
//
//
//- (UIViewController *)rootViewController{
//    if (!_rootViewController) {
//        _rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    }
//    return _rootViewController;
//}
//
//
//#pragma mark anyThinkNative
//- (void)loadATNativeWithUnitId:(NSString *)unitId{
//
//    [[AnyThinkAdatper adatper] loadADWithPlacementId:unitId adType:kADTypeNative nativeFrame:CGRectZero];
//
//}

@end

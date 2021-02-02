//
//  JoypacUnityBirdge.m
//  Unity-iPhone
//
//  Created by 洋吴 on 2019/6/11.
//

#import <Foundation/Foundation.h>
#import "JPCAdvertManager.h"
#import "JPCAdvertManager+native.h"
#import "JPCAdvertManager+banner.h"
#import "JPCAdvertManager+interstitial.h"
#import "JPCAdvertManager+rewardVideo.h"
#import "JoypacNativeHelper.h"
#import "JoypacGDPR.h"
#import "JPCDataReportManager.h"
#import "JPLogManager.h"

extern "C" {
    
    void initSDK(const char *appID, const char *userType,const char *adType){
        
        NSString *appId = [NSString stringWithUTF8String:appID];
        NSString *uType = [NSString stringWithUTF8String:userType];
        NSString *adsType = [NSString stringWithUTF8String:adType];
        [[JPCAdvertManager manager] startSDKWithAppID:appId userType:uType adType:adsType];
    }
    
    void loadBannerWithPlacementId(const char *placementId){
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager loadBannerWithPlacementId:unitId];
        [manager setBannerAlign:BannerAlign(BannerAlignBottom | BannerAlignHorizontalCenter) offset:CGPointMake(0, 0)];
    }
    
    bool isReadyBannerWithPlacementId(const char *placementId){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        return [manager isReadyBannerWithPlacement:unitId];
        
    }
    
    void showBannerWithPlacementId(const char *placementId){
        
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager showBannerWithPlacementId:unitId];
    }
    
    void setBannerAlign(const int align, float x, float y){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager setBannerAlign:(BannerAlign)align offset:CGPointMake(x, y)];
    }
    
    void hideBanner(){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager hideBanner];
        
    }
    
    void removeBanner(){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager removeBanner];
    }
    
    void loadInterstitalWithPlacementId(const char *placementId){
        
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager loadInterstitialWithPlacementId:unitId];
        
    }
    
    bool isReadyInterstitalWithPlacementId(const char *placementId){
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        return [manager isReadyInterstitialWithPlacementId:unitId];
        
    }
    
    void showIntersititalWithPlacementId(const char *placementId){
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager showInterstitialWithPlacementId:unitId];
        
    }
    
    void loadNativeWithPlacementId(const char *placementId,const float width,const float height){
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager loadNativeAdWithPlacementId:unitId nativeFrame:CGRectMake(0, 0, width, height)];
        
    }
    
    bool isReadyNativeWithPlacementId(const char *placementId){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        return [manager isReadyNativeAdWithPlacementId:unitId];
        
    }
    
    void layoutNativeWithFrame(const float x,const float y,const float width, const float height){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager layoutNativeWithX:x Y:y W:width H:height];
        
    }
    
    void showNativeWithPlacementId(const char *placementId){
        NSString *unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager showNativeWithPlacementId:unitId];
        
    }
    
    void hideNative(){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager hideNative];
        
    }
    
    void removeNative(){
        
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager removeNative];
        
    }
    
    void loadRewardVideoWithPlacementId(const char *placementId){
        
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager loadVideoWithPlacementId:unitId];
    }
    
    bool isReadyRewardVideoWithPlacementId(const char *placementId){
        
        NSString* unitId = [NSString stringWithUTF8String:placementId];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        return [manager isReadVideoWithPlacementId:unitId];
        
    }
    
    void showRewardVideoWithPlacementId(const char *placementId, const char *eventPosition){
        
        NSString *unitId = [NSString stringWithUTF8String:placementId];
        NSString *position = [NSString stringWithUTF8String:eventPosition];
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [manager showVideoWithPlacementId:unitId eventPosition:position];
        
    }
    
    void setUpSplashConfig(const char *iap,const char *dispatchTime,const char *hotScreen){
        
        NSString *isIap = [NSString stringWithUTF8String:iap];
        NSString *dispatch = [NSString stringWithUTF8String:dispatchTime];
        NSString *hs = [NSString stringWithUTF8String:hotScreen];
        [[JoypacNativeHelper helper] getSplashPara:isIap dispatchTime:dispatch hotScreen:hs];
    }
    
    bool presentViewControllerAtProtectArea(){
        
        return [[JoypacGDPR shareInstance] presentViewControllerInProtectArea];
    };
    
    void joypacEventLog(const char *eventSort,const char *eventType,const char *eventPosition,const char *eventExtra){
        NSString *event_sort = [NSString stringWithUTF8String:eventSort];
        NSString *event_type = [NSString stringWithUTF8String:eventType];
        NSString *event_position = [NSString stringWithUTF8String:eventPosition];
        NSString *event_extra = [NSString stringWithUTF8String:eventExtra];
        [[JPCDataReportManager manager]reportEventWithEventType:event_type eventSort:event_sort position:event_position eventExtra:event_extra];
    }
    
    void conserveUserPurchaseData(){
        
        [kUserDefault setValue:@"1" forKey:kJoypacUserType];
    }

    void receiveAdJustData(const char *adJustJson){
        
        
        [kUserDefault setObject:[NSString stringWithUTF8String:adJustJson] forKey:kJoypacAdjustJsonString];
        
        [[JPCAdvertManager manager]refreshSegment];
        
    }

    void receiveGameGroupId(const char *jsonString){
        
        [kUserDefault setValue:[NSString stringWithUTF8String:jsonString] forKey:kCgroupId];
        
    }
    const char *getDeviceID(){

        
        return strdup([[JPCHTTPParameter parameter].devids UTF8String]);
        
    }

    void setLogEnable(bool enable){
    
    [JPLogManager setLogEnable:enable];
    }

}

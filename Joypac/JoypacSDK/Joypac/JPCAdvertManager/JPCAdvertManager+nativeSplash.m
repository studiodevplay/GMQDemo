//
//  JPCAdvertManager+nativeSplash.m
//  JoypacSDK
//
//  Created by 洋吴 on 2019/6/20.
//  Copyright © 2019 洋吴. All rights reserved.
//

#import "JPCAdvertManager+nativeSplash.h"
#import <objc/runtime.h>


static NSString *backgroundTimeKey = @"backgroundTimeKey";
static void *backgroundViewKey = &backgroundViewKey;
static void *disLinkKey = &disLinkKey;

@implementation JPCAdvertManager (nativeSplash)

#pragma mark 属性添加
- (void)setDisLink:(CADisplayLink *)disLink{
    
    objc_setAssociatedObject(self, &disLinkKey, disLink, OBJC_ASSOCIATION_RETAIN);
    
}

- (CADisplayLink *)disLink{
    
    return objc_getAssociatedObject(self, &disLinkKey);
}

- (void)setBackgroundView:(UIView *)backgroundView{
    
    objc_setAssociatedObject(self, &backgroundViewKey, backgroundView, OBJC_ASSOCIATION_RETAIN);
    
}
- (UIView *)backgroundView{
    
    return objc_getAssociatedObject(self, &backgroundViewKey);
}

- (void)setBackgroundTime:(NSString *)backgroundTime{
    
    objc_setAssociatedObject(self, &backgroundTimeKey,backgroundTime, OBJC_ASSOCIATION_COPY);
    
}


- (NSString *)backgroundTime{
    
    return objc_getAssociatedObject(self, &backgroundTimeKey);
}

#pragma mark 请求广告方法
- (void)loadNativeSplashWithPlacementId:(NSString*)placementId{
    
    if ([JPCAdvertManager manager].initializeSDK) {
        
        JPCUnitModel *splashModel = [self splashModelByPlacementID:placementId];
        
        if(splashModel.unitID != nil){
            [[JPCAdvertManager manager].delegate loadADWithPlacementId:splashModel.unitID adType:kADTypeNativeSplash nativeFrame:CGRectZero];
        }
        
    //数据上报
    [[JPCDataReportManager manager] reportWithType:kTriggerLoadAd
                                       placementId:splashModel.unitID
                                             reson:@""
                                            result:placementId
                                            adType:@"splash"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
        
    }
}

- (BOOL)isReadyNativeSplashWithPlacementId:(NSString *)placementId{
    
    if (![JPCAdvertManager manager].initializeSDK) return NO;
    
    JPCUnitModel *splashModel = [self splashModelByPlacementID:placementId];
    NSInteger minTimeInterval = [splashModel.minTimeInterval integerValue];
    NSInteger maxTimeInterval = [splashModel.maxTimeInterval integerValue];
    
    NSInteger idx = [kUserDefault integerForKey:@"splashIndex"]?[kUserDefault integerForKey:@"splashIndex"]:0;
    NSString *lastShowTime = [kUserDefault stringForKey:@"splashLastShowTime"]?[kUserDefault stringForKey:@"splashLastShowTime"]:@"0";
    
    
    //获取当前时间
    NSString *nowShowTime = [NSDate getCurrentTime];
    //这次展示距离上次展示时间
    NSInteger timeInterval = [NSDate timeIntervalFromLastTime:lastShowTime ToCurrentTime:nowShowTime];
    
    if ([splashModel.status isEqualToString:@"1"]) {
        
        if (timeInterval >= minTimeInterval) {
            
            if (timeInterval >= maxTimeInterval && maxTimeInterval != 0) {
                
                BOOL splashIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeNativeSplash];
                if (splashIsReady) {
                    [self reportSplashIsReadyForUnitId:splashModel.unitID JPUnitId:placementId result:@"true"];
                }else{
                    [self reportSplashIsReadyForUnitId:splashModel.unitID JPUnitId:placementId result:@"false"];
                }
                
                return splashIsReady;
                
            }else{
                
                if ([[self getAdsOrderWithIndex:idx adOrder:splashModel.adOrder] isEqualToString:@"1"]) {
                    
                    BOOL splashIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeNativeSplash];
                    if (splashIsReady) {
                        [self reportSplashIsReadyForUnitId:splashModel.unitID JPUnitId:placementId result:@"true"];
                    }else{
                        [self reportSplashIsReadyForUnitId:splashModel.unitID JPUnitId:placementId result:@"false"];
                    }
                    return splashIsReady;
                    
                }else{
                    
                    [self loadNativeSplashWithPlacementId:placementId];
                    idx = idx < splashModel.adOrder.length - 1 ? idx+1 : 0;
                    [kUserDefault  setInteger:idx forKey:@"splashIndex"];
                    [self reportSplashIsReadyForUnitId:splashModel.unitID JPUnitId:placementId result:@"0"];
                    return NO;
                }
            }
        }else{
            
            [self loadNativeSplashWithPlacementId:placementId];
            
            [self reportSplashIsReadyForUnitId:splashModel.unitID JPUnitId:placementId result:@"0"];
            
            return NO;
        }
    }else{
        
        [self reportSplashIsReadyForUnitId:splashModel.unitID JPUnitId:placementId result:@"0"];
        
        return NO;
    }

}

- (void)reportSplashIsReadyForUnitId:(NSString *)unitId JPUnitId:(NSString *)JPUnitId result:(NSString *)result{
    
    [[JPCDataReportManager manager] reportWithType:kIsReady
                                       placementId:unitId
                                             reson:JPUnitId
                                            result:result
                                            adType:@"splash"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
}

- (void)showNativeSplashWithPlacementId:(NSString *)placementId{
    
    
    [[JPCAdvertManager manager].delegate showADWithADType:kADTypeNativeSplash];
    JPCUnitModel *splashModel = [self splashModelByPlacementID:placementId];
    
    [self reportSplashNativeWithPlacementid:splashModel.unitID
                                    adOrder:splashModel.adOrder
                                   JPUnitId:placementId];
    
    
}

- (void)reportSplashNativeWithPlacementid:(NSString *)placementid adOrder:(NSString *)adOrder JPUnitId:(NSString *)unitId{
    
    //数据上报
    if (!kISNullString(placementid) && !kISNullString(unitId) && !kISNullString(adOrder)) {
        [self.searchManager jp_putJPUnitID:unitId Key:kJoypacSplashUnitID];
        
        NSInteger interIndex = [kUserDefault integerForKey:@"splashIndex"] ? [kUserDefault integerForKey:@"splashIndex"] : 0;
        
        
        interIndex = interIndex < adOrder.length - 1 ? interIndex+1 : 0;
        
        [kUserDefault setInteger:interIndex forKey:@"splashIndex"];
        [kUserDefault setObject:[NSDate getCurrentTime] forKey:@"splashLastShowTime"];
        
        [[JPCDataReportManager manager] reportWithType:kTriggerShowAd
                                           placementId:placementid
                                                 reson:unitId
                                                result:@""
                                                adType:@"splash"
                                                extra1:@""
                                                extra2:@""
                                                extra3:@""];
        
        
    }
    
    
}

- (NSString *)getAdsOrderWithIndex:(NSInteger)index adOrder:(NSString *)adOrder{
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (int i=0; i<adOrder.length; i++) {
        [arrM addObject:[adOrder substringWithRange:NSMakeRange(i, 1)]];
    }
    if (index > adOrder.length - 1) {
        return arrM[0];
    }else{
        return arrM[index];
    }
    
}

- (JPCUnitModel *)splashModelByPlacementID:(NSString *)placementID{
    
    if (![JPCAdvertManager manager].splashModel) {
        
        JPCSearchManager *searchManager = [JPCSearchManager shareManager];
        JPCUnitModel *splashModel = [searchManager jp_getUnitConfigWithPlacementID:placementID];
        if (!splashModel) {
            splashModel = [searchManager jp_getDefaultUnitConfigWithKey:kJoypacSplashModel unitId:nil];
        }
        [JPCAdvertManager manager].splashModel = splashModel;
        return [JPCAdvertManager manager].splashModel;
        
    }else{
        return [JPCAdvertManager manager].splashModel;
    }
}




@end

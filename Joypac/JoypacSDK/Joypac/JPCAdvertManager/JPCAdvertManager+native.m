//
//  JPCAdvertManager+native.m

//
//  Created by 洋吴 on 2019/5/8.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCAdvertManager+native.h"


@implementation JPCAdvertManager (native)


- (void)loadNativeAdWithPlacementId:(NSString *)placementId nativeFrame:(CGRect)frame{
    
    if ([JPCAdvertManager manager].initializeSDK) {
        JPCUnitModel *nativeModel = [self getNativeUnitModelWithPlacementID:placementId];
        
        if (nativeModel.unitID != nil) {
            //请求广告
            [[JPCAdvertManager manager].delegate loadADWithPlacementId:nativeModel.unitID adType:kADTypeNative nativeFrame:frame];
            NSDictionary *nativeDict = [[JPCHTTPParameter parameter] toDictionaryWithJsonString:nativeModel.extra];
            NSString *nativeStyle = nativeDict[@"nativeStyle"];
            if (kISNullString(nativeStyle)) {
                nativeStyle = @"defaultStyle";
            }
            [[JPCAdvertManager manager].delegate nativeStyle:nativeStyle];
        }
        
       
            
    //数据上报
    [[JPCDataReportManager manager] reportWithType:kTriggerLoadAd
                                       placementId:nativeModel.unitID
                                             reson:@"" result:placementId
                                            adType:@"native"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
            
     
    }
    
    
}

- (BOOL)isReadyNativeAdWithPlacementId:(NSString *)placementId{
    
    
    if (![JPCAdvertManager manager].initializeSDK) return NO;
    
    JPCUnitModel *nativeModel = [self getNativeUnitModelWithPlacementID:placementId];
    //获取最小时间间隔
    NSInteger getMinTimeInterval = [nativeModel.minTimeInterval integerValue];
    //获取最大时间间隔
    NSInteger getMaxTimeInterval = [nativeModel.maxTimeInterval integerValue];
    //获取上次广告展示时间
    NSDictionary *para = [self.searchManager jp_getLastShowTimeAndIndexWithPlacement:placementId];
    
    NSString *lastShowTime;
    
    int idx;
    if (!kISNullDict(para)) {
        lastShowTime = para[@"JPCLASTSHOWTIME"];
        idx = [para[@"JPCLASTINDEX"] intValue];
    }else{
        lastShowTime = [NSDate getCurrentTime];
        idx = 0;
    }
    //获取当前时间
    NSString *nowShowTime = [NSDate getCurrentTime];
    
    //这次展示距离上次展示时间
    NSInteger timeInterval = [NSDate timeIntervalFromLastTime:lastShowTime ToCurrentTime:nowShowTime];
    if ([nativeModel.status isEqualToString:@"1"]) {
        
        if (timeInterval >= getMinTimeInterval) {
            
            if (timeInterval >= getMaxTimeInterval) {
                BOOL nativeIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeNative];
                
                if (nativeIsReady) {
                    
                    [self reportNativeIsReadyForUnitId:nativeModel.unitID JPUnitId:placementId result:@"true"];
                }else{
                    [self reportNativeIsReadyForUnitId:nativeModel.unitID JPUnitId:placementId result:@"false"];
                }
                
                return nativeIsReady;
                
                
            }else{
                
                if ([[self getNativeAdOrderWithIndex:idx adOrder:nativeModel.adOrder] isEqualToString:@"1"]) {
                    BOOL nativeIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeNative];
                    if (nativeIsReady) {
                        
                        [self reportNativeIsReadyForUnitId:nativeModel.unitID JPUnitId:placementId result:@"true"];
                    }else{
                        [self reportNativeIsReadyForUnitId:nativeModel.unitID JPUnitId:placementId result:@"false"];
                    }
                    return nativeIsReady;
                }else{
                    
                    [self reportNativeIsReadyForUnitId:nativeModel.unitID JPUnitId:placementId result:@"0"];
                    return NO;
                }
            }
        }else{
            [self reportNativeIsReadyForUnitId:nativeModel.unitID JPUnitId:placementId result:@"0"];
            return NO;
        }
    }else{
        [self reportNativeIsReadyForUnitId:nativeModel.unitID JPUnitId:placementId result:@"0"];
        return NO;
    }
    
}

- (void)reportNativeIsReadyForUnitId:(NSString *)unitId JPUnitId:(NSString *)JPUnitId result:(NSString *)result{
    
    [[JPCDataReportManager manager] reportWithType:kIsReady
                                       placementId:unitId
                                             reson:JPUnitId
                                            result:result
                                            adType:@"native"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
}

- (void)layoutNativeWithX:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w H:(CGFloat)h{
    
    [[JPCAdvertManager manager].delegate layoutNativeWithX:x Y:y W:w H:h];
}

- (void)showNativeWithPlacementId:(NSString *)placementId{
        
        JPCUnitModel *nativeModel = [self getNativeUnitModelWithPlacementID:placementId];
    
        
        [self showAndReportNativeWithPlacementid:nativeModel.unitID adOrder:nativeModel.adOrder JPUnitId:placementId];
        
    
}

- (void)showAndReportNativeWithPlacementid:(NSString *)placementid adOrder:(NSString *)adOrder JPUnitId:(NSString *)unitId{
    
    //show native
    
    [[JPCAdvertManager manager].delegate showADWithADType:kADTypeNative];
    
    //数据上报
    if (!kISNullString(placementid) && !kISNullString(unitId) && !kISNullString(adOrder)) {
        [self.searchManager jp_putJPUnitID:unitId Key:kJoypacNativeUnitID];
        
        NSDictionary *para = [self.searchManager jp_getLastShowTimeAndIndexWithPlacement:unitId];
        
        int nativeIndex;
        if (!kISNullDict(para)) {
            
            nativeIndex = [para[@"JPCLASTINDEX"] intValue];
        }else{
            
            nativeIndex = 0;
        }
        
        nativeIndex = nativeIndex < adOrder.length - 1 ? nativeIndex + 1 : 0;
        [self.searchManager jp_putLastShowTime:[NSDate getCurrentTime] index:[NSString stringWithFormat:@"%d",nativeIndex] placementID:unitId];
        
        [[JPCDataReportManager manager] reportWithType:kTriggerShowAd
                                           placementId:placementid
                                                 reson:unitId
                                                result:@""
                                                adType:@"native"
                                                extra1:@""
                                                extra2:@""
                                                extra3:@""];
    }
}

- (void)hideNative{
    
    [[JPCAdvertManager manager].delegate hideNative];
    
}
- (void)removeNative{
    
    [[JPCAdvertManager manager].delegate removeNative];
}

#pragma mark 获取adorder
- (NSString *)getNativeAdOrderWithIndex:(NSInteger)index adOrder:(NSString *)adOrder{
    
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

- (JPCUnitModel *)getNativeUnitModelWithPlacementID:(NSString *)placementID{
    
    if (![JPCAdvertManager manager].nativeModel) {
        JPCUnitModel *NativeUnitModel = [self.searchManager jp_getUnitConfigWithPlacementID:placementID];
        if (!NativeUnitModel) {
            NativeUnitModel = [self.searchManager jp_getDefaultUnitConfigWithKey:kJoypacNativeModel unitId:nil];
        }
        return NativeUnitModel;
    }else{
        return [JPCAdvertManager manager].nativeModel;
    }
}




@end

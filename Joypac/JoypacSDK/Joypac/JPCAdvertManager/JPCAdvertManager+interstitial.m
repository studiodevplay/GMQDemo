//
//  JPCAdvertManager+interstitial.m

//
//  Created by 洋吴 on 2019/5/5.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCAdvertManager+interstitial.h"


@implementation JPCAdvertManager (interstitial)

#pragma mark load
- (void)loadInterstitialWithPlacementId:(NSString*)placementId{
    
    
    if ([JPCAdvertManager manager].initializeSDK) {
        JPCUnitModel *interstitialModel = [self getIVUnitModelWithPlacementID:placementId];
        if (interstitialModel.unitID != nil) {
            //请求广告
            [[JPCAdvertManager manager].delegate loadADWithPlacementId:interstitialModel.unitID adType:kADTypeIterstital nativeFrame:CGRectZero];
        }
        
    //数据上报
    [[JPCDataReportManager manager] reportWithType:kTriggerLoadAd
                                       placementId:interstitialModel.unitID
                                             reson:@""
                                            result:placementId
                                            adType:@"interstitial"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
            
        
    }else{
        
        JPCRecordClass *record = [[JPCRecordClass alloc]init];
        record.m_method = @"loadInterstitialWithPlacementId:";
        record.m_parameter = placementId;
        [[JPCAdvertManager manager].queueArr addObject:record];
    }
    
}

#pragma mark isReady
- (BOOL)isReadyInterstitialWithPlacementId:(NSString *)placementId{
    
    if (![JPCAdvertManager manager].initializeSDK) return NO;
    
    JPCUnitModel *IVModel = [self getIVUnitModelWithPlacementID:placementId];
    
    DLog(@"%@\n\tadOrder = %@\n\tmaxTimeInterval = %@\n\tminTimeInterval=%@\n\tstatus = %@\n\tunitID = %@\n\tname = %@\n\tsid = %@\n\textra = %@",@"插屏配置信息",IVModel.adOrder,IVModel.maxTimeInterval,IVModel.minTimeInterval,IVModel.status,IVModel.unitID,IVModel.name,IVModel.sid,IVModel.extra);
    //获取最小时间间隔
    NSInteger getMinTimeInterval = [IVModel.minTimeInterval integerValue];
    //获取最大时间间隔
    NSInteger getMaxTimeInterval = [IVModel.maxTimeInterval integerValue];
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
    
    if ([IVModel.status isEqualToString:@"1"]) {
        
        if (timeInterval >= getMinTimeInterval) {
            
            if (timeInterval >= getMaxTimeInterval && getMaxTimeInterval != 0) {
                
                BOOL isReadyAds = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeIterstital];
                if (isReadyAds) {
                    [self reportIsReadyForUnitId:IVModel.unitID JPUnitId:placementId result:@"true"];
                }else{
                    [self reportIsReadyForUnitId:IVModel.unitID JPUnitId:placementId result:@"false"];
                }
                DLog(@"%@\n\treson = %@\n\tadType = %@",[NSString stringWithFormat:@"%d",isReadyAds],@"大于最大时间间隔",@"interstitial");
                return isReadyAds;
                
            }else{
                if ([[self getAdOrderWithIndex:idx adOrder:IVModel.adOrder] isEqualToString:@"1"]) {
                    
                    BOOL isReadyAds = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeIterstital];
                    if (isReadyAds) {
                        [self reportIsReadyForUnitId:IVModel.unitID JPUnitId:placementId result:@"true"];
                    }else{
                        [self reportIsReadyForUnitId:IVModel.unitID JPUnitId:placementId result:@"false"];
                    }
                    DLog(@"%@\n\treson = %@\n\tadType = %@",[NSString stringWithFormat:@"%d",isReadyAds],@"小于最大时间间隔且adOrder为1",@"interstitial");
                    return isReadyAds;
                    
                }else{
                    
                    idx = idx < IVModel.adOrder.length - 1 ? idx+1 : 0;
                    [self.searchManager jp_putLastShowTime:lastShowTime index:[NSString stringWithFormat:@"%d",idx] placementID:placementId];
                    [self reportIsReadyForUnitId:IVModel.unitID JPUnitId:placementId result:@"0"];
                    DLog(@"%@\n\treson = %@\n\tadType = %@",@"0",@"小于最大时间间隔且adOrder为0",@"interstitial");
                    return NO;
                }
            }
        }else{
            
            if (![[self getAdOrderWithIndex:idx adOrder:IVModel.adOrder] isEqualToString:@"1"]){
                idx = idx < IVModel.adOrder.length - 1 ? idx+1 : 0;
                [self.searchManager jp_putLastShowTime:lastShowTime index:[NSString stringWithFormat:@"%d",idx] placementID:placementId];
            }
            [self reportIsReadyForUnitId:IVModel.unitID JPUnitId:placementId result:@"0"];
            DLog(@"%@\n\treson = %@\n\tadType = %@",@"0",@"小于最小时间间隔",@"interstitial");
            return NO;
        }
    }else{
        DLog(@"%@\n\treson = %@\n\tadType = %@",@"0",@"广告开关为-关",@"interstitial");
        [self reportIsReadyForUnitId:IVModel.unitID JPUnitId:placementId result:@"0"];
        return NO;
    }
    
}
#pragma mark report isReady
- (void) reportIsReadyForUnitId:(NSString *)unitId JPUnitId:(NSString *)JPUnitId result:(NSString *)result{
    
    [[JPCDataReportManager manager] reportWithType:kIsReady
                                       placementId:unitId
                                             reson:JPUnitId
                                            result:result
                                            adType:@"interstitial"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
    
}


#pragma mark show
- (void)showInterstitialWithPlacementId:(NSString *)placementId{
    
    JPCUnitModel *ivModel = [self getIVUnitModelWithPlacementID:placementId];
    
    [self showAndReportIVWithPlacementid:ivModel.unitID adOrder:ivModel.adOrder JPUnitId:placementId];
    
}

- (void)showAndReportIVWithPlacementid:(NSString *)placementid adOrder:(NSString *)adOrder JPUnitId:(NSString *)unitId{
    
    //调用show IV
    [[JPCAdvertManager manager].delegate showADWithADType:kADTypeIterstital];
    
    //数据上报
    if (!kISNullString(placementid) && !kISNullString(unitId) && !kISNullString(adOrder)) {
        [self.searchManager jp_putJPUnitID:unitId Key:kJoypacIVUnitID];
        
        NSDictionary *para = [self.searchManager jp_getLastShowTimeAndIndexWithPlacement:unitId];
        
        int interIndex;
        if (!kISNullDict(para)) {
            
            interIndex = [para[@"JPCLASTINDEX"] intValue];
        }else{
            
            interIndex = 0;
        }
        
        interIndex = interIndex < adOrder.length - 1 ? interIndex+1 : 0;
        
        [[JPCDataReportManager manager] reportWithType:kTriggerShowAd
                                           placementId:placementid
                                                 reson:unitId
                                                result:@""
                                                adType:@"interstitial"
                                                extra1:@""
                                                extra2:@""
                                                 extra3:@""];
        
        [self.searchManager jp_putLastShowTime:[NSDate getCurrentTime] index:[NSString stringWithFormat:@"%d",interIndex] placementID:unitId];
        
    }
}

#pragma mark 获取当前order
- (NSString *)getAdOrderWithIndex:(int)index adOrder:(NSString *)adOrder{
    
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

- (JPCUnitModel *)getIVUnitModelWithPlacementID:(NSString *)placementID{
    
    if (![JPCAdvertManager manager].ivUnitModel || ![[JPCAdvertManager manager].ivUnitModel.name isEqualToString:placementID] ) {
        
        JPCUnitModel *IVUnitModel = [self.searchManager jp_getUnitConfigWithPlacementID:placementID];
        if (!IVUnitModel) {
            IVUnitModel = [self.searchManager jp_getDefaultUnitConfigWithKey:kJoypacIVModel unitId:placementID];
            if (IVUnitModel) {
                [self.searchManager jp_putLastShowTime:[NSDate getCurrentTime] index:@"0" placementID:placementID];
            }
        }
        [JPCAdvertManager manager].ivUnitModel = IVUnitModel;
        return [JPCAdvertManager manager].ivUnitModel;
        
    }else{
        return [JPCAdvertManager manager].ivUnitModel;
    }
}

@end

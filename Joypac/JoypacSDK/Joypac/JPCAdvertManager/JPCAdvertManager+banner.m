//
//  JPCAdvertManager+banner.m

//
//  Created by 洋吴 on 2019/5/9.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCAdvertManager+banner.h"



@implementation JPCAdvertManager (banner)


#pragma mark Banner
- (void)loadBannerWithPlacementId:(NSString*)placementId{
    
    if ([JPCAdvertManager manager].initializeSDK) {
        
        JPCUnitModel *bannerUnitModel = [self getBannerUnitModelWithPlacementID:placementId];
        if (bannerUnitModel.unitID != nil) {
            
            [[JPCAdvertManager manager].delegate loadADWithPlacementId:bannerUnitModel.unitID adType:kADTypeBanner nativeFrame:CGRectZero];
        }
       
            
    //数据上报
    [[JPCDataReportManager manager] reportWithType:kTriggerLoadAd
                                       placementId:bannerUnitModel.unitID
                                             reson:@""
                                            result:placementId
                                            adType:@"banner"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
            
     
        
    }else{
        JPCRecordClass *record = [[JPCRecordClass alloc]init];
        record.m_method = @"loadBannerWithPlacementId:";
        record.m_parameter = placementId;
        [[JPCAdvertManager manager].queueArr addObject:record];
    }
    
    
}


- (void)setBannerAlign:(BannerAlign)align offset:(CGPoint)offset{
    
    [[JPCAdvertManager manager].delegate setBannerAlign:align offset:offset];
    
}

- (void)showBannerWithPlacementId:(NSString *)placementId{
    
    JPCUnitModel *bannerModel = [self getBannerUnitModelWithPlacementID:placementId];
    [self showAndReportBannerWithPlacementid:bannerModel.unitID adOrder:bannerModel.adOrder JPCPlacementId:placementId];
}

- (BOOL)isReadyBannerWithPlacement:(NSString *)placementId{
    
    if (![JPCAdvertManager manager].initializeSDK) return NO;
    
    JPCUnitModel *bannerModel = [self getBannerUnitModelWithPlacementID:placementId];
    if (!bannerModel) return NO;
    //获取最小时间间隔
    NSInteger getMinTimeInterval = [bannerModel.minTimeInterval integerValue];
    //获取最大时间间隔
    NSInteger getMaxTimeInterval = [bannerModel.maxTimeInterval integerValue];
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
    
    if ([bannerModel.status isEqualToString:@"1"]) {
        
        if (timeInterval >= getMinTimeInterval) {
            
            if (timeInterval >= getMaxTimeInterval) {
                
                BOOL bannerIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeBanner];
                if (bannerIsReady) {
                    [self reportBannerIsReadyUnit:bannerModel.unitID JPCUnitId:placementId result:@"true"];
                }else{
                    [self reportBannerIsReadyUnit:bannerModel.unitID JPCUnitId:placementId result:@"false"];
                }
                return bannerIsReady;
                
            }else{
                
                if ([[self getBannerAdOrderWithIndex:idx adOrder:bannerModel.adOrder] isEqualToString:@"1"]) {
                    //调用show接口
                    BOOL bannerIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeBanner];
                    if (bannerIsReady) {
                        [self reportBannerIsReadyUnit:bannerModel.unitID JPCUnitId:placementId result:@"true"];
                    }else{
                        [self reportBannerIsReadyUnit:bannerModel.unitID JPCUnitId:placementId result:@"false"];
                    }
                    return bannerIsReady;
                    
                }else{
                    [self reportBannerIsReadyUnit:bannerModel.unitID JPCUnitId:placementId result:@"0"];
                    return NO;
                }
            }
        }else{
            [self reportBannerIsReadyUnit:bannerModel.unitID JPCUnitId:placementId result:@"0"];
            return NO;
        }
    }else{
        [self reportBannerIsReadyUnit:bannerModel.unitID JPCUnitId:placementId result:@"0"];
        return NO;
    }
}

- (void)reportBannerIsReadyUnit:(NSString *)unitId JPCUnitId:(NSString *)JPCUnitId result:(NSString *)result{
    
    [[JPCDataReportManager manager] reportWithType:kIsReady
                                       placementId:unitId
                                             reson:JPCUnitId
                                            result:result
                                            adType:@"banner"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
}

- (void)hideBanner{
    
    [[JPCAdvertManager manager].delegate hideBanner];
    
}
- (void)removeBanner{
    
    [[JPCAdvertManager manager].delegate removeBanner];
}

#pragma mark 获取当前order
- (NSString *)getBannerAdOrderWithIndex:(int)index adOrder:(NSString *)adOrder{
    
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


- (void)showAndReportBannerWithPlacementid:(NSString *)placementid adOrder:(NSString *)adOrder JPCPlacementId:(NSString *)JPCPlacementId{
    
    [[JPCAdvertManager manager].delegate showADWithADType:kADTypeBanner];
    
    if (!kISNullString(JPCPlacementId) && !kISNullString(adOrder)) {
        [self.searchManager jp_putJPUnitID:JPCPlacementId Key:kJoypacBannerUnitID];
        
        NSDictionary *para = [self.searchManager jp_getLastShowTimeAndIndexWithPlacement:JPCPlacementId];
        
        int bannerIndex;
        if (!kISNullDict(para)) {
            
            bannerIndex = [para[@"JPCLASTINDEX"] intValue];
        }else{
            
            bannerIndex = 0;
        }
        
        bannerIndex = bannerIndex < adOrder.length - 1 ? bannerIndex + 1 : 0;
    
        [self.searchManager jp_putLastShowTime:[NSDate getCurrentTime]
                                         index:[NSString stringWithFormat:@"%d",bannerIndex]
                                   placementID:JPCPlacementId];
        
        [[JPCDataReportManager manager] reportWithType:kTriggerShowAd
                                           placementId:placementid
                                                 reson:JPCPlacementId
                                                result:@""
                                                adType:@"banner"
                                                extra1:@""
                                                extra2:@""
                                                extra3:@""];
        
    }
}

- (JPCUnitModel *)getBannerUnitModelWithPlacementID:(NSString *)placementID{
    
    if (![JPCAdvertManager manager].bannerModel) {
        JPCUnitModel *bannerUnitModel = [self.searchManager jp_getUnitConfigWithPlacementID:placementID];
        if (!bannerUnitModel) {
            bannerUnitModel = [self.searchManager jp_getDefaultUnitConfigWithKey:kjoypacbannerModel unitId:nil];
        }
        return bannerUnitModel;
    }else{
        return [JPCAdvertManager manager].bannerModel;
    }
    
}




@end

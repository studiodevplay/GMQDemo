//
//  JPCAdvertManager+rewardVideo.m

//
//  Created by 洋吴 on 2019/5/6.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCAdvertManager+rewardVideo.h"


@implementation JPCAdvertManager (rewardVideo)


- (void)loadVideoWithPlacementId:(NSString*)placementId{
    
    if ([JPCAdvertManager manager].initializeSDK) {
        JPCUnitModel *rewardViedoModel = [self getRVUnitModelWithPlacementID:placementId];
        
        if (rewardViedoModel.unitID != nil) {
            //请求广告
            
            [[JPCAdvertManager manager].delegate loadADWithPlacementId:rewardViedoModel.unitID adType:kADTypeVideo nativeFrame:CGRectZero];
        }
      
    //数据上报
    [[JPCDataReportManager manager] reportWithType:kTriggerLoadAd
                                       placementId:rewardViedoModel.unitID
                                             reson:@""
                                            result:placementId
                                            adType:@"rewardVideo"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
            
        
    }else{
        
        JPCRecordClass *record = [[JPCRecordClass alloc]init];
        record.m_method = @"loadVideoWithPlacementId:";
        record.m_parameter = placementId;
        [[JPCAdvertManager manager].queueArr addObject:record];
    }
    
    
}

- (BOOL)isReadVideoWithPlacementId:(NSString *)placementId{
    
    if (![JPCAdvertManager manager].initializeSDK) return NO;
    
    JPCUnitModel *rewardViedoModel = [self getRVUnitModelWithPlacementID:placementId];
    //获取最小时间间隔
    NSInteger getMinTimeInterval = [rewardViedoModel.minTimeInterval integerValue];
    //获取最大时间间隔
    NSInteger getMaxTimeInterval = [rewardViedoModel.maxTimeInterval integerValue];
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
    
    if ([rewardViedoModel.status isEqualToString:@"1"]) {
        
        if (timeInterval >= getMinTimeInterval) {
            
            if (timeInterval >= getMaxTimeInterval) {
                BOOL ivIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeVideo];
                if (ivIsReady) {
                    [self reportRVIsReadyForUnitId:rewardViedoModel.unitID JPUnitId:placementId result:@"true"];
                }else{
                    [self reportRVIsReadyForUnitId:rewardViedoModel.unitID JPUnitId:placementId result:@"false"];
                }
                return ivIsReady;
                
            }else{
                
                if ([[self getRVAdOrderWithIndex:idx adOrder:rewardViedoModel.adOrder] isEqualToString:@"1"]) {
                    
                    BOOL ivIsReady = [[JPCAdvertManager manager].delegate isReadyADWithADType:kADTypeVideo];
                    if (ivIsReady) {
                        [self reportRVIsReadyForUnitId:rewardViedoModel.unitID JPUnitId:placementId result:@"true"];
                    }else{
                        [self reportRVIsReadyForUnitId:rewardViedoModel.unitID JPUnitId:placementId result:@"false"];
                    }
                    return ivIsReady;
                    
                }else{
                    [self reportRVIsReadyForUnitId:rewardViedoModel.unitID JPUnitId:placementId result:@"0"];
                    return NO;
                }
            }
        }else{
            [self reportRVIsReadyForUnitId:rewardViedoModel.unitID JPUnitId:placementId result:@"0"];
            return NO;
        }
    }else{
        [self reportRVIsReadyForUnitId:rewardViedoModel.unitID JPUnitId:placementId result:@"0"];
        return NO;
    }
    
}

- (void)reportRVIsReadyForUnitId:(NSString *)unitId JPUnitId:(NSString *)JPUnitId result:(NSString *)result{
    
    [[JPCDataReportManager manager] reportWithType:kIsReady
                                       placementId:unitId
                                             reson:JPUnitId
                                            result:result
                                            adType:@"rewardVideo"
                                            extra1:@""
                                            extra2:@""
                                            extra3:@""];
}


- (void)showVideoWithPlacementId:(NSString *)placementId eventPosition:(NSString *)position{
    
    JPCUnitModel *rewardViedoModel = [self getRVUnitModelWithPlacementID:placementId];
    
    [JPCHTTPParameter parameter].eventPosition = position;
    
    [self showAndReportRVWithPlacementid:rewardViedoModel.unitID adOrder:rewardViedoModel.adOrder JPUnitId:placementId];
    
    
    
}

- (void)showAndReportRVWithPlacementid:(NSString *)placementid adOrder:(NSString *)adOrder JPUnitId:(NSString *)unitId{
    
    [[JPCAdvertManager manager].delegate showADWithADType:kADTypeVideo];
    if (!kISNullString(placementid) && !kISNullString(unitId) && !kISNullString(adOrder)) {
        
        [self.searchManager jp_putJPUnitID:unitId Key:kJoypacRVUnitID];
        NSDictionary *para = [self.searchManager jp_getLastShowTimeAndIndexWithPlacement:unitId];
        
        int rvIndex;
        if (!kISNullDict(para)) {
            
            rvIndex = [para[@"JPCLASTINDEX"] intValue];
        }else{
            
            rvIndex = 0;
        }
        
        rvIndex = rvIndex < adOrder.length - 1 ? rvIndex+1 : 0;
        
        [[JPCDataReportManager manager] reportWithType:kTriggerShowAd
                                           placementId:placementid
                                                 reson:unitId
                                                result:@""
                                                adType:@"rewardVideo"
                                                extra1:@""
                                                extra2:@""
                                                extra3:@""];
        
        [self.searchManager jp_putLastShowTime:[NSDate getCurrentTime] index:[NSString stringWithFormat:@"%d",rvIndex] placementID:unitId];
        
    }
}


- (NSString *)getRVAdOrderWithIndex:(NSInteger)index adOrder:(NSString *)adOrder{
    
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

- (JPCUnitModel *)getRVUnitModelWithPlacementID:(NSString *)placementID{
    
    if (![JPCAdvertManager manager].rvUnitModel || ![[JPCAdvertManager manager].rvUnitModel.name isEqualToString:placementID] ) {
        JPCUnitModel *RVUnitModel = [self.searchManager jp_getUnitConfigWithPlacementID:placementID];
        if (!RVUnitModel) {
            RVUnitModel = [self.searchManager jp_getDefaultUnitConfigWithKey:kJoyoacRVModel unitId:nil];
        }
        return RVUnitModel;
    }else{
        return [JPCAdvertManager manager].rvUnitModel;
    }
    
}

@end

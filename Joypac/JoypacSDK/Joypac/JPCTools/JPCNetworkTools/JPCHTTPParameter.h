//
//  Utils.h

//
//  Created by 洋吴 on 2019/3/14.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface JPCHTTPParameter : NSObject

typedef enum {
    kInitSDK,
    kTriggerLoadAd,
    kLoadAdCallBack,
    kTriggerShowAd,
    kShowAdResult,
    kRewardedInfo,
    kDidClickAd,
    kIsReady,
    kJPEvent,
    kJoypacSessionStart,
    kJoypacSessionEnd,
    kJoypacIAP
}DataReportType;

@property (nonatomic,strong)NSString *networkType;

@property (nonatomic,strong)NSString *devids;

@property (nonatomic,strong)NSString *eventPosition;

@property (nonatomic,assign)long long requestEndTime;

@property (nonatomic,assign)long long startTime;

@property (nonatomic,assign)long long endTime;

@property (nonatomic,strong)NSString *sessionStart;

@property (nonatomic,strong)NSString *settingCategory;

@property (nonatomic,strong)NSString *logId;

@property (nonatomic,strong)NSString *groupId;

@property (nonatomic,strong)NSString *productInfos;

+ (JPCHTTPParameter *)parameter;

//获取网络请求参数
- (NSDictionary *)getHTTPParameter;

- (NSDictionary *)getEuropeHTTPParameter;

- (NSDictionary *)getDataReportParameterWithType:(DataReportType)type
                                     placementid:(NSString *)placementid
                                           reson:(NSString *)reson
                                          result:(NSString *)result
                                          adType:(NSString *)adType
                                          extra1:(NSString *)extra1
                                          extra2:(NSString *)extra2
                                          extra3:(NSString *)extra3;


- (NSDictionary *)eventLogParameterWithEventType:(NSString *)eventType
                                       eventSort:(NSString *)eventSort
                                        position:(NSString *)position
                                           extra:(NSString *)extra;

- (NSString *)JPID;

- (NSString *)createSession;

- (NSString *)timestamp;

- (NSDictionary *)toDictionaryWithJsonString:(NSString *)jsonString;

- (NSString *)getIAPParameterWithProductId:(NSString *)productId productInfos:(NSString *)productionInfos;

@end



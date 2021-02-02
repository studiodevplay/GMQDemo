//
//  Utils.m

//
//  Created by 洋吴 on 2019/3/14.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCHTTPParameter.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "JPCConst.h"
#import "JPCSettingModel.h"
#import "MJExtension.h"
#import "JPCSearchManager.h"
#import <WebKit/WebKit.h>
#import "JPCAdvertManager.h"

@interface JPCHTTPParameter ()
@property(nonatomic,strong)NSString *appName;
@property(nonatomic,strong)NSString *platform;
@property(nonatomic,strong)NSString *osVersion;
@property(nonatomic,strong)NSString *appVersion;
@property(nonatomic,strong)NSString *appVersionCode;
@property(nonatomic,strong)NSString *brand;
@property(nonatomic,strong)NSString *model;
@property(nonatomic,strong)NSString *packageName;
@property(nonatomic,strong)NSString *language;
@property(nonatomic,strong)NSString *timeZone;
@property(nonatomic,strong)NSString *channel;
@property(nonatomic,strong)NSString *screenSize;
@property(nonatomic,strong)NSString *SDKName;
@property(nonatomic,strong)NSString *userType;
@property(nonatomic,strong)NSString *appId;
@property(nonatomic,strong)NSString *requestId;
@property(nonatomic,strong)NSString *apiVersion;
@property(nonatomic,assign)long long requestStartTime;
@end

@implementation JPCHTTPParameter

+ (JPCHTTPParameter *)parameter{
    static JPCHTTPParameter *m_parameter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_parameter = [[self alloc]init];
    });
    return m_parameter;
}


#pragma mark - setting
- (NSDictionary *)getHTTPParameter{
    
    NSString *time = [self timestamp];
    NSString *installTime = [kUserDefault objectForKey:kJoypacInstallTime];
    installTime = kISNullString(installTime)?@"":installTime;
    self.requestStartTime = [NSDate getDateTimeTOMilliSeconds];
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSDictionary *dict = @{@"category":@"all",
                           @"channel_callback":[self getChannelCallback],
                           @"install_scheme_hash":[self GetInstallSchemesHash],
                           @"api_version":self.apiVersion,
                           @"SDKVersion":kJoypacSDKVersion,
                           @"app_id":[self getJPAppID],
                           @"install_ts":installTime,
                           @"user_channel":[self getUserChannel],
                           @"timestamp":time,
                           @"token":[self tokenWithTimestamp:time],
                           @"appName":self.appName,
                           @"platform":self.platform,
                           @"session":session,
                           @"osVersion":self.osVersion,
                           @"appVersion":self.appVersion,
                           @"appVersionCode":self.appVersionCode,
                           @"brand":self.brand,
                           @"model":self.model,
                           @"packageName":self.packageName,
                           @"networkType":self.networkType,
                           @"language":self.language,
                           @"timeZone":self.timeZone,
                           @"channel":self.channel,
                           @"devids":self.devids,
                           @"ua":[self getUserAgent],
                           @"screenSize":self.screenSize,
                           @"user_type":self.userType,
                           @"reqId":[self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",self.requestStartTime] JPID:[self JPID]],
                           @"adjustTrack":[self getAdjustTrack]
                           };
    return dict;
    
}

#pragma mark - GDPR
- (NSDictionary *)getEuropeHTTPParameter{
    
    NSString *time = [self timestamp];
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    
    NSDictionary *dict = @{@"reqId":requestId,
                           @"channel_callback":[self getChannelCallback],
                           @"timestamp":time,
                           @"SDKVersion":kJoypacSDKVersion,
                           @"app_id":[self getJPAppID],
                           @"token":[self tokenWithTimestamp:time],
                           @"action_type":@"isEU",
                           @"api_version":self.apiVersion,
                           @"session":session,
                           @"appName":self.appName,
                           @"platform":self.platform,
                           @"osVersion":self.osVersion,
                           @"appVersion":self.appVersion,
                           @"appVersionCode":self.appVersionCode,
                           @"brand":self.brand,
                           @"model":self.model,
                           @"packageName":self.packageName,
                           @"networkType":self.networkType,
                           @"language":self.language,
                           @"timeZone":self.timeZone,
                           @"channel":self.channel,
                           @"devids":self.devids,
                           @"ua":[self getUserAgent],
                           @"screenSize":self.screenSize
                           };
    return dict;
    
    
}

#pragma mark - DataReport Parameter
- (NSDictionary *)getDataReportParameterWithType:(DataReportType)type
                                     placementid:(NSString *)placementid
                                           reson:(NSString *)reson
                                          result:(NSString *)result
                                          adType:(NSString *)adType
                                          extra1:(NSString *)extra1
                                          extra2:(NSString *)extra2
                                          extra3:(NSString *)extra3{
    NSDictionary *dict;
    JPCSearchManager *manager =  [JPCSearchManager shareManager];
    
    if (type ==kInitSDK) {
        
        dict = [self startSDKParameterByPlacementId:placementid manager:manager];
        
    }else if (type == kTriggerLoadAd){
        
        dict = [self triggerLoadAdParameterByPlacementID:placementid adType:adType JPCPlacementID:result];
        
    }else if(type == kLoadAdCallBack){
        
        dict = [self loadAdCallBackParameterByPlacementID:placementid result:result reson:reson adType:adType];
        
    }else if (type == kTriggerShowAd){
        
        dict = [self triggerShowAdBySearchManager:manager placementID:placementid adType:adType JPCPlacementId:reson adOrder:result];
        
    }else if (type == kShowAdResult){
        
        dict = [self showAdResultBySearchManager:manager placementID:placementid result:result reson:reson adType:adType];
        
    }else if (type == kDidClickAd){
        
        dict = [self clickAdsParameterByPlacementID:placementid JPCPlacementID:reson searchManager:manager adType:adType];
        
    }else if (type == kIsReady){
        
        dict = [self isReadyParameterUnitId:placementid adType:adType JPCUnitId:reson result:result];
        
    }else if(type == kJPEvent){
    
        dict = [self getTimeConsumingParameter];
        
    }else if(type == kJoypacSessionStart){
        
        dict = [self getSessionStartParameterBySessionID:extra1];
    
    }else if(type == kJoypacSessionEnd){
        
        dict = [self getSessionEndParameterBySessionID:extra1 timeDifferent:extra2];
    }else if (type == kJoypacIAP){
        
        dict = [self getIAPParameterByEventType:extra1 productId:extra2 failReason:extra3];
        
    }else{
        
        dict = [self rewardedInfoByPlacementID:placementid result:result reson:reson];
        
    }
    
    return dict;
}

- (NSDictionary *)getIAPParameterByEventType:(NSString *)eventT productId:(NSString *)pId failReason:(NSString *)failReason{
    
    NSString *requestId = [NSString stringWithFormat:@"%llu-%@",[NSDate getDateTimeTOMilliSeconds],[self JPID]];
    NSString *time = [self timestamp];
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    NSDictionary *pInfos = [self toDictionaryWithJsonString:[[JPCHTTPParameter parameter]getIAPParameterWithProductId:pId productInfos:[JPCHTTPParameter parameter].productInfos]];
    id iapExtra = kISNullString(failReason)?pInfos:failReason;
    
    return  @{
        @"reqId":requestId,
        @"channel_callback":[self getChannelCallback],
        @"timestamp":time,
        @"session":session,
        @"token":[self tokenWithTimestamp:time],
        @"appName":self.appName,
        @"platform":self.platform,
        @"osVersion":self.osVersion,
        @"appVersion":self.appVersion,
        @"appVersionCode":self.appVersionCode,
        @"brand":self.brand,
        @"model":self.model,
        @"screenSize":self.screenSize,
        @"packageName":self.packageName,
        @"networkType":self.networkType,
        @"language":self.language,
        @"timeZone":self.timeZone,
        @"channel":self.channel,
        @"devids":self.devids,
        @"ua":[self getUserAgent],
        @"app_id":[self getJPAppID],
        @"eventType":eventT,
        @"SDKVersion":kJoypacSDKVersion,
        @"data":@{},
        @"api_version":self.apiVersion,
        @"event_sort":@"IAP_SDK",
        @"event_position":@"",
        @"event_extra":@{
                @"group_id":groupId,
                @"cgroup_id":[self getCgroupId],
                @"log_id":logId,
                @"IAPExtra":iapExtra
                },
        @"adjustTrack":[self getAdjustTrack]
    };
}

#pragma mark - 程序启动事件上报
- (NSDictionary *)getSessionStartParameterBySessionID:(NSString *)sessionID{
    
    NSString *requestId = [NSString stringWithFormat:@"%llu-%@",[NSDate getDateTimeTOMilliSeconds],[self JPID]];
    NSString *time = [self timestamp];
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    return  @{
        @"reqId":requestId,
        @"channel_callback":[self getChannelCallback],
        @"timestamp":time,
        @"session":session,
        @"token":[self tokenWithTimestamp:time],
        @"appName":self.appName,
        @"platform":self.platform,
        @"osVersion":self.osVersion,
        @"appVersion":self.appVersion,
        @"appVersionCode":self.appVersionCode,
        @"brand":self.brand,
        @"model":self.model,
        @"screenSize":self.screenSize,
        @"packageName":self.packageName,
        @"networkType":self.networkType,
        @"language":self.language,
        @"timeZone":self.timeZone,
        @"channel":self.channel,
        @"devids":self.devids,
        @"ua":[self getUserAgent],
        @"app_id":[self getJPAppID],
        @"eventType":@"lifeMs",
        @"SDKVersion":kJoypacSDKVersion,
        @"data":@{},
        @"api_version":self.apiVersion,
        @"event_sort":@"jpEvent",
        @"event_position":@"session_start",
        @"event_extra":@{
                @"group_id":groupId,
                @"cgroup_id":[self getCgroupId],
                @"log_id":logId
                },
        @"adjustTrack":[self getAdjustTrack]
    };
}

#pragma mark - 程序退出上报
- (NSDictionary *)getSessionEndParameterBySessionID:(NSString *)sessionID timeDifferent:(NSString *)timeDifferent{
    
    NSString *requestId = [NSString stringWithFormat:@"%llu-%@",[NSDate getDateTimeTOMilliSeconds],[self JPID]];
    NSString *time = [self timestamp];
    timeDifferent = kISNullString(timeDifferent)?@"":timeDifferent;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{
        @"reqId":requestId,
        @"channel_callback":[self getChannelCallback],
        @"session":session,
        @"timestamp":time,
        @"token":[self tokenWithTimestamp:time],
        @"appName":self.appName,
        @"platform":self.platform,
        @"osVersion":self.osVersion,
        @"appVersion":self.appVersion,
        @"appVersionCode":self.appVersionCode,
        @"brand":self.brand,
        @"model":self.model,
        @"screenSize":self.screenSize,
        @"packageName":self.packageName,
        @"networkType":self.networkType,
        @"language":self.language,
        @"timeZone":self.timeZone,
        @"channel":self.channel,
        @"devids":self.devids,
        @"ua":[self getUserAgent],
        @"app_id":[self getJPAppID],
        @"eventType":@"lifeMs",
        @"SDKVersion":kJoypacSDKVersion,
        @"data":@{},
        @"api_version":self.apiVersion,
        @"event_sort":@"jpEvent",
        @"event_position":@"session_end",
        @"event_extra":@{
                @"group_id":groupId,
                @"cgroup_id":[self getCgroupId],
                @"timeDifferent":timeDifferent,
                @"log_id":logId
                },
        @"adjustTrack":[self getAdjustTrack]
    };
}


#pragma mark - SDK时间差上报
- (NSDictionary *) getTimeConsumingParameter{
    
    NSString *time = [self timestamp];
    NSString *reqId = [NSString stringWithFormat:@"%llu-%@",[NSDate getDateTimeTOMilliSeconds],[self JPID]];
    long long cstMs = self.requestStartTime;
    long long cetMs = self.requestEndTime;
    long long ctcMs = cetMs - cstMs;
    NSString *cstMsStr = [NSString stringWithFormat:@"%llu",cstMs];
    NSString *cetMsStr = [NSString stringWithFormat:@"%llu",cetMs];
    NSString *ctcMsStr = [NSString stringWithFormat:@"%llu",ctcMs];
    cstMsStr = kISNullString(cstMsStr)?@"":cstMsStr;
    cetMsStr = kISNullString(cetMsStr)?@"":cetMsStr;
    ctcMsStr = kISNullString(ctcMsStr)?@"":ctcMsStr;
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":reqId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"token":[self tokenWithTimestamp:time],
              @"channel_callback":[self getChannelCallback],
              @"appName":self.appName,
              @"platform":self.platform,
              @"session":session,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"screenSize":self.screenSize,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"app_id":[self getJPAppID],
              @"eventType":@"requestTime",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"jpEvent",
              @"event_position":@"",
              @"event_extra":@{
                      @"reqPath":@"/setting/batch",
                      @"reqId":[NSString stringWithFormat:@"%@-%@",cstMsStr,[self JPID]],
                      @"cstMs":cstMsStr,
                      @"cetMs":cetMsStr,
                      @"ctcMs":ctcMsStr,
                      @"log_id":logId,
                      @"group_id":groupId
                      },
              @"adjustTrack":[self getAdjustTrack]
    };
}

#pragma mark - 获取initSDK参数
- (NSDictionary *) startSDKParameterByPlacementId:(NSString *)placementId manager:(JPCSearchManager *)manager{
    
    JPCSettingModel *appModel = [manager jp_getAppConfigWithGameName:kJoypacGameName];
    NSString *sid = appModel.sid ? appModel.sid : @"";
    NSString *time = [self timestamp];
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"screenSize":self.screenSize,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"session":session,
              @"app_id":[self getJPAppID],
              @"eventType":@"initSDK",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":@"",
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"result":@"success",
                      @"reason":@"initSDK success",
                      @"sid":sid,
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
              };
    
}

#pragma mark - 获取isready参数
- (NSDictionary *)isReadyParameterUnitId:(NSString *)unitID adType:(NSString *)adType JPCUnitId:(NSString *)JPCUnitId result:(NSString *)result{
    unitID = kISNullString(unitID) ? @"" :unitID;
    JPCUnitId = kISNullString(JPCUnitId) ? @"":JPCUnitId;
    JPCUnitModel *unitModel = [self getUnitModelByPlacementID:JPCUnitId];
    NSString *sid = unitModel.sid ? unitModel.sid : @"";
    NSString *time = [self timestamp];
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"screenSize":self.screenSize,
              @"session":session,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"app_id":[self getJPAppID],
              @"adType":adType,
              @"eventType":@"isReadyAds",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":@"",
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"placementid":unitID,
                      @"JPCPlacementID":JPCUnitId,
                      @"sid":sid,
                      @"group_id":groupId,
                      @"result":result,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
              };
}

#pragma mark - 获取triggerLoadAd参数
- (NSDictionary *) triggerLoadAdParameterByPlacementID:(NSString *)placementID adType:(NSString *)adType JPCPlacementID:(NSString *)JPCPlacementID{
    
    placementID = kISNullString(placementID) ? @"" :placementID;
    adType = kISNullString(adType) ? @"" : adType;
    JPCPlacementID = kISNullString(JPCPlacementID) ? @"":JPCPlacementID;
    JPCUnitModel *unitModel = [self getUnitModelByPlacementID:JPCPlacementID] ;
    NSString *sid = unitModel.sid ? unitModel.sid : @"";
    NSString *time = [self timestamp];
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"screenSize":self.screenSize,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"session":session,
              @"app_id":[self getJPAppID],
              @"adType":adType,
              @"eventType":@"triggerLoadAd",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":@"",
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"placementid":placementID,
                      @"JPCPlacementID":JPCPlacementID,
                      @"sid":sid,
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
              };
}

#pragma mark - 获取loadAdCallBack参数
- (NSDictionary *) loadAdCallBackParameterByPlacementID:(NSString *)placementID result:(NSString *)result reson:(NSString *)reson adType:(NSString *)adType{
    
    JPCUnitModel *unitModel = [self getUnitModelByPlacementID:placementID] ;
    NSString *sid = unitModel.sid ? unitModel.sid : @"";
    placementID = kISNullString(placementID) ? @"" :placementID;
    reson = kISNullString(reson) ? @"" : reson;
    result = kISNullString(result) ? @"" : result;
    adType = kISNullString(adType) ? @"" : adType;
    NSString *time = [self timestamp];
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"session":session,
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"osVersion":self.osVersion,
              @"screenSize":self.screenSize,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"app_id":[self getJPAppID],
              @"adType":adType,
              @"eventType":@"loadAdCallBack",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":@"",
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"placementid":placementID,
                      @"sid":sid,
                      @"result":result,
                      @"reson":reson,
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
              };
}

#pragma mark - 获取triggerShowAd参数
- (NSDictionary *) triggerShowAdBySearchManager:(JPCSearchManager *)manager placementID:(NSString *)placementID adType:(NSString *)adType JPCPlacementId:(NSString *)jpcPlacementId adOrder:(NSString *)nowAdOrder{
    
    JPCUnitModel *unitModel = [manager jp_getUnitConfigWithPlacementID:jpcPlacementId];
    NSString *sid = unitModel.sid ? unitModel.sid : @"";
    NSString *adOrder = unitModel.adOrder ? unitModel.adOrder : @"";
    NSString *maxInterval = unitModel.maxTimeInterval ? unitModel.maxTimeInterval : @"";
    NSString *minInterval = unitModel.minTimeInterval ? unitModel.minTimeInterval : @"";
    NSString *time = [self timestamp];
    placementID = kISNullString(placementID) ? @"" :placementID;
    jpcPlacementId = kISNullString(jpcPlacementId) ? @"" :jpcPlacementId;
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"session":session,
              @"channel_callback":[self getChannelCallback],
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"screenSize":self.screenSize,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"app_id":[self getJPAppID],
              @"adType":adType,
              @"eventType":@"triggerShowAd",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":@"",
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"placementid":placementID,
                      @"sid":sid,
                      @"ad_order_number":nowAdOrder,
                      @"ad_order":adOrder,
                      @"max_time_interval":maxInterval,
                      @"min_time_interval":minInterval,
                      @"JPCPlacementId":jpcPlacementId,
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
              
    };
}

#pragma mark - 获取showAdResult参数
- (NSDictionary *) showAdResultBySearchManager:(JPCSearchManager *)manager placementID:(NSString *)placementID result:(NSString *)result reson:(NSString *)reson adType:(NSString *)adType{
    
    placementID = kISNullString(placementID)? @"" : placementID;
    JPCUnitModel *unitModel = [manager jp_getUnitConfigWithPlacementID:placementID];
    NSString *sid = unitModel.sid ? unitModel.sid : @"";
    NSString *adOrder = unitModel.adOrder ? unitModel.adOrder : @"";
    NSString *maxInterval = unitModel.maxTimeInterval ? unitModel.maxTimeInterval : @"";
    NSString *minInterval = unitModel.minTimeInterval ? unitModel.minTimeInterval : @"";
    NSString *time = [self timestamp];
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *position = @"";
    if ([adType isEqualToString:@"rewardVideo"]) {
        position = kISNullString(self.eventPosition)?@"":self.eventPosition;
    }
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"session":session,
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"screenSize":self.screenSize,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"app_id":[self getJPAppID],
              @"adType":adType,
              @"eventType":@"showAdResult",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":position,
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"placementid":placementID,
                      @"sid":sid,
                      @"ad_order_number":@"1",
                      @"ad_order":adOrder,
                      @"max_time_interval":maxInterval,
                      @"min_time_interval":minInterval,
                      @"result":result,
                      @"reson":reson,
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
    };
}


#pragma mark - 获取rewardedInfo参数
- (NSDictionary *) rewardedInfoByPlacementID:(NSString *)placementID result:(NSString *)result reson:(NSString *)reson{
    
    JPCUnitModel *unitModel = [[JPCSearchManager shareManager] jp_getUnitConfigWithPlacementID:placementID];
    NSString *sid = unitModel.sid ? unitModel.sid : @"";
    NSString *time = [self timestamp];
    self.eventPosition = kISNullString(self.eventPosition) ? @"" : self.eventPosition;
    placementID = kISNullString(placementID) ? @"" :placementID;
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"token":[self tokenWithTimestamp:time],
              @"session":session,
              @"appName":self.appName,
              @"platform":self.platform,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"screenSize":self.screenSize,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"app_id":[self getJPAppID],
              @"eventType":@"rewardedInfo",
              @"adType":@"rewardVideo",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":self.eventPosition,
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"placementid":placementID,
                      @"sid":sid,
                      @"result":result,
                      @"reson":reson,
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
              };
    
}

#pragma mark - 获取点击广告参数
- (NSDictionary *)clickAdsParameterByPlacementID:(NSString *)placementID JPCPlacementID:(NSString *)JPCPlacementID searchManager:(JPCSearchManager *)manager adType:(NSString *)adType{
    JPCUnitModel *model = [manager jp_getUnitConfigWithPlacementID:JPCPlacementID];
    JPCPlacementID = kISNullString(JPCPlacementID) ? @"": JPCPlacementID;
    placementID = kISNullString(placementID) ? @"" :placementID;
    NSString *time = [self timestamp];
    NSString *sid = model.sid ? model.sid : @"";
    NSString *position = @"";
    if ([adType isEqualToString:@"rewardVideo"]) {
        position = kISNullString(self.eventPosition)?@"":self.eventPosition;
    }
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;

    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"session":session,
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"screenSize":self.screenSize,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"app_id":[self getJPAppID],
              @"adType": adType,
              @"eventType":@"didClickAd",
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":@"unitAdEvent",
              @"event_position":position,
              @"event_extra":@{
                      @"mediation_name":self.SDKName,
                      @"mediation_appid":self.appId,
                      @"placementid":placementID,
                      @"sid":sid,
                      @"JPCPlacementId":JPCPlacementID,
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
                      },
              @"adjustTrack":[self getAdjustTrack]
              
    };
    
}

#pragma mark - 游戏上报参数
- (NSDictionary *)eventLogParameterWithEventType:(NSString *)eventType eventSort:(NSString *)eventSort position:(NSString *)position extra:(NSString *)extra{
    eventType = kISNullString(eventType) ? @"" : eventType;
    eventSort = kISNullString(eventSort) ? @"" : eventSort;
    position = kISNullString(position) ? @"" : position;
    NSString *time = [self timestamp];
    NSString *requestId = [self getRequestIdByTimeStamp:[NSString stringWithFormat:@"%llu",[NSDate getDateTimeTOMilliSeconds]] JPID:[self JPID]];
    NSString *settingCate = kISNullString(self.settingCategory)?@"":self.settingCategory;
    NSString *session = kISNullString(self.sessionStart)?@"":self.sessionStart;
    NSString *groupId = kISNullString(self.groupId)?@"":self.groupId;
    NSString *logId = kISNullString(self.logId)?@"00000":self.logId;
    
    return  @{@"reqId":requestId,
              @"setting_category":settingCate,
              @"timestamp":time,
              @"channel_callback":[self getChannelCallback],
              @"session":session,
              @"app_id":[self getJPAppID],
              @"token":[self tokenWithTimestamp:time],
              @"appName":self.appName,
              @"platform":self.platform,
              @"screenSize":self.screenSize,
              @"osVersion":self.osVersion,
              @"appVersion":self.appVersion,
              @"appVersionCode":self.appVersionCode,
              @"brand":self.brand,
              @"model":self.model,
              @"packageName":self.packageName,
              @"networkType":self.networkType,
              @"language":self.language,
              @"timeZone":self.timeZone,
              @"channel":self.channel,
              @"devids":self.devids,
              @"ua":[self getUserAgent],
              @"adType": @"",
              @"eventType":eventType,
              @"SDKVersion":kJoypacSDKVersion,
              @"data":@{},
              @"api_version":self.apiVersion,
              @"event_sort":eventSort,
              @"event_position":position,
              @"event_extra":@{
                      @"game_extra":[self toDictionaryWithJsonString:extra],
                      @"group_id":groupId,
                      @"cgroup_id":[self getCgroupId],
                      @"log_id":logId
              },
              @"adjustTrack":[self getAdjustTrack]
              };
    
}


#pragma mark - json字符串转化为字典/数组
- (NSDictionary *)toDictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return @{};
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    
    if(err){
        
        return @{};
    }

    return dic;
}

- (NSArray *)toArrayWithJsonString:(NSString *)jsonString{
    if (jsonString != nil) {
        NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:&err];
 
        if (err) {
            
            return nil;
        }
        
        if (jsonObject != nil){
            return jsonObject;
        }else{
            // 解析错误
            return nil;
        }
    }
    return nil;
}

- (JPCUnitModel *)getUnitModelByPlacementID:(NSString *)placementID{
    
    return [[JPCSearchManager shareManager] jp_getUnitConfigWithPlacementID:placementID];
    
}


#pragma mark - lazyLoading
- (NSString *)appName{
    if (!_appName) {
        _appName = !kISNullString(kJoypacGameName) ? kJoypacGameName : @"";
    }
    return _appName;
    
}

- (NSString *)platform{
    if (!_platform) {
        _platform = @"ios";
    }
    return _platform;
}

- (NSString *)osVersion{
    if (!_osVersion) {
        _osVersion = [[UIDevice currentDevice]systemVersion];
    }
    return _osVersion;
}

- (NSString *)appVersion{
    if (!_appVersion) {
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return _appVersion;
}

-(NSString *)appVersionCode{
    if (!_appVersionCode) {
        _appVersionCode = [[UIDevice currentDevice]systemVersion];
    }
    return _appVersionCode;
}

-(NSString *)brand{
    if (!_brand) {
        _brand = @"apple";
    }
    return _brand;
}

- (NSString *)model{
    if (!_model) {
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
        if (model) {
            _model = [self currentModel:model];
        }else{
            _model = @"";
        }
    }
    return _model;
}

- (NSString *)packageName{
    if (!_packageName) {
        _packageName = [NSBundle mainBundle].bundleIdentifier;
    }
    return _packageName;
}

- (NSString *)networkType{
    if (!_networkType) {
        _networkType = [self getNetworkType];
    }
    return _networkType;
}

- (NSString *)getNetworkType{
    
    NSString *netconnType = @"";
    
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络
        {
            
            netconnType = @"NotReachable";
        }
            break;
            
        case ReachableViaWiFi:// Wifi
        {
            netconnType = @"Wifi";
        }
            break;
        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                
                netconnType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                
                netconnType = @"EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                
                netconnType = @"WCDMA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                
                netconnType = @"HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                
                netconnType = @"HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                
                netconnType = @"CDMA1x";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                
                netconnType = @"CDMAEVDORev0";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                
                netconnType = @"CDMAEVDORevA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                
                netconnType = @"CDMAEVDORevB";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                
                netconnType = @"eHRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                
                netconnType = @"LTE";
            }
        }
            break;
            
        default:
            break;
    }
    
    return netconnType;
}

-(NSString *)language{
    if (!_language) {
        _language = [[kUserDefault  objectForKey:@"AppleLanguages"] objectAtIndex:0];
    }
    return _language;
}

- (NSString *)timeZone{
    if (!_timeZone) {
        _timeZone = [NSTimeZone localTimeZone].abbreviation;
    }
    return _timeZone;
}

- (NSString *)channel{
    if (!_channel) {
        _channel = @"App Store";
    }
    return _channel;
}

- (NSString *)devids{
    if (!_devids) {
        _devids = [NSString stringWithFormat:@",%@,,,,%@,%@",[self getIDFA],[self getIDFV],[self JPID]];
    }
    return _devids;
}

- (NSString *)screenSize{
    if (!_screenSize) {
        CGRect screenBounds = [[UIScreen mainScreen]bounds];
        CGFloat screenScale = [UIScreen mainScreen].scale;
        CGFloat screenWidth = screenBounds.size.width * screenScale;
        CGFloat screenHeight = screenBounds.size.height * screenScale;
        _screenSize = [NSString stringWithFormat:@"%.f x %.f",screenWidth,screenHeight];
        
    }
    return _screenSize;
    
}

- (NSString *)SDKName{
    if (!_SDKName) {
        _SDKName = [[JPCSearchManager shareManager] jp_getMediationSDKName];
    }
    return _SDKName;
}


- (NSString *)getJPAppID{
    
    NSString *JPAppId = [JPCAdvertManager manager].JPAppID;
    if (kISNullString(JPAppId)) {
        NSString *appid = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"JoypacAppId"];
        return kISNullString(appid) ? @"" :appid;
    }else{
        return JPAppId;
    }
}

- (NSString *)apiVersion{
    
    
    if (!_apiVersion) {
        _apiVersion = @"1.0.3";
    }
    return _apiVersion;
}

- (NSString *)userType{
    if (!_userType) {
        NSString *uType = [kUserDefault objectForKey:kJoypacUserType];
        _userType = kISNullString(uType)?@"0":uType;
    }
    return _userType;
}


- (NSString *)appId{
    if (!_appId) {
        _appId = [[JPCSearchManager shareManager] jp_getAppID];
    }
    return _appId;
    
}

- (NSString *)GetInstallSchemesHash{
    
    return kISNullString([kUserDefault objectForKey:@"installSchemeHash"])?@"8b2209fb4eb6aeddc":[kUserDefault objectForKey:@"installSchemeHash"];
    
}
//创建session
- (NSString *)createSession{
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return uuid;
}

- (NSString *)timestamp{
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", time];
}

- (NSString *)tokenWithTimestamp:(NSString *)timeStamp{
    
    NSString *md5Str = [NSString stringWithFormat:@"%@%@%@%@",timeStamp,[self appName],[self platform],kJoypacKay];
    return [self md5:md5Str];
}

- (NSString *)currentModel:(NSString *)phoneModel {
    //iphone
    if ([phoneModel isEqualToString:@"iPhone3,1"] ||
        [phoneModel isEqualToString:@"iPhone3,2"])   return @"iPhone 4";
    if ([phoneModel isEqualToString:@"iPhone4,1"])   return @"iPhone 4S";
    if ([phoneModel isEqualToString:@"iPhone5,1"] ||
        [phoneModel isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
    if ([phoneModel isEqualToString:@"iPhone5,3"] ||
        [phoneModel isEqualToString:@"iPhone5,4"])   return @"iPhone 5C";
    if ([phoneModel isEqualToString:@"iPhone6,1"] ||
        [phoneModel isEqualToString:@"iPhone6,2"])   return @"iPhone 5S";
    if ([phoneModel isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([phoneModel isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([phoneModel isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([phoneModel isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([phoneModel isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([phoneModel isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([phoneModel isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,1"] ||
        [phoneModel isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([phoneModel isEqualToString:@"iPhone10,2"] ||
        [phoneModel isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,3"] ||
        [phoneModel isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([phoneModel isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([phoneModel isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([phoneModel isEqualToString:@"iPhone11,6"]||
        [phoneModel isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    if ([phoneModel isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if ([phoneModel isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if ([phoneModel isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
    //ipad
    if ([phoneModel isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([phoneModel isEqualToString:@"iPad2,1"] ||
        [phoneModel isEqualToString:@"iPad2,2"] ||
        [phoneModel isEqualToString:@"iPad2,3"] ||
        [phoneModel isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([phoneModel isEqualToString:@"iPad3,1"] ||
        [phoneModel isEqualToString:@"iPad3,2"] ||
        [phoneModel isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([phoneModel isEqualToString:@"iPad3,4"] ||
        [phoneModel isEqualToString:@"iPad3,5"] ||
        [phoneModel isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([phoneModel isEqualToString:@"iPad4,1"] ||
        [phoneModel isEqualToString:@"iPad4,2"] ||
        [phoneModel isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([phoneModel isEqualToString:@"iPad5,3"] ||
        [phoneModel isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    if ([phoneModel isEqualToString:@"iPad6,3"] ||
        [phoneModel isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch";
    if ([phoneModel isEqualToString:@"iPad6,7"] ||
        [phoneModel isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if ([phoneModel isEqualToString:@"iPad6,11"] ||
        [phoneModel isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([phoneModel isEqualToString:@"iPad7,1"] ||
        [phoneModel isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if ([phoneModel isEqualToString:@"iPad7,3"] ||
        [phoneModel isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    //new
    if ([phoneModel isEqualToString:@"iPad7,5"] ||
        [phoneModel isEqualToString:@"iPad7,6"]) return @"iPad 6th generation";
    
    if ([phoneModel isEqualToString:@"iPad8,1"] ||
        [phoneModel isEqualToString:@"iPad8,2"] || ([phoneModel isEqualToString:@"iPad8,3"])||([phoneModel isEqualToString:@"iPad8,4"])) return @"iPad Pro 11-inch";
    if ([phoneModel isEqualToString:@"iPad8,5"] ||
        [phoneModel isEqualToString:@"iPad8,6"] || ([phoneModel isEqualToString:@"iPad8,7"])||([phoneModel isEqualToString:@"iPad8,8"])) return @"iPad Pro 12.9-inch";
    if ([phoneModel isEqualToString:@"iPad11,3"] ||
        [phoneModel isEqualToString:@"iPad11,4"]) return @"iPad Air 3rd generation";
    
    if ([phoneModel isEqualToString:@"iPad2,5"] ||
        [phoneModel isEqualToString:@"iPad2,6"] ||
        [phoneModel isEqualToString:@"iPad2,7"]) return @"iPad mini";
    if ([phoneModel isEqualToString:@"iPad4,4"] ||
        [phoneModel isEqualToString:@"iPad4,5"] ||
        [phoneModel isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([phoneModel isEqualToString:@"iPad4,7"] ||
        [phoneModel isEqualToString:@"iPad4,8"] ||
        [phoneModel isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([phoneModel isEqualToString:@"iPad5,1"] ||
        [phoneModel isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    //ipod
    if ([phoneModel isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([phoneModel isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([phoneModel isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([phoneModel isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([phoneModel isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([phoneModel isEqualToString:@"iPod7,1"]) return @"iTouch6";
    //Simulator
    if ([phoneModel isEqualToString:@"i386"] || [phoneModel isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return phoneModel;
    
}


- (NSString *)getIDFA{
    
    return [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled ? [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] : @"";
    
}

- (NSString *)getIDFV{
    
    return [UIDevice currentDevice].identifierForVendor.UUIDString ? [UIDevice currentDevice].identifierForVendor.UUIDString : @"";
    
}


- (NSString *)getUserAgent{
    
    NSUserDefaults *uDefault = kUserDefault ;
    NSString *defaultUserAgent = [uDefault objectForKey:@"JoypacUserAgent"];
    if (kISNullString(defaultUserAgent)) {
        WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;
        webViewConfig.allowsInlineMediaPlayback = YES;
        
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,1,1) configuration:webViewConfig];
        wkWebView.backgroundColor = [UIColor clearColor];
        wkWebView.hidden = YES;
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:wkWebView];
        [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            if (result != nil) {
                [kUserDefault setValue:result forKey:@"JoypacUserAgent"];
            }
        }];
        return [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    }else{
        return defaultUserAgent;
    }
    
}


//MD5
- (NSString *) md5:(NSString *) str{
    
    if (!str) return nil;
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}

//获取游戏上报分组
- (NSString *)getCgroupId{
    
    NSString *cGroupId = [kUserDefault objectForKey:kCgroupId];
    return kISNullString(cGroupId) ? @"" : cGroupId;
    
}

//requestId
- (NSString *)getRequestIdByTimeStamp:(NSString *)timeStamp JPID:(NSString *)JPID{
    return [NSString stringWithFormat:@"%@-%@",timeStamp,JPID];
    
}

#pragma mark - JPID生成

- (NSString *)JPID{
    
    if (!kISNullString([kUserDefault objectForKey:kJPID])) {
        
        return [kUserDefault objectForKey:kJPID];
        
    }else if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled){
        
        NSString *JPID = [self md5:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]];
        [kUserDefault setObject:JPID forKey:kJPID];
        return JPID;
    
    }else{
        
        NSString *JPID = [self md5:[UIDevice currentDevice].identifierForVendor.UUIDString];
        [kUserDefault setObject:JPID forKey:kJPID];
        return JPID;
    }
    
}

#pragma mark - adjust parameter
- (NSString *)getUserChannel{
    
    NSString *adjustNetwork = [kUserDefault objectForKey:kJoypacAdjustJsonString];
    if (kISNullString(adjustNetwork)) {
        return @"notercv";
    }else{
        NSDictionary *adjustStr = [self toDictionaryWithJsonString:adjustNetwork];
        if (kISNullString(adjustStr[@"network"])) {
            return @"";
        }else{
            return adjustStr[@"network"];
        }
    }
}


- (NSString *)getChannelCallback{
    
    if (kISNullString([kUserDefault objectForKey:kJoypacAdjustJsonString])) {
        return @"0";
    }else{
        return @"1";
    }
}

- (NSString *)getAdjustTrack{
    
    if (kISNullString([kUserDefault objectForKey:kJoypacAdjustJsonString])){
        return @"";
    }else{
        return [kUserDefault objectForKey:kJoypacAdjustJsonString];
    }
}

#pragma mark - IAP

- (NSString *)getIAPParameterWithProductId:(NSString *)productId productInfos:(NSString *)productionInfos{
    
    
    if (kISNullString(productId) || kISNullString(productionInfos)) {
        return @"";
    }
    
    NSArray *array = [self toArrayWithJsonString:productionInfos];
     
    if (array.count) {
        
        __block NSUInteger index;
        __block NSDictionary *finalDic;
        
        [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([dic[@"storeSpecificId"] isEqualToString:productId]) {
                index = idx;
                finalDic = dic;
                *stop = YES;
            }
            
        }];
        
        NSString *extraJsonStr = [self convertToJsonData:finalDic];
        if (kISNullString(extraJsonStr)) {
            return @"";
        }else{
            return extraJsonStr;
        }
    }else{
        return @"";
    }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{

    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {

        jsonString = @"";

    }else{

        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;

}

@end


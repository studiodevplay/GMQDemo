//
//  JPCSearchManager.m

//
//  Created by 洋吴 on 2019/5/7.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCSearchManager.h"
#import "JPCDataBaseTools.h"
#import "JPCConst.h"
#import "MJExtension.h"

@implementation JPCSearchManager

+ (JPCSearchManager *)shareManager{
    
    static JPCSearchManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[JPCSearchManager alloc]init];
    });
    return shareManager;
    
}


- (JPCSettingModel *_Nullable)jp_getAppConfigWithGameName:(NSString *)gameName{
    
    NSArray *arr =  [[JPCDataBaseTools dbTools]getObjectById:kJoypacAPPConfig];
    __block JPCSettingModel *appMolde;
    if (arr.count) {
        
        [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"name"] isEqualToString:gameName]) {
                appMolde = [JPCSettingModel mj_objectWithKeyValues:obj];
                *stop = YES;
            }
        }];
    }
    return appMolde;
}

- (JPCUnitModel *_Nullable)jp_getUnitConfigWithPlacementID:(NSString *)placementID {
    
    NSArray *arr = [[JPCDataBaseTools dbTools] getObjectById:kJoypacUnitConfig];
    __block JPCUnitModel *unitModel;
    if (arr.count) {
        [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"name"]isEqualToString:placementID]) {
                unitModel = [JPCUnitModel mj_objectWithKeyValues:obj];
                *stop = YES;
            }else{
                if ([obj[@"unitID"]isEqualToString:placementID]) {
                    unitModel = [JPCUnitModel mj_objectWithKeyValues:obj];
                }
            }
        }];
    }
    return unitModel;
}

- (JPCSettingModel * _Nullable)jp_getDefaultAppConfig{
    
    NSDictionary *dic = [[JPCDataBaseTools dbTools] getObjectById:kJoypacDefaultAppModel];
    __block JPCSettingModel *defaultAppModel;
    if (!kISNullDict(dic)) {
        defaultAppModel = [JPCSettingModel mj_objectWithKeyValues:dic];
    }
    return defaultAppModel;
}

- (JPCUnitModel *_Nullable)jp_getDefaultUnitConfigWithKey:(NSString *)key unitId:(NSString *_Nullable)unitid{
    
    __block JPCUnitModel *defaultModel;
    if ([key isEqualToString:kJoypacIVModel]) {
        if (!kISNullString(unitid)) {
            id object = [[JPCDataBaseTools dbTools] getObjectById:key];
            if ([object isKindOfClass:[NSArray class]]&&object !=nil) {
                [object enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj[@"name"] && [obj[@"name"]isEqualToString:unitid]) {
                        defaultModel = [JPCUnitModel mj_objectWithKeyValues:obj];
                        *stop = YES;
                    }
                }];
                return defaultModel;
            }else{
                return nil;
            }
            return nil;
        }else{
            return nil;
        }
    }else{
        
        NSDictionary *dic = [[JPCDataBaseTools dbTools] getObjectById:key];
        if (!kISNullDict(dic)) {
            defaultModel = [JPCUnitModel mj_objectWithKeyValues:dic];
        }
        return defaultModel;
    }
}

- (NSDictionary *)jp_getLastShowTimeAndIndexWithPlacement:(NSString *)placement{
    return [[JPCDataBaseTools dbTools] getObjectById:placement];
    
}

- (void)jp_putLastShowTime:(NSString *)time index:(NSString *)index placementID:(NSString *)placementID{
    
    NSDictionary *dic = @{@"JPCLASTINDEX":index,@"JPCLASTSHOWTIME":time};
    [[JPCDataBaseTools dbTools] putObject:dic withId:placementID];
    
}

-(JPCUnitModel *)jp_getRVDefaultUnitConfig{
    NSDictionary *rvDic = [[JPCDataBaseTools dbTools] getObjectById:kJoyoacRVModel];
    __block JPCUnitModel *rvModel;
    if (!kISNullDict(rvDic)) {
        rvModel = [JPCUnitModel mj_objectWithKeyValues:rvDic];
    }
    return rvModel;
    
}

- (NSString *)jp_getMediationAppID{
    
    JPCSettingModel *model = [self jp_getAppConfigWithGameName:kJoypacGameName];
    return model.appID ? model.appID : @"NULL";
    
}

- (NSString *)jp_getMediationSDKName{
    
    
    JPCSettingModel *model = [self jp_getAppConfigWithGameName:kJoypacGameName];
    return model.sdkPlatform ? model.sdkPlatform : @"1";
    
}

- (NSString *)jp_getAppID{
    
    JPCSettingModel *appModel = [self jp_getAppConfigWithGameName:kJoypacGameName];
    if (kISNullString(appModel.appID)) {
        appModel = [self jp_getDefaultAppConfig];
    }
    if (kISNullString(appModel.appID)) {
    
        return @"";
    }else{
        return appModel.appID;
    }
}

- (void)jp_putJPUnitID:(NSString *)unitID Key:(NSString *)key{
    
    [[JPCDataBaseTools dbTools] putString:unitID withId:key];
    
}

- (NSString *)jp_getJPUnitIDWithKey:(NSString *)key{
    
    return [[JPCDataBaseTools dbTools] getStringById:key] ? [[JPCDataBaseTools dbTools] getStringById:key] : 0;
}

@end

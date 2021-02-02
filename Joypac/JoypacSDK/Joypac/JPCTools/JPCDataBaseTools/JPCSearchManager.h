//
//  JPCSearchManager.h

//
//  Created by 洋吴 on 2019/5/7.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPCSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPCSearchManager : NSObject

+ (JPCSearchManager *)shareManager;

//获取当前APP配置文件
- (JPCSettingModel *_Nullable)jp_getAppConfigWithGameName:(NSString *)gameName;

//获取unit配置文件
- (JPCUnitModel *_Nullable)jp_getUnitConfigWithPlacementID:(NSString *)placementID;

//获取本地配置APP文件
- (JPCSettingModel *_Nullable)jp_getDefaultAppConfig;

//获取本地unitConfig
- (JPCUnitModel *_Nullable)jp_getDefaultUnitConfigWithKey:(NSString *)key unitId:(NSString *_Nullable)unitid;

//获取当前聚合SDK APPID
- (NSString *)jp_getMediationAppID;

//获取当前聚合SDK name 空时取值”NULL“
- (NSString *)jp_getMediationSDKName;

//获取当前聚合SDK name 空时取本地值
- (NSString *)jp_getAppID;

//存储joypac placementID
- (void)jp_putJPUnitID:(NSString *)unitID Key:(NSString *)key;

- (NSString *)jp_getJPUnitIDWithKey:(NSString *)key;

#pragma IV&RV
//获取上次展示时间以及游标
- (NSDictionary *)jp_getLastShowTimeAndIndexWithPlacement:(NSString *)placement;

//存储上次展示时间及游标
- (void)jp_putLastShowTime:(NSString *)time index:(NSString *)index placementID:(NSString *)placementID;


@end

NS_ASSUME_NONNULL_END

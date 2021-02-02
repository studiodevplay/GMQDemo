//
//  JPCDataReportManager.h

//
//  Created by 洋吴 on 2019/5/5.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPCHTTPParameter.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPCDataReportManager : NSObject

+ (JPCDataReportManager *) manager;

- (void)reportWithType:(DataReportType)type placementId:(NSString *)placementId reson:(NSString *)reson result:(NSString *)result adType:(NSString *)adType extra1:(NSString *)extra1 extra2:(NSString *)extra2 extra3:(NSString *)extra3;


- (void)reportEventWithEventType:(NSString *)eventType eventSort:(NSString *)eventSort position:(NSString *)position eventExtra:(NSString *)eventExt;

//IAP 代码注入
- (void)reportIAPByEventType:(NSString *)eventType pId:(NSString *)pId failReason:(NSString *)failReason;


@end

NS_ASSUME_NONNULL_END

//
//  JPCAdvertManager.h
//  //
//  Created by 洋吴 on 2019/3/14.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPCProtocal.h"
#import "NSDate+JPCDate.h"
#import "JPCDataReportManager.h"
#import "JPCSearchManager.h"
#import "JPCRecordClass.h"
#import "JPLogManager.h"

@interface JPCAdvertManager : NSObject

@property (nonatomic,weak)id<JPCProtocal> delegate;

@property (nonatomic,strong)JPCUnitModel *ivUnitModel;
@property (nonatomic,strong)JPCUnitModel *rvUnitModel;
@property (nonatomic,strong)JPCUnitModel *splashModel;
@property (nonatomic,strong)JPCUnitModel *bannerModel;
@property (nonatomic,strong)JPCUnitModel *nativeModel;
@property (nonatomic,strong)NSString *JPAppID;

@property (nonatomic, strong)JPCSearchManager *searchManager;

@property (nonatomic,assign)BOOL initializeSDK;

@property (nonatomic,strong)NSMutableArray *queueArr;

+ (JPCAdvertManager *)manager;
//请求广告初始化
- (instancetype)initSDK;
//初始化SDK
- (void)startSDKWithAppID:(NSString *)appID userType:(NSString *)userType adType:(NSString *)type;

- (NSString *)sdkVersion;

- (void)refreshSegment;


@end




//
//  JPCAdvertManager.m

//
//  Created by 洋吴 on 2019/3/14.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCAdvertManager.h"
#import "JPCHTTPSessionManager.h"
#import "JPCDataBaseTools.h"
#import "AnyThinkAdatper.h"
#import "MJExtension.h"




@interface JPCAdvertManager ()

@property (nonatomic, strong)JPCDataBaseTools *dbTools;

@property (nonatomic, strong)id adapter;

@property (nonatomic, assign) BOOL initInHTTP;

@property (nonatomic, assign) BOOL initInDispatch;

@property (nonatomic,strong)NSString *adType;


@end

@implementation JPCAdvertManager


+ (JPCAdvertManager *)manager{
    static JPCAdvertManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JPCAdvertManager alloc]initSDK];
    });
    return manager;
}

- (instancetype)initSDK{
    if (self = [super init]) {
        _dbTools = [JPCDataBaseTools dbTools];
        _searchManager = [JPCSearchManager shareManager];
    }
    return self;
}

- (void)setInitSDKStatus{
    
    [self setupDefaultSetting];
    
}


#pragma mark initSDk
- (void)startSDKWithAppID:(NSString *)appID userType:(NSString *)userType adType:(NSString *)type{
    
    if (![JPCAdvertManager manager].initializeSDK) {
        
        if (userType) {
            
            [kUserDefault setValue:userType forKey:kJoypacUserType];
        }
        [JPCAdvertManager manager].JPAppID = appID;
        
        self.adType = type;
        [self setInitSDKStatus];
        self.initInHTTP = NO;
        self.initInDispatch = NO;
        [self settingLogicHandle];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
}



#pragma mark setting逻辑处理
- (void)settingLogicHandle{
    
    //判断配置文件是否过期
    if ([self checkConfigExp]){
        
        //配置文件过期，请求setting
        [self getSettingData];
        
    }else{
        
        //配置文件没过期，判断timeout_use_cache字段，是否使用上一次配置
        if ([self usingLastConfiguration]) {
            //使用上一次配置
            //判断有没有配置
            if ([self checkLocalConfigConfig]) {
                [JPCHTTPParameter parameter].settingCategory = @"2";
                [self initSDKWithLocalConfig];
                
            }else{
                [JPCHTTPParameter parameter].settingCategory = @"0";
                [self initSDKWithDefaultConfig];
                
                
            }
        }else{
            //不使用上次配置 清除配置
            [self deleteSettingData];
            //重新请求setting
            [self getSettingData];
        }
        
    }
}


#pragma mark 请求setting配置
- (void)getSettingData{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([[[JPCAdvertManager manager]getRequestTimeOut]intValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.initInHTTP && ![JPCAdvertManager manager].initializeSDK) {
            
            if ([self usingLastConfiguration]) {
                
                if ([self checkLocalConfigConfig]) {
                    [JPCHTTPParameter parameter].settingCategory = @"2";
                    [self initSDKWithLocalConfig];
                    
                }else{
                    [JPCHTTPParameter parameter].settingCategory = @"0";
                    [self initSDKWithDefaultConfig];
                    
                }
                
            }else{
                [self deleteSettingData];
                [JPCHTTPParameter parameter].settingCategory = @"0";
                [self initSDKWithDefaultConfig];
                
            }
            
            self.initInDispatch = YES;
            
        }
    });
    [[JPCHTTPSessionManager manager]GET:kJoypacSettingURL params:[[JPCHTTPParameter parameter]getHTTPParameter] timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task,id responseObj) {
        
        [self reportSDKTimeInterval];
        DLog(@"%@\n\tresponseObj = %@",@"Success",responseObj);
        //通过网络请求初始化SDK
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (self.initInDispatch) {
            
            //储存install_scheme
            if (response.statusCode == 200&&responseObj[@"detail"][@"setting"][@"install_scheme"] != nil) {
                if (self.delegate) {
                    NSArray *objArr = responseObj[@"detail"][@"setting"][@"install_scheme"];
                    if ([objArr isKindOfClass:[NSArray class]]&&objArr.count) {
                        //存储安装列表配置规则
                        [self.dbTools putObject:objArr withId:kJoypacInstallScheme];
                    }
                }
            }
            //存储installHash
            if (!kISNullString(responseObj[@"detail"][@"install_scheme_hash"])&&[responseObj[@"detail"][@"install_scheme_hash"] isKindOfClass:[NSString class]]) {
                [kUserDefault setObject:responseObj[@"detail"][@"install_scheme_hash"] forKey:@"installSchemeHash"];
            }
            
            [self refreshSegmentWithArray: responseObj[@"detail"][@"setting"][@"segment"]];
            
            
        }else{
            if (response.statusCode == 200 && responseObj[@"detail"][@"setting"] != nil && responseObj[@"detail"][@"setting"][@"app"] != nil&&responseObj[@"detail"][@"setting"][@"unit"] != nil) {
                //存储setting、使用配置初始化SDK
                [self saveDataModelWithDict:responseObj];
                
            }else{
                if ([self usingLastConfiguration]) {
                    
                    if ([self checkLocalConfigConfig]) {
                        [JPCHTTPParameter parameter].settingCategory = @"2";
                        [self initSDKWithLocalConfig];
                        
                    }else{
                        [JPCHTTPParameter parameter].settingCategory = @"0";
                        [self initSDKWithDefaultConfig];
                        
                    }
                    
                }else{
                    [self deleteSettingData];
                    [JPCHTTPParameter parameter].settingCategory = @"0";
                    [self initSDKWithDefaultConfig];
                    
                }
            }
            
            self.initInHTTP = YES;
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
    
}


#pragma mark 删除配置文件
- (void)deleteSettingData{
    
    [self.dbTools deleteObjectById:kJoypacAPPConfig];
    [self.dbTools deleteObjectById:kJoypacUnitConfig];
    [self.dbTools deleteObjectById:kJoypacGetSettingTime];
    [kUserDefault removeObjectForKey:kJoypacGroupId];
    [kUserDefault removeObjectForKey:kJoypacSegment];
    [self.dbTools deleteObjectById:kJoypacInstallScheme];
    [kUserDefault removeObjectForKey:@"installSchemeHash"];
    
}



- (void)saveDataModelWithDict:(NSDictionary *)dict{
    
    //存储APPconfig
    [self.dbTools putObject:dict[@"detail"][@"setting"][@"app"] withId:kJoypacAPPConfig];
    
    //存储unitConfig
    [self.dbTools putObject:dict[@"detail"][@"setting"][@"unit"] withId:kJoypacUnitConfig];
    
    //存储安装列表信息
    NSArray *objArr = dict[@"detail"][@"setting"][@"install_scheme"];
    if ([objArr isKindOfClass:[NSArray class]]&&objArr.count) {
        //存储安装列表配置规则
        [self.dbTools putObject:objArr withId:kJoypacInstallScheme];
    }
    
    //存储安装列表hash值
    if (!kISNullString(dict[@"detail"][@"install_scheme_hash"])&&[dict[@"detail"][@"install_scheme_hash"] isKindOfClass:[NSString class]]) {
        
        [kUserDefault setObject:dict[@"detail"][@"install_scheme_hash"] forKey:@"installSchemeHash"];
    }
    
    //存储setting时间
    [self.dbTools putString:[NSDate getCurrentTime] withId:kJoypacGetSettingTime];
    
    //group_id
    NSString *groupId = dict[@"detail"][@"group_id"];
    if (!kISNullString(groupId)) {
        [kUserDefault setValue:groupId forKey:kJoypacGroupId];
    }
    
    //log_id
    NSString *logId = dict[@"detail"][@"log_id"];
    if (!kISNullString(logId)) {
        [kUserDefault setValue:logId forKey:kJoypacLogId];
    }
    
    NSArray *segment = dict[@"detail"][@"setting"][@"segment"];
    
    if (segment.count && [segment isKindOfClass:[NSArray class]]) {
        if (segment.count) {
            
            NSDictionary *segmentDic = segment[0];
            NSArray *segmentArr = segmentDic[@"segment_map"];
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc]init];
            if ([segmentArr isKindOfClass:[NSArray class]]) {
                if (segmentArr.count) {
                    [segmentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                            
                            if (obj[@"key"]&&obj[@"value"]) {
                                
                                [dictM setValue:obj[@"value"] forKey:obj[@"key"]];
                            }
                        }
                        
                    }];
                    [kUserDefault setValue:dictM forKey:kJoypacSegment];

                }else{
                    [kUserDefault setValue:@{} forKey:kJoypacSegment];
                }
            }
        }else{
            [kUserDefault setValue:@{} forKey:kJoypacSegment];
        }
        
        
    }else{
        [kUserDefault setValue:@{} forKey:kJoypacSegment];
    }
    
    if (!self.initializeSDK) {
        [JPCHTTPParameter parameter].settingCategory = @"1";
        [self initSDKWithLocalConfig];
        
    }
    
}

#pragma mark 使用默认配置初始化SDK
- (void)initSDKWithDefaultConfig{
    
    NSString *appId = [NSBundle mainBundle].infoDictionary[@"UparpuAppId"];
    NSString *appKey = [NSBundle mainBundle].infoDictionary[@"UparpuAppKey"];
    
    if (!kISNullString(appId)&&!kISNullString(appKey)) {
        self.adapter = [AnyThinkAdatper adatper];
        self.delegate = self.adapter;
        [self startSDKWithAppId:appId appKey:appKey];
        DLog(@"%@\n\tappid = %@\n\tappKey = %@",@"使用默认配置",appId,appKey);
    }
}


#pragma mark 用本地配置初始化SDK
- (void)initSDKWithLocalConfig{
    
    //本地存在配置文件、使用本地配置初始化
    JPCSettingModel *appModel = [self.searchManager jp_getAppConfigWithGameName:kJoypacGameName];
    [JPCHTTPParameter parameter].groupId = [kUserDefault objectForKey:kJoypacGroupId];
    [JPCHTTPParameter parameter].logId   = [kUserDefault objectForKey:kJoypacLogId];
    if (appModel.appID&&appModel.appKey) {
        
        if ([appModel.sdkPlatform isEqualToString:@"1"]) {
            self.adapter = [AnyThinkAdatper adatper];
        }else{
            
        }
        self.delegate = self.adapter;
        [self startSDKWithAppId:appModel.appID appKey:appModel.appKey];
        DLog(@"%@\n\tappid = %@\n\tappKey = %@",@"使用服务端配置",appModel.appID,appModel.appKey);
        
    }
}

#pragma mark 初始化聚合SDK
- (void)startSDKWithAppId:(NSString *)appId appKey:(NSString *)appKey{
    //初始化SDK
    [JPCAdvertManager manager].initializeSDK = YES;
        
    //调用adapter
    [self.delegate initSDKWithAppId:appId appKey:appKey];
    
    //数据上报
    [[JPCDataReportManager manager] reportWithType:kInitSDK placementId:@"" reson:@"" result:@"" adType:@"" extra1:@"" extra2:@"" extra3:@""];
    
    //清空上次广告显示时间
    NSArray *arr = [[JPCDataBaseTools dbTools] getObjectById:kJoypacUnitConfig];
    if (arr.count) {
        [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj[@"unitID"]) {
                [self.searchManager jp_putLastShowTime:[NSDate getCurrentTime] index:@"0" placementID:obj[@"name"]];
            }
        }];
    }
    //执行queue里的代码
    NSMutableArray *queueA = [JPCAdvertManager manager].queueArr;
    if (queueA.count) {
        JPCAdvertManager *manager = [[JPCAdvertManager alloc]initSDK];
        [queueA enumerateObjectsUsingBlock:^(JPCRecordClass *rclass, NSUInteger idx, BOOL * _Nonnull stop) {
            SEL selector = NSSelectorFromString(rclass.m_method);
            if ([manager respondsToSelector:selector]) {
                [manager performSelector:selector withObject:rclass.m_parameter];
            }
        }];
    }
    
    //传递参数给unity unit 维度配置
    if (self.adType) {
        JPCUnitModel *m = [self.searchManager jp_getUnitConfigWithPlacementID:self.adType];
        if (!kISNullString(m.extra)) {
            UnitySendMessage("AdObject", "ReceiveSettingData", [m.extra UTF8String]);
        }
    }
    
    //传递参数给unity app 维度配置
    JPCSettingModel *settingModel = [self.searchManager jp_getAppConfigWithGameName:kJoypacGameName];
    if (!kISNullString(settingModel.extra)) {
        UnitySendMessage("AdObject", "ReceiveExtraData", [settingModel.extra UTF8String]);
    }
}

#pragma mark 判断本地是否存在配置文件
- (BOOL)checkLocalConfigConfig{
    
    NSArray *appConfig = [self.dbTools getObjectById:kJoypacAPPConfig];
    NSArray *unitConfig = [self.dbTools getObjectById:kJoypacUnitConfig];
    //判断是否缓存正确的APPconfig
    __block bool correctConfig = false;
    [appConfig enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"name"] isEqualToString:kJoypacGameName]) {
            correctConfig = true;
        }
    }];
    if (appConfig.count && unitConfig.count && correctConfig) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 判断本地配置文件是否过期
- (BOOL)checkConfigExp{
    
    NSArray *appConfig = [self.dbTools getObjectById:kJoypacAPPConfig];
    if (appConfig.count) {
        __block JPCSettingModel *appModel;
        [appConfig enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"name"] isEqualToString:kJoypacGameName]) {
                appModel = [JPCSettingModel mj_objectWithKeyValues:obj];
                *stop = YES;
            }
        }];
        NSString *saveTime = [self.dbTools getStringById:kJoypacGetSettingTime];
        NSString *currentTime = [NSDate getCurrentTime];
        NSInteger timeInterval = [NSDate timeIntervalFromLastTime:saveTime ToCurrentTime:currentTime];
        if (timeInterval > [appModel.cacheTimeS integerValue]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}

#pragma mark 获取超时时间
- (NSString *)getRequestTimeOut{
    NSArray *appConfig = [self.dbTools getObjectById:kJoypacAPPConfig];
    if (appConfig.count) {
        __block JPCSettingModel *appModel;
        [appConfig enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"name"] isEqualToString:kJoypacGameName]) {
                appModel = [JPCSettingModel mj_objectWithKeyValues:obj];
                *stop = YES;
            }
        }];
        return kISNullString(appModel.requestTimeoutMs) ? @"4" : [NSString stringWithFormat:@"%d",[appModel.requestTimeoutMs intValue]/1000];
    }else{
        return @"4";
    }
}


#pragma mark 获取timeout_use_cache字段
- (BOOL)usingLastConfiguration{
    
    JPCSettingModel *appModel = [self.searchManager jp_getAppConfigWithGameName:kJoypacGameName];
    if (!kISNullString(appModel.timeout_use_cache)) {
        if ([appModel.timeout_use_cache isEqualToString:@"1"]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
    
}

- (void)setupDefaultSetting{
    
    NSString *appId = [NSBundle mainBundle].infoDictionary[@"UparpuAppId"];
    NSString *appKey = [NSBundle mainBundle].infoDictionary[@"UparpuAppKey"];
    if (!kISNullString(appId)&&!kISNullString(appKey)) {
        //设置APP 模型
        NSDictionary *appDict =  @{@"name":[[[NSBundle mainBundle] infoDictionary]objectForKey:@"JoypacAppName"],
                                   @"appID":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"UparpuAppId"],
                                   @"appKey":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"UparpuAppKey"],
                                   @"appSecret":@"",
                                   @"cacheTimeS":@"",
                                   @"requestTimeoutMs":@"5",
                                   @"sdkPlatform":@"1"};
        
        //保存本地配置
        [self.dbTools putObject:appDict withId:kJoypacDefaultAppModel];
    }
    
    if (!kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"bannerPlacement"])) {
        //设置unit模型
        NSString *bannerStatus = kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"bannerStatus"]) ? @"1" : [[[NSBundle mainBundle]infoDictionary]objectForKey:@"bannerStatus"];
        
        NSDictionary *bannerDict = @{@"adOrder":@"1",
                                     @"maxTimeInterval":@"0",
                                     @"sid":@"",
                                     @"minTimeInterval":@"0",
                                     @"status":bannerStatus,
                                     @"unitID":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"bannerPlacement"],
                                     @"name":@""};
        [self.dbTools putObject:bannerDict withId:kjoypacbannerModel];
    }
    
    if (!kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"interstitialConfig"])) {
        NSString *jsonString = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"interstitialConfig"];
        NSError *error = nil;
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
        if(jsonObject != nil && error == nil){
            
            [self.dbTools putObject:jsonObject withId:kJoypacIVModel];
        }
    }
    
    if (!kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"rewardVideoPlacement"])) {
        
        NSString *rvStatus = kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"rewardVideoStatus"]) ? @"1":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"rewardVideoStatus"];
        
        NSDictionary *RVDict = @{@"adOrder":@"1",
                                 @"maxTimeInterval":@"0",
                                 @"sid":@"0",
                                 @"minTimeInterval":@"0",
                                 @"status":rvStatus,
                                 @"unitID":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"rewardVideoPlacement"],
                                 @"name":@""};
        [self.dbTools putObject:RVDict withId:kJoyoacRVModel];
    }
    
    if (!kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"nativePlacement"])) {
        NSString *nativeStatus = kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"nativeStatus"])?@"1":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"nativeStatus"];
        NSDictionary *nativeDict = @{@"adOrder":@"1",
                                     @"sid":@"",
                                     @"maxTimeInterval":@"0",
                                     @"minTimeInterval":@"0",
                                     @"status":nativeStatus,
                                     @"unitID":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"nativePlacement"],
                                     @"name":@""};
        [self.dbTools putObject:nativeDict withId:kJoypacNativeModel];
    }
    if (!kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"splashPlacement"])) {
        NSString *splashStatus = kISNullString([[[NSBundle mainBundle]infoDictionary]objectForKey:@"splashStatus"]) ? @"0" : [[[NSBundle mainBundle]infoDictionary]objectForKey:@"splashStatus"];
        NSDictionary *splashDict = @{@"adOrder":@"1",
                                     @"sid":@"",
                                     @"maxTimeInterval":@"0",
                                     @"minTimeInterval":@"0",
                                     @"status":splashStatus,
                                     @"unitID":[[[NSBundle mainBundle]infoDictionary]objectForKey:@"splashPlacement"],
                                     @"name":@""};
        [self.dbTools putObject:splashDict withId:kJoypacSplashModel];
    }
    
}

- (NSString *)sdkVersion{
    
    return kJoypacSDKVersion;
}

- (void)refreshSegment{
    
    [[JPCHTTPSessionManager manager]GET:kJoypacSettingURL params:[[JPCHTTPParameter parameter]getHTTPParameter] timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task,id responseObj) {
        
        //存储安装列表信息
        NSArray *objArr = responseObj[@"detail"][@"setting"][@"install_scheme"];
        if ([objArr isKindOfClass:[NSArray class]]&&objArr.count) {
            //存储安装列表配置规则
            [self.dbTools putObject:objArr withId:kJoypacInstallScheme];
        }
        
        //存储安装列表hash值
        if (!kISNullString(responseObj[@"detail"][@"install_scheme_hash"])&&[responseObj[@"detail"][@"install_scheme_hash"] isKindOfClass:[NSString class]]) {
            
            [kUserDefault setObject:responseObj[@"detail"][@"install_scheme_hash"] forKey:@"installSchemeHash"];
        }
        
        [self refreshSegmentWithArray:responseObj[@"detail"][@"setting"][@"segment"]];
        
        
    } failure:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
    
    
}

- (void)refreshSegmentWithArray:(NSArray*)array{
    
    
    
    if (array.count && [array isKindOfClass:[NSArray class]]) {
        if (array.count) {
            
            NSDictionary *segmentDic = array[0];
            NSArray *segmentArr = segmentDic[@"segment_map"];
            NSMutableDictionary *dictM = [[NSMutableDictionary alloc]init];
            if ([segmentArr isKindOfClass:[NSArray class]]) {
                if (segmentArr.count) {
                    [segmentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                            
                            if (obj[@"key"]&&obj[@"value"]) {
                                
                                [dictM setValue:obj[@"value"] forKey:obj[@"key"]];
                            }
                        }
                        
                    }];
                    [self.adapter refreshSegmentWithDictionary:dictM];
                    [kUserDefault setValue:dictM forKey:kJoypacSegment];

                }else{
                    [self.adapter refreshSegmentWithDictionary:@{}];
                    [kUserDefault setValue:@{} forKey:kJoypacSegment];
                }
            }
        }else{
            [self.adapter refreshSegmentWithDictionary:@{}];
            [kUserDefault setValue:@{} forKey:kJoypacSegment];
        }
        
        
    }else{
        [self.adapter refreshSegmentWithDictionary:@{}];
        [kUserDefault setValue:@{} forKey:kJoypacSegment];
    }
    
}

- (NSMutableArray *)queueArr{
    if (!_queueArr) {
        _queueArr = [NSMutableArray array];
    }
    return _queueArr;
}

#pragma mark applicationDidFinish&applicationDidBecomeActive
void methodExchange(SEL oldSEL,SEL defaultSEL, SEL newSEL)
{
    Class aClass = objc_getClass("UnityAppController");
    if ( aClass == 0 )
    {
        
        return;
    }
    Class bClass = [JPCAdvertManager class];
    class_addMethod(aClass, newSEL, class_getMethodImplementation(bClass, newSEL),nil);
    class_addMethod(aClass, oldSEL, class_getMethodImplementation(bClass, defaultSEL),nil);
    
    Method oldMethod = class_getInstanceMethod(aClass, oldSEL);
    Method newMethod = class_getInstanceMethod(aClass, newSEL);
    method_exchangeImplementations(oldMethod, newMethod);
    
}


+ (void)load {
    
    methodExchange(@selector(applicationWillEnterForeground:),
    @selector(MEDefaultApplicationWillEnterForeground:),
    @selector(MEMapApplicationWillEnterForeground:));
    
    methodExchange(@selector(application:didFinishLaunchingWithOptions:), @selector(MEDefaultapplication:didFinishLaunchingWithOptions:), @selector(MEMapapplication:didFinishLaunchingWithOptions:));
    
    methodExchange(@selector(application:didReceiveLocalNotification:), @selector(MEDefaultDidReceiveLocalNotification:), @selector(MEMapDidReceiveLocalNotification:));
}


- (void)MEDefaultDidReceiveLocalNotification:(UILocalNotification *)notification{
    
}

- (void)MEMapDidReceiveLocalNotification:(UILocalNotification *)notification{
    
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateActive) {     // 前台
        
        
    } else if (applicationState == UIApplicationStateInactive) {// 从前台进入后台
        
        [[JPCDataReportManager manager]reportEventWithEventType:@"User-Processes" eventSort:@"click" position:@"push" eventExtra:@""];
        
        
    }
}

- (BOOL)MEDefaultapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    
    return YES;
    
}


- (BOOL)MEMapapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [self MEMapapplication:application didFinishLaunchingWithOptions:launchOptions];
    NSString *it = [kUserDefault objectForKey:kJoypacInstallTime];
    if (kISNullString(it)) {
        
        [kUserDefault setValue:[[JPCHTTPParameter parameter]timestamp] forKey:kJoypacInstallTime];
    }
    
    [JPCHTTPParameter parameter].sessionStart = [[JPCHTTPParameter parameter] createSession];
    [JPCHTTPParameter parameter].startTime = [[NSDate date]timeIntervalSince1970];
    
    [[JPCDataReportManager manager]reportWithType:kJoypacSessionStart
                                      placementId:@""
                                            reson:@""
                                           result:@""
                                           adType:@""
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
    if (launchOptions != nil) {
        UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification != nil) {
            // 程序完全退出状态下，点击推送通知后的业务处理
            [[JPCDataReportManager manager]reportEventWithEventType:@"User-Processes" eventSort:@"click" position:@"push" eventExtra:@""];
            
        }
    }
    
    NSInteger applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
    application.applicationIconBadgeNumber = applicationIconBadgeNumber >= 0 ? applicationIconBadgeNumber : 0;
    
    return YES;
}


- (void)MEDefaultApplicationWillEnterForeground:(UIApplication *)application{
    
}

-(void)MEMapApplicationWillEnterForeground:(UIApplication*)application{
    
    [self MEMapApplicationWillEnterForeground:application];
    
    [JPCHTTPParameter parameter].startTime = [[NSDate date]timeIntervalSince1970];
    
    if (([JPCHTTPParameter parameter].startTime - [JPCHTTPParameter parameter].endTime)>=60) {
        
        [JPCHTTPParameter parameter].sessionStart = [[JPCHTTPParameter parameter] createSession];
    }
    
    [[JPCDataReportManager manager]reportWithType:kJoypacSessionStart
                                      placementId:@""
                                            reson:@""
                                           result:@""
                                           adType:@""
                                           extra1:@""
                                           extra2:@""
                                           extra3:@""];
    
    NSInteger applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
    application.applicationIconBadgeNumber = applicationIconBadgeNumber >= 0 ? applicationIconBadgeNumber : 0;
    
    
}


- (void)applicationEnterBackground{
    
    [kUserDefault setValue:[[JPCHTTPParameter parameter]timestamp] forKey:kJoypacWillEnterBackground];
    [JPCHTTPParameter parameter].endTime = [[NSDate date]timeIntervalSince1970];
    long long timeS = [JPCHTTPParameter parameter].startTime;
    long long timeD = [JPCHTTPParameter parameter].endTime - timeS;
    
    NSString *timeDStr = [NSString stringWithFormat:@"%llu",timeD];

    [[JPCDataReportManager manager]reportWithType:kJoypacSessionEnd placementId:@"" reson:@"" result:@"" adType:@"" extra1:@"" extra2:timeDStr extra3:@""];
    
}

#pragma mark 上报SDK时间差
- (void)reportSDKTimeInterval{
    
    [JPCHTTPParameter parameter].requestEndTime = [NSDate getDateTimeTOMilliSeconds];
    
    [[JPCDataReportManager manager]reportWithType:kJPEvent placementId:@"" reson:@"" result:@"" adType:@"" extra1:@"" extra2:@"" extra3:@""];
    
}

@end

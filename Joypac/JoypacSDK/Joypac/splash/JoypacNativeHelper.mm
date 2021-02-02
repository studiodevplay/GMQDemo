//
//  JoypacNativeHelper.c
//  AdmobAdvertANE
//
//  Created by 洋吴 on 2019/4/10.
//  Copyright © 2019 hyx. All rights reserved.
//

#include "JoypacNativeHelper.h"
#import "JPCAdvertManager+nativeSplash.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import "JPCConst.h"


#ifdef __cplusplus
extern "C"{
#endif
    
        void    UnityPause(int pause);
        void    UnityWillResume();
        int     UnityIsPaused();
    
#ifdef __cplusplus
}
#endif

@interface JoypacNativeHelper ()

@property(nonatomic,strong) UIView *backgroundView;

@property(nonatomic,strong) NSString *backgroundTime;

@property(nonatomic,strong)NSDictionary *splashParaDict;

@end



@implementation JoypacNativeHelper


+ (JoypacNativeHelper *)helper{
    static JoypacNativeHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[JoypacNativeHelper alloc]init];
    });
    return helper;
}

- (void) showSplashInLaunchWithCallBack:(callBackBlock)callBack{

    //iap
    
    NSString *IAP = [kUserDefault objectForKey:@"JPCIAP"] ? [kUserDefault objectForKey:@"JPCIAP"] : @"NO";
    
    NSString *placementId =[NSBundle mainBundle].infoDictionary[@"JPSplashPlacement"];
    
    JPCAdvertManager *manager = [JPCAdvertManager manager];
    //延迟时间
    
    NSString *firstLaunch = [kUserDefault objectForKey:@"JPCFirstLaunch"];
    
    if ([IAP isEqualToString:@"YES"] || !firstLaunch) {
        if (callBack) {
            callBack();
        }
        
    }else{
        //暂停游戏
        JPCUnitModel *splashModel = [[JPCSearchManager shareManager] jp_getUnitConfigWithPlacementID:placementId];
        if (!splashModel) {
            splashModel = [[JPCSearchManager shareManager] jp_getDefaultUnitConfigWithKey:kJoypacSplashModel unitId:nil];
        }
        
        
        if ([splashModel.status isEqualToString:@"1"] && placementId) {
            
            if (self.backgroundView != nil) {
                
                [[JoypacNativeHelper helper] getBackgroundView];
                
            }
            
            NSString *appid = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"JoypacAppId"];
            
            [manager startSDKWithAppID:appid userType:@"" adType:@""];
            
            [manager loadNativeSplashWithPlacementId:placementId];
    
            NSDictionary *lanuchDict = [[JPCHTTPParameter parameter] toDictionaryWithJsonString:splashModel.extra];
            NSString *disPatchTime = lanuchDict[@"launch"];
            if (kISNullString(disPatchTime)) {
                disPatchTime = @"0";
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([disPatchTime intValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([manager isReadyNativeSplashWithPlacementId:placementId]){
                    [manager showNativeSplashWithPlacementId:placementId];
                }else{
                    [[JoypacNativeHelper helper] failToLoadSplash];
                    [manager loadNativeSplashWithPlacementId:placementId];
                }
            });
             
        }else{
            if (callBack) {
                callBack();
            }
        }
    }
    [self removeBackgoundView];
    [kUserDefault setObject:@"launched" forKey:@"JPCFirstLaunch"];
    [kUserDefault removeObjectForKey:kJoypacWillEnterBackground];
}



#pragma mark 热启动
- (void) showSplashInEnterForground{
    
    NSString *IAP = [kUserDefault objectForKey:@"JPCIAP"] ? [kUserDefault objectForKey:@"JPCIAP"] : @"NO";
    
    JPCAdvertManager *manager = [JPCAdvertManager manager];
    NSString *placementId = [NSBundle mainBundle].infoDictionary[@"JPSplashPlacement"];
    
    JPCUnitModel *splashModel = [[JPCSearchManager shareManager] jp_getUnitConfigWithPlacementID:placementId];
    
    if (!splashModel) {
        splashModel = [[JPCSearchManager shareManager] jp_getDefaultUnitConfigWithKey:kJoypacSplashModel unitId:nil];
    }
    
    
    
    if ([IAP isEqualToString:@"YES"]){
        [[JoypacNativeHelper helper] failToLoadSplash];
    }else{
        
        if (placementId) {
            
            NSString *leaveTime = [kUserDefault objectForKey:kJoypacWillEnterBackground];
            NSString *activeTime = [[JPCHTTPParameter parameter]timestamp];
            
            NSDictionary *extraDic = [[JPCHTTPParameter parameter]toDictionaryWithJsonString:splashModel.extra];
            NSString *timeD = extraDic[@"becameActive"];
            
            if (kISNullString(timeD)) {
                timeD = @"5";
            }
            int t = ([activeTime intValue]-[leaveTime intValue]);
            if (t >[timeD intValue]&&leaveTime) {
                
                if ([manager isReadyNativeSplashWithPlacementId:placementId]) {
                    [manager showNativeSplashWithPlacementId:placementId];
                    
                }else{
                    [manager loadNativeSplashWithPlacementId:placementId];
                    UnityWillResume();
                    UnityPause(0);
                }
            }else{
                UnityWillResume();
                UnityPause(0);
            }
        }else{
            
            UnityWillResume();
            UnityPause(0);
        }
    }
   [kUserDefault removeObjectForKey:kJoypacWillEnterBackground];
}

#pragma mark 应用进入后台
- (void) applicationDidEnterBackgound{
    
}


#pragma mark 删除等待背景图层
- (void)failToLoadSplash{
    
    if (self.backgroundView) {
        self.backgroundView.alpha = 0;
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    if (UnityIsPaused()){
        UnityWillResume();
        UnityPause(0);
    }else{
        if (self.backBlock) {
            self.backBlock();
        }
    }
}


#pragma mark 获取等待背景图
- (void)getBackgroundView{
    
    self.backgroundView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[self getTheLaunchImage]];
    [self.backgroundView addSubview:imageView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
    
}

- (void) removeBackgoundView{
    if (self.backgroundView) {
        self.backgroundView.alpha = 0;
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
}

#pragma mark 获取启动图片
- (UIImage *)getTheLaunchImage {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    NSString *viewOrientation = nil;
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)) {
        viewOrientation = @"Portrait";
    }else {
        viewOrientation = @"Landscape";
    }
    
    NSString *launchImage = @"";
    
    NSArray *imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary *dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    
    return [UIImage imageNamed:launchImage];
}

#pragma mark 获取友盟在线参数
- (void) getSplashPara:(NSString *)iap dispatchTime:(NSString *)dispatchTime hotScreen:(NSString *)hotScreen{
    
    iap = iap ? iap : @"NO";
    [kUserDefault setValue:iap forKey:@"JPCIAP"];
    
    dispatchTime = dispatchTime ? dispatchTime : @"3";
    [kUserDefault setValue:dispatchTime forKey:@"JPCDISPATCHTIME"];
    
    hotScreen = hotScreen ? hotScreen : @"NO";
    [kUserDefault setValue:hotScreen forKey:@"JPCHOTSCREEN"];
}

@end

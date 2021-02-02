//
//  JoypacGDPR.m
//  Unity-iPhone
//
//  Created by 洋吴 on 2019/9/4.
//

#import "JoypacGDPR.h"
#import "JoypacNativeHelper.h"
#import "JPCConst.h"
#import "JPCHTTPSessionManager.h"
#import "JoypacPrivacyViewController.h"
#import "JPCHTTPParameter.h"
#import "NSDate+JPCDate.h"



#ifdef __cplusplus
extern "C"{
#endif
    
    void    UnityPause(int pause);

    
#ifdef __cplusplus
}
#endif

@interface JoypacGDPR ()

@property(nonatomic,strong)NSString *oldTime;

@end

@implementation JoypacGDPR



+(JoypacGDPR *)shareInstance{
    
    static JoypacGDPR *m_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_instance = [[JoypacGDPR alloc]init];
    });
    return m_instance;
}

- (void)inProtectedAreas{
    
    UnityPause(1);
    [[JoypacNativeHelper helper]getBackgroundView];
    NSString *nowTime = [NSDate getCurrentTime];
    NSTimeInterval differentTime = [self timeDifferent:nowTime];
    NSTimeInterval dispatchTime = 3 - differentTime;
    if (dispatchTime < 0 || !self.oldTime) {
        
        [self performSelector:@selector(doDispatchAfterFunction) withObject:nil afterDelay:1.0];
        
    }else{
        [self performSelector:@selector(doDispatchAfterFunction) withObject:nil afterDelay:dispatchTime];
    }
}

- (void)doDispatchAfterFunction{
    
    NSUserDefaults *userDefault = kUserDefault ;
    NSString *isEurope = [userDefault valueForKey:kJoypacEurope];
    NSString *presented = [userDefault valueForKey:@"hasPresentVC"];
    //    [self presentDataConsentDialog];
    
    if ([isEurope isEqualToString:@"Europe"] && !presented) {
        //欧洲国家弹框
        [self presentDataConsentDialog];
        
    }else{
        //非欧洲国家展示开屏
        [[JoypacNativeHelper helper]showSplashInLaunchWithCallBack:^{
            UnityPause(0);
        }];
    }
}


- (void)sendGDPRRequest{
    
    NSUserDefaults *userDefault = kUserDefault ;
    NSInteger contentStatus = [userDefault integerForKey:kJoypacGDPRStatus];
    
    //已设置同意
    if (contentStatus == JoypacDataConsentSetPersonalized) {
        [[JPCHTTPSessionManager manager]GET:kJoypacGDPRURL params:[[JPCHTTPParameter parameter] getEuropeHTTPParameter] timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
            if (responseObj != nil) {
                if (responseObj[@"detail"] != nil &&responseObj[@"detail"][@"isEU"] != nil) {
                    if ([responseObj[@"detail"][@"isEU"] isKindOfClass:[NSNumber class]]) {
                        NSString *isEU = [NSString stringWithFormat:@"%@",responseObj[@"detail"][@"isEU"]];
                        if ([isEU isEqualToString:@"0"]) {
                            //非欧洲
                            [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
                        }else{
                            [userDefault setValue:@"Europe" forKey:kJoypacEurope];
                        }
                    }else{
                        [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
                    }
                }else{
                    [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
                }
            }else{
                [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
            }
        } failure:^(NSError * _Nullable error) {
            [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
        }];
        
    }else if (contentStatus == JoypacDataConsentSetNonpersonalized){
        
        //用户不同意 请求server
        [[JPCHTTPSessionManager manager]GET:kJoypacGDPRURL params:[[JPCHTTPParameter parameter] getEuropeHTTPParameter] timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
            if (responseObj != nil) {
                if (responseObj[@"detail"] != nil &&responseObj[@"detail"][@"isEU"] != nil) {
                    if ([responseObj[@"detail"][@"isEU"] isKindOfClass:[NSNumber class]]) {
                        NSString *isEU = [NSString stringWithFormat:@"%@",responseObj[@"detail"][@"isEU"]];
                        if ([isEU isEqualToString:@"0"]) {
                            //非欧洲
                            [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
                            [userDefault setInteger:JoypacDataConsentSetPersonalized forKey:kJoypacGDPRStatus];
                        }else{
                            [userDefault setValue:@"Europe" forKey:kJoypacEurope];
                        }
                    }else{
                        [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
                    }
                }else{
                    [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
                }
            }else{
                [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
            }
        } failure:^(NSError * _Nullable error) {
            [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
        }];
        
    }else{
        //未设置
        NSString *countryCode = [userDefault objectForKey:kJoypacEurope];
        if (countryCode != nil && [countryCode isEqualToString:@"NonEurope"]) {
            //有国家信息_非欧盟地区
            [userDefault setInteger:JoypacDataConsentSetPersonalized forKey:kJoypacGDPRStatus];
            
        }else if(countryCode != nil &&[countryCode isEqualToString:@"Europe"]){
            //有国家信息_欧盟地区
            
        }else{
            //无信息
            //添加计时器
            self.oldTime = [NSDate getCurrentTime];
            //请求
            [[JPCHTTPSessionManager manager]GET:kJoypacGDPRURL params:[[JPCHTTPParameter parameter] getEuropeHTTPParameter] timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
                if (responseObj != nil) {
                    if (responseObj[@"detail"] != nil &&responseObj[@"detail"][@"isEU"] != nil) {
                        if ([responseObj[@"detail"][@"isEU"] isKindOfClass:[NSNumber class]]) {
                            NSString *isEU = [NSString stringWithFormat:@"%@",responseObj[@"detail"][@"isEU"]];
                            if ([isEU isEqualToString:@"1"]) {
                                //欧洲
                                //存储国家信息
                                [userDefault setValue:@"Europe" forKey:kJoypacEurope];
                                
                            }else{
                                //非欧洲
                                [userDefault setValue:@"NonEurope" forKey:kJoypacEurope];
                                [userDefault setInteger:JoypacDataConsentSetPersonalized forKey:kJoypacGDPRStatus];
                            }
                        }else{
                            //未知
                            [userDefault setInteger:JoypacDataConsentSetPersonalized forKey:kJoypacGDPRStatus];
                        }
                    }else{
                        //非欧洲
                        [userDefault setInteger:JoypacDataConsentSetPersonalized forKey:kJoypacGDPRStatus];
                    }
                }else{
                    //未知
                    [userDefault setInteger:JoypacDataConsentSetPersonalized forKey:kJoypacGDPRStatus];
                }
            } failure:nil];
            
        }
    }
}

//时间差值
- (NSTimeInterval)timeDifferent:(NSString *)nowTime{
    
    if (!self.oldTime) {
        return 0;
    }else{
        return [NSDate timeIntervalFromLastTime:self.oldTime ToCurrentTime:nowTime];
    }
    
}

//弹出控制器
- (void)presentDataConsentDialog{
    
    JoypacPrivacyViewController *pvc = [[JoypacPrivacyViewController alloc]init];
    UIViewController *rootvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    pvc.responeCallback = ^{
        
        [rootvc dismissViewControllerAnimated:YES completion:^{
            [[JoypacNativeHelper helper]showSplashInLaunchWithCallBack:^{
                
                UnityPause(0);
                [[JoypacNativeHelper helper]removeBackgoundView];
                
            }];
        }];
    };
    
    [rootvc presentViewController:pvc animated:YES completion:nil];
    [kUserDefault setValue:@"yes" forKey:@"hasPresentVC"];
    
}

- (BOOL)presentViewControllerInProtectArea{
    
    NSString *countryCode = [kUserDefault objectForKey:kJoypacEurope];
    if (![countryCode isEqualToString:@"Europe"]) {
        return false;
    }else{
        JoypacPrivacyViewController *pvc = [[JoypacPrivacyViewController alloc]init];
        UIViewController *rootvc = [UIApplication sharedApplication].keyWindow.rootViewController;
        pvc.responeCallback = ^{
            
            [rootvc dismissViewControllerAnimated:YES completion:nil];
        };
        
        [rootvc presentViewController:pvc animated:YES completion:nil];
        
    }
    return true;
    
    
}

@end

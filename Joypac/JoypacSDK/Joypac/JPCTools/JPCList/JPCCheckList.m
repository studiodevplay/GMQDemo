//
//  JPCCheckList.m
//  Joypac_Unity_SDK
//
//  Created by 洋吴 on 2019/12/25.
//  Copyright © 2019 洋吴. All rights reserved.
//

#import "JPCCheckList.h"
#import <UIKit/UIKit.h>
#import "JPCConst.h"
#import "JPCDataBaseTools.h"

@implementation JPCCheckList

+ (NSDictionary *)checkInstallList{
    
    JPCDataBaseTools *dbTools = [JPCDataBaseTools dbTools];
    NSArray *urlSchemes = [dbTools getObjectById:kJoypacInstallScheme];
        
    if ([urlSchemes isKindOfClass:[NSArray class]]&&urlSchemes.count != 0) {
        //服务端规则
        NSMutableDictionary *mDict = [self serviceRuleInstallListWithUrlSchemes:urlSchemes];
        return mDict;
        
    }else{
        //本地规则
        NSMutableDictionary *defaultMdict = [self defaultRuleInstallList];
        return defaultMdict;
    }
}

#pragma mark 服务端规则
+ (NSMutableDictionary *)serviceRuleInstallListWithUrlSchemes:(NSArray *)urlSchemeS{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [urlSchemeS enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dic addEntriesFromDictionary:[self serviceInstallList:obj]];
    }];
    
    return dic;
}

+ (NSMutableDictionary *)serviceInstallList:(NSDictionary *)schemes{
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]init];
    NSString *listValue;
    if (!kISNullString(schemes[@"scheme_target"])) {
        
        listValue = schemes[@"scheme_target"];
        
    }else{
        
        listValue = @"";
        
    }
    
    if (schemes[@"scheme_keys"]) {
        
        NSArray *arr = schemes[@"scheme_keys"];
        
        if (arr.count) {
            
            for (NSString *urlScheme in arr) {
                
                BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlScheme]];
                if (canOpen) {
                    
                    [resultDict setValue:@"1" forKey:listValue];
                    
                    break;
                    
                }
            }
        }
    }
    return resultDict;
}

#pragma mark 本地规则
+ (NSMutableDictionary *)defaultRuleInstallList{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *adwordsDictM = [self adWords];
    NSMutableDictionary *fbDictM = [self facebook];
    NSMutableDictionary *baiduDictM = [self baidu];
    NSMutableDictionary *taobaoDictM = [self taobao];
    NSMutableDictionary *tencentDictM = [self tencent];
    NSMutableDictionary *tiktokDictM = [self tiktok];
    
    if (!kISNullDict(tencentDictM)&&tencentDictM.count) {
        
        [dic addEntriesFromDictionary:tencentDictM];
        
    }
    
    if (!kISNullDict(adwordsDictM)&&adwordsDictM.count) {
        
        [dic addEntriesFromDictionary:adwordsDictM];
        
    }
    
    if (!kISNullDict(fbDictM)&&fbDictM.count) {
        
        [dic addEntriesFromDictionary:fbDictM];
        
    }
    
    if (!kISNullDict(taobaoDictM)&&taobaoDictM.count) {
        
        [dic addEntriesFromDictionary:taobaoDictM];
        
    }
    
    if (!kISNullDict(baiduDictM)&&baiduDictM.count) {
        
        [dic addEntriesFromDictionary:baiduDictM];
        
    }
    
    if (!kISNullDict(tiktokDictM)&&tiktokDictM.count) {
        
        [dic addEntriesFromDictionary:tiktokDictM];
        
    }
    return dic;
}

+ (NSMutableDictionary *)adWords{
    
    NSArray *arr = @[@"googlechrome://",@"youtube://"];
    NSMutableDictionary *adwordsDict = [[NSMutableDictionary alloc]init];
    for (NSString *urlScheme in arr) {
        BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlScheme]];
        if (canOpen) {
            [adwordsDict setValue:@"1" forKey:@"cohort_install_google"];
            return adwordsDict;
            
        }
    }
    return adwordsDict;
}

+ (NSMutableDictionary *)facebook{
    
    NSArray *arr = @[@"instagram://",@"fb://",@"fb-messenger-api://"];
    NSMutableDictionary *facebookDict = [[NSMutableDictionary alloc]init];
    for (NSString *urlScheme in arr) {
        BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlScheme]];
        if (canOpen) {
            [facebookDict setValue:@"1" forKey:@"cohort_install_facebook"];
            return facebookDict;
            
        }
    }
    return facebookDict;
}

+ (NSMutableDictionary *)taobao{
    
    NSArray *arr = @[@"alitaobao://",
                     @"alitmall://",
                     @"ucnews://",
                     @"ucbrowser://",
                     @"koubei://",
                     @"alipays://",
                     @"dingtalk://"];
    NSMutableDictionary *taobaoDict = [[NSMutableDictionary alloc]init];
    for (NSString *urlScheme in arr) {
        BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlScheme]];
        if (canOpen) {
            [taobaoDict setValue:@"1" forKey:@"cohort_install_taobao"];
            return taobaoDict;
            
        }
    }
    return taobaoDict;
}

+ (NSMutableDictionary *)baidu{
    
    NSArray *arr = @[@"baiduboxapp://",@"baidumap://",@"qiyi-iphone://"];
    NSMutableDictionary *baiduDict = [[NSMutableDictionary alloc]init];
    for (NSString *urlScheme in arr) {
        BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlScheme]];
        if (canOpen) {
            [baiduDict setValue:@"1" forKey:@"cohort_install_baidu"];
            return baiduDict;
        }
    }
    return baiduDict;
}

+ (NSMutableDictionary *)tencent{
    
    NSArray *arr = @[@"wechat://",
                     @"mqq://",
                     @"tenvideo://",
                     @"qqnews://",
                     @"comicreader://",
                     @"tencentlaunch1104466820://",
                     @"weread://"];
    NSMutableDictionary *tencentDict = [[NSMutableDictionary alloc]init];
    
    for (NSString *urlScheme in arr) {
        BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlScheme]];
        if (canOpen) {
            [tencentDict setValue:@"1" forKey:@"cohort_install_tencent"];
            return tencentDict;
        }
    }
    return tencentDict;
}

+ (NSMutableDictionary *)tiktok{
    
    NSArray *arr = @[@"snssdk1128://",@"ttnewswttshare://",@"bytedanceApp1112://",@"snssdk32://",@"snssdk1233://"];
    NSMutableDictionary *tiktokDict = [[NSMutableDictionary alloc]init];
    
    for (NSString *urlScheme in arr) {
        BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlScheme]];
        if (canOpen) {
            [tiktokDict setValue:@"1" forKey:@"cohort_install_toutiao"];
            return tiktokDict;
        }
    }
    return tiktokDict;
}

@end

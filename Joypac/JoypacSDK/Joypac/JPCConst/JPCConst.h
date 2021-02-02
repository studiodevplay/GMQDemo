//
//  JPCConst.h

//
//  Created by 洋吴 on 2019/3/14.
//  Copyright © 2019 yodo1. All rights reserved.
//

#ifndef JPCConst_h
#define JPCConst_h


//#ifndef __OPTIMIZE__
//#define DLog(fmt, ...) {NSLog((@"\n======= Joypac LOG ======= \n{\n\tfunction = %@\n\tadType = %@\n\tresult = %@\n\t" fmt "\n}\n=========================="), ##__VA_ARGS__);}
////#define kJoypacSettingURL       @"http://47.101.201.7/api/v1/batch"
////#define kJoypacGDPRURL          @"http://47.101.201.7/api/v1/global"
//#define kJoypacDataReportURL    @"http://47.101.201.7/report"
//#else
//#define DLog(...)
//#define kJoypacDataReportURL    @"https://server.joypac.cn/report"
//#endif

#define kJoypacSettingURL       @"https://server.joypac.cn/api/v1/batch"
#define kJoypacGDPRURL          @"https://server.joypac.cn/api/v1/global"
#define kJoypacDataReportURL    @"https://server.joypac.cn/report"

#define DLog(fmt, ...) [JPLogManager customLogWithFunction:__FUNCTION__ result:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]

//约定key
#define kJoypacKay @"352D74742A67A62598819B29BC5E8A92"

#define kJoypacSDKVersion @"1.2.8"

//当前展示广告的joypac unitID
#define kJoypacBannerUnitID         @"kJoypacBannerUnitID"
#define kJoypacIVUnitID             @"kJoypacIVUnitID"
#define kJoypacRVUnitID             @"kJoypacRVUnitID"
#define kJoypacNativeUnitID         @"kJoypacNativeUnitID"
#define kJoypacSplashUnitID         @"kJoypacSplashUnitID"

//数据库名称
#define kJoypacDBName @"kJoypacDB.db"
//joypac 存储表名
#define kJoypacTableName @"kJoypacTable"

///存储配置
#define kJoypacConfig @"kJoypacConfig"

//APP维度存储
#define kJoypacAPPConfig @"kJoypacAppConfig"

//unit维度存储
#define kJoypacUnitConfig @"kJoypacUnitConfig"

//安装列表
#define kJoypacInstallScheme @"kJoypacInstallScheme"

//当前APP名字
#define kJoypacGameName         [[[NSBundle mainBundle] infoDictionary]objectForKey:@"JoypacAppName"]
#define kJoypacUserType             @"kJoypacUserType"
#define kJoypacGroupId              @"kJoypacGroupId"
#define kJoypacLogId                @"kJoypacLogId"
#define kJoypacSegment              @"kJoypacSegment"
#define kJoypacStartTime            @"kJoypacStartTime"
#define kJoypacWillEnterBackground  @"kJoypacWillEnterBackground"
#define kJoypacDidBecomeActive      @"kJoypacDidBecomeActive"
#define kJoypacIVModel              @"kJoypacIVModel"
#define kJoyoacRVModel              @"kJoyoacRVModel"
#define kJoypacNativeModel          @"kJoypacNativeModel"
#define kjoypacbannerModel          @"kjoypacbannerModel"
#define kJoypacSplashModel          @"kJoypacSplashModel"
#define kJoypacGDPRStatus           @"kJoypacGDPRStatus"
#define kJoypacEurope               @"kJoypacEurope"

#define kJPID                       @"kJPID"
#define kCgroupId                   @"kCgroupId"
#define kUserDefault                [NSUserDefaults standardUserDefaults]
#define kJoypacInstallTime          @"kJoypacInstallTime"
#define kJoypacAdjustJsonString     @"kJoypacAdjustJsonString"

//默认配置
#define kJoypacDefaultAppModel      @"kJoypacDefaultAppModel"

//服务器传来的请求超时时间
#define kJoypacRequestTimeOut       @"kJoypacRequestTimeOut"

//保存配置的事件
#define kJoypacGetSettingTime       @"kJoypacGetSettingTime"

//广告上次展示时间
#define kJoypacBannerLastShowTime   @"kJoypacBannerLastShowTime"

#define kJoypacIVLastShowTime       @"kJoypacIVLastShowTime"

#define kJoypacRVLastShowTime       @"kJoypacRVLastShowTime"

#define kJoypacNativeLastShowTime   @"kJoypacNativeLastShowTime"


//字符串是否为空
#define kISNullString(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kISNullArray(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0 ||[array isEqual:[NSNull null]])
//字典是否为空
#define kISNullDict(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0 || [dic isEqual:[NSNull null]])
//是否是空对象
#define kISNullObject(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))
//判断对象是否为空,为空则返回默认值
#define D_StringFix(_value,_default) ([_value isKindOfClass:[NSNull class]] || !_value || _value == nil || [_value isEqualToString:@"(null)"] || [_value isEqualToString:@"<null>"] || [_value isEqualToString:@""] || [_value length] == 0)?_default:_value

#define UI_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define UI_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define UI_IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREENSIZE_IS_35  (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define SCREENSIZE_IS_40  (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define SCREENSIZE_IS_47  (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define SCREENSIZE_IS_55  (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0 || [[UIScreen mainScreen] bounds].size.width == 736.0)
//判断iPHoneXr
#define SCREENSIZE_IS_XR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1624), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

//判断iPHoneX、iPHoneXs
#define SCREENSIZE_IS_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)
#define SCREENSIZE_IS_XS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

//判断iPhoneXs Max
#define SCREENSIZE_IS_XS_MAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

#define IS_IPhoneX_All ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

//判断iphone 7p 8p
#define SCREENSIZE_IS_8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

//判断iphone 7 8 6sp
#define SCREENSIZE_IS_6SP ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2001), [[UIScreen mainScreen] currentMode].size) && !UI_IS_IPAD : NO)

typedef enum {
    BannerAlignLeft               = 1 << 0,
    BannerAlignHorizontalCenter   = 1 << 1,
    BannerAlignRight              = 1 << 2,
    BannerAlignTop                = 1 << 3,
    BannerAlignVerticalCenter     = 1 << 4,
    BannerAlignBottom             = 1 << 5,
}BannerAlign;

typedef enum{
    kADTypeBanner,
    kADTypeVideo,
    kADTypeIterstital,
    kADTypeNative,
    kADTypeNativeSplash
} ADType;



#endif /* JPCConst_h */

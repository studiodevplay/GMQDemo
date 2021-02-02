//
//  DataReportDelegate.m
//  DataReportDemo
//
//  Created by 洋吴 on 2019/1/7.
//  Copyright © 2019 洋吴. All rights reserved.
//

#import "JPDataReportDelegate.h"
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "JPCHTTPParameter.h"
#import "JPCConst.h"
#import "JPLogManager.h"


@interface JPDataReportDelegate ()

@property (nonatomic,strong)NSArray *appInfoArray;

@end


@implementation JPDataReportDelegate

+ (JPDataReportDelegate*)instance{
    static JPDataReportDelegate *datareportDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        datareportDelegate = [[JPDataReportDelegate alloc]init];
    });
    return datareportDelegate;
}

- (void)JPUploadDataReport{
    
    //距上次上传是否超过24小时
    if (![self isADay]) return;
    
    //apps_info是否有变化
    if (![self isChangeAppsInfo])return;
    
    //上报数据
    [self uploadData];
    
    
}



#pragma mark apps_info是否变化
- (BOOL) isChangeAppsInfo{
    
    NSString *newApps_info = [self UIUtilsFomateJsonArrWithArray:self.appInfoArray];
    NSString *newApps_infoMD5 = [self md5:newApps_info];
    NSString *oldApps_infoMD5 = [kUserDefault  objectForKey:@"appsInfoMD5"];
    if ([newApps_infoMD5 isEqualToString:oldApps_infoMD5]) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark 距上次上传是否超过24小时
- (BOOL) isADay{
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH-mm-ss";
    NSString *dateStr = [kUserDefault  objectForKey:@"uploadDate"];
    if (dateStr == nil ) return YES;
    NSDate *creat = [formatter dateFromString:dateStr]; // 传入的时间
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitHour;
    NSDateComponents *compas = [calendar components:unit fromDate:creat toDate:nowDate options:0];
    if (compas.hour >=24) {
        return YES;
    }else{
        return NO;
    }
}



#pragma mark 上传数据
- (void)uploadData{
    
    NSURLSession *seccion = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://collector-cn.dataplatform.mobvista.com/joypac_ios"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //post请求
    request.HTTPMethod = @"POST";
    //超时时间
    request.timeoutInterval = 10;
    //content-type json
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //设置请求体
    NSString *body = [self getBodyJsonPara];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [seccion dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode == 200) {
            NSDate *date=[NSDate date];
            NSDateFormatter *format1=[[NSDateFormatter alloc] init];
            [format1 setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
            NSString *dateStr;
            dateStr = [format1 stringFromDate:date];
            [kUserDefault  setValue:dateStr forKey:@"uploadDate"];
            NSString *appsInfo = [self UIUtilsFomateJsonArrWithArray:self.appInfoArray];
            NSString *appsInfoMD5 = [self md5:appsInfo];
            if (appsInfoMD5 != nil) {
                
                [kUserDefault  setValue:appsInfoMD5 forKey:@"appsInfoMD5"];
                [kUserDefault  setValue:[self getUserID] forKey:@"userID"];
                
                DLog(@"%@\n\tDescription = %@",@"Success",@"AppList");
            }
            
        }else{
            
            DLog(@"%@\n\tDescription = %@",@"Fail",@"AppList");
        }
    }];
    [dataTask resume];
    
}

#pragma mark 获取请求体参数(json)
- (NSString *) getBodyJsonPara{
    
    NSString *appsInfo = [self UIUtilsFomateJsonArrWithArray:self.appInfoArray];
    if (!appsInfo) {
        return @"noJsonData";
    }
    NSString *userID = [kUserDefault  objectForKey:@"userID"];
    if (!userID) {
        userID = [self getUserID];
    }
    NSDictionary *dic = @{@"id":userID,
                          @"platform":[self getPlarform],
                          @"os_version":[self getOS_version],
                          @"package_name":[self getPackageName],
                          @"app_version":[self getAppVersion],
                          @"app_version_code":[self getAppVersionCode],
                          @"brand":[self getBrand],
                          @"model":[self getModel],
                          @"idfa":[self getIDFA],
                          @"network_type":[self getNetconnType],
                          @"language":[self getLanguage],
                          @"time_zone":[self getTimeZone],
                          @"apps_info":appsInfo,
                          @"idfv":[self getIDFV],
                          @"business_name":@"joypac_ios",
                          @"business_pass":@"joypac_ios-sdk0121"};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
    
}

#pragma mark 获取用户ID
- (NSString *) getUserID{
    NSString *IDFA = [self getIDFA];
    NSString *model = [self getModel];
    NSString *appsInfo = [self UIUtilsFomateJsonArrWithArray:self.appInfoArray];
    
    NSString *IDStr = [NSString stringWithFormat:@"%@%@%@",IDFA,model,appsInfo];
    NSString *IDMD5 = [self md5:IDStr];
    return IDMD5;
    
}

#pragma mark 获取平台 1-android,2-ios,0-other
- (NSString *)getPlarform{
    
    return @"2";
    
}

#pragma mark 获取体统版本号
- (NSString *)getOS_version{
    
    return [[UIDevice currentDevice]systemVersion];
    
}

#pragma mark 应用包名
- (NSString *)getPackageName{
    
    return [NSBundle mainBundle].bundleIdentifier;
}

#pragma mark APP版本号
- (NSString *)getAppVersion{
    
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

#pragma mark APP构建版本号(取整)
- (NSString *)getAppVersionCode{
    
    int appVersionCode = [[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"] floatValue];
    NSString *appVersionCodeStr = [NSString stringWithFormat:@"%d",appVersionCode];
    return appVersionCodeStr;
    
}

#pragma mark 手机品牌
- (NSString *)getBrand{
    
    return @"iPhone";
    
}

#pragma mark 手机型号
- (NSString *)getModel{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    return [self currentModel:model];
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

#pragma mark IDFA
- (NSString *)getIDFA{
    
    if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
        return [[ASIdentifierManager sharedManager] .advertisingIdentifier UUIDString];
    }else{
        return @"00000000-0000-0000-0000-000000000000";
    }
    
}

#pragma mark 网络类型
- (NSString *)getNetconnType{
    
    NSString *netconnType = @"";
    
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络
        {
            
            netconnType = @"no network";
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
                
                netconnType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                
                netconnType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                
                netconnType = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                
                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                
                netconnType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                
                netconnType = @"4G";
            }
        }
            break;
            
        default:
            break;
    }
    
    return netconnType;
}

#pragma mark 语言类型
- (NSString *) getLanguage{
    
    
    return [[kUserDefault  objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
}

#pragma mark 用户选择的时区
- (NSString *) getTimeZone{
    
    return [NSTimeZone localTimeZone].abbreviation;
    
}


- (NSArray *)appInfoArray{
    
    if (!_appInfoArray) {
        _appInfoArray = [self getAppsInfo];
    }
    return _appInfoArray;
    
}

#pragma mark apps_info
- (NSArray *) getAppsInfo{
    
    NSMutableArray *arrM = [NSBundle mainBundle].infoDictionary[@"LSApplicationQueriesSchemes"];
    NSMutableArray *appsInfo = [NSMutableArray array];
    if (arrM.count) {
        
        for (NSString *urlScheme in arrM) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            BOOL canOpen = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[urlScheme stringByAppendingString:@"://"]]];
            NSString *values = [NSString stringWithFormat:@"%d",canOpen];
            [dic setObject:values forKey:urlScheme];
            [appsInfo addObject:dic];
        }
        return appsInfo;
    }else{
        return nil;
    }
}

#pragma mark MD5加密
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

#pragma mark 数据字典转json
- (NSString *)UIUtilsFomateJsonArrWithArray:(NSArray *)array {
    
    if (!array.count) return @"0";
    NSString *string = [NSString string];
    
    for (int j = 0; j<array.count; j++) {
        
        NSDictionary *dic = array[j];
        
        NSArray *keys = [dic allKeys];
        
        for (int i = 0; i<keys.count; i++) {
            
            NSString *key = keys[i];
            
            NSString *value = [dic objectForKey:key];
            
            value = [NSString stringWithFormat:@"\"%@\"",value];
            
            key = [NSString stringWithFormat:@"\"%@\"",key];
            
            if (!string.length) {
                string = [NSString stringWithFormat:@"%@:%@}",key,value];
            }else if(i == 0){
                string = [NSString stringWithFormat:@"%@:%@}%@",key,value,string];
            }else {
                string = [NSString stringWithFormat:@"%@:%@,%@",key,value,string];
            }
        }
        if (j != array.count-1){
            string = [NSString stringWithFormat:@",{%@",string];
        }else{
            string = [NSString stringWithFormat:@"[{%@]",string];
        }
    }
    return string;
}
#pragma mark 方法交换
void DRDelegateMappping(SEL oldSEL,SEL defaultSEL, SEL newSEL)
{
    
    //UnityAppController
    Class aClass = objc_getClass("UnityAppController");
    if ( aClass == 0 )
    {
        
        return;
    }
    Class bClass = [JPDataReportDelegate class];
    class_addMethod(aClass, newSEL, class_getMethodImplementation(bClass, newSEL),nil);
    class_addMethod(aClass, oldSEL, class_getMethodImplementation(bClass, defaultSEL),nil);
    
    Method oldMethod = class_getInstanceMethod(aClass, oldSEL);
    Method newMethod = class_getInstanceMethod(aClass, newSEL);
    method_exchangeImplementations(oldMethod, newMethod);
    
}

void DRdelegateMap(SEL oldSEL,SEL defaultSEL, SEL newSEL)
{
    Class aClass = objc_getClass("UnityAppController");
    if ( aClass == 0 )
    {
        
        return;
    }
    Class bClass = [JPDataReportDelegate class];
    class_addMethod(aClass, newSEL, class_getMethodImplementation(bClass, newSEL),nil);
    class_addMethod(aClass, oldSEL, class_getMethodImplementation(bClass, defaultSEL),nil);
    
    Method oldMethod = class_getInstanceMethod(aClass, oldSEL);
    Method newMethod = class_getInstanceMethod(aClass, newSEL);
    method_exchangeImplementations(oldMethod, newMethod);
    
}


#pragma mark load
+ (void)load {
    
    DRDelegateMappping(@selector(applicationDidBecomeActive:),
                       @selector(DRDefaultApplicationDidBecomeActive:),
                       @selector(DRMapApplicationDidBecomeActive:));
    
}

#pragma mark defaultApplication
- (BOOL)DRDefaultApplicationDidBecomeActive:(UIApplication *)application{
    return YES;
}

-(BOOL)DRMapApplicationDidBecomeActive:(UIApplication*)application{
    
    [self DRMapApplicationDidBecomeActive:application];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JPDataReportDelegate instance]JPUploadDataReport];
    });
    
    
    return YES;
}

- (NSString *)getIDFV{
    
    return [UIDevice currentDevice].identifierForVendor.UUIDString ? [UIDevice currentDevice].identifierForVendor.UUIDString : @"";
    
}

@end

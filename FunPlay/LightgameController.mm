////
////  LightgameController.m
////  Unity-iPhone
////
////  Created by 高梦卿 on 2020/10/22.
////
//
#import "AppController.h"
#import"LightgameChannel.h"
#import "LightGameSDK/LightGameSDK.h"
@interface LightgameController:AppController
@end

@implementation LightgameController

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    NSLog(@"执行 LightgameController");
   #pragma mark - _LightgameChannel
    
    
    // 设置debug log 方便查找问题.仅调试使⽤用。release版本请设置为 NO
         [LightGameManager isDebuLog:NO];
    // 设置debug log 默认为中文，You can change to English:LGDebugLogType_English
         [LightGameManager debugType:LGDebugLogType_Chinese];
    
    
    // 深度转化相关功能配置
         LGBDConfig *bdCfg = [[LGBDConfig alloc] init];
    // 域名默认国内，新加坡:LGBDAutoTrackServiceVendorSG
         bdCfg.serviceVendor = LGBDAutoTrackServiceVendorCN;
    // 是否在控制台输出⽇日志，仅调试使⽤用。release版本请设置为 NO
        bdCfg.showDebugLog = NO;
    // 是否加密⽇日志，默认加密。release版本请设置为 YES
        bdCfg.logNeedEncrypt = YES;
    // ⾃自定义 “⽤用户公共属性”(可选，在需要的位置调⽤用，key相同会覆盖，在调⽤用 startTrackWithConfig 后⽣生效)
        bdCfg.customHeaderBlock = ^NSDictionary<NSString *,id> * _Nonnull{
                return @{@"gender":@"female"};
            };
  //    [LightGameManager ABTestConfigValueForKey:@"keyForABTest" defaultValue:@"defaultValue"];
       
//       bdCfg.ABTestFinishBlock = ^(BOOL ABTestEnabled, NSDictionary * _Nullable allConfigs) {
//
//       };
        [[LightGameManager sharedInstance] configTTTrack:bdCfg];
    
    
    
    _LightgameChannel=[[LightgameChannel alloc ]init ];
    [LightGameManager startWithAppID:@"7X8+jCz7KO0cEcdiuEGva2TYWZVRiUk+kTXBKNUOGMlRjlKjc1XmV4ZGvQoXgyrqSalxYsNtq1CpaGTsaYNboWBkxUOTOdUjNYg96jToJDWDHM8w7xsXuA/MQJ9Je8ZAiwryKTW2Nv0W+zATuRvTAck8L5gs8zy/b3fVerZW+jAhkAnDLNYOPJMP1HqfZWnaCZ4GoCQEvQadWqgNBsoCz16lZ2eXa60Boj085mqFQb16NZ4w0CjVGh3PWLg5/mA61V7OFvcHXpEE0QjdSTb6NDiAB8UH" appName:@"打怪我贼溜_ios" channel:@"App Store"];
    return YES;
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    NSLog(@"执行 LightgameController openURL");
    if ([[BDAutoTrackSchemeHandler sharedHandler] handleURL:url appID:@"213297" scene:nil]) {
        return YES;
    }
      return YES;
    return YES;
}

@end


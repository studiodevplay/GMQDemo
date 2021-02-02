//////
//////  LightgameChannel.m
//////  Unity-iPhone
//////
//////  Created by 高梦卿 on 2020/10/15.
//////
////
#import"LightgameChannel.h"
#import <Foundation/Foundation.h>
#import <LightGameSDK/LGFullScreenVideoAd.h>
#import <LightGameSDK/LGRewardedVideoAd.h>
#import <LightGameSDK/LGNativeAd.h>
#import <LightGameSDK/LightGameManager.h>
LightgameChannel* _LightgameChannel = nil;
@interface  LightgameChannel()<LGRewardedVideoAdDelegate,LGNativeAdDelegate,LGFullScreenVideoAdDelegate>
@property (nonatomic, strong) LGRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) LGFullScreenVideoAd *fullScreenVideoAd;
@property (nonatomic, strong)LGNativeAd *nativeAd;
@property (nonatomic, strong) UIView *customview;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UILabel *adLabel;

@property (nonatomic, strong) LGNativeAdRelatedView *relatedView;
@end
//

@implementation LightgameChannel
-(void)initLightgame{
  
    // 必填参数
    [self initReward:@"945799991"];
    [self initFullscreenAdWithSlotID:@"945799997"];
    
}

-(NSString *)stringFromCString:(const char *)string {
  if (string && string[0] != 0) {
    return [NSString stringWithUTF8String:string];
  }

  return nil;
}

-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil)
      return nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
      NSLog(@"json解析失败：%@",err);
      return nil;
    }
    return dic;
}
-(void)sendMessageToUnity:(NSString *)CALLBACK_OBJECT
               unityMethod:(NSString *)CALLBACK_METHOD
                  msg:(const char*)msg
{

   UnitySendMessage([ CALLBACK_OBJECT cStringUsingEncoding:NSUTF8StringEncoding],[CALLBACK_METHOD cStringUsingEncoding:NSUTF8StringEncoding],msg);
}
-(void)SDKCallBack:(const char*)msg{
    [self sendMessageToUnity:GetLightgameChannel().CALLBACK_OBJECT unityMethod :(@"SDKCallBack") msg:msg];
    
}
#pragma    -------------------------------init-------------------------------------
-(void)initReward:(NSString *)slotID{
    if (!self.rewardedVideoAd){
        LGRewardedVideoModel *rewardModel = [[LGRewardedVideoModel alloc] init];
                //rewardModel.userId = @"900546826";
                _rewardedVideoAd = [[LGRewardedVideoAd alloc] initWithSlotID:slotID rewardedVideoModel:rewardModel];
                _rewardedVideoAd.delegate = self;
    }
   
}

- (void)initBanner {
    LGAdSlot *slot = [[LGAdSlot alloc] init];
    LGAdSize *imgSize = [[LGAdSize alloc] init];
    imgSize.width = 450;
    imgSize.height = 300;
    slot.imgSize = imgSize;
    slot.ID = @"945103048";
    slot.isOriginAd = YES;
    slot.AdType = LGAdSlotAdTypeBanner;
    slot.position = LGAdSlotPositionBottom;
    slot.isSupportDeepLink = YES;
    _nativeAd = [[LGNativeAd alloc] initWithSlot:slot];
    _nativeAd.rootViewController = self.navigationController;
    _nativeAd.delegate = self;
     [_nativeAd loadAdData];
   
}
- (void) initFullscreenAdWithSlotID:(NSString *)slotID {
    if (!self.fullScreenVideoAd){
        self.fullScreenVideoAd = [[LGFullScreenVideoAd alloc] initWithSlotID:slotID];
        _fullScreenVideoAd.delegate = self;
    }
  
   
}


#pragma    -------------------------------logEvent-------------------------------------
-(void )logEvent:(NSString *)event{
   
    NSDictionary*dic=[NSDictionary dictionary];
    [LightGameManager lg_event:event params:dic];
    
}
#pragma    -------------------------------load-------------------------------------
-(void)loadReward{
    if(GetLightgameChannel()._isLog)
    NSLog(@"loadReward");
    [_rewardedVideoAd loadAdData];
}
-(void )loadBanner{
     [_nativeAd loadAdData];
}
-(void)loadFullScreenVideo{
     [_fullScreenVideoAd loadAdData];
}
-(BOOL)hasRewardedVideo{
    return self._isRewardLoad;
   // return [_rewardedVideoAd isAdValid];
}
-(BOOL)hasFullScreenVideo{
    
    return  self._isFullLoad;
   // return [_fullScreenVideoAd isAdValid];
}
#pragma    -------------------------------show-------------------------------------
-(void )showReward{
   
    [_rewardedVideoAd showAdFromRootViewController:UnityGetGLViewController()];
}

-(void)showBanner{
 
}

-(void)showFullScreenVideoAd {
   
      [_fullScreenVideoAd showAdFromRootViewController:UnityGetGLViewController()];
}

 

#pragma <LGNativeAdDelegate>

- (void)nativeAdDidLoad:(LGNativeAd *)nativeAd {
    if(GetLightgameChannel()._isLog)
      NSLog(@"bannerAd did load...\n");
    //self.adLoaded = YES;
}

- (void)nativeAd:(LGNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
//    [ToastHelper toastMessage:[NSString stringWithFormat:@"bannerAd load with error: %@", error.localizedDescription] onView:self.view];
}

- (void)nativeAdDidBecomeVisible:(LGNativeAd *)nativeAd {

}

- (void)nativeAdDidClick:(LGNativeAd *)nativeAd withView:(UIView *_Nullable)view {

}

- (void)nativeAd:(LGNativeAd *)nativeAd dislikeWithReason:(NSArray<LGDislikeWords *> *)filterWords {
    for (LGDislikeWords *dislikeWords in filterWords) {
    }
    //[self.customView removeFromSuperview];
}


extern"C"{
    void _init(char *callbackObjectName,bool isLog){
        [GetLightgameChannel() initLightgame];
        GetLightgameChannel(). CALLBACK_OBJECT = [GetLightgameChannel() stringFromCString:(callbackObjectName)];
         GetLightgameChannel()._isLog=isLog;
    }
}

extern"C"{
    void _logEvent(char *eventName){
        NSString*eventname=[GetLightgameChannel() stringFromCString:(eventName)];
        [GetLightgameChannel() logEvent:eventname ];
    }
}
extern"C"{
    void _loadFullScreenVideo(){
       [GetLightgameChannel()loadFullScreenVideo];
    }
}
extern"C"{
    void _loadReward(){
         [GetLightgameChannel() loadReward];
        
    }
}
extern"C"{
    void _showReward(){
         [GetLightgameChannel() showReward];
         //[GetLightgameChannel() showBanner];
    }
}
extern"C"{
    void _showFullScreenVideoAd(){
        [GetLightgameChannel()showFullScreenVideoAd];
    }
}
extern"C"{
    bool _isFullScreenVideoAvailable(){
        if(GetLightgameChannel()._isLog)
            NSLog(@"_isFullScreenVideoAvailable%@",[GetLightgameChannel() hasFullScreenVideo]?@"YES":@"NO");//打印BOOL型数据YES
       
         
        return [GetLightgameChannel() hasFullScreenVideo];
    }
}
extern"C"{
    bool _isRewardedVideoAvailable(){
        if(GetLightgameChannel()._isLog)
           NSLog(@"_isRewardedVideoAvailable%@",[GetLightgameChannel() hasRewardedVideo]?@"YES":@"NO");//打印BOOL型数据YES
      
                return [GetLightgameChannel() hasRewardedVideo];
    }
}



- (void)rewardedVideoAd:(LGRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd didFailWithError--%ld:%@\n", error.code, error.localizedDescription);
    
      NSString * msg  = [NSString stringWithFormat:@"%@$%d$%@",@"reward",Error,error.localizedDescription ,nil ];
    [self SDKCallBack:[msg cStringUsingEncoding:NSUTF8StringEncoding]];
}
#pragma <LGRewardedVideoAdDelegate>
///以下代理按需实现
- (void)rewardedVideoAdDidLoad:(LGRewardedVideoAd *)rewardedVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAdDidLoad DidLoad...\n");
    // 物料加载后广告才会可用
    self._isRewardLoad=true;
}

- (void)rewardedVideoAdVideoDidLoad:(LGRewardedVideoAd *)rewardedVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd VideoDidLoad...\n");
    // 视频内容load成功后才能展示广告
    
   
}


- (void)rewardedVideoAdWillVisible:(LGRewardedVideoAd *)rewardedVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd WillVisible...\n");
}

- (void)rewardedVideoAdDidVisible:(LGRewardedVideoAd *)rewardedVideoAd {
    UnityPause(true);
    if(GetLightgameChannel()._isLog)
     NSLog(@"rewardedVideoAd DidVisible...\n");
}

- (void)rewardedVideoAdWillClose:(LGRewardedVideoAd *)rewardedVideoAd {
    
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd WillClose...\n");
}

- (void)rewardedVideoAdDidClose:(LGRewardedVideoAd *)rewardedVideoAd {
    self._isRewardLoad=false;
    UnityPause(false);
   NSString * msg  = [NSString stringWithFormat:@"%@$%d$%@",@"reward",Close,@"0" ,nil ];
       [self SDKCallBack:[msg cStringUsingEncoding:NSUTF8StringEncoding]];
}

- (void)rewardedVideoAdDidClick:(LGRewardedVideoAd *)rewardedVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd DidClick...\n");
}

- (void)rewardedVideoAdDidPlayFinish:(LGRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd DidPlayFinish... errer---%ld:%@\n", error.code, error.localizedDescription);
    
}

- (void)rewardedVideoAdServerRewardDidSucceed:(LGRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    NSString * msg  = [NSString stringWithFormat:@"%@$%d$%@",@"reward",Succeed,@"0"];
       [self SDKCallBack:[msg cStringUsingEncoding:NSUTF8StringEncoding]];
}

- (void)rewardedVideoAdServerRewardDidFail:(LGRewardedVideoAd *)rewardedVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd ServerRewardDidFail...\n");
}

- (void)rewardedVideoAdDidClickSkip:(LGRewardedVideoAd *)rewardedVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"rewardedVideoAd DidClickSkip...\n");
}

#pragma <LGFullscreenVideoAdDelegate>
- (void)fullscreenVideoMaterialMetaAdDidLoad:(LGFullScreenVideoAd *)fullscreenVideoAd {
    NSLog(@"fullscreenVideo MaterialMetaAdDidLoa\n");
    // 物料加载后广告才会可用
    [_fullScreenVideoAd isAdValid];
    self._isFullLoad=true;
    
}

- (void)fullscreenVideoAd:(LGFullScreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo didFailWithError---%ld:%@\n", error.code, error.localizedDescription);
    
    NSString * msg  = [NSString stringWithFormat:@"%@$%d$%@",@"interstitial",Error,error.localizedDescription ,nil ];
  [self SDKCallBack:[msg cStringUsingEncoding:NSUTF8StringEncoding]];
    
    
    
}

- (void)fullscreenVideoAdVideoDataDidLoad:(LGFullScreenVideoAd *)fullscreenVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo VideoDataDidLoad\n");
    
}

- (void)fullscreenVideoAdWillVisible:(LGFullScreenVideoAd *)fullscreenVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo WillVisible\n");
}


- (void)fullscreenVideoAdDidVisible:(LGFullScreenVideoAd *)fullscreenVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo DidVisible\n");
}

- (void)fullscreenVideoAdDidClick:(LGFullScreenVideoAd *)fullscreenVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo DidClick\n");
}

- (void)fullscreenVideoAdWillClose:(LGFullScreenVideoAd *)fullscreenVideoAd {
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo WillClose\n");
}


- (void)fullscreenVideoAdDidClose:(LGFullScreenVideoAd *)fullscreenVideoAd {
    self._isFullLoad=false;
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo DidClose\n");
    [self.navigationController popViewControllerAnimated:YES];
    
       NSString * msg  = [NSString stringWithFormat:@"%@$%d$@",@"interstitial",Close,nil ];
    [self SDKCallBack:[msg cStringUsingEncoding:NSUTF8StringEncoding]];
}


- (void)fullscreenVideoAdDidPlayFinish:(LGFullScreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo idPlayFinish error---%ld:%@\n", error.code, error.localizedDescription);
}

- (void)fullscreenVideoAdDidClickSkip:(LGFullScreenVideoAd *)fullscreenVideoAd {
    
    if(GetLightgameChannel()._isLog)
    NSLog(@"fullscreenVideo DidClickSkip\n");
}

//-(NSString*)ISGetValueBaseInput:(NSString *)firstArg, ... NS_REQUIRES_NIL_TERMINATION {
//    NSString* result = firstArg;
//
//
//            result = [NSString stringWithFormat:@"%@$%@",result, arg];
//
//    }
//    return result;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end

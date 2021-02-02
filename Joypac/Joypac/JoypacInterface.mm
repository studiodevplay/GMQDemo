#include <UMOnlineConfig/UMOnlineConfig.h>
#include "Thirdparty/SDWebImage/UIButton+WebCache.h"
#import <AdSupport/AdSupport.h>
#import "JPCConst.h"

@interface JoypacInterface : NSObject<NSURLSessionDelegate> {
    int _crossIndex;
    NSArray* _crossArray;
    UIView* _crossBGView;
    UIButton* _buttonContent;
    UIButton* _buttonClose;
    bool _isSHownCross;
    NSString* _crossAppUrl;
    NSString* _crossAdjustUrl;
}

typedef void(^clickCallback)();
typedef void(^startClickCallback)();
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
-(void)initCross:(NSString*)json_str;
@property (nonatomic,strong)UIButton *crossBtn;
@property (nonatomic,copy) clickCallback clickCallback;
@property (nonatomic,copy) startClickCallback startClickCallback;
@end

@implementation JoypacInterface


-(void)initCross:(NSString*)json_str{
    // _crossIndex = 0;
    NSLog(@"initCross, json_str = %@",json_str);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _crossIndex = [defaults integerForKey:@"CROSS_INDEX"];
    
    _crossArray = nil;
    NSData *data= [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if ([jsonObject isKindOfClass:[NSArray class]]){
        _crossArray = (NSArray *)jsonObject;
        NSLog(@"Dersialized JSON Array = %@", _crossArray);
    } else {
        NSLog(@"An error happened while deserializing the JSON data.");
        return;
    }
    
    float bt_width = (SCREEN_WIDTH<SCREEN_HEIGHT?SCREEN_WIDTH:SCREEN_HEIGHT)*0.8;
    float bt_height = bt_width;
    
    if(_crossBGView!=nil)
    {
        [_crossBGView removeFromSuperview];
    }
    
    _crossBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_crossBGView setBackgroundColor:[UIColor clearColor]];
    
    UIView* block = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [block setBackgroundColor:[UIColor blackColor]];
    [block setAlpha:0.5];
    
    UIButton *btn =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [btn setBackgroundColor:[UIColor clearColor]];
    //    [btn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    [block addSubview:btn];
    
    [_crossBGView addSubview:block];
    
    
    _buttonContent = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-bt_width/2, SCREEN_HEIGHT/2-bt_height/2, bt_width, bt_height)];
    [_buttonContent setBackgroundColor:[UIColor clearColor]];
    [_buttonContent addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _buttonClose = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+bt_width/2-20, SCREEN_HEIGHT/2-bt_height/2-12, 32, 32)];
    
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"UMeng" ofType :@"bundle"];
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *img_path = [bundle pathForResource:@"close" ofType:@"png"];
    
    UIImage *image_1=[UIImage imageWithContentsOfFile:img_path];
    
    [_buttonClose setBackgroundImage:image_1 forState:UIControlStateNormal];
    
    [_buttonClose addTarget:self action:@selector(hideCross) forControlEvents:UIControlEventTouchUpInside];
    
    [_crossBGView addSubview:_buttonContent];
    [_crossBGView addSubview:_buttonClose];
    
}

-(void)showCross:(void(^)())callback startClickCallback:(void(^)()) _startClickCallback{
    self.startClickCallback = _startClickCallback;
    if(!_isSHownCross && _crossArray!=nil)
    {
        if(_crossIndex >= [_crossArray count])
        _crossIndex =0;
        NSArray *arr = [_crossArray objectAtIndex:_crossIndex];
        if(arr && [arr count]==4)
        {
            NSURL *url = [ [ NSURL alloc ] initWithString: [arr objectAtIndex:0]];
            [_buttonContent sd_setImageWithURL:url forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if(image)
                {
                    [[UIApplication sharedApplication].keyWindow addSubview:_crossBGView];
                    _crossAppUrl = [arr objectAtIndex:1];
                    _crossAdjustUrl = [arr objectAtIndex:3];
                    _crossIndex++;
                    _isSHownCross = true;
                    [[NSUserDefaults standardUserDefaults] setInteger:_crossIndex forKey:@"CROSS_INDEX"];
                    callback();
                }
            }];
        }
        else{
            NSLog(@"An error happened while deserializing the JSON data 2.");
        }
    }
    
}

-(void)hideCross{
    
    if (_crossBGView) {
        [_crossBGView removeFromSuperview];
    }
    
    if (self.crossBtn) {
        [self.crossBtn removeFromSuperview];
        self.crossBtn = nil;
        _isSHownCross = NO;
    }
}

-(void)btnClick{
    
    if (self.clickCallback) {
        self.clickCallback();
    }
    
    if(self.startClickCallback){
        self.startClickCallback();
    }
    
    NSURL *url = [[NSURL alloc]initWithString:_crossAppUrl ];
    
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
        [self handHTTPWithUrl:_crossAdjustUrl];
    }
    //    [[UIApplication sharedApplication] openURL:url];
//    NSURLRequest *req = [NSURLRequest requestWithURL:url];
//
//    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError) {
//            NSLog(@"error:%@",connectionError);
//        }else{
//            NSLog(@"response:%@",response);
//            if(response.URL){
//                [[UIApplication sharedApplication] openURL:response.URL];
//            }
//
//        }
//    }];
}

- (void)handHTTPWithUrl:(NSString *)urlString{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?idfa=%@",urlString,[self getIDFA]]];
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:url];
    quest.HTTPMethod = @"GET";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    
    [task resume];
}

- (NSString *)getIDFA{
    
    if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
        return [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    }else{
        return @"00000000-0000-0000-0000-000000000000";
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler;{
    
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
    
    if (urlResponse.statusCode == 302) {
        
        NSDictionary *dic = urlResponse.allHeaderFields;
        
        if (dic[@"Location"]) {
            
            [self handHTTPWithUrl:dic[@"Location"]];
            
        }
    }
}

- (void)showCrossWithOriginX:(CGFloat )x originY:(CGFloat)y width:(CGFloat)w height:(CGFloat)h callBack:(void(^)())callback clickCallback:(void(^)())clickCallback{
    self.clickCallback = clickCallback;
    CGFloat scales = [UIScreen mainScreen].scale;
    //    CGFloat wid = w * [UIScreen mainScreen].bounds.size.width;
    //    CGFloat hig;
    //    if (SCREENSIZE_IS_XR||SCREENSIZE_IS_X||SCREENSIZE_IS_XS_MAX||IS_IPhoneX_All) {
    //        hig = h * ([UIScreen mainScreen].bounds.size.height - 78) ;
    //    }else{
    //        hig = h * [UIScreen mainScreen].bounds.size.height ;
    //    }
    UIButton *crossBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [crossBtn setBackgroundColor: [UIColor whiteColor]];
    if (SCREENSIZE_IS_6SP) {
        
        crossBtn.frame = CGRectMake(x/0.92/scales, y/0.9/scales, w/scales, h/scales);
        
    }else if (SCREENSIZE_IS_8P){
        
        crossBtn.frame = CGRectMake(x/0.87/scales, y/0.87 /scales, w/0.87/scales, h/0.87/scales);
        
    }else if (SCREENSIZE_IS_XR && scales == 2){
        
        crossBtn.frame = CGRectMake(x/scales, y/scales- 44, w/2.2, h/2.2);
    }else{
        
        crossBtn.frame = CGRectMake(x/scales, y/scales, w/scales, h/scales);
        
    }
    //    crossBtn.frame = CGRectMake(x, y, wid, hig);
    
    //    CGFloat halfWidth = [UIScreen mainScreen].bounds.size.width/2;
    //    CGFloat halfHeight = [UIScreen mainScreen].bounds.size.height/2;
    //    CGFloat centY = [UIApplication sharedApplication].keyWindow.rootViewController.view.center.y- y * halfHeight;
    //    CGFloat centX = [UIApplication sharedApplication].keyWindow.rootViewController.view.center.x + x * halfWidth;
    //    crossBtn.center = CGPointMake(centX, centY);
    [crossBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    _crossBtn = crossBtn;
    
    if(!_isSHownCross && _crossArray!=nil)
    {
        if(_crossIndex >= [_crossArray count])
            _crossIndex =0;
        NSArray *arr = [_crossArray objectAtIndex:_crossIndex];
        if(arr && [arr count]==4)
        {
            NSURL *url = [ [ NSURL alloc ] initWithString: [arr objectAtIndex:0]];
            [crossBtn sd_setImageWithURL:url forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if(image)
                {
                    if (self.crossBtn) {
                        [crossBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
                        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:crossBtn];
                        _crossAppUrl = [arr objectAtIndex:1];
                        _crossAdjustUrl = [arr objectAtIndex:3];
                        _crossIndex++;
                        _isSHownCross = true;
                        [[NSUserDefaults standardUserDefaults] setInteger:_crossIndex forKey:@"CROSS_INDEX"];
                        callback();
                    }
                    
                }
            }];
        }
        else{
            NSLog(@"An error happened while deserializing the JSON data 2.");
        }
    }
    
}



@end

extern "C" {
    typedef void (*CallBack)();
    typedef void (*ClickCallBack)();
    
    char* OnlineStringParamUmeng(const char* _key){
        NSString* onlineValue = [UMOnlineConfig stringParams:[NSString stringWithUTF8String:_key]];
        if (onlineValue == nil) {
            return strdup("");
        }
        return strdup([onlineValue UTF8String]);
    }
    
    void InitOnlineParams(const char* _appkey, bool _logEnable){
        [UMOnlineConfig initWithAppkey:[NSString stringWithUTF8String:_appkey]];
        [UMOnlineConfig fetchData];
        [UMOnlineConfig setLogEnabled:_logEnable];
    }
    
    char * ScreenBounds(){
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        NSString *sizeString = [NSString stringWithFormat:@"%f_%f", width, height];
        return strdup([sizeString UTF8String]);
    }
    
    static JoypacInterface* s_joypacInterface = NULL;
    
    void InitCross(const char* _url){
        if(s_joypacInterface == NULL) s_joypacInterface = [[JoypacInterface alloc] init];
        
        [s_joypacInterface initCross:[NSString stringWithUTF8String:_url]];
    }
    
    void ShowCross(CallBack _callback, ClickCallBack _clickCallback){
        
        [s_joypacInterface showCross:^{
            _callback();
        } startClickCallback:^{
            _clickCallback();
        }];
    }
    
    void ShowNativeCrossWithOriginX(float x, float y, float w, float h, CallBack _callback, ClickCallBack _clickCallback){
        [s_joypacInterface showCrossWithOriginX:x originY:y width:w height:h callBack:^{
            _callback();
        } clickCallback:^{
            _clickCallback();
        }];
        
    }
    
    
    void SendUrl2Adjust(const char * _adjustUrl){
        [s_joypacInterface handHTTPWithUrl:[NSString stringWithUTF8String:_adjustUrl]];
    }
    
    void HideCross(){
        [s_joypacInterface hideCross];
    }
}



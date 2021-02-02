//
//  JPCCross.m
//  UPArpuDemo
//
//  Created by 洋吴 on 2019/5/20.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCCross.h"
#import <StoreKit/StoreKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AVFoundation/AVFoundation.h>
#import "UIColor+Hex.h"


//旋转角度
#define degreesToRadinas(x) (M_PI * (x)/180.0)

#define JPC_UI_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define JPC_SCREENSIZE_IS_XR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !JPC_UI_IS_IPAD : NO)

//判断iPHoneX、iPHoneXs
#define JPC_SCREENSIZE_IS_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !JPC_UI_IS_IPAD : NO)

#define JPC_SCREENSIZE_IS_XS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !JPC_UI_IS_IPAD : NO)

//判断iPhoneXs Max
#define JPC_SCREENSIZE_IS_XS_MAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !JPC_UI_IS_IPAD : NO)

#define JPC_IS_IPhoneX_All ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

#define K_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define k_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface JPCCross ()<SKStoreProductViewControllerDelegate,NSURLSessionDelegate>

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UIButton *playBtn;

@property (nonatomic, strong)UIView *mediaView;

@property (nonatomic, strong)UIButton *backgroundView;

@property (nonatomic, assign)BOOL showingCross;

@property (nonatomic, assign)BOOL isReadyVideo;

@property (nonatomic, strong) SKStoreProductViewController *storeProductVC;

@property (nonatomic, assign) NSInteger crossIndex;

//播放器
@property (nonatomic, strong)AVPlayer *JPPlayer;

@property (nonatomic, strong)AVPlayerItem *currentPlayerItem;

@property (nonatomic, strong)NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong)NSString *webVideoPath;

@property (nonatomic, strong)NSString *showUrlString;

@property (nonatomic, strong)NSString *clickUrlStr;

@property (nonatomic, strong)NSString *storekitId;

@property (nonatomic, strong)UIViewController *rootViewController;

@property(nonatomic, strong) UIButton *loadingAnimateBGView;

@end

@implementation JPCCross

+ (JPCCross *)cross{
    
    static JPCCross *cross = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cross = [[JPCCross alloc]init];
        
    });
    return cross;
    
}

- (instancetype)init{
    
    if (self = [super init]) {
        _showingCross = NO;
        _isReadyVideo = NO;
        
        
    }
    return self;
}


- (void)initCrossWithX:(double )x Y:(double)y Width:(float)width Height:(float )height Degrees:(float )degress Dictionary:(NSString *)crossParameter;{
    
    //还在展示拒绝请求
    if (self.showingCross) return;
    
    NSArray *paraArr;
    NSData *data= [crossParameter dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if ([jsonObject isKindOfClass:[NSArray class]]){
        paraArr = (NSArray *)jsonObject;
        NSLog(@"Dersialized JSON Array = %@", paraArr);
    } else {
        NSLog(@"An error happened while deserializing the JSON data.");
        return;
    }
    self.rootViewController = [self getRootViewController];
    if (!paraArr.count) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _crossIndex = [defaults integerForKey:@"CROSS_INDEX"] ? [defaults integerForKey:@"CROSS_INDEX"] : 0;
    if (_crossIndex>= paraArr.count) {
        _crossIndex = 0;
    }
    
    NSDictionary *backgroundFrame = [self getBackgroundViewFrameWithX:x Y:y Width:width Height:height];
    UIButton *backgroundView = [[UIButton alloc]init];
    CGRect bgFrame = backgroundView.frame;
    bgFrame.size.width = [backgroundFrame[@"width"] floatValue];
    bgFrame.size.height = [backgroundFrame[@"height"] floatValue];
    
    backgroundView.frame = bgFrame;
    
    CGPoint bgCenter = backgroundView.center;
    bgCenter.x = [backgroundFrame[@"x"]floatValue];
    bgCenter.y = [backgroundFrame[@"y"]floatValue];
    backgroundView.center = bgCenter;
    backgroundView.layer.cornerRadius = 3.0f;
    backgroundView.layer.masksToBounds = NO;
    backgroundView.layer.shadowOffset = CGSizeMake(0, 3);
    backgroundView.layer.shadowOpacity = 0.3;
    backgroundView.layer.shadowRadius = 3.0f;
    backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    NSArray *items = paraArr[_crossIndex];
    NSString *staticsUrlStr = items[3];
    self.showUrlString = staticsUrlStr;
    NSString *clickUrlStr = items.lastObject;
    self.clickUrlStr = clickUrlStr;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCross:)];
    [backgroundView addGestureRecognizer:tap];
    self.backgroundView = backgroundView;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.storekitId = paraArr[_crossIndex][2];
    //预加载store kit
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    NSDictionary *dic = [NSDictionary dictionaryWithObject:self.storekitId forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dic completionBlock:nil];
    self.storeProductVC = storeProductVC;
    
    [self initSubViewsWithParameter:paraArr[_crossIndex] degrees:degress];
    
}



- (void)initSubViewsWithParameter:(NSArray *)parameter degrees:(int)degrees{
    
    if (!parameter.count) return;
    
    //视频view
    UIView *mediaView = [[UIView alloc]init];
    mediaView.frame = CGRectMake(3, 3, CGRectGetWidth(self.backgroundView.frame) - 6, CGRectGetWidth(self.backgroundView.frame) - 6);
    [self.backgroundView addSubview:mediaView];
    self.mediaView = mediaView;
    
    //底部view
    UIView *bottomView = [[UIView alloc]init];
    bottomView.frame = CGRectMake(0, CGRectGetMaxY(mediaView.frame), CGRectGetWidth(self.backgroundView.frame), self.backgroundView.bounds.size.height - mediaView.frame.size.height-3);
    
    bottomView.layer.cornerRadius = 3.0f;
    bottomView.layer.masksToBounds = YES;
    [self.backgroundView addSubview:bottomView];
    
    //游戏名字
    //    UILabel *nameLabel = [[UILabel alloc]init];
    //    nameLabel.frame = CGRectMake(5, 0,CGRectGetWidth(bottomView.frame) - 51,CGRectGetHeight(bottomView.frame));
    //    nameLabel.font = [UIFont systemFontOfSize:10];
    //
    //    nameLabel.text = parameter[0];
    //    [bottomView addSubview:nameLabel];
    //    self.nameLabel = nameLabel;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(3, CGRectGetHeight(bottomView.frame)/2 - 10, CGRectGetWidth(bottomView.frame) - 6, 20);
    
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"JPCross" ofType :@"bundle"];
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *img_path = [bundle pathForResource:@"2" ofType:@"png"];
    
    UIImage *image_1=[UIImage imageWithContentsOfFile:img_path];
    [btn.imageView setContentMode:UIViewContentModeScaleToFill];
    [btn setImage:image_1 forState:UIControlStateNormal];
    //    btn.layer.cornerRadius = 4.0f;
    //    btn.layer.masksToBounds = YES;
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn addTarget:self action:@selector(tapCross:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btn];
    self.playBtn = btn;
    
    self.backgroundView.transform = CGAffineTransformIdentity;
    self.backgroundView.transform = CGAffineTransformMakeRotation(degreesToRadinas(degrees));
    
    //预加载视频 c2e664ad32f01f9c3254577c182f069b.mp4
    NSString *webVideoPath = parameter[1];
    self.webVideoPath = webVideoPath;
    
    NSString *joypacVideoFile = [NSString stringWithFormat:@"%@.mp4",[self md5:webVideoPath]];
    if ([self isFileExist:joypacVideoFile]) {
        
        NSURL *videoUrl = [NSURL fileURLWithPath:[self videoFilePath:joypacVideoFile]];
        AVAsset *asset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
        
        if (_currentPlayerItem) {
            [_currentPlayerItem removeObserver:self forKeyPath:@"status"];
            [[NSNotificationCenter defaultCenter] removeObserver: self name: AVPlayerItemDidPlayToEndTimeNotification object: _currentPlayerItem];
            _currentPlayerItem = nil;
        }
        _currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        [_currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(replayVideo:)
                                                     name: AVPlayerItemDidPlayToEndTimeNotification object: _currentPlayerItem
         ];
        
        if (!_JPPlayer) {
            _JPPlayer = [AVPlayer playerWithPlayerItem:_currentPlayerItem];
            _JPPlayer.volume = 0;
        }
        if (_JPPlayer.currentItem != _currentPlayerItem) {
            [_JPPlayer replaceCurrentItemWithPlayerItem:_currentPlayerItem];
        }
        
        AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:self.JPPlayer];
        avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        avLayer.frame = mediaView.bounds;
        [mediaView.layer addSublayer:avLayer];
        
    }else{
        
        
        [self downloadCrossVideoWithUrl:webVideoPath];
        
    }
    
    //处理通知
    [self handleObserver];
    
}

//视图属性接口
- (void)bgColor:(NSString *)bgColor titleColor:(NSString *)tColor desTextColor:(NSString *)dColor btnBgColor:(NSString *)btnBgColor btnTextColor:(NSString *)bTColor{
    
    if (self.backgroundView && bgColor) {
        self.backgroundView.backgroundColor = [UIColor colorWithHexString:bgColor];
    }
    if (self.nameLabel && tColor) {
        self.nameLabel.textColor = [UIColor colorWithHexString:tColor];
    }
    
    if (self.playBtn &&btnBgColor) {
        [self.playBtn setBackgroundColor:[UIColor colorWithHexString:btnBgColor]];
    }
    if (self.playBtn && bTColor) {
        [self.playBtn setTitleColor:[UIColor colorWithHexString:bTColor] forState:UIControlStateNormal];
    }
    
}

//展示交叉推广
- (void)showCross{
    
    if (self.backgroundView && !self.showingCross && self.isReadyVideo) {
        
        [[self getRootViewController].view addSubview:self.backgroundView];
        
        self.showingCross = YES;
        
        [self.JPPlayer play];
        
        [self handHTTPWithUrl:self.showUrlString];
        
    }
}

//交叉推广是否准备好
- (BOOL)isReadyCross{
    
    return self.isReadyVideo&&self.backgroundView&&!self.showingCross;
}

//移除交叉推广
- (void)removeCross{
    
    if (self.backgroundView && self.showingCross) {
        [self.JPPlayer pause];
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
        self.showingCross = NO;
        self.isReadyVideo = NO;
        self.crossIndex++;
        [[NSUserDefaults standardUserDefaults] setInteger:self.crossIndex forKey:@"CROSS_INDEX"];
        
        if (_JPPlayer) {
            [_JPPlayer.currentItem removeObserver:self forKeyPath:@"status"];
            
            [_JPPlayer pause];
            _JPPlayer = nil;
        }
        
        if (_currentPlayerItem) {
            [[NSNotificationCenter defaultCenter] removeObserver: self name: AVPlayerItemDidPlayToEndTimeNotification object: _currentPlayerItem];
            _currentPlayerItem = nil;
        }
        
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if ([self folderSizeAtPath:[self createFileDocumentDir]] > 50.f) {
            NSLog(@"当前文件存储大于50M");
            [self clearCache:[self createFileDocumentDir]];
        }else{
            NSLog(@"当前文件存储小于50M");
        }
        
    });
}

//判断当前是否有交叉推广
- (BOOL)isShowCross{
    
    return self.showingCross;
}

#pragma mark 视频下载
- (void)downloadCrossVideoWithUrl:(NSString *)urlString{
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:urlString]];
    [self.downloadTask resume];
    
}

#pragma mark 视频下载回调
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //下载进度
    CGFloat progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        //进行UI操作  设置进度条
        NSLog(@"下载进度%f",progress);
    });
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error){
        
        UnitySendMessage("Joypaccross", "LoadCrossFailCallBack","");
    }
    
    
    
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSString *cache = [self createFileDocumentDir];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[self md5:self.webVideoPath]];
    NSString *file = [cache stringByAppendingPathComponent:fileName];
    NSLog(@"下载后文件存放地址%@",file);
    if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil]) {
        
        AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:file] options:nil];
        
        if (_currentPlayerItem) {
            [_currentPlayerItem removeObserver:self forKeyPath:@"status"];
            _currentPlayerItem = nil;
        }
        _currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
        [_currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        if (!_JPPlayer){
            _JPPlayer = [AVPlayer playerWithPlayerItem:_currentPlayerItem];
            _JPPlayer.volume = 0;
            
            
        }
        if (_JPPlayer.currentItem != _currentPlayerItem) {
            [_JPPlayer replaceCurrentItemWithPlayerItem:_currentPlayerItem];
        }
        
        AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:self.JPPlayer];
        avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        avLayer.frame = self.mediaView.bounds;
        [self.mediaView.layer addSublayer:avLayer];
        
        
    }
}


//获取背景view的frame
- (NSDictionary *) getBackgroundViewFrameWithX:(CGFloat)oX Y:(CGFloat)oY Width:(CGFloat)oWidth Height:(CGFloat)oHeight{
    
    float x = oX;
    float y = oY;
    
    CGFloat halfWidth = [UIScreen mainScreen].bounds.size.width/2;
    CGFloat halfHeight = [UIScreen mainScreen].bounds.size.height/2;
    
    UIView *superView = [self getRootViewController].view;
    x = superView.center.x - x*halfWidth;
    y = superView.center.y - y*halfHeight;
    
    return @{@"x":@(x),@"y":@(y),@"width":@(oWidth),@"height":@(oHeight)};
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//获取视频宽高比
- (CGFloat )getVideoScale:(NSURL *)URL{
    //获取视频尺寸
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    
    NSArray *array = asset.tracks;
    CGSize videoSize = CGSizeZero;
    for (AVAssetTrack *track in array) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
    
    return videoSize.height/videoSize.width;
}

#pragma mark store kit 弹出App Store
- (void)tapCross:(UITapGestureRecognizer *)tap{
    
    [self startloadingCycle];
    if (self.storeProductVC) {
        [self stopLoadingCycle];
        [self.rootViewController presentViewController:self.storeProductVC animated:YES completion:nil];
    }else{
        SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
        storeProductVC.delegate = self;
        NSDictionary *dic = [NSDictionary dictionaryWithObject:self.storekitId forKey:SKStoreProductParameterITunesItemIdentifier];
        [storeProductVC loadProductWithParameters:dic completionBlock:^(BOOL result, NSError * _Nullable error) {
            [self stopLoadingCycle];
            [self.rootViewController presentViewController:storeProductVC animated:YES completion:nil];
            
        }];
        
    }
    
    
    [self handHTTPWithUrl:self.clickUrlStr];
    
    
}

- (void)handHTTPWithUrl:(NSString *)urlString{
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:url];
    quest.HTTPMethod = @"GET";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    
    [task resume];
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

//关闭App Store
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    
    [viewController dismissViewControllerAnimated:YES completion:^{
        self.storeProductVC = nil;
    }];
}

#pragma mark 获取根控制器
- (UIViewController*)getRootViewController {
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray* windows = [[UIApplication sharedApplication] windows];
        for (window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    for (UIView* subView in [window subviews]) {
        UIResponder* responder = [subView nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return [self topMostViewController:(UIViewController*)responder];
        }
    }
    NSLog(@"hyx--获取当前viewcontroller 为nil");
    return nil;
}

- (UIViewController*)topMostViewController:(UIViewController*)controller {
    BOOL isPresenting = NO;
    do {
        UIViewController* presented = [controller presentedViewController];
        isPresenting = presented != nil;
        if (presented != nil) {
            controller = presented;
        }
    } while (isPresenting);
    return controller;
}


//监听通知
- (void)handleObserver{
    
    //设置声音兼容
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];

    //程序进入前台
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playVideo) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //耳机中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    //打电话中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
}

//打电话中断/恢复
- (void)handleInterruption:(NSNotification *)notification{
    
    NSDictionary *info = notification.userInfo;
    //一个中断状态类型
    AVAudioSessionInterruptionType type =[info[AVAudioSessionInterruptionTypeKey] integerValue];
    
    //判断开始中断还是中断已经结束
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //停止播放
        [self.JPPlayer pause];
        
    }else {
        //如果中断结束会附带一个KEY值，表明是否应该恢复音频
        AVAudioSessionInterruptionOptions options =[info[AVAudioSessionInterruptionOptionKey] integerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            //恢复播放
            [self.JPPlayer play];
        }
    }
}

//耳机/蓝牙耳机连接、拔出
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            //判断为耳机接口
            AVAudioSessionRouteDescription *previousRoute =interuptionDict[AVAudioSessionRouteChangePreviousRouteKey];
            
            AVAudioSessionPortDescription *previousOutput =previousRoute.outputs[0];
            NSString *portType =previousOutput.portType;
            
            if ([portType isEqualToString:AVAudioSessionPortHeadphones] || [portType isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
                // 拔掉耳机/蓝牙耳机 继续播放
                
                [self.JPPlayer play];
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            break;
    }
}

- (void)playVideo{
    
    [self.JPPlayer play];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        if (status == AVPlayerStatusReadyToPlay) {
            _isReadyVideo = YES;
            UnitySendMessage("Joypaccross", "LoadCrossSuccessCallBack","");
        } else if (status == AVPlayerStatusFailed) {
            _isReadyVideo = NO;
            NSLog(@"AVPlayerStatusFailed");
        } else {
            _isReadyVideo = NO;
            NSLog(@"AVPlayerStatusUnknown");
        }
    }
}

#pragma mark - 接收播放完成的通知
- (void)replayVideo:(NSNotification *)notification {
    
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
    [self.JPPlayer play];
}

//移除通知
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.JPPlayer = nil;
    
}

#pragma mark MD5
- (nullable NSString *)md5:(nullable NSString *)str {
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

#pragma 创建交叉推广文件相关
- (NSString *)createFileDocumentDir{
    
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:@"JoypacVideo"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"rarFilePath%@",rarFilePath);
    return rarFilePath;
}


-(BOOL) isFileExist:(NSString *)fileName
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:[self videoFilePath:fileName]];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}

- (NSString *)videoFilePath:(NSString *)fileName{
    
    NSString *filePath = [[self createFileDocumentDir] stringByAppendingPathComponent:fileName];
    return filePath;
}

///获取单个文件存储大小
- (float)fileSizeAtPath:(NSString *)path {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

///获取文件夹下文件大小
- (float)folderSizeAtPath:(NSString *)path {
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:absolutePath];
        }
        return folderSize;
    }
    return 0;
}

- (void)clearCache:(NSString *)path {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            if([fileManager removeItemAtPath:absolutePath error:nil]){
                NSLog(@"删除文件%@",absolutePath);
            }else{
                NSLog(@"未删除文件");
            }
            
        }
    }
}

-(void)startloadingCycle{
    
    _loadingAnimateBGView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_WIDTH, k_SCREEN_HEIGHT)];
    [_loadingAnimateBGView setBackgroundColor:[UIColor blackColor]];
    [_loadingAnimateBGView setAlpha:0.5];
    
    UIActivityIndicatorView *loading=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [_loadingAnimateBGView addSubview:loading];
    
    //设置显示位置
    //只能设置中心，不能设置大小，因为UIActivityIndicatorView不能改变大小只能改变位置。
    loading.center = _loadingAnimateBGView.center;
    
    //设置背景色
    loading.backgroundColor = [UIColor clearColor];
    
    //设置背景透明度
    loading.alpha = 1;
    
    [[self getRootViewController].view addSubview:_loadingAnimateBGView];
    
    //开始显示Loading动画
    [loading startAnimating];
    
}

-(void)stopLoadingCycle{
    if(_loadingAnimateBGView){
        
        [_loadingAnimateBGView removeFromSuperview];
        _loadingAnimateBGView = NULL;
        
    }
}


@end


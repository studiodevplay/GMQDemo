//
//  JoypacNativeHelper.h
//  AdmobAdvertANE
//
//  Created by 洋吴 on 2019/4/10.
//  Copyright © 2019 hyx. All rights reserved.
//

#ifndef JoypacNativeHelper_h

#include <stdio.h>
#import <UIKit/UIKit.h>



@interface JoypacNativeHelper : NSObject

typedef void(^callBackBlock)(void);

@property (nonatomic,strong)callBackBlock backBlock;

+ (JoypacNativeHelper *)helper;

- (void) failToLoadSplash;

- (void) showSplashInLaunchWithCallBack:(callBackBlock)callBack;

- (void) showSplashInEnterForground;

- (void) applicationDidEnterBackgound;

- (void) getSplashPara:(NSString *)iap dispatchTime:(NSString *)dispatchTime hotScreen:(NSString *)hotScreen;

- (void) getBackgroundView;

- (void) removeBackgoundView;

@end


#endif /* JoypacNativeHelper_h */

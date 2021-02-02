//
//  UBannerView.m
//
//  Created by huafei qu on 12-11-21.
//  Copyright (c) 2012年 游道易. All rights reserved.
//

#import "AdmobBannerView.h"

@interface AdmobBannerView(){
    BOOL isPause;
    CGPoint currentPoint;
}

@end

@implementation AdmobBannerView

- (instancetype)initWithAdapter {
    self = [super init];
    if (self) {
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)dealloc {

}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    //添加到父View
    if(newSuperview){
        isPause = NO;
        [super willMoveToSuperview:newSuperview];
    } else { //从父View移除
        [super willMoveToSuperview:newSuperview];
        isPause = YES;
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    //当前UIView作为其他UIWindow的子元素被追加或者删除前
    if (newWindow) {
        isPause = NO;
    }else{
        isPause = YES;
    }
    
}

- (CGSize)actualAdSize {
    return self.frame.size;
}

- (void)showBanner {
    [self setAlpha:1.0f];
}

- (void)hideBanner {
    [self setAlpha:0.0f];
}

- (BOOL)isPauseBanner {
    return isPause;
}

- (void)setPause:(BOOL)pause {
    isPause = pause;
}

@end

//
//  AdmobBannerView.h
//  AdmobBannerView
//
//  Created by huafei qu on 12-11-21.
//  Copyright (c) 2012年 游道易. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "AdmobBannerDelegate.h"

@interface AdmobBannerView : UIView

- (instancetype)initWithAdapter;

- (CGSize)actualAdSize;

- (void)hideBanner;

- (void)showBanner;

- (BOOL)isPauseBanner;

- (void)setPause:(BOOL)pause;

@end

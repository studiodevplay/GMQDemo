//
//  UPAdmobBannerDelegate.h
//
//  Created by yixian huang on 2017/8/14.
//
//

#ifndef UPAdmobBannerDelegate_h
#define UPAdmobBannerDelegate_h

#import <Foundation/Foundation.h>

@protocol AdmobBannerDelegate <NSObject>

@optional

/**
 Called after a banner ad has been successfully loaded
 */
- (void)bannerDidLoad;

/**
 Called after a banner has attempted to load an ad but failed.
 
 @param error The reason for the error
 */
- (void)bannerDidFailToLoadWithError:(NSError *)error;

/**
 Called after a banner has been clicked.
 */
- (void)didClickBanner;

/**
 Called when a banner is about to present a full screen content.
 */
- (void)bannerWillPresentScreen;

/**
 Called after a full screen content has been dismissed.
 */
- (void)bannerDidDismissScreen;

@end

#endif /* UPAdmobBannerDelegate_h */

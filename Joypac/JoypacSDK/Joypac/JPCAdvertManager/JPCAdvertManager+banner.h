//
//  JPCAdvertManager+banner.h

//
//  Created by 洋吴 on 2019/5/9.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCAdvertManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPCAdvertManager (banner)

//Banner
- (void)loadBannerWithPlacementId:(NSString *)placementId;

- (void)setBannerAlign:(BannerAlign)align offset:(CGPoint)offset;

- (void)showBannerWithPlacementId:(NSString *)placementId;

- (BOOL)isReadyBannerWithPlacement:(NSString *)placementId;

- (void)hideBanner;

- (void)removeBanner;

@end

NS_ASSUME_NONNULL_END

//
//  JPCAdvertManager+rewardVideo.h

//
//  Created by 洋吴 on 2019/5/6.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCAdvertManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPCAdvertManager (rewardVideo)

//Video
- (void)loadVideoWithPlacementId:(NSString*)placementId;

- (BOOL)isReadVideoWithPlacementId:(NSString *)placementId;

- (void)showVideoWithPlacementId:(NSString *)placementId eventPosition:(NSString *)position;

@end

NS_ASSUME_NONNULL_END

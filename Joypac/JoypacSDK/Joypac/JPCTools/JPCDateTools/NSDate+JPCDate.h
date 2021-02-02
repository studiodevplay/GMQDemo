//
//  NSDate+JPCDate.h

//
//  Created by 洋吴 on 2019/4/2.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (JPCDate)

+ (NSInteger)timeIntervalFromLastTime:(NSString *)lastTime ToCurrentTime:(NSString *)currentTime;

+ (NSString *)getCurrentTime;

+ (long long)getDateTimeTOMilliSeconds;

+ (BOOL)isADayWithTimeString:(NSString *)time;

@end

NS_ASSUME_NONNULL_END

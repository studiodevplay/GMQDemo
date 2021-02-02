//
//  LogManager.h
//  JPSDK
//
//  Created by 洋吴 on 2020/4/26.
//  Copyright © 2020 洋吴. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPLogManager : NSObject

+ (void)setLogEnable:(BOOL)enable;

+ (BOOL)getLogEnable;

+ (void)customLogWithFunction:(const char *)function result:(NSString *)result;

@end

NS_ASSUME_NONNULL_END

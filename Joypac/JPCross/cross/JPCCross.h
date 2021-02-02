//
//  JPCCross.h
//  UPArpuDemo
//
//  Created by 洋吴 on 2019/5/20.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface JPCCross : NSObject

+ (JPCCross *)cross;

- (void)initCrossWithX:(double )x Y:(double)y Width:(float)width Height:(float)height Degrees:(float )degress Dictionary:(NSString *)crossParameter;

- (void)bgColor:(NSString *)bgColor titleColor:(NSString *)tColor desTextColor:(NSString *)dColor btnBgColor:(NSString *)btnBgColor btnTextColor:(NSString *)bTColor;

- (BOOL)isReadyCross;

- (void)showCross;

- (void)removeCross;

- (BOOL)isShowCross;


@end

NS_ASSUME_NONNULL_END

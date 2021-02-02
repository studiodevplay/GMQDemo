//
//  JPCCrossBridge.m
//  UPArpuDemo
//
//  Created by 洋吴 on 2019/7/11.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPCCross.h"

extern "C" {
    
    void initCrossWithString(const double x,const double y,const float width, const float height,const float degrees, const char *jsonStr){
        
        NSString *js = [NSString stringWithUTF8String:jsonStr];
        
        [[JPCCross cross]initCrossWithX:x Y:y Width:width Height:height Degrees:degrees Dictionary:js];
        
    }
    
    void ExtraAttributs(const char *bgColor,const char *titleColor,const char *desTextColor,const char *btnBgColor,const char *btnTextColor){
        NSString *bgC = [NSString stringWithUTF8String:bgColor];
        NSString *tColor = [NSString stringWithUTF8String:titleColor];
        NSString *dTC = [NSString stringWithUTF8String:desTextColor];
        NSString *bBgC = [NSString stringWithUTF8String:btnBgColor];
        NSString *bTC = [NSString stringWithUTF8String:btnTextColor];
        [[JPCCross cross]bgColor:bgC titleColor:tColor desTextColor:dTC btnBgColor:bBgC btnTextColor:bTC];
    }
    
    bool isReadyCross(){
        
        return [[JPCCross cross] isReadyCross];
    }
    
    void showCross(){
        
        [[JPCCross cross]showCross];
        
    }
    
    void removeCross(){
        
        [[JPCCross cross]removeCross];
    }
    
    bool isShowingCross(){
        
        return [[JPCCross cross]isShowCross];
    }
    
}

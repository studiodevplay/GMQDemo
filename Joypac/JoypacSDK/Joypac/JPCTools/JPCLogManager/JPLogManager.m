//
//  LogManager.m
//  JPSDK
//
//  Created by 洋吴 on 2020/4/26.
//  Copyright © 2020 洋吴. All rights reserved.
//

#import "JPLogManager.h"

static BOOL kLogEnable = NO;

@implementation JPLogManager

+ (void)setLogEnable:(BOOL)enable {
    
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    
    return kLogEnable;
    
}


+ (void)customLogWithFunction:(const char *)function result:(NSString *)result{
    
    if ([self getLogEnable]) {
        
        NSLog((@"\n======= Joypac LOG ======= \n{\n\tFunction = %s\n\tresult = %@\n\t"  "\n}\n=========================="), function,result);
    }
    
}



@end

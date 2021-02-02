//
//  NSDictionary+obj.m
//  JoypacSDK
//
//  Created by 洋吴 on 2019/5/17.
//  Copyright © 2019 洋吴. All rights reserved.
//

#import "NSDictionary+obj.h"
#import <objc/runtime.h>

@implementation NSDictionary (obj)

+ (void)load {
    Method fromMethod = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:));
    Method toMethod = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(em_setObject:forKey:));
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)em_setObject:(id)emObject forKey:(NSString *)key {
    if (emObject && key) {
        [self em_setObject:emObject forKey:key];
    }
}

@end

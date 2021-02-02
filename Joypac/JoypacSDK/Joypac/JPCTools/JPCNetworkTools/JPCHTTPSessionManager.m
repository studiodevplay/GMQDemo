//
//  JPCNetWorkTools.m

//
//  Created by 洋吴 on 2019/3/14.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCHTTPSessionManager.h"
#import "JPCConst.h"


@implementation JPCHTTPSessionManager

+ (JPCHTTPSessionManager *)manager{
    static JPCHTTPSessionManager *httpSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpSessionManager = [[self alloc]init];
    });
    return httpSessionManager;
}

-(instancetype)init {
    if (self = [super init]) {
        
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html",@"application/json",@"charset=utf-8",nil];
        _manager.requestSerializer =[AFJSONRequestSerializer serializer];
        
    }
    return self;
}

- (void)GET:(NSString *)url params:(NSDictionary *)params timeoutInterval:(NSString *)timeoutInterval success:(void (^)(NSURLSessionDataTask * _Nonnull task,id responseObj))success failure:(void (^)(NSError *error))failure{
    
    self.manager.requestSerializer.timeoutInterval = [timeoutInterval doubleValue];
    
    [self.manager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)POST:(NSString *)url params:(NSDictionary *)params timeoutInterval:(NSString *)timeoutInterval success:(void (^)(NSURLSessionDataTask * _Nonnull task,id responseObj))success failure:(void (^)(NSError *error))failure{
    
    self.manager.requestSerializer.timeoutInterval = [timeoutInterval doubleValue];
    NSDictionary *header = @{@"Content-Type":@"application/json",@"Accept":@"application/json"};
    [self.manager POST:url parameters:params headers:header constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}



@end

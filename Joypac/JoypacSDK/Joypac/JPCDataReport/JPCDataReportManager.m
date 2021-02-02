//
//  JPCDataReportManager.m

//
//  Created by 洋吴 on 2019/5/5.
//  Copyright © 2019 yodo1. All rights reserved.
//

#import "JPCDataReportManager.h"
#import "JPCHTTPSessionManager.h"
#import "JPCConst.h"
#import "JPLogManager.h"


@implementation JPCDataReportManager

+ (JPCDataReportManager *)manager{
    static JPCDataReportManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JPCDataReportManager alloc]init];
    });
    return manager;
}

#pragma mark - 内部SDK上报
- (void)reportWithType:(DataReportType)type placementId:(NSString *)placementId reson:(NSString *)reson result:(NSString *)result adType:(NSString *)adType extra1:(NSString *)extra1 extra2:(NSString *)extra2 extra3:(NSString *)extra3{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = [[JPCHTTPParameter parameter] getDataReportParameterWithType:type placementid:placementId reson:reson result:result adType:adType extra1:extra1 extra2:extra2 extra3:extra3];
        [[JPCHTTPSessionManager manager] POST:kJoypacDataReportURL params:dic timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task,id responseObj) {

        } failure:^(NSError *error) {
        }];
    });
}

#pragma mark - 游戏上报
- (void)reportEventWithEventType:(NSString *)eventType eventSort:(NSString *)eventSort position:(NSString *)position eventExtra:(NSString *)eventExt{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [[JPCHTTPParameter parameter]eventLogParameterWithEventType:eventType eventSort:eventSort position:position extra:eventExt];
        [[JPCHTTPSessionManager manager]POST:kJoypacDataReportURL params:dict timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
            DLog(@"%@\n\teventType = %@\n\teventSort = %@\n\teventPosition = %@\n\teventExtra = %@\n\tDescription = %@",@"Success",eventType,eventSort,position,eventExt,@"游戏打点上报");

        } failure:^(NSError * _Nullable error) {
            
            DLog(@"%@\n\treson = %@\n\tDescription = %@",@"Fail",error,@"游戏打点上报");        }];
    });
}

#pragma mark - IAP 上报
- (void)reportIAPByEventType:(NSString *)eventType pId:(NSString *)pId failReason:(NSString *)failReason{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = [[JPCHTTPParameter parameter] getDataReportParameterWithType:kJoypacIAP placementid:@"" reson:@"" result:@"" adType:@"" extra1:eventType extra2:pId extra3:failReason];
        [[JPCHTTPSessionManager manager] POST:kJoypacDataReportURL params:dic timeoutInterval:@"60" success:^(NSURLSessionDataTask * _Nonnull task,id responseObj) {
            DLog(@"%@\n\teventType = %@\n\teventExtra = %@\n\tfailReason = %@\n\tDescription = %@",@"Success",eventType,[[JPCHTTPParameter parameter]getIAPParameterWithProductId:pId productInfos:[JPCHTTPParameter parameter].productInfos],failReason,@"用户IAP上报");
        } failure:^(NSError *error) {
            DLog(@"%@\n\treson = %@\n\tDescription = %@",@"Fail",error,@"用户IAP上报");
        }];
    });
    
}

@end

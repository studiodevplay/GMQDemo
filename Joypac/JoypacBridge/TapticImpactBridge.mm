//
//  TapticImpactBridge.mm
//  Unity-iPhone
//
//  Created by orange on 2020/6/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>


@interface TapticImpactBridge : NSObject

@end


@implementation TapticImpactBridge

+(void)generateImpactFeedback:(UIImpactFeedbackStyle)style{
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
    [generator prepare];
    [generator impactOccurred];
    generator = nil;
}

//*******************评价***************************
+(void)rateByUrl{
    NSString* strUrl =  @"itms-apps://itunes.apple.com/app/id1516798037?action=write-review";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
}

+(BOOL)canRateInGame{
    return [SKStoreReviewController respondsToSelector:@selector(requestReview)];
}

+(void)rateInGame{
    [SKStoreReviewController requestReview];
}


@end


extern "C"
{
    void nav_impactLight(){
        [TapticImpactBridge generateImpactFeedback:UIImpactFeedbackStyleLight];
    }

    void nav_impactMedium(){
        [TapticImpactBridge generateImpactFeedback:UIImpactFeedbackStyleMedium];
    }

    void nav_impactHeavy(){
        [TapticImpactBridge generateImpactFeedback:UIImpactFeedbackStyleHeavy];
    }

    //URL评价
    void nav_rateByUrl()
    {
        NSString* strUrl =  @"itms-apps://itunes.apple.com/app/id1516798037?action=write-review";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
    }
    //游戏是否可以内评价
    BOOL nav_canRateInGame()
    {
        return [SKStoreReviewController respondsToSelector:@selector(requestReview)];
    }
    //游戏内评价
    void nav_rateInGame()
    {
        if(nav_canRateInGame)
            [SKStoreReviewController requestReview];
    }

    
    //*******************本地通知***************************
    //注册通知
    void nav_RegisterNotification()
    {
        UIUserNotificationSettings* notiSettings;
        notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert) categories: nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notiSettings];
    }
    //添加一条本地通知
    void nav_AddLocalNotification(const char* notifiText,float waitSecond)
    {
        // create local notification
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        NSDate *date = [NSDate date];
        NSDate *dateNotifi = [NSDate dateWithTimeInterval:waitSecond sinceDate:date];
        localNotif.fireDate = dateNotifi;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.alertBody = [NSString stringWithUTF8String:notifiText];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    //清理通知
    void nav_ClearAllLocalNotifications()
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

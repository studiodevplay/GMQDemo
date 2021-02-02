//
//  JoypacGDPR.h
//  Unity-iPhone
//
//  Created by 洋吴 on 2019/9/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JoypacGDPR : NSObject

typedef NS_ENUM(NSInteger, JoypacDataConsentSet) {
    
    JoypacConsentSetUnknown = 0,
    JoypacDataConsentSetPersonalized = 1,
    JoypacDataConsentSetNonpersonalized = 2,
};

+(JoypacGDPR *)shareInstance;

- (void)inProtectedAreas;

- (void)sendGDPRRequest;

- (BOOL)presentViewControllerInProtectArea;

@end

NS_ASSUME_NONNULL_END

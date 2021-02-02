//
//  JoypacPrivacyViewController.h
//  Unity-iPhone
//
//  Created by 洋吴 on 2019/9/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ResponeCallback)(void);

@interface JoypacPrivacyViewController : UIViewController

@property(nonatomic,copy)ResponeCallback responeCallback;

@end

NS_ASSUME_NONNULL_END

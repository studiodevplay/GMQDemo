//
//  LightgameChannel.h
//  Unity-iPhone
//
//  Created by 高梦卿 on 2020/10/15.
//

#ifndef LightgameChannel_h
#define LightgameChannel_h


#endif /* LightgameChannel_h */

#import <UIKit/UIKit.h>
#import "UnityAppController.h"
@interface LightgameChannel :UIViewController
extern UIViewController *UnityGetGLViewController();
@property NSString *CALLBACK_OBJECT ;
@property BOOL _isLog;
@property BOOL _isRewardLoad;
@property BOOL _isFullLoad;
enum CallBackCode {
    Error = -1,
    NotReady = 0,
    Succeed = 1,
    Failed = 2,
    Skipped = 3,
    Close=4
    
};
@end


extern LightgameChannel* _LightgameChannel;
inline LightgameChannel* GetLightgameChannel()
{
    return _LightgameChannel;
}

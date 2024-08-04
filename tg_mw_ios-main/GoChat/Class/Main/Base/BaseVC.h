//
//  BaseVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "NavBaseVC.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSInteger, UIFunc) {
    
    UIFuncDeviceAddTimer,
    UIFuncDeviceEditTimer,
    UIFuncRoomAdd,
    UIFuncRoomEdit,
    UIFuncDeviceAdd,
    UIFuncDeviceEdit,
    UIFuncRuleAdd,
    UIFuncRuleEdit,
    UIFuncRuleTaskAdd,
    UIFuncRuleTaskEdit,
    UIFuncHubAdd,
};
typedef enum {
    NavigationType_Apple = 1,
    NavigationType_GaoDe,
    NavigationType_Google,
    NavigationType_QQ,
    NavigationType_Baidu,
} NavigationType;
@interface BaseVC : NavBaseVC
<BusinessListenerProtocol>

/// 显示logo 默认不显示
- (void)showLogoUI;

@end

NS_ASSUME_NONNULL_END

//
//  SettingHelper.h
//  GoChat
//
//  Created by Autumn on 2022/2/9.
//

#import <Foundation/Foundation.h>
#import "SessionDevice.h"
#import "NotificationSoundInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BOOLCompletion)(BOOL success);
typedef void(^SessionsCompletion)(NSArray<SessionDevice *> *lists);
typedef void(^NotificationSoundCompletion)(NotificationSoundInfo * _Nullable info);

@interface SettingHelper : NSObject

/// 获取账号离线期限
+ (void)getAccountTtl:(void(^)(NSNumber *days))completion;
/// 设置账号离线期限
+ (void)setAccountTtl:(NSNumber *)day completion:(BOOLCompletion)completion;

/// 获取多端登录状态
+ (void)getAccountMultiOnline:(BOOLCompletion)completion;
/// 设置允许多端登录
+ (void)setAccountMultiOnline:(BOOL)isOn completion:(BOOLCompletion)completion;

/// 下线其他终端设备
+ (void)terminateAllOtherSessions:(BOOLCompletion)completion;

/// 下线终端
+ (void)terminateSession:(NSInteger)sId completion:(BOOLCompletion)completion;

/// 获取登录的设备
+ (void)getActiveSessions:(SessionsCompletion)completion;


+ (void)getNotificationSettings:(NotificationSoundCompletion)completion;

+ (void)modifyNotificationSettings:(NotificationSoundInfo *)info completion:(BOOLCompletion)completion;

@end

NS_ASSUME_NONNULL_END

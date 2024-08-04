//
//  NotificationSoundInfo.h
//  GoChat
//
//  Created by Autumn on 2022/2/26.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationSoundInfo : JWModel

/// 显示通知
@property (nonatomic, assign) BOOL showNotification;

/// 应用内声音提示
@property (nonatomic, assign) BOOL inAppSound;

/// 应用内震动提示
@property (nonatomic, assign) BOOL inAppVibration;

- (NSArray *)values;

- (NSDictionary *)jsonObject;

+ (instancetype)defaultSetting;

@end

NS_ASSUME_NONNULL_END

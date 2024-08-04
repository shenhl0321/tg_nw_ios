//
//  NotificationSoundInfo.m
//  GoChat
//
//  Created by Autumn on 2022/2/26.
//

#import "NotificationSoundInfo.h"

@implementation NotificationSoundInfo

- (NSArray *)values {
    return @[@[@(self.showNotification)], @[@(self.inAppSound), @(self.inAppVibration)]];
}

- (NSDictionary *)jsonObject {
    return @{
        @"showNotification": @(self.showNotification),
        @"inAppSound": @(self.inAppSound),
        @"inAppVibration": @(self.inAppVibration),
    };
}

+ (instancetype)defaultSetting {
    NotificationSoundInfo *info = NotificationSoundInfo.model;
    info.showNotification = YES;
    info.inAppSound = YES;
    info.inAppVibration = YES;
    return info;
}

@end

//
//  SessionDevice.m
//  GoChat
//
//  Created by Autumn on 2022/2/9.
//

#import "SessionDevice.h"

@implementation SessionDevice

- (UIImage *)deviceIcon {
    if (self.api_id == 81) {
        return [UIImage imageNamed:@"icon_device_web"];
    } else if ([self.system_version.lowercaseString containsString:@"macos"] ||
               [self.system_version.lowercaseString containsString:@"windows"]) {
        return [UIImage imageNamed:@"icon_device_pc"];
    } else {
        return [UIImage imageNamed:@"icon_device_phone"];
    }
}

- (NSString *)versionText {
    NSString *platform;
    
    if (self.api_id == 81) {
        platform = @"Web";
    } else if ([self.system_version.lowercaseString containsString:@"windows"] ||
               [self.system_version.lowercaseString containsString:@"macos"]) {
        platform = @"Desktop";
    } else if ([self.device_model.lowercaseString containsString:@"iphone"] ||
               [self.device_model.lowercaseString containsString:@"ipad"] ||
               [self.device_model.lowercaseString containsString:@"ios"]) {
        platform = @"iOS";
    } else {
        platform = @"Android";
    }
    return [NSString stringWithFormat:@"%@ %@ %@", Common.appName, platform, self.system_version];
}

@end

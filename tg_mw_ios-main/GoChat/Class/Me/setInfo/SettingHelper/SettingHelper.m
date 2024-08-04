//
//  SettingHelper.m
//  GoChat
//
//  Created by Autumn on 2022/2/9.
//

#import "SettingHelper.h"

@implementation SettingHelper

+ (void)getAccountTtl:(void(^)(NSNumber *days))completion {
    NSDictionary *parameters = @{@"@type": @"getAccountTtl"};
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"accountTtl"]) {
            return;
        }
        NSNumber *days = response[@"days"];
        !completion ? : completion(days);
    } timeout:^(NSDictionary *request) {}];
}

+ (void)setAccountTtl:(NSNumber *)day completion:(BOOLCompletion)completion {
    NSDictionary *parameters = @{
        @"@type": @"setAccountTtl",
        @"ttl": @{
            @"@type": @"accountTtl",
            @"days": day
        }
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        if ([TelegramManager isResultOk:response]) {
            !completion ? : completion(YES);
        }
    } timeout:^(NSDictionary *request) {}];
}

+ (void)getAccountMultiOnline:(BOOLCompletion)completion {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"accounts.getMultiOnline"
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"customRequestResult"]) {
            return;
        }
        NSString *result = response[@"result"];
        NSDictionary *resp = result.mj_JSONObject;
        if ([resp[@"code"] intValue] != 200) {
            return;
        }
        NSDictionary *data = resp[@"data"];
        BOOL isOn = [data[@"isOn"] boolValue];
        !completion ? : completion(isOn);
        if (!isOn) {
            [self terminateAllOtherSessions:^(BOOL success) {}];
        }
    } timeout:^(NSDictionary *request) {}];
}

+ (void)setAccountMultiOnline:(BOOL)isOn completion:(BOOLCompletion)completion {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"accounts.toggleMultiOnline",
        @"parameters": @{@"isOn": @(isOn)}.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"customRequestResult"]) {
            !completion ? : completion(false);
            return;
        }
        NSString *result = response[@"result"];
        NSDictionary *resp = result.mj_JSONObject;
        BOOL success = [resp[@"code"] intValue] == 200;
        !completion ? : completion(success);
        if (success && !isOn) {
            [self terminateAllOtherSessions:^(BOOL success) {}];
        }
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(false);
    }];
}

+ (void)terminateAllOtherSessions:(BOOLCompletion)completion {
    NSDictionary *parameters = @{@"@type": @"terminateAllOtherSessions"};
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        !completion ? : completion([TelegramManager isResultOk:response]);
    } timeout:^(NSDictionary *request) {}];
}

+ (void)terminateSession:(NSInteger)sId completion:(BOOLCompletion)completion {
    NSDictionary *parameters = @{@"@type": @"terminateSession", @"session_id": @(sId)};
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        !completion ? : completion([TelegramManager isResultOk:response]);
    } timeout:^(NSDictionary *request) {}];
}

+ (void)getActiveSessions:(SessionsCompletion)completion {
    NSDictionary *parameters = @{@"@type": @"getActiveSessions"};
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"sessions"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *sessions = response[@"sessions"];
        NSArray *lists = [SessionDevice mj_objectArrayWithKeyValuesArray:sessions];
        !completion ? : completion(lists);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}


+ (void)getNotificationSettings:(NotificationSoundCompletion)completion {
    NSDictionary *param = @{
        @"@type": @"sendCustomRequest",
        @"method": @"accounts.getNotificationSettings",
        @"parameters": @""
    };
    [TelegramManager.shareInstance jw_request:param result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            NotificationSoundInfo *info = [NotificationSoundInfo mj_objectWithKeyValues:resp[@"data"]];
            !completion ? : completion(info);
            return;
        }
        !completion ? : completion(nil);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(nil);
    }];
}

+ (void)modifyNotificationSettings:(NotificationSoundInfo *)info completion:(BOOLCompletion)completion {
    NSDictionary *param = @{
        @"@type": @"sendCustomRequest",
        @"method": @"accounts.modifyNotificationSettings",
        @"parameters": info.jsonObject.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:param result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            if ([resp[@"code"] integerValue] == 200) {
                !completion ? : completion(YES);
                return;
            }
        }
        !completion ? : completion(NO);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}

@end

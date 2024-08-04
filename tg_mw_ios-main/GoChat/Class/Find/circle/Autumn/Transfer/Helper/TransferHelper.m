//
//  TransferHelper.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferHelper.h"

@implementation TransferHelper

+ (void)transfer:(NSDictionary *)param completion:(TransferCompletion)completion {
    [TelegramManager.shareInstance jw_request:param result:^(NSDictionary *request, NSDictionary *response) {
        if ([TelegramManager isResultError:response]) {
            !completion ? : completion(NO, response[@"message"], 0);
            return;
        }
        NSDictionary *result = [response[@"result"] mj_JSONObject];
        NSInteger code = [result[@"code"] integerValue];
        if (code == 200) {
            !completion ? : completion(YES, nil, 0);
            return;
        }
        !completion ? : completion(NO, nil, code);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO, @"请求超时", 0);
    }];
}

+ (void)transferInfo:(NSInteger)tId completion:(TransferInfoCompletion)completion {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"remittance.getRecord",
        @"parameters": @{
            @"remittanceId": @(tId)
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            Transfer *transfer = [Transfer mj_objectWithKeyValues:resp[@"data"]];
            !completion ? : completion(transfer);
            return;
        }
        !completion ? : completion(nil);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(nil);
    }];
}

+ (void)received:(NSInteger)tId completion:(void(^)(NSString * _Nullable error))completion {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"remittance.receive",
        @"parameters": @{
            @"remittanceId": @(tId)
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if (![result isKindOfClass:NSString.class]) {
            !completion ? : completion(@"领取失败".lv_localized);
            return;
        }
        NSDictionary *resp = result.mj_JSONObject;
        NSInteger code = [resp[@"code"] integerValue];
        if (code == 400) {
            !completion ? : completion(@"您不是收款人".lv_localized);
            return;
        }
        if (code == 200) {
            !completion ? : completion(nil);
            return;
        }
        !completion ? : completion(@"领取失败".lv_localized);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@"领取失败".lv_localized);
    }];
}

+ (void)refund:(NSInteger)tId completion:(void(^)(NSString * _Nullable error))completion {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"remittance.refund",
        @"parameters": @{
            @"remittanceId": @(tId)
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if (![result isKindOfClass:NSString.class]) {
            !completion ? : completion(@"退还失败".lv_localized);
            return;
        }
        NSDictionary *resp = result.mj_JSONObject;
        NSInteger code = [resp[@"code"] integerValue];
        if (code == 400) {
            !completion ? : completion(@"您不是收款人".lv_localized);
            return;
        }
        if (code == 200) {
            !completion ? : completion(nil);
            return;
        }
        !completion ? : completion(@"退还失败".lv_localized);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@"退还失败".lv_localized);
    }];
}

+ (void)remind:(NSInteger)tId completion:(void(^)(NSString * _Nullable error))completion {
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"remittance.remind",
        @"parameters": @{
            @"remittanceId": @(tId)
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if (![result isKindOfClass:NSString.class]) {
            !completion ? : completion(@"提醒失败".lv_localized);
            return;
        }
        NSDictionary *resp = result.mj_JSONObject;
        NSInteger code = [resp[@"code"] integerValue];
        if (code == 200) {
            !completion ? : completion(nil);
            return;
        }
        !completion ? : completion(@"提醒失败".lv_localized);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@"提醒失败".lv_localized);
    }];
}

@end

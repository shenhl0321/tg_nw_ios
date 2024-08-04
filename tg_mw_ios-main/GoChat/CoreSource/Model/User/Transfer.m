//
//  Transfer.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "Transfer.h"
#import "UserinfoHelper.h"

@implementation Transfer

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"atType": @"@type",
        @"extra": @"@extra",
        @"ids": @"id",
        @"descriptions": @[@"description", @"Description"],
        @"payerUID": @[@"payerUID", @"PayerUID"],
        @"payeeUID": @[@"payeeUID", @"PayeeUID"],
    };
}

- (void)setPayerUID:(NSInteger)payerUID {
    _payerUID = payerUID;
    if (self.payerName) {
        return;
    }
    [UserinfoHelper getUsernames:@[@(payerUID)] completion:^(NSArray * _Nonnull names) {
        self.payerName = names.firstObject;
    }];
}

- (void)setPayeeUID:(NSInteger)payeeUID {
    _payeeUID = payeeUID;
    if (self.payeeName) {
        return;
    }
    [UserinfoHelper getUsernames:@[@(payeeUID)] completion:^(NSArray * _Nonnull names) {
        self.payeeName = names.firstObject;
    }];
}

- (NSString *)money {
    return [NSString stringWithFormat:@"￥%.2f", self.amount];
}

- (UIImage *)icon {
    BOOL isMeReceived = UserInfo.shareInstance._id == self.payeeUID;
    switch (self.status) {
        case 0:
            return isMeReceived ? [UIImage imageNamed:@"icon_transfer_me_wait"] : [UIImage imageNamed:@"icon_transfer_other_wait"];
        case 1:
            return isMeReceived ? [UIImage imageNamed:@"icon_transfer_me_received"] : [UIImage imageNamed:@"icon_transfer_other_received"];
        case 2:
        case 3:
            return [UIImage imageNamed:@"icon_transfer_refund"];
        default:
            return nil;
    }
}

- (BOOL)showRemindView {
    return self.status == 0 && UserInfo.shareInstance._id != self.payeeUID;
}

- (BOOL)showReceivedView {
    return self.status == 0 && UserInfo.shareInstance._id == self.payeeUID;
}

- (void)tipMessage:(void(^)(NSString *msg))completion {
    BOOL isMeReceived = UserInfo.shareInstance._id == self.payeeUID;
    NSString *statusText = nil;
    switch (self.status) {
        case 0:
            statusText = isMeReceived ? @"待你收款".lv_localized : @"待%@收款".lv_localized;
            break;
        case 1:
            statusText = isMeReceived ? @"你已收款".lv_localized : @"%@已收款".lv_localized;
            break;
        case 2:
            statusText = isMeReceived ? @"你已退还".lv_localized : @"%@已退还".lv_localized;
            break;
        case 3:
            statusText = isMeReceived ? @"过期未收款，已退还".lv_localized : @"%@过期未收款，已退还".lv_localized;
            break;
        default:
            break;
    }
    if (isMeReceived) {
        !completion ? : completion(statusText);
        return;
    }
    [UserinfoHelper getUsernames:@[@(self.payeeUID)] completion:^(NSArray * _Nonnull names) {
        NSString *name = names.firstObject;
        NSString *text = [NSString stringWithFormat:statusText, name];
        !completion ? : completion(text);
    }];
}

@end

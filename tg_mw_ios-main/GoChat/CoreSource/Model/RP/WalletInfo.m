//
//  WalletInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/4/19.
//

#import "WalletInfo.h"

@implementation WalletInfo

@end

@implementation WalletOrderInfo

- (BOOL)isRPtype {
    return [@[@5, @6] containsObject:@(self.type)];
}

- (void)setExtData:(NSDictionary *)extData {
    _extData = extData;
    if (self.remittanceInfo) {
        
    }
}

- (Transfer *)remittanceInfo {
    if (!_remittanceInfo) {
        _remittanceInfo = [Transfer mj_objectWithKeyValues:self.extData[@"remittanceInfo"]];
    }
    return _remittanceInfo;
}

@end

@implementation WalletRechargeRes

@end

@implementation WalletTixianRes

@end

@implementation ThirdRechargeChannelInfo
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"channels" : @"ThirdRechargeChannels"};
}
@end

@implementation ThirdRechargeChannels

@end

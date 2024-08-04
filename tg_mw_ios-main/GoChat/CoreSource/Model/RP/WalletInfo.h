//
//  WalletInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/4/19.
//

#import <Foundation/Foundation.h>
#import "Transfer.h"

@interface WalletInfo : NSObject
//余额
@property (nonatomic) float balance;
//地址
@property (nonatomic, copy) NSString *address;
//是否设置过支付
@property (nonatomic) BOOL hasPaymentPassword;
@end

@interface WalletOrderInfo : NSObject
//类型 1.充值 2提现 3.收款 4.转账 5.创建红包 6.领取红包 7.红包退回 12转账付款 13转账收款 14用户退款 15 系统退款
@property (nonatomic) int type;
@property (nonatomic) float amount;
@property (nonatomic, copy) NSString *remarks;
@property (nonatomic) long createAt;
@property (nonatomic, assign) long related;

- (BOOL)isRPtype;


/// 额外数据
@property (nonatomic, strong) NSDictionary *extData;
/// 信息
@property (nonatomic, strong) Transfer *remittanceInfo;


@property (nonatomic, copy) NSString *rpContent;

@end

@interface WalletRechargeRes : NSObject
@property (nonatomic) long csUserId;
@property (nonatomic, copy) NSString *payUrl;
@end

@interface WalletTixianRes : NSObject
@property (nonatomic) long csUserId;
@property (nonatomic, copy) NSString *checkoutUrl;
@end

@interface ThirdRechargeChannelInfo : NSObject
@property (nonatomic) long csUserId;
@property (nonatomic, strong) NSArray *channels;
@end

@interface ThirdRechargeChannels : NSObject
@property (nonatomic) long channelID;
@property (nonatomic, copy) NSString *channelName;
@end

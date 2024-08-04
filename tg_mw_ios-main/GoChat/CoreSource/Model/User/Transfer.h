//
//  Transfer.h
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Transfer : JWModel

/// 1 单聊，2 群聊
@property (nonatomic, assign) NSInteger type;

/// 付 id
@property (nonatomic, assign) NSInteger payerUID;

/// 收 id
@property (nonatomic, assign) NSInteger payeeUID;

/// 创建时间
@property (nonatomic, assign) float remittedAt;

/// 收款时间
@property (nonatomic, assign) float receivedAt;

/// 退款时间
@property (nonatomic, assign) float refundedAt;

/// 会话标识
@property (nonatomic, assign) NSInteger chatId;

/// 说明
@property (nonatomic, copy) NSString *descriptions;

/// 状态
/// 0 - 未领取 1 - 已领取 2 - 用户退回 3 - 系统退回
@property (nonatomic, assign) NSInteger status;

/// 金额
@property (nonatomic, assign) CGFloat amount;

@property (nonatomic, copy) NSString *payerName;
@property (nonatomic, copy) NSString *payeeName;



/// 显示的金额：￥200.00
- (NSString *)money;
/// 展示的图标
- (UIImage *)icon;
/// 提示文字
- (void)tipMessage:(void(^)(NSString *msg))completion;

/// 显示提醒
- (BOOL)showRemindView;

/// 显示收款
- (BOOL)showReceivedView;

@end

NS_ASSUME_NONNULL_END

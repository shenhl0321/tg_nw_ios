//
//  TransferMsgInfo.h
//  GoChat
//
//  Created by Autumn on 2022/1/24.
//

#import "JWModel.h"
#import "Transfer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransferMsgInfo : JWModel

/// id
@property (nonatomic, assign) NSInteger remittanceId;
/// 付款人
@property (nonatomic, assign) NSInteger payer;
/// 收款人
@property (nonatomic, assign) NSInteger payee;
/// 金额
@property (nonatomic, assign) CGFloat amount;


/// 状态
@property (nonatomic, assign) Transfer_MessageSubType state;
/// 是发出的消息
@property (nonatomic, assign, getter=isOutgoing) BOOL outgoing;

@property (nonatomic, strong) Transfer *transfer;


/// 显示的金额：￥200.00
- (NSString *)money;
/// 展示的图标
- (UIImage *)icon;
/// 提示文字
- (NSString *)tipMessage;
/// 背景颜色
- (UIColor *)bgColor;

- (void)fetchInfo;


@end

NS_ASSUME_NONNULL_END

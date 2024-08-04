//
//  ChatMsgSender.h
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgObject.h"
#import "ChatMsgContent.h"
#import "ChatMsgReplyMarkup.h"

NS_ASSUME_NONNULL_BEGIN

/// 消息发送体
/// 通过模型创建，转成 json。

@interface ChatMsgSender : ChatMsgObject

/// 会话 id，必填
@property (nonatomic, assign, readonly) NSInteger chatId;

@property (nonatomic, strong) ChatMsgContent *content;

@property (nonatomic, strong) ChatMsgReplyMarkup *replyMarkup;

+ (instancetype)initWithId:(NSInteger)chatId;

- (instancetype)initWithId:(NSInteger)chatId;


@end

NS_ASSUME_NONNULL_END

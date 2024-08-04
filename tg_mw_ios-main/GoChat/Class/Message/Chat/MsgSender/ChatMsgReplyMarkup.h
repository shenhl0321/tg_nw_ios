//
//  ChatMsgReplyMarkup.h
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgObject.h"

NS_ASSUME_NONNULL_BEGIN

@class ChatMsgInlineKeyboardButton;
@interface ChatMsgReplyMarkup : ChatMsgObject

@property (nonatomic, strong) NSMutableArray<NSMutableArray<ChatMsgInlineKeyboardButton *> *> *rows;

- (BOOL)isReplyMarkupInlineKeyboard;

@end

NS_ASSUME_NONNULL_END

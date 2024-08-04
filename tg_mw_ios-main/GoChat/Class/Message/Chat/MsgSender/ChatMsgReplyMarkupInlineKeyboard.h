//
//  ChatMsgReplyMarkupInlineKeyboard.h
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgReplyMarkup.h"
#import "ChatMsgObject.h"

NS_ASSUME_NONNULL_BEGIN

@class ChatMsgInlineKeyboardButton, ChatMsgInlineKeyboardButtonTypeUrl;

@interface ChatMsgReplyMarkupInlineKeyboard : ChatMsgObject

@property (nonatomic, strong) NSMutableArray<NSMutableArray<ChatMsgInlineKeyboardButton *> *> *rows;


/// 通过用户输入的内容规则生成
/// 示例:
///     [[a:http://a.com], [b：http://b.com]]
/// @param inputs 内容数组
+ (instancetype)initWithInputs:(NSArray<NSString *> *)inputs;
- (instancetype)initWithInputs:(NSArray<NSString *> *)inputs;

@end



@interface ChatMsgInlineKeyboardButton : ChatMsgObject

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) ChatMsgInlineKeyboardButtonTypeUrl *type;

+ (instancetype)initWithInput:(NSString *)input;
- (instancetype)initWithInput:(NSString *)input;

@end

@interface ChatMsgInlineKeyboardButtonTypeUrl : ChatMsgObject

@property (nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END

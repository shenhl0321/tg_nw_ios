//
//  ChatMsgSender.m
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgSender.h"

@interface ChatMsgSender ()

@property (nonatomic, assign) NSInteger chatId;

@end

@implementation ChatMsgSender

- (NSString *)types {
    return @"sendMessage";
}


- (NSDictionary *)jsonObject {
    NSAssert(self.chatId, @"chatId 必填".lv_localized);
    return @{
        @"@type": self.types,
        @"chat_id": @(self.chatId),
        @"input_message_content": self.content.jsonObject,
        @"reply_markup": self.replyMarkup.jsonObject
    };
}

+ (instancetype)initWithId:(NSInteger)chatId {
    return [[ChatMsgSender alloc] initWithId:chatId];
}

- (instancetype)initWithId:(NSInteger)chatId {
    self = [super init];
    if (self) {
        self.chatId = chatId;
    }
    return self;
}


@end

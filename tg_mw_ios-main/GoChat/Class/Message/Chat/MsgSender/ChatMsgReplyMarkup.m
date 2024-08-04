//
//  ChatMsgReplyMarkup.m
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgReplyMarkup.h"

@implementation ChatMsgReplyMarkup

- (BOOL)isReplyMarkupInlineKeyboard {
    return [self.types isEqualToString:@"replyMarkupInlineKeyboard"];
}

@end

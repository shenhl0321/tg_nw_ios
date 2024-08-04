//
//  MessageInfo+ReactionEmoji.m
//  GoChat
//
//  Created by Autumn on 2022/3/26.
//

#import "MessageInfo+ReactionEmoji.h"

@implementation MessageReactionList


@end

@implementation MessageReaction

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"reactionList": MessageReactionList.class};
}

@end



@implementation MessageInfo (ReactionEmoji)

/// 当前消息体是否支持表情回复
- (BOOL)canShowLongPressReactionEmojiView {
    /// 支持显示的消息类型
    NSArray *msgTypes = @[
        @(MessageType_Text),
        @(MessageType_Animation),
        @(MessageType_Audio),
        @(MessageType_Voice),
        @(MessageType_Document),
        @(MessageType_Location),
        @(MessageType_Photo),
        @(MessageType_Video),
        @(MessageType_Location),
    ];
    /// 群组内管理员发广告和图文暂时不显示
    BOOL isAd =  (self.reply_markup && self.reply_markup.isReplyMarkupInlineKeyboard) ||
    [NSString xhq_notEmpty:self.content.caption[@"text"]];
    BOOL canMsgType = [msgTypes containsObject:@(self.messageType)];
    return canMsgType && !isAd;
}

- (NSMutableArray *)reactions {
    NSMutableArray *reactions = objc_getAssociatedObject(self, _cmd);
    if (!reactions) {
        reactions = NSMutableArray.array;
        objc_setAssociatedObject(self, @selector(reactions), reactions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return reactions;
}

- (void)setReactions:(NSMutableArray *)reactions {
    objc_setAssociatedObject(self, @selector(reactions), reactions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isShowGroupReactionView {
//    long cId = [ChatInfo toLocalChatId:self.chat_id];
//    ChatInfo *chat = [TelegramManager.shareInstance getChatInfo:cId];
//    return self.reactions.count > 0 && chat.isGroup;
    return self.reactions.count;
}

- (void)updateRecation:(MessageReactionList *)list {
    /// 存在相同的userid 先删除
    for (MessageReactionList *r in self.reactions.objectEnumerator) {
        if (r.userId == list.userId) {
            [self.reactions removeObject:r];
            break;
        }
    }
    /// 不是固定的几个 id 类型的话 ，则不添加（删除功能）
    if ([ReactionEmojiIds() containsObject:@(list.reactionId)]) {
        [self.reactions addObject:list];
    }
    self.msg_cell_height = 0;
}

- (void)reactionWithEmoji:(NSString *)emoji {
    ChatInfo *chat = [TelegramManager.shareInstance getChatInfo:self.chat_id];
    NSNumber *reactionId = ReactionIdForEmoji(emoji);
    /// 重复的表情为取消
    for (MessageReactionList *list in self.reactions) {
        if (list.userId == UserInfo.shareInstance._id && reactionId.integerValue == list.reactionId) {
            reactionId = @(0);
            break;
        }
    }
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"messages.sendReaction",
        @"parameters": @{
            @"messageId": @(self._id),
            @"chatId": @([ChatInfo toServerPeerId:self.chat_id]),
            @"type": chat.isGroup ? @(2) : @(1),
            @"reactionId": reactionId
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)getReactions {
    if (!self.canShowLongPressReactionEmojiView) {
        return;
    }
    ChatInfo *chat = [TelegramManager.shareInstance getChatInfo:self.chat_id];
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"messages.getMessagesReactions",
        @"parameters": @{
            @"messageIds": @[@(self._id)],
            @"chatId": @([ChatInfo toServerPeerId:self.chat_id]),
            @"type": chat.isGroup ? @(2) : @(1),
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            NSArray *reactions = [MessageReaction mj_objectArrayWithKeyValuesArray:resp[@"data"]];
            if (reactions.count == 0) {
                return;
            }
            MessageReaction *reaction = reactions.firstObject;
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Reaction_Update) withInParam:reaction];
        }
    } timeout:^(NSDictionary *request) {
        
    }];
    
}

@end

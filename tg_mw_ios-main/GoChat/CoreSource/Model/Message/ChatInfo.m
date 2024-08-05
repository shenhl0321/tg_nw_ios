//
//  ChatInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/11/3.
//

#import "ChatInfo.h"

@implementation ChatType

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

@end

@implementation ChatPermissions

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

@end

@implementation ChatPosition

@end

@interface ChatInfo ()

@property (nonatomic, strong) SuperGroupInfo *superGroupInfo;

@end

@implementation ChatInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id"};
}

//关键字是否匹配
- (BOOL)isMatch:(NSString *)keyword
{
    return [[self.title uppercaseString] containsString:[keyword uppercaseString]]
    || [[self.title_full_py uppercaseString] containsString:[keyword uppercaseString]];
}

- (long)modifyDate
{
    if(self.lastMessage != nil)
    {
        return self.lastMessage.date;
    }
    return 0;
}

- (void)copyChatContent:(ChatInfo *)info
{
    self.type = info.type;
    self.title = info.title;
    self.photo = info.photo;
    self.permissions = info.permissions;
    self.is_marked_as_unread = info.is_marked_as_unread;
    self.unread_count = info.unread_count;
    self.unread_mention_count = info.unread_mention_count;
    self.last_read_inbox_message_id = info.last_read_inbox_message_id;
    self.last_read_outbox_message_id = info.last_read_outbox_message_id;
    self.is_pinned = info.is_pinned;
    self.default_disable_notification = info.default_disable_notification;
}

- (NSString *)groupLastSenderNickname {
    return [self groupSenderNickname:self.lastMessage.sender.user_id];
}

- (NSString *)groupSenderNickname:(long)userId {
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:userId];
    NSString *name = user.displayName;
    if (!self.isGroup || self.groupMembers.count == 0) {
        return name;
    }
    for (GroupMemberInfo *m in self.groupMembers) {
        if (m.user_id == self.lastMessage.sender.user_id && [NSString xhq_notEmpty:m.nickname]) {
            name = m.nickname;
            break;
        }
    }
    return name;
}

- (void)setType:(ChatType *)type {
    _type = type;
    if ([self isSuperGroup]) {
        [self getSuperGroupInfo:nil];
    }
}

- (void)getSuperGroupInfo:(void(^)(SuperGroupInfo *info))completion {
//    if (self.superGroupInfo) {
//        !completion ? : completion(self.superGroupInfo);
//        return;
//    }
    if (![self isSuperGroup]) {
        !completion ? : completion(nil);
        return;
    }
    [TelegramManager.shareInstance getSuperGroupInfo:self.superGroupId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if ([obj isKindOfClass:SuperGroupInfo.class]) {
            self.superGroupInfo = (SuperGroupInfo *)obj;
        }
        !completion ? : completion(self.superGroupInfo);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(nil);
    }];
}


- (BOOL)isGroup
{
    return [@"chatTypeBasicGroup" isEqualToString:self.type.type] || [@"chatTypeSupergroup" isEqualToString:self.type.type];
}

- (BOOL)isSuperGroup
{
    return [@"chatTypeSupergroup" isEqualToString:self.type.type];
}

- (BOOL)isSecretChat
{
    return [@"chatTypeSecret" isEqualToString:self.type.type];
}

- (long)userId
{
    return self.type.user_id;
}

- (long)groupId
{
    return self.type.basic_group_id;
}

- (long)superGroupId
{
    return self.type.supergroup_id;
}

/// 重载 isEqual: 方法，通过 id 比较 chat
- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:ChatInfo.class]) {
        return NO;
    }
    ChatInfo *obj = (ChatInfo *)object;
    return obj._id == self._id;
}

//构造会话
+ (ChatInfo *)fromUser:(UserInfo *)user
{
    ChatInfo *chatInfo = [ChatInfo new];
    chatInfo._id = user._id;
    chatInfo.title = user.displayName;
    ChatType *chatType = [ChatType new];
    chatType.type = @"chatTypePrivate";
    chatType.user_id = user._id;
    chatInfo.type = chatType;
    return chatInfo;
}

+ (long)toServerPeerId:(long)chatId
{
    NSString *str = [NSString stringWithFormat:@"%ld", chatId];
    if([str hasPrefix:@"-100"])
    {
        str = [str substringFromIndex:(@"-100".length-1)];
    }
    return [str longLongValue];
}

+ (long)toLocalChatId:(long)chatId
{
    NSString *str = [NSString stringWithFormat:@"%ld", chatId];
    if(![str hasPrefix:@"-100"])
    {
        str = [NSString stringWithFormat:@"-100%@", str];
    }
    return [str longLongValue];
}

@end

@implementation SecretChat

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id", @"state" : @"state.@type"};
//    return @{@"_id" : @"id"};
}

- (SecretChatState)chatState{
//    secretChatStateClosed, secretChatStatePending, and secretChatStateReady
    
    if ([self.state isEqualToString:@"secretChatStateReady"]) {
        return secretChatStateReady;
    } else if ([self.state isEqualToString:@"secretChatStateClosed"]) {
        return secretChatStateClosed;
    } else {
        return secretChatStatePending;
    }
}


@end

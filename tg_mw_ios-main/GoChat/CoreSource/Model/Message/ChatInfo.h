//
//  ChatInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import "MessageInfo.h"
#import "UserInfo.h"

typedef NS_ENUM(NSInteger, SecretChatState) {
    secretChatStatePending,
    secretChatStateReady,
    secretChatStateClosed,
};

@class SecretChat;
//{"@type":"updateNewChat","chat":{"@type":"chat","id":777000,"type":{"@type":"chatTypePrivate","user_id":777000},"title":"Nebulachat","permissions":{"@type":"chatPermissions","can_send_messages":true,"can_send_media_messages":true,"can_send_polls":true,"can_send_other_messages":true,"can_add_web_page_previews":true,"can_change_info":false,"can_invite_users":false,"can_pin_messages":false},"order":"0","is_pinned":false,"is_marked_as_unread":false,"is_sponsored":false,"has_scheduled_messages":false,"can_be_deleted_only_for_self":true,"can_be_deleted_for_all_users":true,"can_be_reported":false,"default_disable_notification":false,"unread_count":0,"last_read_inbox_message_id":1048576,"last_read_outbox_message_id":0,"unread_mention_count":0,"notification_settings":{"@type":"chatNotificationSettings","use_default_mute_for":true,"mute_for":0,"use_default_sound":true,"sound":"default","use_default_show_preview":true,"show_preview":false,"use_default_disable_pinned_message_notifications":true,"disable_pinned_message_notifications":false,"use_default_disable_mention_notifications":true,"disable_mention_notifications":false},"action_bar":{"@type":"chatActionBarReportAddBlock"},"pinned_message_id":0,"reply_markup_message_id":0,"client_data":""}}
@interface ChatType : NSObject
@property (nonatomic, strong) NSString *type;
//单聊时有效
@property (nonatomic) long user_id;
//讨论组时有效
@property (nonatomic) long basic_group_id;
//超级讨论组时有效
@property (nonatomic) long supergroup_id;
@property (nonatomic) BOOL is_channel;
/// 私密聊天id
@property (nonatomic,assign) long secret_chat_id;
@end

@interface ChatPermissions : NSObject
//chatPermissions
@property (nonatomic, strong) NSString *type;
@property (nonatomic) BOOL can_send_messages;
@property (nonatomic) BOOL can_send_media_messages;
@property (nonatomic) BOOL can_send_polls;
@property (nonatomic) BOOL can_send_other_messages;
@property (nonatomic) BOOL can_add_web_page_previews;
@property (nonatomic) BOOL can_change_info;
@property (nonatomic) BOOL can_invite_users;
@property (nonatomic) BOOL can_pin_messages;
/// 能发送DM@ 消息
@property (nonatomic,assign) BOOL can_send_dm_messages;
@end

@interface ChatPosition : NSObject
@property (nonatomic, strong) NSString *list;
@property (nonatomic) long order;
@property (nonatomic) BOOL is_pinned;
@property (nonatomic, strong) NSString *source;
@end

@interface ChatInfo : NSObject

/// 是否选中
@property (assign, nonatomic) BOOL isChoose;
@property (nonatomic) long _id;
@property (nonatomic, strong) ChatType *type;
@property (nonatomic, strong) NSArray *positions;//ChatPosition
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) ProfilePhoto *photo;
@property (nonatomic, strong) ChatPermissions *permissions;
@property (nonatomic) BOOL is_marked_as_unread;
/// 在黑名单中
@property (nonatomic) BOOL is_blocked;
@property (nonatomic) int unread_count;
@property (nonatomic) int unread_mention_count;
@property (nonatomic) long last_read_inbox_message_id;
@property (nonatomic) long last_read_outbox_message_id;
@property (nonatomic, strong) MessageInfo *lastMessage;

@property (nonatomic) BOOL is_pinned;
@property (nonatomic) BOOL default_disable_notification;
@property (nonatomic) BOOL isManage;
/// 私密聊天信息
@property (nonatomic,strong) SecretChat *secretChatInfo;
//from getUserFullInfo
//@property (nonatomic) BOOL is_blocked;

- (long)modifyDate;

//拷贝除lastMessage之外的所有值
- (void)copyChatContent:(ChatInfo *)info;

//title对应的拼音
@property (nonatomic, copy) NSString *title_full_py;
//列表索引使用
@property (nonatomic, assign) NSInteger sectionNum;
//关键字是否匹配
- (BOOL)isMatch:(NSString *)keyword;

//构造会话
//+ (ChatInfo *)fromUser:(UserInfo *)user;

/// 群组成员信息（目前用于获取群组内成员昵称）
@property (nonatomic, strong) NSArray *groupMembers;
/// 群组成员的自定义昵称
- (NSString *)groupLastSenderNickname;
- (NSString *)groupSenderNickname:(long)userId;

/// 如果是超级群 获取信息
/// @param completion 回调
- (void)getSuperGroupInfo:(void(^)(SuperGroupInfo *info))completion;

- (BOOL)isGroup;

- (BOOL)isSuperGroup;
- (BOOL)isSecretChat;
- (long)userId;
- (long)groupId;
- (long)superGroupId;

+ (long)toServerPeerId:(long)chatId;
+ (long)toLocalChatId:(long)chatId;
@end

@interface SecretChat : NSObject

@property (nonatomic) long _id;
@property (nonatomic) long user_id;
/// 状态 secretChatStateClosed, secretChatStatePending, and secretChatStateReady.
@property (nonatomic,copy) NSString *state;
@property (nonatomic) BOOL is_outbound;
@property (nonatomic) long layer;

/// 私密聊天状态
@property (nonatomic,assign) SecretChatState chatState;
@end

//
//  MessageInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import "PhotoInfo.h"
#import "CallInfo.h"
#import "AnimationInfo.h"
#import "MsgInterActionInfo.h"
#import "PersonCardContactModel.h"
#import "ChatMsgReplyMarkup.h"
#import "TransferMsgInfo.h"

@class TextUnit;
//{"@type":"updateChatLastMessage","chat_id":777000,"last_message":{"@type":"message","id":1048576,"sender_user_id":777000,"chat_id":777000,"is_outgoing":false,"can_be_edited":false,"can_be_forwarded":true,"can_be_deleted_only_for_self":true,"can_be_deleted_for_all_users":true,"is_channel_post":false,"contains_unread_mention":false,"date":1603602775,"edit_date":0,"reply_to_message_id":0,"ttl":0,"ttl_expires_in":0.000000,"via_bot_user_id":0,"author_signature":"","views":0,"media_album_id":"0","restriction_reason":"","content":{"@type":"messageText","text":{"@type":"formattedText","text":"Login code: 59282. Do not give this code to anyone, even if they say they are from NebulaChat!\n\nThis code can be used to log in to your NebulaChat account. We never ask it for anything else.\n\nIf you didn't request this code by trying to log in on another device, simply ignore this message.","entities":[{"@type":"textEntity","offset":0,"length":11,"type":{"@type":"textEntityTypeBold"}},{"@type":"textEntity","offset":22,"length":3,"type":{"@type":"textEntityTypeBold"}}]}}},"order":"0"}

//消息状态
@interface MessageSendingState : NSObject
//messageSendingStatePending
//messageSendingStateFailed
@property (nonatomic, copy) NSString *state;
@property (nonatomic) int error_code;
@property (nonatomic, copy) NSString *error_message;

- (MessageSendState)sendState;
@end

//消息内容相关
@interface WebpageModel : NSObject
@property (nonatomic, copy) NSString *msgtype;
@property (nonatomic, copy) NSString *descriptionmsg;
@property (nonatomic, copy) NSString *display_url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;
@end

@interface MessageSender : NSObject
@property (nonatomic, copy) NSString *type;
@property (nonatomic) long user_id;
@property (nonatomic) long chat_id;
@end

@interface ReplyMarkup : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *rows;

- (BOOL)isReplyMarkupInlineKeyboard;



@end

//消息内容相关
@interface MessageContent : NSObject
//maybe @messageText @messagePhoto ...
@property (nonatomic, copy) NSString *type;

//群成员被移除对应的userid
@property (nonatomic) long user_id;
//被邀请进群组
@property (nonatomic, strong) NSArray *member_user_ids;

//1、会话标题变化消息
//2、文件消息标题
@property (nonatomic, copy) NSString *title;

//图片相关
@property (nonatomic, strong) PhotoInfo *photo;
//视频相关
@property (nonatomic, strong) VideoInfo *video;
//语音相关
@property (nonatomic, strong) AudioInfo *audio;
//语音相关
@property (nonatomic, strong) VoiceInfo *voice_note;
//文件相关
@property (nonatomic, strong) DocumentInfo *document;
//位置相关
@property (nonatomic, strong) MsgLocationInfo *location;
//gif
@property (nonatomic, strong) AnimationInfo *animation;
//名片信息
@property (nonatomic, strong) PersonCardContactModel *contact;

@property (nonatomic,strong) WebpageModel *web_page;

@property (nonatomic,strong) NSDictionary *text;

@property (nonatomic, strong) NSDictionary *caption;


@end

@interface MessageInfo : NSObject
@property (nonatomic) long _id;
@property (nonatomic, strong) MessageSender *sender;
@property (nonatomic) long chat_id;
@property (nonatomic) long date;
@property (nonatomic) long ttl;
@property (nonatomic) double ttl_expires_in;
@property (nonatomic) BOOL is_outgoing;
@property (nonatomic) BOOL is_channel_post;
@property (nonatomic) BOOL contains_unread_mention;
@property (nonatomic,strong) MsgInterActionInfo *interaction_info;
//@property (nonatomic) int views;
@property (nonatomic,assign) long reply_to_message_id;
@property (nonatomic,strong) NSString *reply_str;//引用文本
@property (nonatomic,strong) MessageContent *reply_content;//引用模型

/// 回复邮件的标记; 如果没有，则传递 null; 仅适用于机器人
@property (nonatomic, strong) ReplyMarkup *reply_markup;

//消息具体内容
@property (nonatomic, strong) MessageContent *content;

//MessageSendingState - 发送消息当前状态
@property (nonatomic, strong) MessageSendingState *sending_state;
- (MessageSendState)sendState;

//消息类型
@property (nonatomic) MessageType messageType;
- (BOOL)isTipMessage;

//文本消息内容
@property (nonatomic, copy) NSString *textTypeContent;
/// 翻译后的文本
@property (nonatomic,copy) NSString *translateText;
/// 显示翻译
@property (nonatomic,assign, getter=isShowTranslate) BOOL showTranslate;

//视频语音通话消息
@property (nonatomic, strong) LocalCallInfo *callInfo;

@property (nonatomic, strong) RP_Msg *rpInfo;
@property (nonatomic, strong) RP_Pick_Msg *rpGotInfo;
//阅后即焚时长
@property (nonatomic, strong) NSString * fireTime;

/// zz消息
@property (nonatomic, strong) TransferMsgInfo *transferInfo;

//ui使用
@property (nonatomic) CGFloat msg_cell_height;
//是否显示日期
@property (nonatomic) BOOL isShowDayText;

//是否被选中，仅页面使用
@property (nonatomic) BOOL isSelected;

/// 链接类型时，html元素的头部信息(description、title、icon)
@property (nonatomic,strong) NSDictionary *headerInfo;
/// 链接高度
@property (nonatomic,assign) CGFloat linkRowHeight;
/// 文本中的链接列表
@property (nonatomic,strong) NSArray<TextUnit *> *linkUrls;
//是否显示已读未读标志
- (BOOL)canShowReadFlag;
/// 是广告消息
- (BOOL)isAdMessage;

- (BOOL)isLocalMessage;
- (void)parseTextToExMessage;
+ (NSString *)getTextExMessage:(NSString *)text mainCode:(int)mainCode subCode:(int)subCode;
@end

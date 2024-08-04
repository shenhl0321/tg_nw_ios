//
//  MessageInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/11/3.
//

#import "MessageInfo.h"
#import "MessageInfo+ReactionEmoji.h"

@implementation MessageSendingState

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"state" : @"@type"};
}

- (MessageSendState)sendState
{
    if([@"messageSendingStatePending" isEqualToString:self.state])
    {//发送中
        return MessageSendState_Pending;
    }
    return MessageSendState_Fail;
}

@end

@implementation MessageSender : NSObject

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

@end

@implementation ReplyMarkup

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"type" : @"@type"};
}

- (BOOL)isReplyMarkupInlineKeyboard {
    return [self.type isEqualToString:@"replyMarkupInlineKeyboard"];
}

@end


@implementation MessageContent : NSObject

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

@end

@implementation WebpageModel : NSObject

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
        @"msgtype" : @"@type",
        @"descriptionmsg" : @"description"
    };
}

@end

@implementation MessageInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id"};
}

//- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues {
//    [self getReactions];
//}

- (void)setMessageType:(MessageType)messageType {
    _messageType = messageType;
    [self getReactions];
}

- (BOOL)is_outgoing
{
    if(self.chat_id == [UserInfo shareInstance]._id)
    {//我的收藏
        return YES;
    }
    return _is_outgoing;
}

- (BOOL)isTipMessage
{
    if([@"messageBasicGroupChatCreate" isEqualToString:self.content.type] || [@"messageSupergroupChatCreate" isEqualToString:self.content.type])
    {//群组创建
        return YES;
    }
    if([@"messageChatAddMembers" isEqualToString:self.content.type])
    {//群组添加成员
        return YES;
    }
    if([@"messageChatDeleteMember" isEqualToString:self.content.type])
    {//群组成员移除
        return YES;
    }
    if([@"messageChatChangeTitle" isEqualToString:self.content.type])
    {//修改会话标题
        return YES;
    }
    if([@"messageChatChangePhoto" isEqualToString:self.content.type])
    {//修改会话头像
        return YES;
    }
    if([@"messageChatJoinByLink" isEqualToString:self.content.type])
    {//链接进群
        return YES;
    }
    switch (self.messageType)
    {
        case MessageType_Text:
        case MessageType_Text_AudioAVideo_Done:
        case MessageType_Text_New_Rp:
        case MessageType_Text_Transfer:
        case MessageType_Photo:
        case MessageType_Video:
        case MessageType_Audio:
        case MessageType_Voice:
        case MessageType_Document:
        case MessageType_Location:
        case MessageType_Pinned:
        case MessageType_Animation:
        case MessageType_Card:
            return NO;
        case MessageType_Text_Got_Rp:
        case MessageType_Text_Screenshot:
        case MessageType_Text_BeFriend:
        case MessageType_Text_Blacklist:
        case MessageType_Text_Stranger:
        case MessageType_Contact_Registed:
        case MessageType_Text_Kicked_SensitiveWords:
            return YES;
        default:
            return YES;
    }
}

- (CGFloat)linkRowHeight{
//    if (!_linkRowHeight) {
        WebpageModel *webmodel = self.content.web_page;
        if (webmodel) {
            _linkRowHeight = 104;
        } else if (self.headerInfo.count > 0) {
            NSString *desc = self.headerInfo[@"description"];
            NSString *content = self.textTypeContent;
            
            CGSize size = CGSizeMake(SCREEN_WIDTH - 72 - 20, CGFLOAT_MAX);
            CGFloat descH = [desc xhq_sizeWithFont:[UIFont systemFontOfSize:14] withSize:size].height;
            descH = MIN(descH, 55);
            CGFloat contentH = [content xhq_sizeWithFont:[UIFont systemFontOfSize:14] withSize:size].height;
            contentH = MIN(contentH, 55);
            if (IsStrEmpty(desc)) {
                _linkRowHeight = 20 + 45 + 10 + descH + contentH;
            } else {
                _linkRowHeight = 20 + 45 + 10 + descH + contentH;
            }
        } else if (self.linkUrls.count > 0) {
            CGSize size = CGSizeMake(SCREEN_WIDTH - 72 - 20, CGFLOAT_MAX);
            NSString *content = self.linkUrls.firstObject.transferredContent;
            CGFloat contentH = [content xhq_sizeWithFont:[UIFont systemFontOfSize:14] withSize:size].height;
            contentH = MIN(contentH, 55);
            _linkRowHeight = 20 + 45 + 10 + contentH;
        } else {
            CGSize size = CGSizeMake(SCREEN_WIDTH - 72 - 20, CGFLOAT_MAX);
            NSString *content = self.textTypeContent;
            CGFloat contentH = [content xhq_sizeWithFont:[UIFont systemFontOfSize:14] withSize:size].height;
            contentH = MIN(contentH, 55);
            _linkRowHeight = 20 + 45 + 10 + contentH;
        }
//    }
    return _linkRowHeight;
}

- (NSString *)description
{
    if([@"messageBasicGroupChatCreate" isEqualToString:self.content.type] || [@"messageSupergroupChatCreate" isEqualToString:self.content.type])
    {
        if(self.sender.user_id == [UserInfo shareInstance]._id){
            return [NSString stringWithFormat:@"您在%@创建了群组".lv_localized, [Common getMessageTime:self.date]];
        }
        else{
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.sender.user_id];
            return [NSString stringWithFormat:@"%@在%@创建了群组".lv_localized, user.displayName ? : @"", [Common getMessageTime:self.date]];
        }
    }
    if([@"messageChatAddMembers" isEqualToString:self.content.type])
    {
        NSMutableString *memberStr = [NSMutableString stringWithString:@""];
        for (NSNumber *userId in self.content.member_user_ids) {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:userId.longValue];
            if (user) {
                if (memberStr.length > 0) {
                    [memberStr appendString:@"、"];
                    [memberStr appendString:user.displayName];
                } else {
                    [memberStr appendString:user.displayName];
                }
            }
        }
        if (self.sender.user_id == [UserInfo shareInstance]._id) {
            return [NSString stringWithFormat:@"您邀请了 %@ 进群组".lv_localized, memberStr];
        }
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.sender.user_id];
        if (user) {
            if ([user.displayName isEqualToString:memberStr]) {
                return [NSString stringWithFormat:@"%@ 加入了群组".lv_localized, user.displayName];
            }
            return [NSString stringWithFormat:@"%@ 邀请了 %@ 进群组".lv_localized, user.displayName, memberStr];
        }
        return [NSString stringWithFormat:@"%@ 加入了群组".lv_localized, memberStr];
    }
    if([@"messageChatJoinByLink" isEqualToString:self.content.type]) {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.sender.user_id];
//        return [NSString stringWithFormat:@"%@ 通过邀请链接加入群组",user.displayName];
        return [NSString stringWithFormat:@"%@ 加入了群组".lv_localized, user.displayName];
    }
    if([@"messageChatDeleteMember" isEqualToString:self.content.type])
    {
        if(self.content.user_id == [UserInfo shareInstance]._id)
        {
            if(self.sender.user_id == [UserInfo shareInstance]._id)
            {
                return @"您已从群组移出".lv_localized;
            }
            else
            {
                return @"您被移出群组".lv_localized;
            }
        }
        else
        {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.content.user_id];
            if(user != nil)
            {
                if(self.sender.user_id == self.content.user_id)
                {
                    return [NSString stringWithFormat:@"%@ 已退出群组".lv_localized, user.displayName];
                }
                else
                {
                    return [NSString stringWithFormat:@"%@ 被移出群组".lv_localized, user.displayName];
                }
            }
            else
            {
                if(self.sender.user_id == self.content.user_id)
                {
                    return [NSString stringWithFormat:@"[user_%ld] 已退出群组".lv_localized, self.content.user_id];
                }
                else
                {
                    return [NSString stringWithFormat:@"[user_%ld] 被移出群组".lv_localized, self.content.user_id];
                }
            }
        }
    }
    if([@"messageChatChangeTitle" isEqualToString:self.content.type])
    {
        if(self.sender.user_id == [UserInfo shareInstance]._id)
        {
            return [NSString stringWithFormat:@"您已把群组名称修改为：%@".lv_localized, self.content.title];
        }
        else
        {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.sender.user_id];
            if(user != nil)
            {
                return [NSString stringWithFormat:@"%@ 将群组名称修改为：%@".lv_localized, user.displayName, self.content.title];
            }
            else
            {
                return [NSString stringWithFormat:@"群组名称修改为：%@".lv_localized, self.content.title];
            }
        }
    }
    if([@"messageChatChangePhoto" isEqualToString:self.content.type])
    {
        if(self.sender.user_id == [UserInfo shareInstance]._id)
        {
            return @"您已修改了群组头像".lv_localized;
        }
        else
        {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.sender.user_id];
            if(user != nil)
            {
                return [NSString stringWithFormat:@"%@ 修改了群组头像".lv_localized, user.displayName];
            }
            else
            {
                return @"群组头像已修改".lv_localized;
            }
        }
    }
    switch (self.messageType)
    {
        case MessageType_Text:
        case MessageType_Text_AudioAVideo_Done:
        case MessageType_Text_New_Rp:
        case MessageType_Text_Transfer:
        case MessageType_Text_Got_Rp:
            return self.textTypeContent;
        case MessageType_Photo:
            return @"[图片]".lv_localized;
        case MessageType_Video:
            return @"[视频]".lv_localized;
        case MessageType_Audio:
            return @"[音频]".lv_localized;
        case MessageType_Voice:
            return @"[语音]".lv_localized;
        case MessageType_Document:
            return @"[文件]".lv_localized;
        case MessageType_Location:
            return @"[位置]".lv_localized;
        case MessageType_Pinned:
            return @"[群通知]".lv_localized;
        case MessageType_Contact_Registed:
            return [self contactRegistedDescription];
        case MessageType_Text_Kicked_SensitiveWords:
            return [self kickedBySendSensitiveWordsDescription];
        case MessageType_Text_Screenshot:
            //某某于×月×日×时×分截屏了一次
            return [self screenshotDescription];
        case MessageType_Text_BeFriend:
            return [self beFriendDescription];
        case MessageType_Text_Blacklist:
            return @"您已被对方加入黑名单".lv_localized;
        case MessageType_Text_Stranger:
            return @"对方拒绝陌生人会话".lv_localized;
        case MessageType_Animation:
            return @"[gif]".lv_localized;
        case MessageType_Card:
            return @"[个人名片]".lv_localized;
        default:
            return @"[App暂时不支持该消息]".lv_localized;
    }
}

- (NSString *)contactRegistedDescription {
    NSString *name = [UserInfo userDisplayName:self.sender.user_id];
    return [NSString stringWithFormat:@"联系人 %@ 已注册".lv_localized, name];
}

- (NSString *)kickedBySendSensitiveWordsDescription {
    NSString *name = [UserInfo userDisplayName:self.sender.user_id];
    return [NSString stringWithFormat:@"%@ 发送敏感词被移出群聊".lv_localized, name];
}

- (NSString *)screenshotDescription
{
    NSString *who = nil;
    if(self.sender.user_id == [UserInfo shareInstance]._id)
    {
        who = @"你".lv_localized;
    }
    else
    {
        who = [UserInfo userDisplayName:self.sender.user_id];
    }
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:self.date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日hh时mm分".lv_localized];
    NSString *timeStr = [formatter stringFromDate:msgDate];
    return [NSString stringWithFormat:@"%@于%@截屏了一次".lv_localized, who, timeStr];
}

- (NSString *)beFriendDescription
{
    if(self.sender.user_id == [UserInfo shareInstance]._id)
    {
        return [NSString stringWithFormat:@"你加%@为好友了".lv_localized, [UserInfo userDisplayName:self.chat_id]];
    }
    else
    {
        return [NSString stringWithFormat:@"%@加你为好友了".lv_localized, [UserInfo userDisplayName:self.chat_id]];
    }
}

//是否显示已读未读标志
- (BOOL)canShowReadFlag
{
    return self.messageType == MessageType_Text
    || self.messageType == MessageType_Text_New_Rp
    || self.messageType == MessageType_Text_Transfer
    || self.messageType == MessageType_Video
    || self.messageType == MessageType_Photo
    || self.messageType == MessageType_Audio
    || self.messageType == MessageType_Voice
    || self.messageType == MessageType_Document
    || self.messageType == MessageType_Location
    || self.messageType == MessageType_Card
    || self.messageType == MessageType_Animation;
}

- (BOOL)isLocalMessage
{
    return self.messageType == MessageType_Text_AudioAVideo_Done;
}

- (MessageSendState)sendState
{
    if(self.is_outgoing && self.sending_state != nil)
    {
        return [self.sending_state sendState];
    }
    return MessageSendState_Success;
}

- (BOOL)isAdMessage {
    return (self.reply_markup && self.reply_markup.isReplyMarkupInlineKeyboard) ||
    [NSString xhq_notEmpty:self.content.caption[@"text"]];
}

- (void)parseTextToExMessage
{
    if (self.ttl_expires_in>0) {
        self.fireTime = [NSString stringWithFormat:@"%.0f",self.ttl_expires_in];
        self.messageType = MessageType_Text;
        return;
    }
    NSString *text = self.textTypeContent;
    if([text hasPrefix:@"ct!"])
    {
        NSArray *list = [text componentsSeparatedByString:@"!"];
        if(list.count>=5)
        {
            NSString *md5 = list[1];
            int mainCode = [list[2] intValue];
            int subCode = [list[3] intValue];
            NSMutableString *contentStr = [NSMutableString string];
            for(int i=4; i<list.count; i++)
            {
                if(contentStr.length>0)
                    [contentStr appendString:@"!"];
                [contentStr appendString:list[i]];
            }
            if([md5 isEqualToString:[Common md5:contentStr]])
            {
                switch (mainCode)
                {
                    case AudioAVideo_MessageType:
                        //音视频模块消息
                        [self parseTextToAudioAVideoMessage:contentStr subCode:subCode];
                        break;
                    case RP_MessageType:
                        //模块消息
                        [self parseTextToRpMessage:contentStr subCode:subCode];
                        break;
                    case OtherEx_MessageType:
                        //其它扩展类消息
                        [self parseTextToOtherExMessage:contentStr subCode:subCode];
                        break;
                    case Transfer_MessageType:
                        [self parseTextToTransferMessage:contentStr subCode:subCode];
                        break;
                    case Kicked_MessageType:
                        [self parseTextToKickedMessage:contentStr subCode:subCode];
                        break;
//                    case ReadFire_MessageType:
//                        //阅后即焚消息
//                        [self parseTextToReadFireMessage:contentStr];
//                        break;
                    default:
                        self.messageType = MessageType_Unkown;
                        break;
                }
            }
        }
    }
}
-(void)parseTextToReadFireMessage:(NSString *)contentStr{
    NSError * error = nil;
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:[self paserJsonStr:contentStr] options:NSJSONReadingMutableLeaves error:&error];
//    NSDictionary * dic = [contentStr mj_JSONObject];//带\n的解析有问题
    self.textTypeContent = dic[@"text"];
//    self.fireTime = [NSString stringWithFormat:@"%@",dic[@"countDown"]];
    self.fireTime = [NSString stringWithFormat:@"%.0f",self.ttl_expires_in];

    self.messageType = MessageType_Text;
}
-(NSData *)paserJsonStr:(NSString *)originalString{
    NSString * jsonString = [originalString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}
- (void)parseTextToAudioAVideoMessage:(NSString *)contentStr subCode:(int)subCode
{
    switch (subCode)
    {
        case AudioAVideo_MessageType_Done:
        {
            LocalCallInfo *callInfo = [LocalCallInfo mj_objectWithKeyValues:[contentStr mj_JSONObject]];
            self.textTypeContent = [callInfo displayDesc];
            self.callInfo = callInfo;
            self.messageType = MessageType_Text_AudioAVideo_Done;
        }
            break;
        default:
            self.messageType = MessageType_Unkown;
            break;
    }
}

- (void)parseTextToOtherExMessage:(NSString *)contentStr subCode:(int)subCode
{
    switch (subCode)
    {
        case OtherEx_MessageType_Screenshot:
        {//截屏消息
            self.messageType = MessageType_Text_Screenshot;
        }
            break;
        case OtherEx_MessageType_BeFriend:
        {//加好友消息
            self.messageType = MessageType_Text_BeFriend;
        }
            break;
        default:
            self.messageType = MessageType_Unkown;
            break;
    }
}

- (void)parseTextToRpMessage:(NSString *)contentStr subCode:(int)subCode
{
    switch (subCode)
    {
        case RP_MessageType_New:
        {
            RP_Msg *rp = [RP_Msg mj_objectWithKeyValues:[contentStr mj_JSONObject]];
            self.textTypeContent = @"[红包]".lv_localized;
            self.rpInfo = rp;
            self.messageType = MessageType_Text_New_Rp;
        }
            break;
        case RP_MessageType_Got:
        {
            RP_Pick_Msg *rp = [RP_Pick_Msg mj_objectWithKeyValues:[contentStr mj_JSONObject]];
            self.textTypeContent = [rp description:self.sender.user_id];
            self.rpGotInfo = rp;
            self.messageType = MessageType_Text_Got_Rp;
        }
            break;
        default:
            self.messageType = MessageType_Unkown;
            break;
    }
}

- (void)parseTextToTransferMessage:(NSString *)contentStr subCode:(int)subCode {
    self.messageType = MessageType_Text_Transfer;
    self.transferInfo = [TransferMsgInfo mj_objectWithKeyValues:contentStr.mj_JSONObject];
    self.transferInfo.outgoing = self.is_outgoing;
    self.transferInfo.state = subCode;
    switch (subCode) {
        case Transfer_MessageSubType_Remit:
            self.textTypeContent = @"[转账]".lv_localized;
            break;
        case Transfer_MessageSubType_Receive:
            self.textTypeContent = @"[转账]已领取".lv_localized;
            break;
        case Transfer_MessageSubType_RefundByUser:
            self.textTypeContent = @"[转账]已退还".lv_localized;
            break;
        case Transfer_MessageSubType_Remind:
            self.messageType = MessageType_Text;
            self.textTypeContent = @"你有一笔待接收的转账".lv_localized;
            break;
        case Transfer_MessageSubType_RefundBySystem:
            self.textTypeContent = @"[转账]已退还".lv_localized;
            break;
        default:
            break;
    }
}

- (void)parseTextToKickedMessage:(NSString *)contentStr subCode:(int)subCode {
    switch (subCode) {
        case Kicked_MessageSubType_SensitiveWords:
            self.messageType = MessageType_Text_Kicked_SensitiveWords;
        default:
            break;
    }
}

+ (NSString *)getTextExMessage:(NSString *)text mainCode:(int)mainCode subCode:(int)subCode
{
    NSString *md5 = [Common md5:text];
    //^ct:([a-f\d]{32}|[A-F\d]{32}):(\d+):(\d+):([^$]+)
    return [NSString stringWithFormat:@"ct!%@!%d!%d!%@", md5, mainCode, subCode, text];
}

@end

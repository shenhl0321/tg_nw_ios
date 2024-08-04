//
//  HistoryMessageItemCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/3.
//

#import "HistoryMessageItemCell.h"

@interface HistoryMessageItemCell ()
@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic, strong) MessageInfo *msgInfo;
@end

@implementation HistoryMessageItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.badgeLabel.hidden = YES;
    [self.headerImageView setClipsToBounds:YES];
    [self.headerImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)resetChatInfo:(ChatInfo *)info
{
    self.chatInfo = info;

    //TelegramManager
    if(self.chatInfo.isGroup)
    {
        self.titleLabel.text = self.chatInfo.title;
        //群组头像
        if(self.chatInfo.photo != nil)
        {
            if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1)
            {
                [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
                //本地头像
                self.headerImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(self.chatInfo.title.length>0)
                {
                    text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
            }
            else
            {
                [UserInfo cleanColorBackgroundWithView:self.headerImageView];
                self.headerImageView.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
            }
        }
        else
        {
            //本地头像
            self.headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0)
            {
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
        }
    }
    else
    {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo.userId];
        if(user != nil)
        {
            if(user.profile_photo != nil)
            {
                if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
                {
                    [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                    //本地头像
                    self.headerImageView.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
                }
                else
                {
                    [UserInfo cleanColorBackgroundWithView:self.headerImageView];
                    self.headerImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }
            else
            {
                //本地头像
                self.headerImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
            }
            self.titleLabel.text = user.displayName;
        }
        else
        {
            //本地头像
            self.headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0)
            {
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
            self.titleLabel.text = self.chatInfo.title;
        }
    }

    if(self.chatInfo.lastMessage != nil)
    {
        BOOL issetting = NO;
        self.timeLabel.text = [Common getFullMessageTime:self.chatInfo.lastMessage.date showDetail:YES];
        if(self.chatInfo.unread_count<=0){//无未读
            
        }else{//有未读
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo.lastMessage.sender.user_id];
            if (self.chatInfo.isGroup && user != nil && !self.chatInfo.lastMessage.is_outgoing && !self.chatInfo.lastMessage.isTipMessage) {//群聊
                NSDictionary *textdic = self.chatInfo.lastMessage.content.text;
                NSArray *entitiesArr = [textdic objectForKey:@"entities"];
                if (entitiesArr && entitiesArr.count > 0) {
                    for (NSDictionary *itemdic in entitiesArr) {
                        NSDictionary *dicLim = [itemdic objectForKey:@"type"];
                        if (dicLim) {
                            long idlin = [[dicLim objectForKey:@"user_id"] longValue];
                            if (idlin == [UserInfo shareInstance]._id) {//@我
                                issetting = YES;
                                NSString *prestr = @"[有人@我]".lv_localized;
                                NSString *str = [NSString stringWithFormat:@"%@ %@",prestr,[NSString stringWithFormat:@"%@:%@", user.displayName, [self.chatInfo.lastMessage description]]];
                                NSMutableAttributedString *mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                                NSDictionary *attributeDict1 = @{NSForegroundColorAttributeName: COLOR_CG2,NSFontAttributeName: [UIFont systemFontOfSize:15]};
                                [mutabOfferStr addAttributes:attributeDict1 range:[str rangeOfString:prestr]];
                                self.contentLabel.attributedText = mutabOfferStr;
                                break;
                            }
                        }
                    }
                }
                else if (self.chatInfo.unread_mention_count>0){//@未读数大于0
                    issetting = YES;
                    NSString *prestr = @"[有人@我]".lv_localized;
                    NSString *str = [NSString stringWithFormat:@"%@ %@",prestr,[NSString stringWithFormat:@"%@:%@", user.displayName, [self.chatInfo.lastMessage description]]];
                    NSMutableAttributedString *mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                    NSDictionary *attributeDict1 = @{NSForegroundColorAttributeName: COLOR_CG2,NSFontAttributeName: [UIFont systemFontOfSize:15]};
                    [mutabOfferStr addAttributes:attributeDict1 range:[str rangeOfString:prestr]];
                    self.contentLabel.attributedText = mutabOfferStr;
                }
            }
        }
        if (!issetting) {
            //副标题
            NSString *text = [CZCommonTool getdraftchatid:self.chatInfo._id];
            if (text && text.length > 0) {
                NSString *prestr = @"[草稿]".lv_localized;
                NSString *str = [NSString stringWithFormat:@"%@ %@",prestr,text];
                NSMutableAttributedString *mutabOfferStr = [[NSMutableAttributedString alloc]initWithString:str];
                NSDictionary *attributeDict1 = @{NSForegroundColorAttributeName: COLOR_CG2,NSFontAttributeName: [UIFont systemFontOfSize:15]};
                [mutabOfferStr addAttributes:attributeDict1 range:[str rangeOfString:prestr]];
                self.contentLabel.attributedText = mutabOfferStr;
            }else{
                if(self.chatInfo.isGroup)
                {
                    UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo.lastMessage.sender.user_id];
                    if(user != nil && !self.chatInfo.lastMessage.is_outgoing && !self.chatInfo.lastMessage.isTipMessage)
                    {
                        self.contentLabel.text = [NSString stringWithFormat:@"%@:%@", user.displayName, [self.chatInfo.lastMessage description]];
                    }
                    else
                    {
                        self.contentLabel.text = [self.chatInfo.lastMessage description];
                    }
                }
                else
                {
                    self.contentLabel.text = [self.chatInfo.lastMessage description];
                }
            }
        }
        
        if(self.chatInfo.lastMessage.sendState == MessageSendState_Success)
        {
            self.ayIndicatorView.hidden = YES;
            [self.ayIndicatorView stopAnimating];
            self.failImageView.hidden = YES;
        }
        else
        {
            if(self.chatInfo.lastMessage.sendState == MessageSendState_Fail)
            {
                self.ayIndicatorView.hidden = YES;
                [self.ayIndicatorView startAnimating];
                self.failImageView.hidden = NO;
            }
            else
            {
                self.ayIndicatorView.hidden = NO;
                [self.ayIndicatorView startAnimating];
                self.failImageView.hidden = YES;
            }
        }
        //已读未读标志
        self.readImageView.hidden = YES;
        if (self.chatInfo.lastMessage != nil && self.chatInfo.lastMessage.is_outgoing && self.chatInfo.lastMessage.canShowReadFlag)
        {
            if(self.chatInfo.lastMessage.sendState == MessageSendState_Success)
            {
                self.readImageView.hidden = NO;
                BOOL isReaded = self.chatInfo.lastMessage._id<=self.chatInfo.last_read_outbox_message_id;
                if(isReaded)
                {
                    self.readImageView.image = [UIImage imageNamed:@"icon_msg_read_cb"];
                }
                else
                {
                    self.readImageView.image = [UIImage imageNamed:@"icon_msg_sended_cb"];
                }
                //调整位置
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.timeLabel.font, NSFontAttributeName, nil];
                CGRect rc = [self.timeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
                self.readImageRightMargin.constant = rc.size.width+3;
            }
        }
    }
    else
    {
        self.timeLabel.text = nil;
        self.contentLabel.text = nil;
        self.ayIndicatorView.hidden = YES;
        [self.ayIndicatorView stopAnimating];
        self.failImageView.hidden = YES;
        self.readImageView.hidden = YES;
    }
    [self resetChatBadge];

    //icon mute
    if(self.chatInfo.default_disable_notification)
    {
        self.muteImageView.hidden = NO;
        if(!self.failImageView.hidden)
        {
            self.muteImageRightMargin.constant = self.ayIndicatorRightMargin.constant+18+5;
        }
        else if(!self.ayIndicatorView.hidden)
        {
            self.muteImageRightMargin.constant = self.ayIndicatorRightMargin.constant+20+5;
        }
        else if(!self.badgeLabel.hidden)
        {
            self.muteImageRightMargin.constant = self.badgeWidth.constant+5;
        }
        else
        {
            self.muteImageRightMargin.constant = 0;
        }
    }
    else
    {
        self.muteImageView.hidden = YES;
    }

    if(self.chatInfo.is_pinned)
    {//置顶
        self.contentView.backgroundColor = HEX_COLOR(@"#f5f5f5");
    }
    else
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)resetMessageInfo:(MessageInfo *)info
{
    self.msgInfo = info;
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.msgInfo.chat_id];
    if(chat.isGroup)
    {
        self.titleLabel.text = chat.title;
        //群组头像
        if(chat.photo != nil)
        {
            if(!chat.photo.isSmallPhotoDownloaded)
            {
                //本地头像
                self.headerImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(chat.title.length>0)
                {
                    text = [[chat.title uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
            }
            else
            {
                [UserInfo cleanColorBackgroundWithView:self.headerImageView];
                self.headerImageView.image = [UIImage imageWithContentsOfFile:chat.photo.localSmallPath];
            }
        }
        else
        {
            //本地头像
            self.headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(chat.title.length>0)
            {
                text = [[chat.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
        }
    }
    else
    {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:chat.userId];
        if(user != nil)
        {
            if(user.profile_photo != nil)
            {
                if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
                {
                    [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                    //本地头像
                    self.headerImageView.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
                }
                else
                {
                    [UserInfo cleanColorBackgroundWithView:self.headerImageView];
                    self.headerImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }
            else
            {
                //本地头像
                self.headerImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
            }
            self.titleLabel.text = user.displayName;
        }
        else
        {
            //本地头像
            self.headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(chat.title.length>0)
            {
                text = [[chat.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(47, 47) withChar:text];
            self.titleLabel.text = chat.title;
        }
    }
    
    self.timeLabel.text = [Common getFullMessageTime:self.msgInfo.date showDetail:YES];
    if(chat.isGroup)
    {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.msgInfo.sender.user_id];
        if(user != nil && !self.msgInfo.is_outgoing && !self.msgInfo.isTipMessage)
        {
            self.contentLabel.text = [NSString stringWithFormat:@"%@:%@", user.displayName, [self.msgInfo description]];
        }
        else
        {
            self.contentLabel.text = [self.msgInfo description];
        }
    }
    else
    {
        self.contentLabel.text = [self.msgInfo description];
    }
}

- (void)resetChatBadge
{
    if(self.chatInfo.unread_count<=0)
    {
        self.badgeLabel.hidden = YES;
        self.ayIndicatorRightMargin.constant = 0;
    }
    else if(self.chatInfo.unread_count<10)
    {
        self.badgeLabel.hidden = NO;
        self.badgeWidth.constant = 18;
        self.badgeLabel.text = [NSString stringWithFormat:@"%d", self.chatInfo.unread_count];
        self.ayIndicatorRightMargin.constant = self.badgeWidth.constant+5;
    }
    else if(self.chatInfo.unread_count<=99)
    {
        self.badgeLabel.hidden = NO;
        self.badgeWidth.constant = 26;
        self.badgeLabel.text = [NSString stringWithFormat:@"%d", self.chatInfo.unread_count];
        self.ayIndicatorRightMargin.constant = self.badgeWidth.constant+5;
    }
    else
    {
        self.badgeLabel.hidden = NO;
        self.badgeWidth.constant = 32;
        self.badgeLabel.text = @"99+";
        self.ayIndicatorRightMargin.constant = self.badgeWidth.constant+5;
    }
}

@end

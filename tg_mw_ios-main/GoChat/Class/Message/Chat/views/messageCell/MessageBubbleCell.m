//
//  MessageBubbleCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageBubbleCell.h"
#import "IMMessagePasteboard.h"
#import "CoreTextView.h"
#import "ZyPlayerView.h"
#import "UIView+Corner.h"
#import "MessageADButtonsView.h"
#import "MessageReactionEmojiView.h"
#import "MessageReactionBottomView.h"

@implementation ChatMenu
+ (instancetype)menuWithTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action
{
    ChatMenu *menu = [ChatMenu new];
    menu.title = title;
    menu.icon = icon;
    menu.action = action;
    return menu;
}
@end

@interface MessageBubbleCell()<YBPopupMenuDelegate>

@property (nonatomic,strong) UIButton *replayMsgBtn;//引用消息

@property (nonatomic, strong) MessageADButtonsView *adButtonsView;

@property (nonatomic, strong) CoreTextView *captionTextView;

/// 消息回应表情
@property (nonatomic, strong) MessageReactionEmojiView *reactionEmojiView;
@property (nonatomic, weak) YBPopupMenu *longPressPopup;
@property (nonatomic, strong) MessageReactionBottomView *reactionBottomView;

@end

@implementation MessageBubbleCell
@dynamic delegate;
@synthesize isSecret = _isSecret;
#pragma mark - 类方法

+ (CGFloat)ScaleFromCompassToSize:(CGSize)toSize fromSize:(CGSize)fromSize
{
    float scale = 1.0f;
    if (fromSize.width >= fromSize.height)
    {
        if (fromSize.width > toSize.width)
        {
            scale =  toSize.width / fromSize.width;
        }
    }
    else if (fromSize.height > fromSize.width)
    {
        if (fromSize.height > toSize.height)
        {
            scale =  toSize.height / fromSize.height;
        }
    }
    return scale;
}

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    CGFloat height = 0;
    if(chatRecordDTO.isShowDayText)
    {
        //日期高度
        height = MessageCellVertMargins + MessageCellTimestampRegionHeight;
       
    }
    if (chatRecordDTO.isShowGroupReactionView) {
        height += MessageReactionBottomView.viewHeight;
    }
    if (chatRecordDTO.reply_markup && chatRecordDTO.reply_markup.isReplyMarkupInlineKeyboard) {
        /// 有广告
        MessageADButtonsView *temp = [[MessageADButtonsView alloc] init];
        temp.rows = chatRecordDTO.reply_markup.rows;
        height += temp.vHeight;
        temp = nil;
    } else if (chatRecordDTO.content.caption[@"text"]) {
        CGFloat photoWidth = 0.0f;
        UIImage *image = nil;
        PhotoSizeInfo *photoInfo = chatRecordDTO.content.photo.messagePhoto;
        if(photoInfo != nil && photoInfo.isPhotoDownloaded) {
            image = [UIImage imageWithContentsOfFile:photoInfo.photo.local.path];
        }
        CGFloat scale = [self ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(photoInfo.width, photoInfo.height)];
        if (!image) {
            if (photoInfo.width > 0 && photoInfo.height > 0) {
                photoWidth = MIN(MESSAGE_CELL_PHOTO_MAX_WIDTH , MAX(scale*photoInfo.width, 40));
            } else {
                photoWidth = MIN(MESSAGE_CELL_PHOTO_MAX_WIDTH , MAX(MESSAGE_CELL_PHOTO_MAX_WIDTH, 40));
            }
        } else {
            photoWidth = MIN(MESSAGE_CELL_PHOTO_MAX_WIDTH , MAX(scale*image.size.width, 40));
        }
        CoreTextView *temp = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 0, photoWidth, 0)];
        temp.analyzeType = AnalyzeTypeURL|AnalyzeTypeEmail|AnalyzeTypePhoneNumber|AnalyzeTypeSomeone;
        temp.text = chatRecordDTO.content.caption[@"text"];
        [temp startAnalyze];
        [temp adjustFrame];
        height += temp.frame.size.height;
        temp = nil;
    }
    if (chatRecordDTO.reply_str && chatRecordDTO.reply_str.length > 0) {//引用
        CGSize size = [CZCommonTool boundingRectWithString:chatRecordDTO.reply_str withFont:14 withWidth:SCREEN_WIDTH-130];
        //有引用
        CGFloat heightlim = size.height > 30 ? 35 : size.height+10;
        
        height += heightlim+2;
    }
    return height;
}

#pragma mark - 实例方法

- (void)reset
{
    [super reset];

    self.avatarImageView.image = nil;
    
    self.bubbleImageView.image = nil;
    
    self.nickNameLabel.text = nil;
    
    self.dayLabel.text = nil;
    
    if ([self.replayMsgBtn superview]) {
        [self.replayMsgBtn removeFromSuperview];
    }
    if (_adButtonsView.superview) {
        [_adButtonsView removeFromSuperview];
        _adButtonsView = nil;
    }
    if (_reactionBottomView.superview) {
        [_reactionBottomView removeFromSuperview];
        _reactionBottomView = nil;
    }
    [_captionTextView removeFromSuperview];
    _captionTextView = nil;
}

- (void)initialize
{
    [super initialize];
    
    //日期
    self.dayLabel.hidden = YES;
    self.dayLabel.font = fontRegular(14);
    self.dayLabel.textColor = [UIColor colorTextForA9B0BF];
    //头像圆角
    
    [self.avatarImageView setClipsToBounds:YES];
    [self.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    CALayer *l = self.avatarImageView.layer;
    [l setMasksToBounds:YES];
    [l setCornerRadius:21];
    
    if (self.isGroup) {
        if (self.chatRecordDTO.is_outgoing) {
            self.avatarImageView.hidden = YES;
            self.nickNameLabel.hidden = YES;
        } else {
            self.avatarImageView.hidden = NO;
            self.nickNameLabel.hidden = NO;
        }
    } else {
        self.avatarImageView.hidden = YES;
        self.nickNameLabel.hidden = YES;
    }
    
    //设置基本信息
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatRecordDTO.sender.user_id];
    if(user != nil)
    {
        if(user.profile_photo != nil)
        {
            if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
            {
                [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                //本地头像
                self.avatarImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.avatarImageView withSize:CGSizeMake(42, 42) withChar:text];
            }
            else
            {
                [UserInfo cleanColorBackgroundWithView:self.avatarImageView];
                self.avatarImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
            }
        }
        else
        {
            //本地头像
            self.avatarImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(user.displayName.length>0)
            {
                text = [[user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.avatarImageView withSize:CGSizeMake(42, 42) withChar:text];
        }
        self.nickNameLabel.text = user.displayName;
    }
    else
    {
        self.nickNameLabel.text = [NSString stringWithFormat:@"%ld", self.chatRecordDTO.sender.user_id];
        //本地头像
        self.avatarImageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.nickNameLabel.text.length>0)
        {
            text = [[self.nickNameLabel.text uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.avatarImageView withSize:CGSizeMake(42, 42) withChar:text];
    }
    
    /// 群组内昵称显示
    NSString *groupNickname = [self groupNickname];
    if (groupNickname) {
        self.nickNameLabel.text = groupNickname;
    }
    
    //气泡背景
    [self setBubbleImage];
    
    //时间
    //self.timeLabel.hidden = YES;
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = fontRegular(12);
    self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
    self.timeLabel.text = [Common getMessageTime:self.chatRecordDTO.date];
    
    if(self.chatRecordDTO.isShowDayText)
    {//显示日期文本
        self.dayLabel.hidden = NO;
        self.dayLabel.text = [Common getMessageDay:self.chatRecordDTO.date];
    }
}
-(void)loadChatRecord:(MessageInfo *)chatRecordDTO isGroup:(BOOL)isGroup{
    [super loadChatRecord:chatRecordDTO isGroup:isGroup];
    if (isGroup) {
        if (chatRecordDTO.is_outgoing) {
            self.avatarImageView.hidden = YES;
            self.nickNameLabel.hidden = YES;
        }else{
            self.avatarImageView.hidden = NO;
            self.nickNameLabel.hidden = NO;
        }
    }else{
        self.avatarImageView.hidden = YES;
        self.nickNameLabel.hidden = YES;
    }
}

- (void)setBubbleImage
{
    UIImage *bubbleImage = nil;
    if (self.chatRecordDTO.is_outgoing)
    {
        if (self.chatRecordDTO.messageType == MessageType_Text_New_Rp) {
            NSDictionary *dic = [CZCommonTool getGreyRedPagListwithPkid:self.chatRecordDTO.rpInfo.redPacketId];
            if (dic && dic.allKeys.count > 0) {
                bubbleImage = [[UIImage imageNamed:@"chat_send_message_rped_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:30];
                self.bubbleImageView.backgroundColor = [UIColor colorBubbleRedBubbleGot];
            }else{
                bubbleImage = [[UIImage imageNamed:@"chat_send_message_rp_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:30];
                self.bubbleImageView.backgroundColor = [UIColor colorBubbleRedBubble];
            }
            
        } else if (self.chatRecordDTO.messageType == MessageType_Text_Transfer) {
            self.bubbleImageView.backgroundColor = self.chatRecordDTO.transferInfo.bgColor;
        } else {
            bubbleImage = [[UIImage imageNamed:@"chat_send_message_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:30];
            self.bubbleImageView.backgroundColor = [UIColor colorBubbleMe];
        }
    }
    else
    {
        if(self.chatRecordDTO.messageType == MessageType_Text_New_Rp){
            NSDictionary *dic = [CZCommonTool getGreyRedPagListwithPkid:self.chatRecordDTO.rpInfo.redPacketId];
            if (dic && dic.allKeys.count > 0) {
                    bubbleImage = [[UIImage imageNamed:@"chat_receive_message_rped_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:30];
                self.bubbleImageView.backgroundColor = [UIColor colorBubbleRedBubbleGot];
            }else{
                bubbleImage = [[UIImage imageNamed:@"chat_receive_message_rp_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:30];
                self.bubbleImageView.backgroundColor = [UIColor colorBubbleRedBubble];
            }
           
        } else if (self.chatRecordDTO.messageType == MessageType_Text_Transfer) {
            self.bubbleImageView.backgroundColor = self.chatRecordDTO.transferInfo.bgColor;
        }else{
            bubbleImage = [[UIImage imageNamed:@"chat_receive_message_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:30];
            self.bubbleImageView.backgroundColor = [UIColor colorBubbleOther];
        }
    }
    self.bubbleImageView.image = bubbleImage;
}

- (void)config
{
    [super config];
    if (self.chatRecordDTO.reply_str && self.chatRecordDTO.reply_str.length > 0) {
        CGSize size = [CZCommonTool boundingRectWithString:self.chatRecordDTO.reply_str withFont:14 withWidth:SCREEN_WIDTH-130];
        self.replayMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.replayMsgBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.replayMsgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.replayMsgBtn.layer.cornerRadius = 5;
        self.replayMsgBtn.clipsToBounds = YES;
        self.replayMsgBtn.titleLabel.numberOfLines = 2;
        self.replayMsgBtn.backgroundColor =  HexRGB(0xf5f5f5);
        [self.replayMsgBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
        self.replayMsgBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.replayMsgBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.replayMsgBtn addTarget:self action:@selector(quoteViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentBaseView addSubview:self.replayMsgBtn];
        
        
        CGFloat height = size.height > 30 ? 35 : size.height+10;
        self.replayMsgBtn.frame = CGRectMake(0, 0, size.width+10, height);
        [self.replayMsgBtn setTitle:self.chatRecordDTO.reply_str forState:UIControlStateNormal];
    }
    if (self.chatRecordDTO.isShowGroupReactionView) {
        [self.contentBaseView addSubview:self.reactionBottomView];
    }
    if (self.chatRecordDTO.reply_markup && self.chatRecordDTO.reply_markup.isReplyMarkupInlineKeyboard) {
        self.adButtonsView.rows = self.chatRecordDTO.reply_markup.rows;
        [self.contentBaseView addSubview:self.adButtonsView];
    } else if ([NSString xhq_notEmpty:self.chatRecordDTO.content.caption[@"text"]]) {
        [self.contentBaseView addSubview:self.captionTextView];
    }
}

//引用视图点击
- (void)quoteViewClick{
    if ([self.delegate respondsToSelector:@selector(quoteMsgClickWithCell:)]){
        [self.delegate quoteMsgClickWithCell:self];
    }
}

- (void)adjustBubblePosition
{
    CGFloat yOffset = 0;
    if(self.chatRecordDTO.isShowDayText)
    {
        yOffset = MessageCellVertMargins+MessageCellTimestampRegionHeight;
    }
    
    //气泡位置
    CGRect frame = self.bubbleImageView.frame;
    if (!self.chatRecordDTO.is_outgoing)
    {//他人发送
        if (self.isGroup) {
            
            frame.origin.x = MessageCellHeadHorizontalMargins*2+MessageCellAvatarWidth-5;
            if (self.nickNameLabel.hidden == NO)
                frame.origin.y = yOffset+MessageCellVertMargins+MessageCellNicknameHeight;
            else
                frame.origin.y = yOffset+MessageCellVertMargins;
            self.bubbleImageView.frame = frame;
            [self.bubbleImageView addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight radius:10];
            
            
        }else{
            frame.origin.x = 15;
            frame.origin.y = yOffset+MessageCellVertMargins;
            self.bubbleImageView.frame = frame;
            [self.bubbleImageView addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight radius:10];
        }
        
    }
    else
    {//自己发送
        
        frame.origin.x = SCREEN_WIDTH - frame.size.width - 15;
        frame.origin.y = yOffset+MessageCellVertMargins;
        self.bubbleImageView.frame = frame;
        [self.bubbleImageView addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft radius:10];
        
    }
    CGFloat lastBottom = CGRectGetMaxY(frame);
    
    if (self.chatRecordDTO.isShowGroupReactionView) {
        frame.origin.y = lastBottom;
        frame.size.height = self.reactionBottomView.frame.size.height;
        frame.size.width = self.reactionBottomView.frame.size.width;
        self.reactionBottomView.frame = frame;
        lastBottom = CGRectGetMaxY(frame);
    }
    
    /// 配置 广告
    if (self.chatRecordDTO.reply_markup && self.chatRecordDTO.reply_markup.isReplyMarkupInlineKeyboard) {
        frame.origin.y = lastBottom;
        frame.size.height = self.adButtonsView.vHeight;
        self.adButtonsView.frame = frame;
        [self.adButtonsView reloadData];
        lastBottom = CGRectGetMaxY(frame);
    } else if (self.chatRecordDTO.content.caption[@"text"]) {
        frame.origin.y = lastBottom;
        frame.size.height = self.captionTextView.frame.size.height;
        self.captionTextView.frame = frame;
        lastBottom = CGRectGetMaxY(frame);
    }
    
    /// 配置 `引用`
    frame = self.replayMsgBtn.frame;
    frame.origin.y =  lastBottom + 2;
    if (!self.chatRecordDTO.is_outgoing)
    {//他人发送
        frame.origin.x = self.bubbleImageView.frame.origin.x;
    }
    else
    {//自己发送
        frame.origin.x = SCREEN_WIDTH - frame.size.width - 15;
    }

    self.replayMsgBtn.frame = frame;
    lastBottom = CGRectGetMaxY(frame);
}

- (void)adjustFrame
{
    CGFloat yOffset = 0;
    if(self.chatRecordDTO.isShowDayText)
    {
        CGRect frame = self.dayLabel.frame;
        frame.size.width = SCREEN_WIDTH;
        frame.size.height = MessageCellTimestampRegionHeight;
        frame.origin.y = MessageCellVertMargins;
        if(!self.chatRecordDTO.is_outgoing && [self IsMultiSelectingMode] && [self IsCanGotoMultiSelectingMode])
        {
            frame.origin.x = 0;
            frame.size.width = SCREEN_WIDTH - 60;
        }
        else
        {
            frame.origin.x = 0;
        }
        self.dayLabel.frame = frame;
        yOffset = MessageCellVertMargins+MessageCellTimestampRegionHeight;
    }
    
    //头像
    CGRect frame = self.avatarImageView.frame;
    frame.origin.y = yOffset+MessageCellVertMargins;
    frame.size.width =  MessageCellAvatarWidth;
    frame.size.height = MessageCellAvatarHeight;
    if (!self.chatRecordDTO.is_outgoing)
    {
        frame.origin.x = MessageCellHeadHorizontalMargins;
    }
    else
    {
        frame.origin.x = SCREEN_WIDTH - frame.size.width - MessageCellHeadHorizontalMargins;
    }
    self.avatarImageView.frame = frame;
    //昵称位置
    if (!self.nickNameLabel.hidden)
    {
        frame = self.nickNameLabel.frame;
        frame.size.height = MessageCellNicknameHeight-3;
        frame.size.width = 200;
        frame.origin.y = yOffset+MessageCellVertMargins;
        frame.origin.x = self.avatarImageView.frame.origin.x+self.avatarImageView.frame.size.width+MessageCellHeadHorizontalMargins;
        self.nickNameLabel.frame = frame;
    }
    //整个内容区高度调整
    frame = self.contentBaseView.frame;
    frame.size.height = MAX(CGRectGetMaxY(self.bubbleImageView.frame), MessageCellContentMinHeight);
    
    /// 表情回复
    if (self.chatRecordDTO.isShowGroupReactionView) {
        frame.size.height += self.reactionBottomView.frame.size.height;
    }
    
    /// 广告
    if (self.chatRecordDTO.reply_markup && self.chatRecordDTO.reply_markup.isReplyMarkupInlineKeyboard) {
        frame.size.height += self.adButtonsView.frame.size.height;
    } else if (self.chatRecordDTO.content.caption[@"text"]) {
        frame.size.height += self.captionTextView.frame.size.height;
        [self.contentBaseView addSubview:self.captionTextView];
    }
    /// 引用
    if (self.chatRecordDTO.reply_str && self.chatRecordDTO.reply_str.length > 0) {
        frame.size.height += self.replayMsgBtn.frame.size.height;
    }
    
    self.contentBaseView.frame = frame;
    if (self.chatRecordDTO.content.caption[@"text"]) {
        self.captionTextView.xhq_y = self.bubbleImageView.xhq_bottom;
    }
    [super adjustFrame];
    
}

- (NSArray *)menuItems;
{
    NSMutableArray *menuItems = [NSMutableArray array];
    //转发
    if (!self.chatInfo.isSecretChat) {
        [menuItems addObject:[ChatMenu menuWithTitle:@"转发".lv_localized icon:@"menu_forword" action:@selector(forwardMessage:)]];
    }
    
    //删除
    [menuItems addObject:[ChatMenu menuWithTitle:@"删除".lv_localized icon:@"menu_delete" action:@selector(deleteMessage:)]];
    if(self.chatRecordDTO.is_outgoing)
    {
        [menuItems addObject:[ChatMenu menuWithTitle:@"撤回".lv_localized icon:@"menu_revoke" action:@selector(revokeMessage:)]];
    }
    else
    {
        if(!self.delegate.isGroupChat)
        {
            [menuItems addObject:[ChatMenu menuWithTitle:@"撤回".lv_localized icon:@"menu_revoke" action:@selector(revokeMessage:)]];
        }else{
            if(self.delegate.isManage){
                [menuItems addObject:[ChatMenu menuWithTitle:@"撤回".lv_localized icon:@"menu_revoke" action:@selector(revokeMessage:)]];
            }
        }
    }
    //收藏
    if(!self.delegate.isGroupChat && self.chatRecordDTO.chat_id==[UserInfo shareInstance]._id)
    {//我的收藏
    }
    else
    {
        [menuItems addObject:[ChatMenu menuWithTitle:@"收藏".lv_localized icon:@"menu_fov" action:@selector(favorMessage:)]];
    }
    //多选
    [menuItems addObject:[ChatMenu menuWithTitle:@"多选".lv_localized icon:@"menu_multi_sel" action:@selector(gotoMultiSelectingMode:)]];
    if (self.chatRecordDTO.messageType == MessageType_Text) {
        [menuItems addObject:[ChatMenu menuWithTitle:@"翻译".lv_localized icon:@"translation" action:@selector(textTranslate:)]];
    }
//    if (self.chatRecordDTO.messageType == MessageType_Audio) {
//        [menuItems addObject:[ChatMenu menuWithTitle:@"转文字".lv_localized icon:@"Turn_text" action:@selector(voiceTransfer:)]];
//    }
//    if (self.chatRecordDTO.messageType == MessageType_Voice) {
//        [menuItems addObject:[ChatMenu menuWithTitle:@"转文字".lv_localized icon:@"Turn_text" action:@selector(voiceTransfer:)]];
//    }

    
    
    
    return [menuItems copy];
}

//删除消息
- (void)deleteMessage:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillDeleteMessage:)])
    {
        [self.delegate messageCellWillDeleteMessage:self];
    }
}

//撤回消息
- (void)revokeMessage:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillRevokeMessage:)])
    {
        [self.delegate messageCellWillRevokeMessage:self];
    }
}

- (void)voiceTransfer:(id)sender{
    if ([self.delegate respondsToSelector:@selector(messageCellWillTransferMessage:)])
    {
        [self.delegate messageCellWillTransferMessage:self];
    }
}

- (void)textTranslate:(id)sender{
    if ([self.delegate respondsToSelector:@selector(messageCellWillTranslateMessage:)])
    {
        [self.delegate messageCellWillTranslateMessage:self];
    }
}

//转发消息
- (void)forwardMessage:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillForwardMessage:)])
    {
        [self.delegate messageCellWillForwardMessage:self];
    }
}

//引用消息
- (void)quoteMessage:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillQuoteMessage:)])
    {
        [self.delegate messageCellWillQuoteMessage:self];
    }
}

//收藏消息
- (void)favorMessage:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillFavorMessage:)])
    {
        [self.delegate messageCellWillFavorMessage:self];
    }
}

//进入多选模式
- (void)gotoMultiSelectingMode:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillGotoMultiSelectingMode:)])
    {
        [self.delegate messageCellWillGotoMultiSelectingMode:self];
    }
}

//设置自定义剪贴板
- (void)copyMessage:(id)sender
{
    [IMMessagePasteboard messagePasteboard].chatRecordDTO = [self.chatRecordDTO copy];
}

- (void)singleTap:(UITapGestureRecognizer *)singleTapGesture
{
    if (singleTapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [singleTapGesture locationInView:self.contentBaseView];
        BOOL effectiveGesture = CGRectContainsPoint(self.avatarImageView.frame, point);
        if (effectiveGesture)
        {
            if (self.chatRecordDTO.is_outgoing)
            {
                //自己的头像
                if ([self.delegate respondsToSelector:@selector(messageCellMyHeadPhotoWasTapped:)])
                {
                    [self.delegate messageCellMyHeadPhotoWasTapped:self];
                }
            }
            else
            {
                //别人的头像
                if ([self.delegate respondsToSelector:@selector(messageCell:someoneHeadPhotoWasTapped:)])
                {
                    [self.delegate messageCell:self someoneHeadPhotoWasTapped:self.chatRecordDTO.sender.user_id];
                }
            }
        }
    }
    [super singleTap:singleTapGesture];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture
{
    if (longPressGesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [longPressGesture locationInView:self.bubbleImageView.superview];
        BOOL effectiveGesture = CGRectContainsPoint(self.bubbleImageView.frame, point);
        if (effectiveGesture)
        {
            //显示菜单
            NSArray *menuItems = [self menuItems];
            if (menuItems && menuItems.count>0)
            {
                [self becomeFirstResponder];
                
                NSMutableArray *titles = [NSMutableArray array];
                NSMutableArray *icons = [NSMutableArray array];
                for(ChatMenu *menu in menuItems)
                {
                    [titles addObject:menu.title];
                    [icons addObject:menu.icon];
                }
                
                [UserInfo shareInstance].chatPopupMenuList = menuItems;
                CGPoint pt = [longPressGesture locationInView:longPressGesture.view];
                CGPoint ptOnScreen = [longPressGesture.view convertPoint:pt toView:nil];
                ptOnScreen = CGPointMake(ptOnScreen.x, ptOnScreen.y+8);
                
                _reactionEmojiView = nil;
                if (self.chatRecordDTO.canShowLongPressReactionEmojiView) {
                    _reactionEmojiView = [[MessageReactionEmojiView alloc] initWithMessage:self.chatRecordDTO];
                    @weakify(self);
                    _reactionEmojiView.selectedBlock = ^{
                        @strongify(self);
                        [self.longPressPopup dismiss];
                    };
                }
                _longPressPopup = [YBPopupMenu showAtPoint:ptOnScreen titles:titles icons:icons menuWidth:120 customView:_reactionEmojiView otherSettings:^(YBPopupMenu *popupMenu) {
                    popupMenu.dismissOnSelected = YES;
                    popupMenu.isShowShadow = NO;
                    popupMenu.delegate = self;
                    popupMenu.offset = 2;
                    popupMenu.type = YBPopupMenuTypeDefault;
                    popupMenu.maxVisibleCount = 8;
                    popupMenu.rectCorner = UIRectCornerAllCorners;
                    popupMenu.tableView.separatorColor = [UIColor clearColor];
                    popupMenu.arrowHeight = 0;
                    popupMenu.font = fontRegular(13);
                    popupMenu.textColor = [UIColor colorTextFor878D9A];
                }];
               
            }
        }
        else if (self.delegate.isGroupChat && !self.chatRecordDTO.is_outgoing)
        {
            if([self.delegate canManageSomeone:self])
            {
                effectiveGesture = CGRectContainsPoint(self.avatarImageView.frame, point);
                if (effectiveGesture)
                {
                    NSMutableArray *menuItems = [NSMutableArray array];
                    [menuItems addObject:[ChatMenu menuWithTitle:@"@他/她".lv_localized icon:@"menu_at" action:@selector(atSomeone:)]];
                    [menuItems addObject:[ChatMenu menuWithTitle:@"禁言此人".lv_localized icon:@"menu_ban" action:@selector(banSomeone:)]];
                    //[menuItems addObject:[ChatMenu menuWithTitle:@"删除消息" icon:@"menu_delete" action:@selector(delOneHisSomeone:)]];
                    [menuItems addObject:[ChatMenu menuWithTitle:@"删除此人所有消息".lv_localized icon:@"menu_delete" action:@selector(delAllHisSomeone:)]];

                    //显示菜单
                    [self becomeFirstResponder];
                    NSMutableArray *titles = [NSMutableArray array];
                    NSMutableArray *icons = [NSMutableArray array];
                    for(ChatMenu *menu in menuItems)
                    {
                        [titles addObject:menu.title];
                        [icons addObject:menu.icon];
                    }
                    [UserInfo shareInstance].chatPopupMenuList = menuItems;
                    [YBPopupMenu showRelyOnView:self.avatarImageView titles:titles icons:icons menuWidth:200 otherSettings:^(YBPopupMenu *popupMenu) {
                        popupMenu.dismissOnSelected = YES;
                        popupMenu.isShowShadow = YES;
                        popupMenu.delegate = self;
                        popupMenu.offset = 2;
                        popupMenu.type = YBPopupMenuTypeDefault;
                        popupMenu.rectCorner = UIRectCornerAllCorners;
                        popupMenu.tableView.separatorColor = COLOR_SP;
                    }];
                }
            }
            else
            {
                effectiveGesture = CGRectContainsPoint(self.avatarImageView.frame, point);
                if (effectiveGesture)
                {
                    //@某人
                    if ([self.delegate respondsToSelector:@selector(messageCell:shouldAtSomeone:)])
                    {
                        [self.delegate messageCell:self shouldAtSomeone:self.chatRecordDTO.sender.user_id];
                    }
                }
            }
        }
    }
    [super longPress:longPressGesture];
}

- (void)atSomeone:(id)sender
{
    //@某人
    if ([self.delegate respondsToSelector:@selector(messageCell:shouldAtSomeone:)])
    {
        [self.delegate messageCell:self shouldAtSomeone:self.chatRecordDTO.sender.user_id];
    }
}

- (void)banSomeone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillBan:)])
    {
        [self.delegate messageCellWillBan:self];
    }
}

- (void)delOneHisSomeone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillDelOneHis:)])
    {
        [self.delegate messageCellWillDelOneHis:self];
    }
}

- (void)delAllHisSomeone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(messageCellWillDelAllHis:)])
    {
        [self.delegate messageCellWillDelAllHis:self];
    }
}

- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index
{
    if(index>=0 && index<[UserInfo shareInstance].chatPopupMenuList.count)
    {
        ChatMenu *menu = [[UserInfo shareInstance].chatPopupMenuList objectAtIndex:index];
        if (menu.action && [ybPopupMenu.delegate respondsToSelector:menu.action])
        {
            IMP imp = [self methodForSelector:menu.action];
            void (*func)(id, SEL) = (void *)imp;
            func(self, menu.action);
        }
    }
    [UserInfo shareInstance].chatPopupMenuList = nil;
}

//使用该方法不会模糊，根据屏幕密度计算
- (UIImage *)convertViewToImage:(UIView *)view {
    
    UIImage *imageRet = [[UIImage alloc]init];
    //UIGraphicsBeginImageContextWithOptions(区域大小, 是否是非透明的, 屏幕密度);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageRet;
    
}

#pragma mark - getter
- (MessageADButtonsView *)adButtonsView {
    if (!_adButtonsView) {
        _adButtonsView = [[MessageADButtonsView alloc] init];
        _adButtonsView.cellBgColor = self.chatRecordDTO.is_outgoing ? UIColor.colorBubbleMe : UIColor.colorBubbleOther;
    }
    return _adButtonsView;
}

- (MessageReactionBottomView *)reactionBottomView {
    if (!_reactionBottomView) {
        _reactionBottomView = [[MessageReactionBottomView alloc] init];
        _reactionBottomView.reactions = self.chatRecordDTO.reactions;
    }
    return _reactionBottomView;
}

- (CoreTextView *)captionTextView {
    if (!_captionTextView) {
        _captionTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 0, self.bubbleImageView.frame.size.width, 0)];
        _captionTextView.analyzeType = AnalyzeTypeURL|AnalyzeTypeEmail|AnalyzeTypePhoneNumber|AnalyzeTypeSomeone;
        _captionTextView.text = self.chatRecordDTO.content.caption[@"text"];
        [_captionTextView startAnalyze];
        [_captionTextView adjustFrame];
        _captionTextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    }
    return _captionTextView;
}

- (NSString *)groupNickname {
    if (self.groupMembers.count == 0) {
        return nil;
    }
    long uid = self.chatRecordDTO.sender.user_id;
    for (GroupMemberInfo *m in self.groupMembers) {
        if (m.user_id == uid && [NSString xhq_notEmpty:m.nickname]) {
            return m.nickname;
        }
    }
    return nil;
}

@end

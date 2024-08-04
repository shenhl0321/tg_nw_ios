//
//  MNMsgCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/29.
//

#import "MNMsgCell.h"
#import "TF_RequestManager.h"
@interface MNMsgCell ()

@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic, strong) MessageInfo *msgInfo;

@end

@implementation MNMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - 业务数据处理
- (void)resetChatInfo:(ChatInfo *)info
{
    self.chatInfo = info;

    [MNChatUtil headerImgV:self.headerImageView chat:info size:CGSizeMake(52, 52)];
    self.titleLabel.text = [MNChatUtil titleFromChat:info];
    self.contentLabel.attributedText = [MNChatUtil contentFromChat:info];
    
    if (!self.chatInfo.lastMessage.date) {
        self.timeLabel.hidden = YES;
    } else {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = [Common getFullMessageTime:self.chatInfo.lastMessage.date showDetail:YES];
    }
//    if (info.isSecretChat && [info.secretChatInfo.state isEqualToString:@"secretChatStateReady"] && !info.lastMessage) {
//
//        self.timeLabel.text = [Common getFullMessageTime:self.chatInfo.lastMessage.date showDetail:YES];
//    }
    if (info.isSecretChat) {
        self.titleLabel.textColor = [UIColor colorTextFor0DBFC0];
        self.secretIcon.hidden = NO;
        self.contentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@"******"];
    } else {
        self.secretIcon.hidden = YES;
        self.titleLabel.textColor = [UIColor colorTextFor878D9A];
    }
    if(self.chatInfo.lastMessage != nil)
    {
        if(self.chatInfo.lastMessage.sendState == MessageSendState_Success)
        {
            self.ayIndicatorView.hidden = YES;
            self.failImageView.hidden = YES;
            
            //继续处理。然后消息发送成功的情况下要分消息是否被读了
            if ( self.chatInfo.lastMessage.canShowReadFlag)
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
            }else{
                self.readImageView.hidden = YES;
            }
        }else{
            self.readImageView.hidden = YES;
            if(self.chatInfo.lastMessage.sendState == MessageSendState_Fail)
            {
                self.ayIndicatorView.hidden = YES;
                self.failImageView.hidden = NO;
               
            }
            else//发送中的状态吧
            {
                self.ayIndicatorView.hidden = NO;
                self.failImageView.hidden = YES;
            }
        }
    }
    else
    {
        self.ayIndicatorView.hidden = YES;
        self.failImageView.hidden = YES;
        self.readImageView.hidden = YES;
    }
    
    [self resetChatBadge];
    [self refreshButtonsState];
    
    //icon mute
    if(self.chatInfo.default_disable_notification)
    {
        self.muteImageView.hidden = NO;
        if(!self.readImageView.hidden)
        {
            [self.muteImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.readImageView.mas_left).with.offset(-7);
            }];
        }
        else if(!self.ayIndicatorView.hidden)
        {
            [self.muteImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.ayIndicatorView.mas_left).with.offset(-7);
            }];
        
        }
        else if(!self.failImageView.hidden)
        {
            [self.muteImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.failImageView.mas_left).with.offset(-7);
            }];
            
        }
        else
        {
            [self.muteImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
            }];
        }
    }
    else
    {
        self.muteImageView.hidden = YES;
    }

    if(self.chatInfo.is_pinned)
    {//置顶
        self.contentView.backgroundColor = [UIColor colorForF5F9FA];
    }
    else
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
   
}

- (void)refreshButtonsState{
    if (self.chatInfo.default_disable_notification) {
        [self refreshBtn:self.notiBtn title:@"打开通知".lv_localized imageName:@"MsgNoti"];
    }else{
        [self refreshBtn:self.notiBtn title:@"免打扰".lv_localized imageName:@"MsgNotiCancel"];
    }
    
    if(self.chatInfo.is_pinned){
        [self refreshBtn:self.topBtn title:@"取消置顶".lv_localized imageName:@"MsgTopCancel"];
    }else{
        [self refreshBtn:self.topBtn title:@"置顶".lv_localized imageName:@"MsgTop"];
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
    }
    else if(self.chatInfo.unread_count<10)
    {
        self.badgeLabel.hidden = NO;
        [self.badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(18);
        }];
        self.badgeLabel.text = [NSString stringWithFormat:@"%d", self.chatInfo.unread_count];

    }
    else if(self.chatInfo.unread_count<=99)
    {
        self.badgeLabel.hidden = NO;
//        self.badgeWidth.constant = 26;
        [self.badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(26);
        }];
        self.badgeLabel.text = [NSString stringWithFormat:@"%d", self.chatInfo.unread_count];
    }
    else
    {
        self.badgeLabel.hidden = NO;
        [self.badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(32);
        }];
        self.badgeLabel.text = @"99+";
    }
    
   
}

- (void)initUI{
    [super initUI];
    [self addRightSwipe];
}

- (void)initSubUI{
    [self.contentView addSubview:self.headerImageView];
    [self.contentView addSubview:self.backView];
    [self.contentView addSubview:self.badgeLabel];
    [self.backView addSubview:self.titleLabel];
    [self.backView addSubview:self.timeLabel];
    [self.backView addSubview:self.contentLabel];
    [self.backView addSubview:self.ayIndicatorView];
    [self.backView addSubview:self.failImageView];
    [self.backView addSubview:self.readImageView];
    [self.backView addSubview:self.muteImageView];
    [self.backView addSubview:self.secretIcon];
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                forAxis:UILayoutConstraintAxisHorizontal];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(52, 52));
        make.left.mas_equalTo(left_margin());
        make.centerY.mas_equalTo(0);
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImageView.mas_right).with.offset(12);
        make.right.mas_equalTo(-left_margin());
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(52);
    }];
   
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(3);
//        make.right.mas_equalTo(-145);
        make.height.mas_equalTo(23);
    }];
    
    [self.secretIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(5);
        make.centerY.mas_equalTo(self.titleLabel);
        make.width.height.mas_equalTo(15);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
//        make.width.mas_equalTo(140);
        make.left.equalTo(self.titleLabel.mas_right).with.offset(25).priorityLow();
        make.centerY.equalTo(self.titleLabel);
        
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-32-5-20);
        make.bottom.mas_equalTo(-4);
        make.height.mas_equalTo(21);
    }];
    [self.readImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(14);
        make.centerY.equalTo(self.contentLabel);
    }];
    //这个是动态的。
    [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentLabel);
        make.right.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImageView.mas_right).with.offset(-17);
        make.height.mas_equalTo(17);
        make.width.mas_equalTo(17);
        make.top.equalTo(self.headerImageView);
    }];
    
    [self.ayIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.equalTo(self.contentLabel);
    }];
    
    [self.failImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.equalTo(self.contentLabel);
      
    }];
}
#pragma mark - UI定制
-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] init];
    }
    return _backView;
}

-(UIImageView *)headerImageView{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
//        _headerImageView.layer.cornerRadius = 26;
//
//        _headerImageView.layer.borderColor = HexRGB(0xE5EAF0).CGColor;
//        _headerImageView.layer.borderWidth = 1;
//        _headerImageView.layer.maskedCorners = YES;
        [_headerImageView mn_iconStyle];
    }
    return _headerImageView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontSemiBold(16);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _titleLabel;
}


- (void)refreshTitleSystem:(BOOL)system{
    if (system) {
        self.titleLabel.textColor = [UIColor colorTextFor188CFF];
    }else{
        self.titleLabel.textColor = [UIColor colorTextFor23272A];
    }
}
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = fontRegular(13);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor colorFor878D9A];
    }
    return _timeLabel;
}

-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = fontRegular(15);
        _contentLabel.textColor = [UIColor colorTextFor878D9A];
        _contentLabel.text = @"aaaaa";
        _contentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@"bbbbbbb"];
    }
    return _contentLabel;
}

-(UILabel *)badgeLabel{
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = [UIColor colorforFD4E57];
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.layer.cornerRadius = 8.5;
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.textColor = [UIColor colorTextForFFFFFF];
        _badgeLabel.font = fontRegular(12)
        ;    }
    return _badgeLabel;
}

-(UILabel *)ayIndicatorView{
    if (!_ayIndicatorView) {
        _ayIndicatorView = [[UILabel alloc] init];
        _ayIndicatorView.font = fontRegular(13);
        _ayIndicatorView.textColor = [UIColor colorTextFor878D9A];
        _ayIndicatorView.textAlignment = NSTextAlignmentRight;
        _ayIndicatorView.text = LocalString(localSending);
    }
    return _ayIndicatorView;
}

-(UILabel *)failImageView{
    if (!_failImageView) {
        _failImageView = [[UILabel alloc] init];
        _failImageView.font = fontRegular(13);
        _failImageView.textColor = [UIColor colorTextForFD4E57];
        _failImageView.textAlignment = NSTextAlignmentRight;
        _failImageView.text = LocalString(localSendFailed);
    }
    return _failImageView;
}

-(UIImageView *)muteImageView{
    if (!_muteImageView) {
        _muteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MsgMute"]];
    }
    return _muteImageView;
}

-(UIImageView *)readImageView{
    if (!_readImageView) {
        _readImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_msg_read_cb"]];
    }
    return _readImageView;
}

- (UIImageView *)secretIcon{
    if (!_secretIcon) {
        _secretIcon = [[UIImageView alloc] init];
        NSString *imgN = [NSString stringWithFormat:@"private_lock_%ld", MNThemeMgr().themeStyle];
        _secretIcon.image = [UIImage imageNamed:imgN];
        _secretIcon.hidden = YES;
    }
    return _secretIcon;
}

#pragma mark -左滑的4个底部按钮
- (void)addRightSwipe{
   
    self.rightButtons = @[self.deleteBtn,self.notiBtn,self.topBtn];
}

-(MGSwipeButton *)deleteBtn{
    if (!_deleteBtn) {
        MGSwipeButton *btn = [self createBtnWithTitle:LocalString(localDelete) imageName:@"MsgDelete"];
        btn.backgroundColor = [UIColor colorforFD4E57];
        _deleteBtn = btn;
        WS(weakSelf)
        [btn setCallback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            [weakSelf toggleChatDeleteConfirm:weakSelf.chatInfo];
            return YES;
        }];
    }
    return _deleteBtn;
}

-(MGSwipeButton *)topBtn{
    if (!_topBtn) {
        MGSwipeButton *btn = [self createBtnWithTitle:LocalString(localTop) imageName:@"MsgTop"];
        btn.backgroundColor = [UIColor colorFor878D9A];
        _topBtn = btn;
        WS(weakSelf)
        [btn setCallback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            [weakSelf toggleChatPinned:weakSelf.chatInfo];
            return YES;
        }];
    }
    return _topBtn;
}

-(MGSwipeButton *)notiBtn{
    if (!_notiBtn) {
        MGSwipeButton *btn = [self createBtnWithTitle:LocalString(localOpenNoti) imageName:@"MsgNoti"];
        btn.backgroundColor = [UIColor colorforABACAD];
        _notiBtn = btn;
        WS(weakSelf)
        [btn setCallback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            [weakSelf toggleChatNotification:self.chatInfo];
            return YES;
        }];
    }
    return _notiBtn;
}

-(MGSwipeButton *)archiveBtn{
    if (!_archiveBtn) {
        MGSwipeButton *btn = [self createBtnWithTitle:LocalString(localArchive) imageName:@"MsgArchive"];
        btn.backgroundColor = [UIColor colorMain];
        _archiveBtn = btn;
    }
    return _archiveBtn;
}

- (MGSwipeButton *)createBtnWithTitle:(NSString *)title imageName:(NSString *)imageName {
    MGSwipeButton *btn = [MGSwipeButton buttonWithTitle:title backgroundColor:HexRGB(0xFD4E57)];
    [btn setTitleColor:[UIColor colorTextForFFFFFF] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(touchUpBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = fontRegular(12);
    btn.frame = CGRectMake(0, 0, 55, 70);
    [self refreshBtn:btn title:title imageName:imageName];
    
    return btn;
}

- (void)refreshBtn:(UIButton *)btn title:(NSString *)title imageName:(NSString *)imageName{
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImagePosition:LXMImagePositionTop spacing:5];
}


//- (void)touchUpBtn:(MGSwipeButton *)btn{
//    if (btn == self.notiBtn) {
//        [self toggleChatNotification:self.chatInfo];
//    }else if (btn == self.topBtn){
//        [self toggleChatPinned:self.chatInfo];
//    }else if (btn == self.deleteBtn){
//        [self toggleChatDeleteConfirm:self.chatInfo];
//    }
//}


- (void)toggleChatNotification:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatDisableNotification:chat._id isDisableNotification:!chat.default_disable_notification  resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatPinned:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatIsPinned:chat._id isPinned:!chat.is_pinned resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatDeleteConfirm:(ChatInfo *)chat
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定删除吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//删除
            [self toggleChatDelete:chat];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)toggleChatDelete:(ChatInfo *)chat
{
    if (chat.isSecretChat) {
        [UserInfo show];
        // 先关闭私密聊天
        MJWeakSelf
        [TF_RequestManager closeSecretChatWithId:chat.type.secret_chat_id resultBlock:^(NSDictionary *request, NSDictionary *response) {
            
            if([TelegramManager isResultError:response])
            {
                [UserInfo dismiss];
                [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            } else { // 成功后删除回话
                weakSelf.chatInfo.type.type = @"chatTypePrivate";
                [[TelegramManager shareInstance] deleteChatHistory:chat._id isDeleteChat:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    [UserInfo dismiss];
                    if([TelegramManager isResultError:response])
                    {
                        [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                    }
                } timeout:^(NSDictionary *request) {
                    [UserInfo dismiss];
                    [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized];
                }];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized];
        }];
        return;
    }
    
    [chat getSuperGroupInfo:^(SuperGroupInfo *info) {
        if (!info || ![NSString xhq_notEmpty:info.username]) {
            [UserInfo show];
            [[TelegramManager shareInstance] deleteChatHistory:chat._id isDeleteChat:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if ([TelegramManager isResultError:response]) {
                    [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                }
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized];
            }];
            return;
        }
        
        [[TelegramManager shareInstance] leaveGroup:chat._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"删除会话失败，请稍后重试" errorMsg:[TelegramManager errorMsg:response]];
            } else {
                [TelegramManager.shareInstance deleteChat:chat._id];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized];
        }];
    }];
    
    
}

@end

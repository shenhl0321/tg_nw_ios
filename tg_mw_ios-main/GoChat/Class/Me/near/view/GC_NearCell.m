//
//  GC_NearCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/16.
//

#import "GC_NearCell.h"
#import "TF_RequestManager.H"

@implementation NearGroupChatInfo

- (NSInteger)onlineNum{
    if (!_onlineNum || _onlineNum == 0) {
        NSInteger onlineNumber = 0;
        for (GroupMemberInfo *iteminfo in self.membersList) {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:iteminfo.user_id];
            if(user != nil)
            {
                NSString *onlineStyle = [user.status objectForKey:@"@type"];
               if ([onlineStyle isEqualToString:@"userStatusOnline"]){
                    onlineNumber++;
                }else if ([onlineStyle isEqualToString:@"userStatusRecently"]){
                    onlineNumber++;
                }
            }
        }
        _onlineNum = onlineNumber;
    }
    return _onlineNum;
}
@end

@implementation GC_NearCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:14];
    // Initialization code
    [self setFollowStatus:NO];
    self.addBtn.hidden = YES;
    [self.addBtn addTarget:self action:@selector(joinClick:) forControlEvents:UIControlEventTouchUpInside];
    self.headerImageV.clipsToBounds = YES;
    self.headerImageV.layer.cornerRadius = 26;
}
- (void)joinClick:(UIButton *)btn{
    MJWeakSelf
    if (self.chat.isSelfInChat) {
        [AppDelegate gotoChatView:self.chat.chatInfo];
    } else {
        [TF_RequestManager joinChatWithId:self.chat.chatInfo._id result:^(NSDictionary *request, NSDictionary *response) {
            if(![TelegramManager isResultError:response])
            {
                weakSelf.chat.selfInChat = YES;
                [weakSelf changeBtnTitle];
                [[TelegramManager shareInstance] localAddChat:weakSelf.chat.chatInfo];
                
                [TF_RequestManager getLastChatMsg:weakSelf.chat.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response, MessageInfo *obj) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.chat.chatInfo.lastMessage = obj;
                        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Last_Message_Changed) withInParam:weakSelf.chat.chatInfo];
                    });
                } timeout:^(NSDictionary *request) {
                    
                }];
            }
        } timeout:nil];
    }

}

- (void)setFollowStatus:(BOOL)isSelect{
    if (isSelect) {
        [self.addBtn setTitle:@"进入".lv_localized forState:UIControlStateNormal];
        [self.addBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
        [self.addBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.addBtn.backgroundColor = [UIColor colorForF5F9FA];
        self.addBtn .layer.borderWidth = 0;
        self.addBtn .layer.cornerRadius = 8;
    }else{
        [self.addBtn setTitle:@"加入".lv_localized forState:UIControlStateNormal];
        [self.addBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        self.addBtn .layer.borderWidth = 1;
        self.addBtn .layer.borderColor = [UIColor colorMain].CGColor;
        self.addBtn .layer.backgroundColor = [UIColor colorMain].CGColor;
        self.addBtn .layer.cornerRadius = 8;
        self.addBtn.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setUserInfo:(ChatNearby *)userInfo{
    _userInfo = userInfo;
   
//    self.userSexV.hidden = NO;
    self.addBtn.hidden = YES;
    self.locationImageV.hidden = NO;
    self.sexImageV.hidden = NO;
    self.addressLab.text = [NSString stringWithFormat:@"%ld米".lv_localized, userInfo.distance];
//    NSString *url = [userInfo.user.profile_photo localSmallPath];
//    [self.iconV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"image_default_1"]];
    self.titleLab.text = userInfo.user.displayName;

    [self setIconUI];
}

- (void)setIconUI{

    [self.headerImageV setClipsToBounds:YES];
    [self.headerImageV setContentMode:UIViewContentModeScaleAspectFill];
    if(self.userInfo.user.profile_photo != nil)
    {
        if(!self.userInfo.user.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", self.userInfo.user._id] fileId:self.userInfo.user.profile_photo.fileSmallId type:FileType_Photo];
            //本地头像
            self.headerImageV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.userInfo.user.displayName.length>0)
            {
                text = [[self.userInfo.user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(52, 52) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.headerImageV];
            self.headerImageV.image = [UIImage imageWithContentsOfFile:self.userInfo.user.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.headerImageV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.userInfo.user.displayName.length>0)
        {
            text = [[self.userInfo.user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headerImageV withSize:CGSizeMake(52, 52) withChar:text];
    }
}

- (void)setChat:(NearGroupChatInfo *)chat{
    _chat = chat;

    ChatInfo *chatInfo = chat.chatInfo;
//    [self updateUI];
    self.sexImageV.hidden = YES;
    self.locationImageV.hidden = YES;
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.left.mas_equalTo(self.headerImageV.mas_right).offset(12);
    }];
    [self.addressLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-14);
        make.left.mas_equalTo(self.headerImageV.mas_right).offset(12);
    }];
    self.addBtn.hidden = NO;
    /// 头像
    [MNChatUtil headerImgV:self.headerImageV chat:chatInfo size:CGSizeMake(52, 52)];

    self.titleLab.text = chatInfo.title;
    if (chat.totalNum > 0) {
        self.addressLab.text = [NSString stringWithFormat:@"%ld名成员，%ld人在线".lv_localized, chat.totalNum, chat.onlineNum];
    } else {
        self.addressLab.text = [NSString stringWithFormat:@"%ld名成员，%ld人在线".lv_localized, chat.membersList.count, chat.onlineNum];
    }

    [self changeBtnTitle];
}


- (void)changeBtnTitle{
    if (self.chat.isSelfInChat) {
        [self setFollowStatus:YES];
    } else {
        [self setFollowStatus:NO];
    }

}


@end

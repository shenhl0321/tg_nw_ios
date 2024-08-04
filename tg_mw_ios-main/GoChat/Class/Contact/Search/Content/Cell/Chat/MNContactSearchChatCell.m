//
//  MNContactSearchChatCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNContactSearchChatCell.h"

@interface MNContactSearchChatCell ()
@property (nonatomic, strong) MessageInfo *msgInfo;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation MNContactSearchChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
                self.iconImagV.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(chat.title.length>0)
                {
                    text = [[chat.title uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.iconImagV withSize:CGSizeMake(47, 47) withChar:text];
            }
            else
            {
                [UserInfo cleanColorBackgroundWithView:self.iconImagV];
                self.iconImagV.image = [UIImage imageWithContentsOfFile:chat.photo.localSmallPath];
            }
        }
        else
        {
            //本地头像
            self.iconImagV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(chat.title.length>0)
            {
                text = [[chat.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImagV withSize:CGSizeMake(47, 47) withChar:text];
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
                    self.iconImagV.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:self.iconImagV withSize:CGSizeMake(47, 47) withChar:text];
                }
                else
                {
                    [UserInfo cleanColorBackgroundWithView:self.iconImagV];
                    self.iconImagV.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }
            else
            {
                //本地头像
                self.iconImagV.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.iconImagV withSize:CGSizeMake(47, 47) withChar:text];
            }
            self.titleLabel.text = user.displayName;
        }
        else
        {
            //本地头像
            self.iconImagV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(chat.title.length>0)
            {
                text = [[chat.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImagV withSize:CGSizeMake(47, 47) withChar:text];
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


-(void)initUI{
    [super initUI];
    [self.contentView addSubview:self.iconImagV];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
    self.contentView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height);
    [self.iconImagV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(47, 47));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImagV.mas_right).with.offset(12);
        make.right.mas_equalTo(-left_margin());
        make.height.mas_equalTo(23);
        make.top.equalTo(self.iconImagV);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.iconImagV.mas_bottom).with.offset(-1);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.height.mas_equalTo(20);
    }];
}
-(UIImageView *)iconImagV{
    if (!_iconImagV) {
        _iconImagV = [[UIImageView alloc] init];
        [_iconImagV mn_iconStyleWithRadius:23.5];
    }
    return _iconImagV;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontSemiBold(16);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _titleLabel;
}

-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = fontRegular(14);
        _contentLabel.textColor = [UIColor colorFor878D9A];
    }
    return _contentLabel;
}
@end

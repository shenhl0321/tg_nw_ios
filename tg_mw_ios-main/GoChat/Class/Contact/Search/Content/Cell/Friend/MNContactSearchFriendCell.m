//
//  MNContactSearchFriendCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNContactSearchFriendCell.h"

@interface MNContactSearchFriendCell ()
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) ChatInfo *chatInfo;
@end
@implementation MNContactSearchFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)resetUserInfo:(UserInfo *)user
{
    self.userInfo = user;
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

- (void)resetGroupInfo:(ChatInfo *)chat
{
    self.chatInfo = chat;
    self.titleLabel.text = self.chatInfo.title;
    if(self.chatInfo.photo != nil)
    {
        if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            self.iconImagV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0)
            {
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImagV withSize:CGSizeMake(42, 42) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.iconImagV];
            self.iconImagV.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.iconImagV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.chatInfo.title.length>0)
        {
            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.iconImagV withSize:CGSizeMake(42, 42) withChar:text];
    }
}


- (void)resetChatInfo:(id)chat
{
    if ([chat isKindOfClass:[ChatInfo class]]) {
        self.chatInfo = chat;
        self.titleLabel.text = [MNChatUtil titleFromChat:self.chatInfo];
        [MNChatUtil headerImgV:self.iconImagV chat:self.chatInfo size:CGSizeMake(52, 52)];
        //TelegramManager
       
    }else if([chat isKindOfClass:[UserInfo class]]){
        UserInfo *user = chat;
        [self resetUserInfo:user];
    }
    
}

-(void)initUI{
    [super initUI];
    [self.contentView addSubview:self.iconImagV];
    [self.contentView addSubview:self.titleLabel];
   
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
        make.centerY.equalTo(self.iconImagV);
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

@end

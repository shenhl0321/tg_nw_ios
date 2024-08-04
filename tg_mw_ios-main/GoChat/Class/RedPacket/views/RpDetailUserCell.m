//
//  RpDetailUserCell.m
//  GoChat
//
//  Created by wangyutao on 2021/4/9.
//

#import "RpDetailUserCell.h"

@implementation RpDetailUserCell

- (void)awakeFromNib
{
    [super awakeFromNib];
//    [self.headerImageView setClipsToBounds:YES];
//    [self.headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.headerImageView mn_iconStyleWithRadius:26];
    self.nameLabel.font = fontSemiBold(16);
    self.nameLabel.textColor = [UIColor colorTextFor23272A];
    self.timeLabel.font = fontRegular(15);
    self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
    self.priceLabel.font = fontSemiBold(16);
    
}

- (void)resetUserInfo:(RedPacketPickUser *)gotUser isBest:(BOOL)isBest
{
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:gotUser.userId];
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
                [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(52, 52) withChar:text];
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
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(52, 52) withChar:text];
        }
        self.nameLabel.text = user.displayName;
    }
    else
    {
        self.nameLabel.text = [NSString stringWithFormat:@"u%ld", gotUser.userId];
        //本地头像
        self.headerImageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.nameLabel.text.length>0)
        {
            text = [[self.nameLabel.text uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(52, 52) withChar:text];
    }
    self.timeLabel.text = [Common getFullMessageTime:gotUser.gotAt showDetail:YES];
    self.priceLabel.text = [NSString stringWithFormat:@"%@元".lv_localized, [Common priceFormat:gotUser.price]];
    self.bestView.hidden = !isBest;
}

@end

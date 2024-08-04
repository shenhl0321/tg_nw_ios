//
//  ChatItemCell.m
//  GoChat
//
//  Created by wangyutao on 2020/12/17.
//

#import "ChatItemCell.h"

@interface ChatItemCell ()
@property (nonatomic, strong) ChatInfo *chatInfo;
@end

@implementation ChatItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.headerImageView setClipsToBounds:YES];
    [self.headerImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)resetChatInfo:(id)chat
{
    if ([chat isKindOfClass:[ChatInfo class]]) {
        self.chatInfo = chat;
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
    }else if([chat isKindOfClass:[UserInfo class]]){
        UserInfo *user = chat;
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
    
}

@end


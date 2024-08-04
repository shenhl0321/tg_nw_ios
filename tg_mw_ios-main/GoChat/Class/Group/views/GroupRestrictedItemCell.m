//
//  GroupRestrictedItemCell.m
//  GoChat
//
//  Created by wangyutao on 2020/12/17.
//

#import "GroupRestrictedItemCell.h"

@interface GroupRestrictedItemCell ()
@property (nonatomic, strong) UserInfo *userInfo;
@end

@implementation GroupRestrictedItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.headerImageView setClipsToBounds:YES];
    [self.headerImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)resetInfo:(UserInfo *)user
{
    self.userInfo = user;
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
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(42, 42) withChar:text];
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
        [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(42, 42) withChar:text];
    }
    self.titleLabel.text = user.displayName;
}

@end


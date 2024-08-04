//
//  ContactItemCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/24.
//

#import "ContactItemCell.h"

@interface ContactItemCell ()
@property (nonatomic, strong) UserInfo *userInfo;
@end

@implementation ContactItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.headerImageView setClipsToBounds:YES];
    [self.headerImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask
{
    self.userInfo = user;
    if(user.profile_photo != nil)
    {
        if(!user.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId type:FileType_Photo];
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
    
    if(isChoose)
    {
        self.chooseImageView.image = [UIImage imageNamed:@"icon_choose_sel"];
    }
    else
    {
        self.chooseImageView.image = [UIImage imageNamed:@"icon_choose"];
    }
    self.maskView.hidden = !showMask;
}

- (void)resetUserInfo:(UserInfo *)user
{
    self.chooseImageView.hidden = YES;
    [self resetUserInfo:user isChoose:NO showMask:NO];
}

@end

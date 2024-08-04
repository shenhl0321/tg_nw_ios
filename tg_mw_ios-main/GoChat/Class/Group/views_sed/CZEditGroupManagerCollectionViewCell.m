//
//  CZEditGroupManagerCollectionViewCell.m
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import "CZEditGroupManagerCollectionViewCell.h"


@interface CZEditGroupManagerCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@end

@implementation CZEditGroupManagerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat width = (SCREEN_WIDTH - 30 - 20*4)/5;
    [self.userImageView mn_iconStyleWithRadius:width*0.5];
    self.userNameLabel.textColor = [UIColor colorTextFor23272A];
    self.userNameLabel.font = fontRegular(16);
    // Initialization code
}

- (void)resettingUI{
    self.userImageView.image = [UIImage new];
    self.userNameLabel.text = @"";
}

- (void)setInfo:(NSObject *)info{
    [self resettingUI];
    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
    CGSize itemSize = CGSizeMake(cellWidth, cellWidth);
    if (([info isKindOfClass:[GroupMemberInfo class]])) {
        GroupMemberInfo *infoLim = (GroupMemberInfo *)info;
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:infoLim.user_id];
        if(user != nil)
        {
            if(user.profile_photo != nil)
            {
                if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
                {
                    [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                    //本地头像
                    self.userImageView.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:self.userImageView withSize:CGSizeMake(itemSize.width, itemSize.width) withChar:text];
                }
                else
                {
                    [UserInfo cleanColorBackgroundWithView:self.userImageView];
                    self.userImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }
            else
            {
                //本地头像
                self.userImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.userImageView withSize:CGSizeMake(itemSize.width, itemSize.width) withChar:text];
            }
            self.userNameLabel.text = user.displayName;
        }
        else
        {
            self.userNameLabel.text = [NSString stringWithFormat:@"u%ld", infoLim.user_id];
            //本地头像
            self.userImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.userNameLabel.text.length>0)
            {
                text = [[self.userNameLabel.text uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.userImageView withSize:CGSizeMake(itemSize.width, itemSize.width) withChar:text];
        }
    }else if([info isKindOfClass:[NSString class]]){
        if([@"add" isEqualToString:(NSString *)info])
        {
            [UserInfo cleanColorBackgroundWithView:self.userImageView];
            self.userImageView.image = [UIImage imageNamed:@"icon_add"];
            self.userNameLabel.text = @"   ";
        }
        if([@"delete" isEqualToString:(NSString *)info])
        {
            [UserInfo cleanColorBackgroundWithView:self.userImageView];
            self.userImageView.image = [UIImage imageNamed:@"icon_delete"];
            self.userNameLabel.text = @"   ";
        }
    }
}


- (void)settingUI{
    
}

@end

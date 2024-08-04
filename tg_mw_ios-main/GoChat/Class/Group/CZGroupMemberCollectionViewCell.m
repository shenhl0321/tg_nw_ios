//
//  CZGroupMemberCollectionViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/8.
//

#import "CZGroupMemberCollectionViewCell.h"

@interface CZGroupMemberCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation CZGroupMemberCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userNameLabel.textColor = [UIColor colorTextForA9B0BF];
    self.userNameLabel.font = fontRegular(14);
    
    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5 / 2;
    [self.headerImageView mn_iconStyleWithRadius:cellWidth];
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)setCellModel:(NSObject *)cellModel{
    if (cellModel) {
        _cellModel = cellModel;
        if([cellModel isKindOfClass:[GroupMemberInfo class]])
        {
            GroupMemberInfo *info = (GroupMemberInfo *)cellModel;
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.user_id];
            if(user != nil)
            {
                if(user.profile_photo != nil)
                {
                    if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
                    {
                        [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                        //本地头像
                        _headerImageView.image = nil;
                        unichar text = [@" " characterAtIndex:0];
                        if(user.displayName.length>0)
                        {
                            text = [[user.displayName uppercaseString] characterAtIndex:0];
                        }
                        CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                        [UserInfo setColorBackgroundWithView:_headerImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
                    }
                    else
                    {
                        [UserInfo cleanColorBackgroundWithView:_headerImageView];
                        _headerImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                    }
                }
                else
                {
                    //本地头像
                    _headerImageView.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                    [UserInfo setColorBackgroundWithView:_headerImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
                }
                _userNameLabel.text = user.displayName;
                if ([NSString xhq_notEmpty:info.nickname]) {
                    _userNameLabel.text = info.nickname;
                }
            }
            else
            {
                _userNameLabel.text = [NSString stringWithFormat:@"u%ld", info.user_id];
                //本地头像
                _headerImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(_userNameLabel.text.length>0)
                {
                    text = [[_userNameLabel.text uppercaseString] characterAtIndex:0];
                }
                CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                [UserInfo setColorBackgroundWithView:_headerImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
            }
        }
        if([cellModel isKindOfClass:[NSString class]])
        {
            if([@"add" isEqualToString:(NSString *)cellModel])
            {
                [UserInfo cleanColorBackgroundWithView:_headerImageView];
                _headerImageView.image = [UIImage imageNamed:@"icon_add"];
                _userNameLabel.text = @"   ";
            }
            if([@"delete" isEqualToString:(NSString *)cellModel])
            {
                [UserInfo cleanColorBackgroundWithView:_headerImageView];
                _headerImageView.image = [UIImage imageNamed:@"icon_delete"];
                _userNameLabel.text = @"   ";
            }
        }
    }
}

@end

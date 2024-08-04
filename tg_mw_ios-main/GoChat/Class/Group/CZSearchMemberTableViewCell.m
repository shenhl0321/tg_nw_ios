//
//  CZSearchMemberTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/8.
//

#import "CZSearchMemberTableViewCell.h"

@interface  CZSearchMemberTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@end

@implementation CZSearchMemberTableViewCell

- (void)setCellModel:(NSObject *)cellModel{
    _cellModel = cellModel;
    if (cellModel) {
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
                        _headImageView.image = nil;
                        unichar text = [@" " characterAtIndex:0];
                        if(user.displayName.length>0)
                        {
                            text = [[user.displayName uppercaseString] characterAtIndex:0];
                        }
                        CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                        [UserInfo setColorBackgroundWithView:_headImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
                    }
                    else
                    {
                        [UserInfo cleanColorBackgroundWithView:_headImageView];
                        _headImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                    }
                }
                else
                {
                    //本地头像
                    _headImageView.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                    [UserInfo setColorBackgroundWithView:_headImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
                }
                _userNameLabel.text = user.displayName;
            }else{
                _userNameLabel.text = [NSString stringWithFormat:@"u%ld", info.user_id];
                //本地头像
                _headImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(_userNameLabel.text.length>0)
                {
                    text = [[_userNameLabel.text uppercaseString] characterAtIndex:0];
                }
                CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
                [UserInfo setColorBackgroundWithView:_headImageView withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
            }
            _userNameLabel.text = user.displayName;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

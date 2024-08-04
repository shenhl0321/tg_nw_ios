//
//  MNContactFriendCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/2.
//

#import "MNContactFriendCell.h"
#import "UIView+Style.h"

@interface MNContactFriendCell ()
@property (nonatomic, strong) UserInfo *userInfo;
@end
@implementation MNContactFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask
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

- (void)initUI{
    [super initUI];
    [self.contentView addSubview:self.headerImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.stateLabel];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.size.mas_equalTo(CGSizeMake(52, 52));
        make.centerY.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.headerImageView.mas_top).with.offset(3);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.headerImageView.mas_right).with.offset(12);
        make.right.mas_equalTo(left_margin()+20);
    }];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headerImageView.mas_bottom).with.offset(-4);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
    }];
}

-(UIImageView *)headerImageView{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
        [_headerImageView mn_iconStyle];
    }
    return _headerImageView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorTextFor23272A];
        _titleLabel.font = fontRegular(16);
    
    }
    return _titleLabel;
}

-(UILabel *)stateLabel{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = [UIColor colorTextForA9B0BF];
        _stateLabel.font = fontRegular(15);
        _stateLabel.text = @"最近上过线".lv_localized;
        _stateLabel.hidden = YES;
    }
    return _stateLabel;
}

@end

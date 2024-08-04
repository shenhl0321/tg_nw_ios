//
//  MNSubInfoGroupCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoGroupCell.h"

@implementation MNSubInfoGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillDataWithChat:(ChatInfo *)chat{
    self.nameLabel.text = chat.title;
    if(chat.photo != nil)
    {
        if(!chat.photo.isSmallPhotoDownloaded && chat.photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", chat._id] fileId:chat.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            self.iconImgV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(chat.title.length>0)
            {
                text = [[chat.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.iconImgV];
            self.iconImgV.image = [UIImage imageWithContentsOfFile:chat.photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.iconImgV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(chat.title.length>0)
        {
            text = [[chat.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
    }
}

- (void)initUI{
    [super initUI];
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.nameLabel];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(12);
        make.centerY.equalTo(self.iconImgV);
        make.right.mas_equalTo(-left_margin());
    }];
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_default_header"]];
        [_iconImgV mn_iconStyleWithRadius:21];
    }
    return _iconImgV;
}

-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontRegular(16);
        _nameLabel.textColor = [UIColor colorTextFor23272A];
        _nameLabel.text = @"我是测试数据".lv_localized;
    }
    return _nameLabel;
}

@end

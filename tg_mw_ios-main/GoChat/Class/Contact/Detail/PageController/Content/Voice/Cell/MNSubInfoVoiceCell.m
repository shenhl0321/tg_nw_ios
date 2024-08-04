//
//  MNSubInfoVoiceCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoVoiceCell.h"

@implementation MNSubInfoVoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillDataWithMessage:(MessageInfo *)message{
    
    if (message.messageType == MessageType_Audio) {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:message.sender.user_id];
        self.nameLabel.text = user.displayName;
        self.subLabel.text = [NSString stringWithFormat:@"%@ %@",[NSString stringWithFormat:@"%ld\"",lround(message.content.audio.duration)],[Common getMessageDay:message.date]];
    }else if (message.messageType == MessageType_Voice) {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:message.sender.user_id];
        self.nameLabel.text = user.displayName;
        self.subLabel.text = [NSString stringWithFormat:@"%@ %@",[NSString stringWithFormat:@"%ld\"",lround(message.content.voice_note.duration)],[Common getMessageDay:message.date]];
    }else{
        self.nameLabel.text = @"";
        self.subLabel.text = @"";
    }
    
}

- (void)initUI{
    [super initUI];
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.subLabel];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(12);
        make.top.equalTo(self.iconImgV);
        make.right.mas_equalTo(-left_margin());
    }];
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.nameLabel);
        make.bottom.equalTo(self.iconImgV);
    }];
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_voice"]];
    }
    return _iconImgV;
}

-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontRegular(16);
        _nameLabel.textColor = [UIColor colorTextFor23272A];
        _nameLabel.text = @"Aa小精灵@D饼".lv_localized;
    }
    return _nameLabel;
}

-(UILabel *)subLabel{
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = fontRegular(14);
        _subLabel.textColor = [UIColor colorTextForA9B0BF];
        _subLabel.text = @"01:24 2021年7月23日 22:57".lv_localized;
    }
    return _subLabel;
}

@end

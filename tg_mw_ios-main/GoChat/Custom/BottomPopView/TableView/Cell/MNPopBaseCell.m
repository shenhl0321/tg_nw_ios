//
//  MNPopBaseCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNPopBaseCell.h"

@implementation MNPopBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)lineV{
    if (!_lineV){
        _lineV = [[UIView alloc] init];
        _lineV.backgroundColor = HEXCOLOR(0xF0F0F0);
    }
    return _lineV;
}
-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] init];
    }
    return _iconImgV;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

//首页右上角加号弹框 图片和icon
- (void)styleMessageAdd{
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.lineV];
    self.titleLabel.font = fontRegular(14);
    self.titleLabel.textColor = [UIColor colorTextFor000000];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(55);
        make.right.mas_equalTo(5);
        make.centerY.mas_equalTo(0);
    }];
    [self.lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.iconImgV);
        make.right.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView);
        make.height.mas_offset(1);
    }];
}

//聊天页消息编辑的样式
- (void)styleChatEdit{
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.font = fontRegular(13);
    self.titleLabel.textColor = [UIColor colorFor878D9A];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(17, 17));
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(47);
        make.right.mas_equalTo(5);
        make.centerY.mas_equalTo(0);
    }];
}

//群组编辑页 投诉和退出群聊
- (void)styleGroupEdit{
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.font = fontRegular(15);
    self.titleLabel.textColor = [UIColor colorTextFor23272A];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
}

@end

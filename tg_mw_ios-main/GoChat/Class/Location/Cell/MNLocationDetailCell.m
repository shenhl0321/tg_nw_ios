//
//  MNLocationDetailCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNLocationDetailCell.h"

@implementation MNLocationDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initUI{
    [super initUI];
    [self.contentView addSubview:self.lbAddressName];
    [self.contentView addSubview:self.lbAddressDetail];
    [self.contentView addSubview:self.selectedImgV];
    [self.lbAddressName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.right.mas_equalTo(-left_margin()-25);
        make.top.mas_equalTo(15);
        make.height.mas_equalTo(24);
    }];
    [self.lbAddressDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbAddressName.mas_bottom).with.offset(3);
        make.left.equalTo(self.lbAddressName);
        make.right.equalTo(self.lbAddressName);
        make.height.mas_equalTo(20);
    }];
    [self.selectedImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-left_margin());
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(19, 19));
    }];
    
}

-(UILabel *)lbAddressName{
    if (!_lbAddressName) {
        _lbAddressName = [[UILabel alloc] init];
        _lbAddressName.font = fontRegular(17);
        _lbAddressName.textColor = [UIColor colorTextFor23272A];
    }
    return _lbAddressName;
}

-(UILabel *)lbAddressDetail{
    if (!_lbAddressDetail) {
        _lbAddressDetail = [[UILabel alloc] init];
        _lbAddressDetail.font = fontRegular(14);
        _lbAddressDetail.textColor = [UIColor colorTextFor878D9A];
    }
    return _lbAddressDetail;
}

-(UIImageView *)selectedImgV{
    if (!_selectedImgV) {
        _selectedImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Select"]];
    }
    return _selectedImgV;
}

@end

//
//  MNChatBgCell1.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/3.
//

#import "MNChatBgCell1.h"

@implementation MNChatBgCell1

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
    self.needLine = YES;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImgV];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15-8-5);
        make.centerY.mas_equalTo(0);
    }];
    [self.arrowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
    }];
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontRegular(15);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _titleLabel;
}

-(UIImageView *)arrowImgV{
    if (_arrowImgV) {
        _arrowImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellArrow"]];
    }
    return _arrowImgV;
}

@end

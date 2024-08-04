//
//  MNContactAddNormalCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNContactAddNormalCell.h"

@implementation MNContactAddNormalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillDataWithDic:(NSDictionary *)dic{
    self.iconImgV.image = [UIImage imageNamed:dic[@"icon"]];
    self.titleLabel.text = dic[@"name"];
}
- (void)initUI{
    [super initUI];
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImgV];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.mas_equalTo(left_margin());
        make.centerY.mas_equalTo(0);
    }];
    [self.arrowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(5, 12));
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-left_margin());
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(12);
        make.right.mas_equalTo(-(left_margin()+10));
        make.centerY.mas_equalTo(0);
    }];
    
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
        _titleLabel.font = fontRegular(16);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _titleLabel;
}

-(UIImageView *)arrowImgV{
    if (!_arrowImgV) {
        _arrowImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellArrow"]];
        _arrowImgV.hidden = YES;
    }
    return _arrowImgV;
}
@end

//
//  MNGroupLCLbRArrowCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNGroupLCLbRArrowCell.h"

@implementation MNGroupLCLbRArrowCell

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
    [self.contentView addSubview:self.lcLabel];
    [self.contentView addSubview:self.rcArrow];
    [self.lcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-65);
        make.height.mas_equalTo(22.5);
    }];
    [self.rcArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(5, 12));
    }];
}

-(UILabel *)lcLabel{
    if (!_lcLabel) {
        _lcLabel = [[UILabel alloc] init];
        _lcLabel.font = fontRegular(16);
        _lcLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _lcLabel;
}

-(UIImageView *)rcArrow{
    if (!_rcArrow) {
        _rcArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellArrow"]];
        
    }
    return _rcArrow;
}
@end

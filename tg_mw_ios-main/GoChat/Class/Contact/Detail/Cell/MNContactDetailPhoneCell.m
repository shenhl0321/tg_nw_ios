//
//  MNContactDetailPhoneCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNContactDetailPhoneCell.h"

@implementation MNContactDetailPhoneCell

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
    [self.contentView addSubview:self.topLabel];
    [self.contentView addSubview:self.bottomLabel];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(15);
        make.height.mas_equalTo(22.5);
        make.right.mas_equalTo(-15);
    }];
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-15);
        make.height.mas_equalTo(22.5);
    }];
}
-(UILabel *)topLabel{
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = fontRegular(16);
        _topLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _topLabel;
}

-(UILabel *)bottomLabel{
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = fontRegular(16);
        _bottomLabel.textColor = [UIColor colorMain];
    }
    return _bottomLabel;
}
@end

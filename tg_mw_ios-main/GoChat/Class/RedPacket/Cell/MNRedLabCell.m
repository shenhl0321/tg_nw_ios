//
//  MNRedLabCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNRedLabCell.h"

@implementation MNRedLabCell

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
    [self.contentView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(21);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-15);
    }];
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = fontRegular(15);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor colorFor878D9A];
        _tipLabel.text = @"未领取红包, 将于24小时后发起退款".lv_localized;
    }
    return _tipLabel;
}

@end

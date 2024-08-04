//
//  MNCloseNotificationSetTipCell.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/7.
//

#import "MNCloseNotificationSetTipCell.h"

@implementation MNCloseNotificationSetTipCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)click_close2:(UIButton *)btn
{
    if([self.delegate respondsToSelector:@selector(CloseNotificationSetTipCell_Remove:)])
    {
        [self.delegate CloseNotificationSetTipCell_Remove:self];
    }
}
- (void)initUI{
    [super initUI];
    self.aLabel.text = @"开启消息通知，不错过重要消息".lv_localized;
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.aLabel];
    [self.contentView addSubview:self.closeBtn];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(17, 17));
        make.centerY.mas_equalTo(0);
    }];
    [self.aLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(10);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-41);
        
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-4.5);
        make.size.mas_equalTo(CGSizeMake(37, 37));
        make.centerY.mas_equalTo(0);
    }];
    
}
-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_notice"]];
    }
    return _iconImgV;
}

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"GroupAnnounceClose"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(click_close2:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(UILabel *)aLabel{
    if (!_aLabel) {
        _aLabel = [[UILabel alloc] init];
        _aLabel.textColor = [UIColor colorTextFor0DBFC0];
        _aLabel.font = fontRegular(14);
        
    }
    return _aLabel;
}
@end

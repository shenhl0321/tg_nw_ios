//
//  MNRedBtnCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNRedBtnCell.h"

@implementation MNRedBtnCell

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
    [self.contentView addSubview:self.btn];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(55);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

-(UIButton *)btn{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn mn_loginStyleWithBgColor:HexRGB(0xD94545)];
        [_btn setTitle:@"塞钱进红包".lv_localized forState:UIControlStateNormal];
        UIImage *image = [UIImage imageWithColor:UIColor.systemGrayColor size:CGSizeMake(APP_SCREEN_WIDTH-2*30, 55)];
        [_btn setBackgroundImage:image forState:UIControlStateDisabled];
    }
    return _btn;
}

@end

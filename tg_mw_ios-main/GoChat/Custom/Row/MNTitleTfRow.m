//
//  MNTitleTfRow.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNTitleTfRow.h"

@implementation MNTitleTfRow

- (void)initSubUI{
    [self addSubview:self.titleLabel];
    [self addSubview:self.tf];
//    116
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(56);
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-60);
        make.height.mas_equalTo(21);
    }];
    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1.5);
    }];
    self.lineView.backgroundColor = [UIColor colorTextFor0DBFC0];
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontSemiBold(15);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _titleLabel;
}


@end

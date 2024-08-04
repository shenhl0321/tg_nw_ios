//
//  MNContactFriendHeader.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/2.
//

#import "MNContactFriendHeader.h"

@implementation MNContactFriendHeader


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, 50);//默认的大小
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.aLabel];
    [self.aLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(35);
    }];
}

- (UILabel *)aLabel{
    if (!_aLabel) {
        _aLabel = [[UILabel alloc] init];
        _aLabel.font = fontRegular(15);
        _aLabel.textColor = [UIColor colorTextForA9B0BF];
    }
    return _aLabel;
}

@end

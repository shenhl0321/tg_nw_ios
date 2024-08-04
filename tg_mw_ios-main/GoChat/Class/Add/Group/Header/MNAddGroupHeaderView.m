//
//  MNAddGroupHeaderView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNAddGroupHeaderView.h"

@implementation MNAddGroupHeaderView

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
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(15);
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

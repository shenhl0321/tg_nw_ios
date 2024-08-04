//
//  MNEmojisCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/10.
//

#import "MNEmojisCell.h"

@implementation MNEmojisCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.aLabel];
    [self.aLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
}
-(UILabel *)aLabel{
    if (!_aLabel) {
        _aLabel = [[UILabel alloc] init];
        _aLabel.font = fontRegular(30);
    }
    return _aLabel;
}
@end

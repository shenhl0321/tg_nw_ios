//
//  MNContactDetailSearchCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNContactDetailSearchCell.h"

@implementation MNContactDetailSearchCell

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
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

-(UILabel *)aLabel{
    if (!_aLabel) {
        _aLabel = [[UILabel alloc] init];
        _aLabel.font = fontRegular(16);
        _aLabel.textColor = [UIColor colorTextFor878D9A];
        _aLabel.textAlignment = NSTextAlignmentCenter;
        [_aLabel mn_iconStyleWithRadius:10];
        _aLabel.backgroundColor = [UIColor colorForF5F9FA];
    }
    return _aLabel;
}
@end

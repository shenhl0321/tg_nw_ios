//
//  DeviceSectionHeaderView.m
//  GoChat
//
//  Created by mac on 2022/2/10.
//

#import "DeviceSectionHeaderView.h"

@interface DeviceSectionHeaderView ()



@end

@implementation DeviceSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_content;
        label.font = [UIFont semiBoldCustomFontOfSize:16];
        label;
    });
    [self addSubview:_titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)setTerminal:(DeviceSessionTerminal)terminal {
    _terminal = terminal;
    switch (terminal) {
        case Current:
            _titleLabel.text = @"当前设备".lv_localized;
            _titleLabel.textColor = UIColor.colorMain;
            self.backgroundView.backgroundColor = UIColor.colorTextForFFFFFF;
            break;
        case Other:
            _titleLabel.text = @"活跃设备".lv_localized;
            _titleLabel.textColor = UIColor.xhq_content;
            self.backgroundView.backgroundColor = UIColor.clearColor;
            break;
    }
}

@end

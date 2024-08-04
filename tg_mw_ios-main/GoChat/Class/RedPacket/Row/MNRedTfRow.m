//
//  MNRedTfRow.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNRedTfRow.h"

@implementation MNRedTfRow
 
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = [UIColor colorForF5F9FA];
    self.layer.cornerRadius = 13;
    self.layer.masksToBounds = YES;
    [self addSubview:self.leftLabel];
    [self addSubview:self.rightLabel];
    [self addSubview:self.tf];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(24);
        make.centerY.mas_equalTo(0);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(27);
    }];
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15-27);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(200);
    }];
}

-(UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.textColor = [UIColor colorTextFor23272A];
        _leftLabel.font = fontRegular(17);
        _leftLabel.text = @"金额".lv_localized;
    }
    return _leftLabel;
}

-(UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.textColor = [UIColor colorTextFor23272A];
        _rightLabel.font = fontRegular(17);
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.text = @"元".lv_localized;
    }
    return _rightLabel;
}

-(UITextField *)tf{
    if (!_tf) {
        _tf = [[UITextField alloc] init];
        [_tf mn_defalutStyle];
        [_tf setClearButtonMode:UITextFieldViewModeNever];
        _tf.textAlignment = NSTextAlignmentRight;
        _tf.placeholder = @"0.00";
    }
    return _tf;
}
@end

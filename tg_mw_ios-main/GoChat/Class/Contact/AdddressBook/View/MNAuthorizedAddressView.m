//
//  MNAuthorizedAddressView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNAuthorizedAddressView.h"

@interface MNAuthorizedAddressView ()

@property (nonatomic, strong) UIImageView *phoneImgV;
@property (nonatomic, strong) UILabel *phoneLab;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UIButton *addressBtn;

@end

@implementation MNAuthorizedAddressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self buildSubviews];
        
    }
    return self;
}

- (void)buildSubviews{
    [self addSubview:self.phoneImgV];
    [self addSubview:self.phoneLab];
    [self addSubview:self.tipLab];
    [self addSubview:self.addressBtn];
    
    [self.phoneImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(100);
    }];
    [self.phoneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneImgV.mas_bottom).offset(27);
        make.centerX.mas_equalTo(0);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneLab.mas_bottom).offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
    [self.addressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-50);
        make.centerX.mas_equalTo(0);
        make.left.mas_equalTo(left_margin30());
        make.height.mas_equalTo(55);
    }];
}

- (void)addressEvent{
    if (self.goToAuthorizationBlock) {
        self.goToAuthorizationBlock(self.addressBtn);
    }
}

- (UIImageView *)phoneImgV {
    if (!_phoneImgV) {
        _phoneImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Contact"]];
    }
    return _phoneImgV;
}
- (UILabel *)phoneLab {
    if (!_phoneLab) {
        _phoneLab = [[UILabel alloc] init];
        _phoneLab.font = fontRegular(19);
        _phoneLab.textColor = [UIColor colorTextFor23272A];
        _phoneLab.text = @"请授权访问权限".lv_localized;
    }
    return _phoneLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = fontRegular(15);
        _tipLab.textColor = [UIColor colorTextFor878D9A];
        _tipLab.text = [NSString stringWithFormat:@"请在iPhone的“设置-隐私-通讯录”选项中，允许%@访问你的通讯录。".lv_localized, localAppName.lv_localized];
        _tipLab.numberOfLines = 0;
        _tipLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLab;
}

- (UIButton *)addressBtn {
    if (!_addressBtn) {
        _addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addressBtn mn_loginStyle];
        [_addressBtn setTitle:@"前往授权".lv_localized forState:UIControlStateNormal];
        [_addressBtn addTarget:self action:@selector(addressEvent) forControlEvents:UIControlEventTouchUpInside];
        [_addressBtn mn_loginStyle];
    }
    return _addressBtn;
}

@end

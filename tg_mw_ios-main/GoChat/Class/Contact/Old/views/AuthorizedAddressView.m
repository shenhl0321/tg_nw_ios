//
//  AuthorizedAddressView.m
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import "AuthorizedAddressView.h"

@interface AuthorizedAddressView ()

@property (nonatomic, strong) UIImageView *phoneImgV;
@property (nonatomic, strong) UILabel *phoneLab;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UIButton *addressBtn;

@end

@implementation AuthorizedAddressView

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
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(98);
    }];
    [self.phoneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneImgV.mas_bottom).offset(30);
        make.centerX.mas_equalTo(0);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneLab.mas_bottom).offset(18);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
    [self.addressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLab.mas_bottom).offset(130);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(44);
    }];
}

- (void)addressEvent{
    if (self.goToAuthorizationBlock) {
        self.goToAuthorizationBlock(self.addressBtn);
    }
}

- (UIImageView *)phoneImgV {
    if (!_phoneImgV) {
        _phoneImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"binding"]];
    }
    return _phoneImgV;
}
- (UILabel *)phoneLab {
    if (!_phoneLab) {
        _phoneLab = [[UILabel alloc] init];
        _phoneLab.font = [UIFont fontWithName:@"PingFang SC" size: 19];
        _phoneLab.textColor = HEX_COLOR(@"#010108");
        _phoneLab.text = @"请授权访问权限";
    }
    return _phoneLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont fontWithName:@"PingFang SC" size: 15];
        _tipLab.textColor = HEX_COLOR(@"#010108");
        _tipLab.text = [NSString stringWithFormat:@"请在iPhone的“设置-隐私-通讯录”选项中，允许%@访问你的通讯录。".lv_localized, localAppName.lv_localized];
        _tipLab.numberOfLines = 0;
        _tipLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLab;
}

- (UIButton *)addressBtn {
    if (!_addressBtn) {
        _addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addressBtn setBackgroundImage:[UIImage imageNamed:@"commombtnbg"] forState:UIControlStateNormal];
        _addressBtn.titleLabel.textColor = HEX_COLOR(@"#FFFFFF");
        _addressBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size: 17];
        [_addressBtn setTitle:@"前往授权" forState:UIControlStateNormal];
        [_addressBtn addTarget:self action:@selector(addressEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addressBtn;
}

@end

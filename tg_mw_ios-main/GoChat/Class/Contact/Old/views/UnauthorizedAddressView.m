//
//  UnauthorizedAddressView.m
//  GoChat
//
//  Created by Demi on 2021/9/5.
//

#import "UnauthorizedAddressView.h"

@interface UnauthorizedAddressView ()

@property (nonatomic, strong) UIImageView *phoneImgV;
@property (nonatomic, strong) UILabel *phoneLab;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UIButton *addressBtn;

@end

@implementation UnauthorizedAddressView

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
    if (self.authorizedAddressBlock) {
        self.authorizedAddressBlock(self.addressBtn);
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
        NSString *phone = [UserInfo shareInstance].phone_number;
        if(![phone hasPrefix:@"+"]){
            phone = [NSString stringWithFormat:@"+%@", phone];
        }
        _phoneLab.text = [NSString stringWithFormat:@"你的手机号：%@",phone];
    }
    return _phoneLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont fontWithName:@"PingFang SC" size: 15];
        _tipLab.textColor = HEX_COLOR(@"#999999");
        _tipLab.text = [NSString stringWithFormat:@"上传你的手机通讯录后，可查看你通讯录中哪些朋友注册了%@",localAppName.lv_localized];
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
        [_addressBtn setTitle:@"上传通讯录找朋友" forState:UIControlStateNormal];
        [_addressBtn addTarget:self action:@selector(addressEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addressBtn;
}

@end

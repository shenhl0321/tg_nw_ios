//
//  MNUnauthorizedAddressView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNUnauthorizedAddressView.h"

@interface MNUnauthorizedAddressView ()
@property (nonatomic, strong) UIImageView *phoneImgV;
@property (nonatomic, strong) UILabel *phoneLab;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UIButton *addressBtn;
@end
@implementation MNUnauthorizedAddressView

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
        make.top.mas_equalTo(self.phoneImgV.mas_bottom).offset(30);
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
    if (self.authorizedAddressBlock) {
        self.authorizedAddressBlock(self.addressBtn);
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
        NSString *phone = [UserInfo shareInstance].phone_number;
        if(![phone hasPrefix:@"+"]){
            phone = [NSString stringWithFormat:@"+%@", phone];
        }
        _phoneLab.text = [NSString stringWithFormat:@"%@%@",@"你的手机号：".lv_localized,phone];
    }
    return _phoneLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = fontRegular(15);
        _tipLab.textColor = [UIColor colorTextFor878D9A];
        _tipLab.text = [NSString stringWithFormat:@"%@%@",@"上传你的手机通讯录后，可查看你通讯录中哪些朋友注册了".lv_localized,localAppName.lv_localized];
        _tipLab.numberOfLines = 0;
        _tipLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLab;
}

- (UIButton *)addressBtn {
    if (!_addressBtn) {
        _addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addressBtn mn_loginStyle];
        [_addressBtn setTitle:@"上传通讯录找朋友".lv_localized forState:UIControlStateNormal];
        [_addressBtn addTarget:self action:@selector(addressEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addressBtn;
}

@end

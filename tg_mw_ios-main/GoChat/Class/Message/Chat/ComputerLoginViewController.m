//
//  ComputerLoginViewController.m
//  GoChat
//
//  Created by mac on 2021/9/9.
//

#import "ComputerLoginViewController.h"

@interface ComputerLoginViewController ()

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation ComputerLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self.customNavBar setTitle:@"登录确认".lv_localized];
    [self buildSubviews];
}

- (void)buildSubviews{
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.sureBtn];
    [self.contentView addSubview:self.cancelBtn];
    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.top.mas_equalTo(50);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(100);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.iconImgV.mas_bottom).offset(30);
    }];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(180);
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(55);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.sureBtn.mas_bottom).offset(10);
        make.width.mas_equalTo(68);
        make.height.mas_equalTo(44);
    }];
}

- (void)sureEvent{
    
    [[TelegramManager shareInstance] authComputerLogin:self.link resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if (![TelegramManager isResultError: response]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [UserInfo showTips:nil des:@"二维码已过期".lv_localized duration:1];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo showTips:nil des:@"超时".lv_localized duration:1];
    }];
    
    
}
- (void)cancelEvent {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImageView *)iconImgV {
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"windows_login"]];
    }
    return _iconImgV;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = fontRegular(19);
        _titleLab.textColor = [UIColor colorTextFor23272A];
        _titleLab.text = [localAppName.lv_localized stringByAppendingString:@" 电脑端登录确认".lv_localized];
    }
    return _titleLab;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_sureBtn setBackgroundImage:[UIImage imageNamed:@"commombtnbg"] forState:UIControlStateNormal];
//        _sureBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size: 17];
//        _sureBtn.titleLabel.textColor = UIColor.whiteColor;
        [_sureBtn setTitle:@"登录".lv_localized forState:UIControlStateNormal];
        [_sureBtn mn_loginStyle];
        [_sureBtn addTarget:self action:@selector(sureEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = fontSemiBold(17);
//        [_cancelBtn setTitleColor:HEX_COLOR(@"#00BF91") forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消登录".lv_localized forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
//        [_cancelBtn mn_registerStyle];
        [_cancelBtn addTarget:self action:@selector(cancelEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

@end

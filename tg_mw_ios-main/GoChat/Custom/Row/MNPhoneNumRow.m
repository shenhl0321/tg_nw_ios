//
//  MNPhoneNumRow.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNPhoneNumRow.h"

@implementation MNPhoneNumRow

- (void)initSubUI{
    
}

- (UIImageView *)imageV{
    if (!_imageV){
        _imageV = [[UIImageView alloc] init];
        _imageV.image = [UIImage imageNamed:@"icon_down"];
    }
    return _imageV;
}
-(UITextField *)countryTf{
    if (!_countryTf) {
        _countryTf = [[UITextField alloc] init];
        [_countryTf mn_countryCodeStyle];
        _countryTf.placeholder = LocalString(localCountryCode);
        _countryTf.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _countryTf;
}

-(UITextField *)phoneNumTf{
    if (!_phoneNumTf) {
        _phoneNumTf = [[UITextField alloc] init];
        _phoneNumTf.placeholder = LocalString(localPlsEnterPhoneNum);
        [_phoneNumTf mn_defalutStyle];
        _phoneNumTf.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneNumTf;
}

- (void)setOnlyPhoneNumTF:(BOOL)onlyPhoneNumTF{
    _onlyPhoneNumTF = onlyPhoneNumTF;
    if(onlyPhoneNumTF){
        [self addSubview:self.phoneNumTf];
        [self.phoneNumTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorTextForE5EAF0];
        lineView.hidden = YES;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1, 20));
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.phoneNumTf.mas_right).with.offset(2);
        }];
        
    }else{
        [self addSubview:self.countryTf];
        [self addSubview:self.phoneNumTf];
        [self addSubview:self.imageV];
        
        [self.countryTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
        }];
        [self.phoneNumTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.left.equalTo(self.countryTf.mas_right).with.offset(17);
        }];
        [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(45);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorTextForE5EAF0];
        lineView.hidden = YES;
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1, 20));
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.countryTf.mas_right).with.offset(2);
        }];
    }
    
}

@end

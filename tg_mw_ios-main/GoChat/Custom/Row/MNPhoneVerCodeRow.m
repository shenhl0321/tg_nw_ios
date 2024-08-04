//
//  MNPhoneVerCodeRow.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNPhoneVerCodeRow.h"

@implementation MNPhoneVerCodeRow

- (void)initUI{
    [super initUI];
    self.tf.placeholder = LocalString(localPlsEnterVerificationCode);
    self.tf.keyboardType = UIKeyboardTypeNumberPad;
    
}

- (void)initSubUI{
    [self addSubview:self.tf];
    [self addSubview:self.retCodeBtn];
    [self.retCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.right.equalTo(self.retCodeBtn.mas_left).with.offset(-20);
    }];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorTextForE5EAF0];
    [self addSubview:lineView];
    lineView.hidden = YES;
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(1, 20));
        make.centerY.mas_equalTo(0);
//        make.right.equalTo(self.retCodeBtn.mas_left).with.offset(-1);;
        make.right.mas_equalTo(-100);;
    }];
}

-(MNRetCodeBtn *)retCodeBtn{
    if (!_retCodeBtn) {
        _retCodeBtn = [[MNRetCodeBtn alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        _retCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
     
    }
    return _retCodeBtn;
}

@end

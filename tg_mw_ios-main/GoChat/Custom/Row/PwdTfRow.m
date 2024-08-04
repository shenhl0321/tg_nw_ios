//
//  PwdTfRow.m
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/11.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "PwdTfRow.h"

@interface PwdTfRow ()

@end

@implementation PwdTfRow

- (void)initSubUI{
    self.tf.secureTextEntry = YES;
    [self addSubview:self.tf];
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-40);
        make.top.mas_equalTo(0);
    }];
    [self addSubview:self.btn];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(20, 40));
        make.centerY.mas_equalTo(0);
    }];
}

-(UIButton *)btn{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setImage:[UIImage imageNamed:@"PwdHidden"] forState:UIControlStateNormal];
        [_btn setImage:[UIImage imageNamed:@"PwdShow"] forState:UIControlStateSelected];
        [_btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (void)btnAction:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.tf.secureTextEntry = NO;
    }else{
        self.tf.secureTextEntry = YES;
    }
}

@end

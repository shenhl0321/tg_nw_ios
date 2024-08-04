//
//  TransferInfoReceivedView.m
//  GoChat
//
//  Created by Autumn on 2022/1/28.
//

#import "TransferInfoReceivedView.h"

@interface TransferInfoReceivedView ()

@property (nonatomic, strong) UIButton *receivedButton;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *refundLabel;
@property (nonatomic, strong) UIView *container;

@end

@implementation TransferInfoReceivedView

- (void)dy_initUI {
    [super dy_initUI];
    
    _receivedButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"收款".lv_localized forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btn.backgroundColor = UIColor.colorMain;
        btn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [btn xhq_addTarget:self action:@selector(received)];
        [btn xhq_cornerRadius:13];
        btn;
    });
    _container = ({
        UIView *view = UIView.new;
        view;
    });
    _tipLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorFor878D9A;
        label.font = [UIFont regularCustomFontOfSize:14];
        label.text = @"1天内未确认，将退还给对方。".lv_localized;
        label;
    });
    _refundLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorMain;
        label.font = [UIFont regularCustomFontOfSize:14];
        label.text = @"退还".lv_localized;
        label;
    });
    [self addSubview:_receivedButton];
    [self addSubview:_container];
    [_container addSubview:_tipLabel];
    [_container addSubview:_refundLabel];
    @weakify(self);
    [_refundLabel xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self refund];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_receivedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(25);
        make.trailing.mas_equalTo(-25);
        make.height.mas_equalTo(55);
        make.top.mas_equalTo(80);
    }];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(_receivedButton.mas_bottom).offset(20);
        make.height.equalTo(_tipLabel);
    }];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_container);
        make.centerY.mas_equalTo(0);
    }];
    [_refundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_tipLabel.mas_trailing);
        make.trailing.equalTo(_container);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)received {
    !self.receivedBlock ? : self.receivedBlock();
}

- (void)refund {
    !self.refundBlock ? : self.refundBlock();
}

@end

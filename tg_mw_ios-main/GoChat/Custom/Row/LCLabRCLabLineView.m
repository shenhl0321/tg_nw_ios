//
//  LCLabRCLabLineView.m
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/17.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "LCLabRCLabLineView.h"

//@implementation LCLabRCLabLineView
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initUI];
//    }
//    return self;
//}
//- (instancetype)initWithLeftText:(NSString *)leftText rightText:(NSString *)rightText needLine:(BOOL)needLine
//{
//    self = [super init];
//    if (self) {
//        self.frame = CGRectMake(left_margin(), 0, kScreenWidth-2*left_margin(), 50);
//        [self initUI];
//        self.lcLabel.text = leftText;
//        self.rcLabel.text = rightText;
//        self.lineView.hidden = !needLine;
//    }
//    return self;
//}
//
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self initUI];
//    }
//    return self;
//}
//
//- (void)initUI{
//    if (self.frame.size.width == 0) {
//        self.frame = CGRectMake(left_margin(), 0, kScreenWidth-2*left_margin(), 50);
//    }
//    [self addSubview:self.lcLabel];
//    [self addSubview:self.rcLabel];
//    [self addSubview:self.lineView];
//    [self.lcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.left.mas_equalTo(left_margin());
//        make.right.mas_equalTo(-(left_margin()+80));
//    }];
//    [self.rcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.right.mas_equalTo(-left_margin());
//        make.width.mas_equalTo(80);
//    }];
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(-0.5);
//        make.height.mas_equalTo(0.5);
//        make.left.mas_equalTo(left_margin());
//        make.centerX.mas_equalTo(0);
//    }];
//}
//
//-(UILabel *)lcLabel{
//    if (!_lcLabel) {
//        _lcLabel = [[UILabel alloc] init];
//        _lcLabel.font = fontMedium(14);
//        _lcLabel.textColor = colorText(1);
//    }
//    return _lcLabel;
//}
//
//-(UILabel *)rcLabel{
//    if (!_rcLabel) {
//        _rcLabel = [[UILabel alloc] init];
//        _rcLabel.font = fontMedium(14);
//        _rcLabel.textColor = colorText(1);
//        _rcLabel.textAlignment = NSTextAlignmentRight;
//    }
//    return _rcLabel;
//}
//
//-(UIView *)lineView{
//    if (!_lineView) {
//        _lineView = [[UIView alloc] init];
//        _lineView.backgroundColor = [UIColor colorForBDBDBD_];
//    }
//    return _lineView;
//}
//
//@end

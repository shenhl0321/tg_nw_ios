//
//  TfRow.m
//  Coulisse
//
//  Created by XMJ on 2017/8/29.
//  Copyright © 2017年 Coulisse. All rights reserved.
//

#import "TfRow.h"

#import "UITextField+Style.h"

@interface TfRow ()
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholder;
@end

@implementation TfRow

- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, 62);//给个默认的
        [self initUI];
        self.tf.text = [Util objToStr:text];
        self.tf.placeholder = [Util objToStr:placeholder];
    }
    return self;
}

- (void)initSubUI{
    [self addSubview:self.tf];
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
}

-(UITextField *)tf{
    if (!_tf) {
        _tf = [[UITextField alloc] init];
        [_tf mn_defalutStyle];
        _tf.placeholder = [Util objToStr:self.placeholder];
        
        _tf.text = [Util objToStr:self.text];
    }
    return _tf;
}

-(void)setText:(NSString *)text{
    _text = [Util objToStr:text];
    self.tf.text = _text;
}

-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = [Util objToStr:placeholder];
    self.tf.placeholder = _placeholder;
}

@end

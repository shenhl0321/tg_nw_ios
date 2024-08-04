//
//  MNChatDelayView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/26.
//

#import "MNChatDelayView.h"

@interface MNChatDelayView ()
<ASwitchDelegate,MNSlierDelegate>

@property (nonatomic, strong) UIButton *finishBtn;

@end

@implementation MNChatDelayView
- (void)awakeFromNib{
    [super awakeFromNib];
    [self initUI];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)refreshDataWithValue:(NSInteger)value{
    if (value>0) {
        self.isOn = YES;
    }else{
        self.isOn = NO;
    }
    self.value = value;
    [self.aSwitch setOnWithOutAnimation:self.isOn];
    self.slider.enabled = self.isOn;
    self.slider.percent = 1.0*(value-self.min)/(self.max-self.min);
    [self.slider refreshUI];
    [self refreshNameLabelWithValue:value isOn:self.isOn];
}

-(void)setValue:(NSInteger)value{
    if (value < self.min) {
        value = self.min;
    }else if (value>self.max){
        value = self.max;
    }
    _value = value;
}
- (void)refreshNameLabelWithValue:(NSInteger)value isOn:(BOOL)isOn{
    if (isOn) {
        self.nameLabel.text = [NSString stringWithFormat:@"消息阅读后%ld秒自动销毁".lv_localized,value];
    }else{
        self.nameLabel.text = @"阅后即焚倒计时关闭".lv_localized;
    }
}
- (void)finishAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatDelayView:isOn:value:)]) {
        [self.delegate chatDelayView:self isOn:self.isOn value:self.value];
    }
    self.hidden = YES;
}

-(UIButton *)finishBtn{
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.titleLabel.font = fontSemiBold(16);
        [_finishBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _finishBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_finishBtn setTitle:@"完成".lv_localized forState:UIControlStateNormal];
        [_finishBtn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

- (void)initUI{
    _min = 5;
    _max = 600;
    _value = 5;
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.iconImgV];
    [self addSubview:self.nameLabel];
    [self addSubview:self.slider];
    [self addSubview:self.aSwitch];
    [self addSubview:self.finishBtn];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(10);
        make.right.mas_equalTo(15);
        make.centerY.equalTo(self.iconImgV);
    }];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(45, 22));
        make.centerY.equalTo(self.iconImgV);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImgV.mas_bottom).with.offset(23);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-75);
        make.height.mas_equalTo(3);
    }];
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.slider);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(45, 22));
    }];
    UIView *lineView = [[UIView alloc] init];
//#E5EAF0
    lineView.backgroundColor = [UIColor colorTextForE5EAF0];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
    }];
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time"]];
    }
    return _iconImgV;
}

-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontSemiBold(16);
        _nameLabel.textColor = [UIColor colorTextFor23272A];
        _nameLabel.text = @"消息阅读后10秒自动销毁".lv_localized;
    }
    return _nameLabel;
}

-(ASwitch *)aSwitch{
    if (!_aSwitch) {
        _aSwitch = [[ASwitch alloc] initWithFrame:CGRectMake(0, 0, 45, 22)];
        _aSwitch.aSwitchDelegate = self;
    }
    return _aSwitch;
}

- (MNSlider *)slider{
    if (!_slider) {
        _slider = [[MNSlider alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH-15-75, 3)];
        _slider.backImgVColor = [UIColor colorTextForE5EAF0];
        _slider.fontImgVColor = [UIColor colorMain];
        _slider.isVertical = NO;
        _slider.touchSize = CGSizeMake(29, 29);
        _slider.delegate = self;
        
    }
    return _slider;
}

-(void)aSwitch:(ASwitch *)aSwitch isOn:(BOOL)isOn{
    //
    self.isOn = isOn;
    self.slider.enabled = isOn;
    [self refreshNameLabelWithValue:self.value isOn:isOn];
}

-(void)slider_endTouch:(MNSlider *)slider{
    NSInteger value = (NSInteger)roundf(slider.percent *(self.max-self.min)+self.min);
    self.value = value;
}

-(void)slider_continueTouch:(MNSlider *)slider{
    NSInteger value = (NSInteger)roundf(slider.percent *(self.max-self.min)+self.min);
    self.nameLabel.text = [NSString stringWithFormat:@"消息阅读后%ld秒自动销毁".lv_localized,value];
}

@end

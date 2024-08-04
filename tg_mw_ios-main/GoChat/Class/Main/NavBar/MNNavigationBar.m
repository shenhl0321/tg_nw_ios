//
//  MNNavigationBar.m
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/7.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "MNNavigationBar.h"
#define kNavLeftMargin 16
#define kNavRightMargin 16
#define kNavLeftBtnMaxWitdh 70

//#define

@interface MNNavigationBar ()
//样式1
//标题加左右2个按钮的是默认样式
//@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *secondTitleLabel;
@property (nonatomic, strong) UILabel *countLabel;//聊天页面的countlabel
//@property (nonatomic, strong) UIButton *homeNameBtn;
@property (nonatomic, strong) UIButton *leftBtn;//最左边的按钮
@property (nonatomic, strong) UIButton *rightBtn;//最右边的按钮
@property (nonatomic, strong) UIButton *leftBtn2;//从左第二个
@property (nonatomic, strong) UIButton *rightBtn2;//从右往左第二个

@property (nonatomic, strong) UIImageView *titleIV;

@property (nonatomic, strong) UIImageView *privateImgV;

@property (nonatomic, assign, readonly) CGFloat oneLeftBtnMaxWidth;
@property (nonatomic, assign, readonly) CGFloat oneRightBtnMaxWidth;
@property (nonatomic, assign, readonly) CGFloat twoLeftBtnsMaxWidth;
@property (nonatomic, assign, readonly) CGFloat twoRightBtnsMaxWidth;
@property (nonatomic, assign, readonly) CGFloat btnHeight;
@property (nonatomic, assign) BOOL isPrivate;

@end

@implementation MNNavigationBar
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorTextForFFFFFF];
//        [self addRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:16];
        [self addSubview:self.contentView];
        self.contentView.frame = CGRectMake(0, APP_STATUS_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_NAV_BAR_HEIGHT);
        

    }
    return self;
}


- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor blackColor];
        _lineView.hidden = YES;
    }
    return _lineView;
}

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}


- (void)setTitleLabelText:(NSString *)text{
    if (self.titleLabel.superview == nil) {
        [self.contentView addSubview:self.titleLabel];
    }
    self.titleLabel.text = [Util objToStr:text];
}

-(UIButton *)leftBtn{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.titleLabel.numberOfLines = 0;
        _leftBtn.titleLabel.font = fontMedium(15);
        _leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _leftBtn;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _rightBtn.titleLabel.numberOfLines = 0;
        _rightBtn.titleLabel.font = fontSemiBold(17);
        _rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_rightBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _rightBtn;
}

-(UIButton *)leftBtn2{
    if (!_leftBtn2) {
        _leftBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn2.titleLabel.numberOfLines = 0;
        _leftBtn2.titleLabel.font = fontMedium(15);
        _leftBtn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_leftBtn2 setTitleColor:[UIColor colorTextFor23272A] forState:UIControlStateNormal];
        [_leftBtn2 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _leftBtn;
}

-(UIButton *)rightBtn2{
    if (!_rightBtn2) {
        _rightBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn2.titleLabel.numberOfLines = 0;
        _rightBtn2.titleLabel.font = fontMedium(15);
        _rightBtn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_rightBtn2 setTitleColor:[UIColor colorTextFor23272A] forState:UIControlStateNormal];
        [_rightBtn2 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _rightBtn2;
}


- (void)btnAction:(UIButton *)btn{
    NSLog(@"按钮被点击了~~");
    if (btn == self.leftBtn) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigationBar:didClickLeftBtn:)]) {
            [self.delegate navigationBar:self didClickLeftBtn:btn];
        }
        return;
    }
    if (btn == self.rightBtn) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigationBar:didClickRightBtn:)]) {
            [self.delegate navigationBar:self didClickRightBtn:btn];
        }
        return;
    }
    
    if (btn == self.leftBtn2) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigationBar:didClickSecondLeftBtn:)]) {
            [self.delegate navigationBar:self didClickSecondLeftBtn:self.leftBtn2];
        }
    }
    
    if (btn == self.rightBtn2) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigationBar:didClickSecondRightBtn:)]) {
            [self.delegate navigationBar:self didClickSecondRightBtn:self.rightBtn2];
        }
    }
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorTextFor23272A];
        _titleLabel.font = fontSemiBold(19);

    }
    return _titleLabel;
}

-(UILabel *)secondTitleLabel{
    if (!_secondTitleLabel) {
        _secondTitleLabel = [[UILabel alloc] init];
        _secondTitleLabel.font = fontRegular(14);
        _secondTitleLabel.textAlignment = NSTextAlignmentCenter;
        _secondTitleLabel.numberOfLines = 0;
        _secondTitleLabel.textColor = [UIColor colorTextFor878D9A];
        _secondTitleLabel.frame = CGRectMake(left_margin(), 60+APP_STATUS_BAR_HEIGHT, APP_SCREEN_WIDTH-2*left_margin(), 32);
    }
    return _secondTitleLabel;
}

-(UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.frame = CGRectMake(CGRectGetMaxX(self.leftBtn.frame)-15, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, 46, 44);
        _countLabel.font = fontRegular(14);
        _countLabel.textColor = [UIColor colorTextFor878D9A];
    }
    return _countLabel;
}

-(CGFloat)oneLeftBtnMaxWidth{
    CGFloat value = 40;

    return value;
}

-(CGFloat)oneRightBtnMaxWidth{
    CGFloat value = 64;

    return value;
}

- (CGFloat)twoLeftBtnsMaxWidth{
    CGFloat value = 44;
    return value;
}

-(CGFloat)btnHeight{
    CGFloat value = 44;
    return value;
}



- (UILabel *)setTitle:(NSString *)title{
    if (self.titleLabel.superview==nil) {
        [self.contentView addSubview:self.titleLabel];
    }
    self.titleLabel.text = [Util objToStr:title];
    return self.titleLabel;
}

-(UILabel *)setSecondTitle:(NSString *)secondTitle{
    if (self.secondTitleLabel.superview == nil) {
        [self.contentView addSubview:self.secondTitleLabel];
    }
    self.secondTitleLabel.text = [Util objToStr:secondTitle];
    return self.secondTitleLabel;
}
//聊天的计数
-(UILabel *)setCountLabelText:(NSString *)countText{
    if (self.countLabel.superview == nil) {
        [self.contentView addSubview:self.countLabel];
    }
    self.countLabel.text = [Util objToStr:countText];
    return self.countLabel;
}

//传nil
-(UIButton *)setLeftBtnWithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName{
    CGRect rect = self.leftBtn.frame;
    [_leftBtn removeFromSuperview];
    _leftBtn = nil;
    self.leftBtn.frame = rect;
    [self btn:self.leftBtn imageName:imageName title:title highlightedImageName:highlightedImageName];
    return self.leftBtn;
}

-(UIButton *)setRightBtnWithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName{
    CGRect rect = self.rightBtn.frame;
    [_rightBtn removeFromSuperview];   
    _rightBtn = nil;
    self.rightBtn.frame = rect;
    [self btn:self.rightBtn imageName:imageName title:title highlightedImageName:highlightedImageName];
    return self.rightBtn;
}

//传nil
-(UIButton *)setLeftBtn2WithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName{
    
    [self btn:self.leftBtn2 imageName:imageName title:title highlightedImageName:highlightedImageName];
    return self.leftBtn2;
}

-(UIButton *)setRightBtn2WithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName{
    [self btn:self.rightBtn2 imageName:imageName title:title highlightedImageName:highlightedImageName];
    return self.rightBtn2;
}


-(void)btn:(UIButton *)btn imageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName{
    if (btn.superview == nil) {
        [self.contentView addSubview:btn];
    }
    UIImage *image = nil;
    if (imageName) {
        image = [UIImage imageNamed:imageName];
        [btn setImage:image forState:UIControlStateNormal];
    }
    if (highlightedImageName) {
        UIImage *image = [UIImage imageNamed:highlightedImageName];
        [btn setImage:image forState:UIControlStateHighlighted];
    }
    if (title) {
        [btn setTitle:title forState:UIControlStateNormal];
    }else{
        [btn setTitle:@"" forState:UIControlStateNormal];
    }
    if (image && title.length) {
        [btn setImagePosition:LXMImagePositionLeft spacing:10];
    }
}


- (UIImageView *)titleIV{
    if (!_titleIV) {
        _titleIV = [[UIImageView alloc] init];
        _titleIV.contentMode = UIViewContentModeScaleAspectFit;

       
    }
    return _titleIV;
}

- (UIImageView *)setTitleIVWithImageName:(NSString *)imageName{
    if (self.titleIV.superview == nil) {
        [self.contentView addSubview:self.titleIV];
    }
    UIImage *image = [UIImage imageNamed:imageName];
    if (image) {
        [self.titleIV setImage:image];
    }
    return self.titleIV;
}

//左右2个按钮加标题的
- (void)style_title_LeftBtn_RightBtn{
    self.leftBtn.frame = CGRectMake(left_margin(), (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.oneLeftBtnMaxWidth, self.btnHeight);
    self.rightBtn.frame = CGRectMake(APP_SCREEN_WIDTH - left_margin() - self.oneRightBtnMaxWidth, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.oneRightBtnMaxWidth, self.btnHeight);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.leftBtn.frame), 0, APP_SCREEN_WIDTH - 2*CGRectGetMaxX(self.leftBtn.frame), CGRectGetHeight(self.contentView.frame));
}

//左右2个按钮和中间图片的
- (void)style_titleIV_LeftBtn_RightBtn{
    NSLog(@"xxx ---------  %.f",CGRectGetHeight(self.contentView.frame));
    self.leftBtn.frame = CGRectMake(left_margin(), (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.oneLeftBtnMaxWidth, self.btnHeight);
    
    self.rightBtn.frame = CGRectMake(APP_SCREEN_WIDTH - left_margin() - self.oneRightBtnMaxWidth, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.oneRightBtnMaxWidth, self.btnHeight);
    self.titleIV.frame = CGRectMake(CGRectGetMaxX(self.leftBtn.frame), 0, APP_SCREEN_WIDTH - 2*CGRectGetMaxX(self.leftBtn.frame), CGRectGetHeight(self.contentView.frame));

    

}

//左边一个按钮中间文字右边2个按钮的
- (void)style_title_LeftBtn_2RightBtn{
    self.leftBtn.frame = CGRectMake(left_margin(), (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth*2+5, self.btnHeight);
    
    self.rightBtn.frame = CGRectMake(APP_SCREEN_WIDTH - left_margin() - self.twoLeftBtnsMaxWidth, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.rightBtn2.frame = CGRectMake(CGRectGetMinX(self.rightBtn.frame)-self.twoLeftBtnsMaxWidth-5, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.leftBtn.frame), 0, APP_SCREEN_WIDTH - 2*CGRectGetMaxX(self.leftBtn.frame), CGRectGetHeight(self.contentView.frame));
    
}

//左边图片 右边按钮
- (void)style_LeftIV_RightBtn_Ipad{
    self.rightBtn.frame = CGRectMake(APP_SCREEN_WIDTH - left_margin() - self.oneRightBtnMaxWidth, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.oneRightBtnMaxWidth, self.btnHeight);
    
    self.titleIV.frame = CGRectMake(left_margin(), (CGRectGetHeight(self.contentView.frame)-28)*0.5+6,126, 28);
   

}

//登录的导航栏样式
- (void)style_GoChatLogin{
    self.titleIV.frame = CGRectMake(left_margin40(), 5,40, 40);
//    [self.titleIV setImage:[UIImage imageNamed:@"NavLogo"]];
}

////首页消息的页面
- (UILabel *)style_GoChatMessage{
    self.contentView.frame = CGRectMake(0, APP_STATUS_BAR_HEIGHT, APP_SCREEN_WIDTH, 64);
    self.rightBtn.frame = CGRectMake(APP_SCREEN_WIDTH - 20 - self.oneRightBtnMaxWidth, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.oneRightBtnMaxWidth, self.btnHeight);
    self.titleLabel.frame = CGRectMake(20, 0, APP_SCREEN_WIDTH - 100, CGRectGetHeight(self.contentView.frame));
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = fontSemiBold(24);
    return self.titleLabel;
}

-(void)style_Chat{
    self.isPrivate = NO;
    self.leftBtn.frame = CGRectMake(left_margin(), (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.countLabel.frame = CGRectMake(CGRectGetMaxX(self.leftBtn.frame)-15, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, 46, 44);
    
    self.rightBtn.frame = CGRectMake(APP_SCREEN_WIDTH - left_margin() - self.twoLeftBtnsMaxWidth, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.rightBtn2.frame = CGRectMake(CGRectGetMinX(self.rightBtn.frame)-self.twoLeftBtnsMaxWidth-5, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.titleLabel.frame = CGRectMake((APP_SCREEN_WIDTH-200)*0.5, 0, 200, 26);
   
    self.secondTitleLabel.frame = CGRectMake((APP_SCREEN_WIDTH-200)*0.5, 26, 200, 18);
}

- (void)style_ChatPrivate{
    self.isPrivate = YES;
    self.leftBtn.frame = CGRectMake(left_margin(), (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.countLabel.frame = CGRectMake(CGRectGetMaxX(self.leftBtn.frame)-15, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, 46, 44);
    
    self.rightBtn.frame = CGRectMake(APP_SCREEN_WIDTH - left_margin() - self.twoLeftBtnsMaxWidth, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.rightBtn2.frame = CGRectMake(CGRectGetMinX(self.rightBtn.frame)-self.twoLeftBtnsMaxWidth-5, (CGRectGetHeight(self.contentView.frame)-self.btnHeight)*0.5, self.twoLeftBtnsMaxWidth, self.btnHeight);
    self.titleLabel.frame = CGRectMake((APP_SCREEN_WIDTH-200)*0.5, 0, 200, 26);
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-5);
        make.top.mas_equalTo(0);
        make.left.mas_greaterThanOrEqualTo((APP_SCREEN_WIDTH-200)*0.5);
    }];
    [self.contentView addSubview:self.privateImgV];
    [self.privateImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.left.equalTo(self.titleLabel.mas_right).with.offset(5);
    }];
    self.secondTitleLabel.frame = CGRectMake((APP_SCREEN_WIDTH-200)*0.5, 26, 200, 18);
}

-(UIImageView *)privateImgV{
    if (!_privateImgV) {
        _privateImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"private_lock"]];
    }
    return _privateImgV;
}

@end

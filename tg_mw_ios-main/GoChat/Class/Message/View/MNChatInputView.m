//
//  MNChatInputView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/8.
//

#import "MNChatInputView.h"

@interface MNChatInputView ()
<UITextViewDelegate>
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIView *tvBgView;//中间输入的view
@property (nonatomic, strong) UIButton *addBtn;//左侧添加按钮
@property (nonatomic, strong) UIButton *emotionBtn;//表情的按钮
@property (nonatomic, strong) UIButton *talkBtn;//语音 有选中状态和
@property (nonatomic, strong) UIButton *delayBtn;//延时的按钮


@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIView *delayView;
@property (nonatomic, assign) CGFloat heightForSuperView;
@property (nonatomic, assign) CGFloat widthForSuperView;


@end

@implementation MNChatInputView

- (instancetype)initWithSuperView:(UIView *)superView
{
    self = [super init];
    if (self) {
        _heightForSuperView = superView.frame.size.height;
        _widthForSuperView = kScreenWidth();
        [self initUI];
        [superView addSubview:self];
        self.frame = CGRectMake(0, 0, self.widthForSuperView, self.heightForSuperView);
    }
    return self;
}

- (void)refreshToolBarWithNoDelay:(BOOL)noDelay{
    self.delayBtn.hidden = noDelay;
    if (noDelay) {
        [self.tv mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-45);
        }];
    }else{
        [self.tv mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-80);
        }];
    }
}
- (void)freshUIWithType:(NSInteger)type{
    self.frame = CGRectMake(0, self.heightForSuperView-60, self.widthForSuperView, 60);
}
- (void)initUI{
    [self addSubview:self.toolBar];
    [self.toolBar addSubview:self.addBtn];
    [self.toolBar addSubview:self.tvBgView];
    [self.toolBar addSubview:self.talkBtn];
    [self.toolBar addSubview:self.lineView];
    [self.tvBgView addSubview:self.tv];
    [self.tvBgView addSubview:self.delayBtn];
    [self.tvBgView addSubview:self.emotionBtn];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_offset(0);
    }];
    [self.tvBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(37);
        make.left.mas_equalTo(40);
        make.center.mas_equalTo(0);
    }];
    [self.talkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-5);
    }];
    
    [self.emotionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(0);
    }];
    [self.delayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.emotionBtn.mas_left).with.offset(-5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.mas_equalTo(0);
    }];
    [self.tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(7.5);
//        make.top.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-80);
        make.height.mas_equalTo(37);
    }];
//    [self.tvBgView addSubview:self.tv];
//    [self.tv mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(12.5);
//        make.top.mas_equalTo(8);
//        make.right.e
//    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
}
-(UIView *)toolBar{
    if (!_toolBar) {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightForSuperView-60, self.widthForSuperView, 60)];
        _toolBar.backgroundColor = [UIColor whiteColor];
        
        
    }
    return _toolBar;
}

-(UIView *)tvBgView{
    if (!_tvBgView) {
        _tvBgView = [[UIView alloc] init];
        _tvBgView.backgroundColor = [UIColor colorForF5F9FA];
        _tvBgView.layer.masksToBounds = YES;
        _tvBgView.layer.cornerRadius = 18.5;
    }
    return _tvBgView;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorTextForE5EAF0];
    }
    return _lineView;
}

-(UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"ChatAdd"] forState:UIControlStateNormal];
    }
    return _addBtn;
}

-(UIButton *)delayBtn{
    if (!_delayBtn) {
        _delayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delayBtn setImage:[UIImage imageNamed:@"ChatDelay"] forState:UIControlStateNormal];
    }
    return _delayBtn;
}

-(UIButton *)emotionBtn{
    if (!_emotionBtn) {
        _emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emotionBtn setImage:[UIImage imageNamed:@"ChatEmotion"] forState:UIControlStateNormal];
    }
    return _emotionBtn;
}

-(UIButton *)talkBtn{
    if (!_talkBtn) {
        _talkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_talkBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
        [_talkBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    }
    return _talkBtn;
}


-(UITextView *)tv{
    if (!_tv) {
        _tv = [[UITextView alloc] init];
        _tv.placeholder = @"输入消息...".lv_localized;
        _tv.backgroundColor = [UIColor clearColor];
        _tv.font = fontRegular(15);
        
    }
    return _tv;
}
@end

//
//  DeleteTipPopView.m
//  LoganSmart
//
//  Created by 许蒙静 on 2021/10/25.
//

#import "DeleteTipPopView.h"

@interface DeleteTipPopView ()
@property (nonatomic, copy) NSString *content;
@end

@implementation DeleteTipPopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithContent:(NSString *)content
{
    self = [super init];
    if (self) {
        [self refreshContent:content];
        [self initUI];
    }
    return self;
}

- (void)refreshContent:(NSString *)content{
    _content = [Util objToStr:content];
    CGFloat height = [self.content heightWithFont:fontRegular(17) width:kScreenWidth-2*left_margin32()];
    CGFloat maxHeight = MAX(height, 50);//最小就是50
    CGFloat minHeight = MIN(maxHeight, 250);//内容最高是250
    self.contentHeight = 32+minHeight +80 + kBottom34();
    self.contentLabel.text = content;
}

- (void)cancelAction{
    [self hide];
    if ([self.commonDelegate respondsToSelector:@selector(popView:touchUpInsideCancel:)]) {
        [self.commonDelegate popView:self touchUpInsideCancel:self.cancelBtn];
    }
    
}

- (void)deleteAction{
    [self hide];
    if ([self.commonDelegate respondsToSelector:@selector(popView:touchUpInsideDelete:)]) {
        [self.commonDelegate popView:self touchUpInsideDelete:self.deleteBtn];
    }
}
- (void)initUI{
    [self.bottomView addSubview:self.contentLabel];
    [self.bottomView addSubview:self.cancelBtn];
    [self.bottomView addSubview:self.deleteBtn];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(32);
        make.centerX.mas_equalTo(0);
        make.left.mas_equalTo(left_margin32());
    }];
    CGFloat width = (kScreenWidth-left_margin32()*2-33)/2.0;
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-12-kBottom34());
        make.left.mas_equalTo(left_margin32());
        make.size.mas_equalTo(CGSizeMake(width, 36));
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.cancelBtn);
        make.right.mas_equalTo(-left_margin32());
        make.size.equalTo(self.cancelBtn);
    }];
}

-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = fontRegular(17);
        _contentLabel.textColor = [UIColor colorForTextMain];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _contentLabel;
}

-(UIColorButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIColorButton alloc] initWithColorType:UIButtonColorTypeGray Title:LocalString(localCancel)];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

-(UIColorButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [[UIColorButton alloc] initWithColorType:UIButtonColorTypeGrayDelete Title:LocalString(localDelete)];
        [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}


@end

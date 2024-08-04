//
//  GC_CommentFooterView.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/16.
//

#import "GC_CommentFooterView.h"

@implementation GC_CommentFooterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initUI];
    }
    return self;
}
- (void)initUI{
    self.backGroudView = [UIView new];
    self.backGroudView.backgroundColor = [UIColor colorForF5F9FA];
    self.backGroudView.clipsToBounds = YES;
    self.backGroudView.layer.cornerRadius = 13;
    [self addSubview:self.backGroudView];
    
    self.contentLab = [UILabel new];
    self.contentLab.font = [UIFont regularCustomFontOfSize:15];
    self.contentLab.textColor = [UIColor colorTextForA9B0BF];
    self.contentLab.text = @"添加评论".lv_localized;
    [self.backGroudView addSubview:self.contentLab];
    
    [self.backGroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(42);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.centerY.mas_equalTo(0);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  GC_ExpressionDetailTopView.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_ExpressionDetailTopView.h"


@implementation GC_ExpressionDetailTopView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)initUI{
    self.headerImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_mine_place1"]];
    [self addSubview:self.headerImageV];
    [self.headerImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.height.mas_equalTo(90);
        make.top.mas_equalTo(20);
    }];
    
    self.titleLab = [UILabel new];
    self.titleLab.font = [UIFont regularCustomFontOfSize:17];
    self.titleLab.textColor = [UIColor colorTextFor23272A];
    self.titleLab.text = @"蘑菇头表情包".lv_localized;
    [self addSubview:self.titleLab];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageV.mas_right).offset(15);
        make.top.mas_equalTo(self.headerImageV.mas_top).offset(0);
    }];
    
    self.numLab = [UILabel new];
    self.numLab.font = [UIFont regularCustomFontOfSize:15];
    self.numLab.textColor = [UIColor colorTextForA9B0BF];
    self.numLab.text = @"200次添加".lv_localized;
    [self addSubview:self.numLab];
    
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImageV.mas_right).offset(15);
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(5);
    }];
    
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuBtn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
    [self setFollowStatus:NO];
    [self addSubview:self.menuBtn];

    [self.menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(61);
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(self.headerImageV.mas_right).offset(15);
        make.bottom.mas_equalTo(self.headerImageV.mas_bottom).offset(-5);
    }];
    
    self.desLab = [UILabel new];
    self.desLab.font = [UIFont regularCustomFontOfSize:16];
    self.desLab.textColor = [UIColor colorTextForA9B0BF];
    self.desLab.text = [NSString stringWithFormat:@"该表情为%@提供，可直接添加".lv_localized, localAppName.lv_localized];
    [self addSubview:self.desLab];
    
    [self.desLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.headerImageV.mas_bottom).offset(25);
    }];
    
    self.lineLab = [UILabel new];
    self.lineLab.backgroundColor = [UIColor colorTextForE5EAF0];
    [self addSubview:self.lineLab];
    
    [self.lineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
}

- (void)setFollowStatus:(BOOL)isSelect{
    if (isSelect) {
        [self.menuBtn setTitle:@"已添加".lv_localized forState:UIControlStateNormal];
        [self.menuBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
        [self.menuBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.menuBtn.backgroundColor = [UIColor colorForF5F9FA];
        self.menuBtn .layer.borderWidth = 0;
        self.menuBtn .layer.cornerRadius = 8;
    }else{
        [self.menuBtn setTitle:@"添加".lv_localized forState:UIControlStateNormal];
        [self.menuBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        self.menuBtn .layer.borderWidth = 1;
        self.menuBtn .layer.borderColor = [UIColor colorMain].CGColor;
        self.menuBtn .layer.backgroundColor = [UIColor colorMain].CGColor;
        self.menuBtn .layer.cornerRadius = 8;
        self.menuBtn.backgroundColor = [UIColor whiteColor];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

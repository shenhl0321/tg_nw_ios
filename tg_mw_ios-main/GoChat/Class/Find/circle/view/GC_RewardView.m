//
//  GC_RewardView.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_RewardView.h"

@implementation GC_RewardView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        self.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:229/255.0 blue:230/255.0 alpha:1.0].CGColor;
        self.layer.cornerRadius = 11;
        self.clipsToBounds = YES;
    }
    return  self;
}
- (void)initUI{
    self.moneyImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_circle_pakge"]];
    [self addSubview:self.moneyImageV];
    
    self.priceLab = [UILabel new];
    self.priceLab.font = [UIFont regularCustomFontOfSize:14];
    self.priceLab.textColor = [UIColor colorforFD4E57];
    self.priceLab.text = @"¥98.9";
    [self addSubview:self.priceLab];
    
    [self.moneyImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.width.height.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.moneyImageV.mas_right).offset(2);
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

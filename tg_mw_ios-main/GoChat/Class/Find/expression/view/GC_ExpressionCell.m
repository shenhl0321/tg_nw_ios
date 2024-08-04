//
//  GC_ExpressionCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_ExpressionCell.h"

@implementation GC_ExpressionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:14];
    // Initialization code
    [self setFollowStatus:NO];
}

- (void)setFollowStatus:(BOOL)isSelect{
    if (isSelect) {
        [self.addBtn setTitle:@"已添加".lv_localized forState:UIControlStateNormal];
        [self.addBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
        [self.addBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.addBtn.backgroundColor = [UIColor colorForF5F9FA];
        self.addBtn .layer.borderWidth = 0;
        self.addBtn .layer.cornerRadius = 8;
    }else{
        [self.addBtn setTitle:@"添加".lv_localized forState:UIControlStateNormal];
        [self.addBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        self.addBtn .layer.borderWidth = 1;
        self.addBtn .layer.borderColor = [UIColor colorMain].CGColor;
        self.addBtn .layer.backgroundColor = [UIColor colorMain].CGColor;
        self.addBtn .layer.cornerRadius = 8;
        self.addBtn.backgroundColor = [UIColor whiteColor];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  GC_OtherMenuCell.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/7.
//

#import "GC_OtherMenuCell.h"

@implementation GC_OtherMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.hiBtn.clipsToBounds = YES;
    self.hiBtn.layer.cornerRadius = 13;
    self.hiBtn.backgroundColor = [UIColor colorMain];
    
    self.complaintBtn.clipsToBounds = YES;
    self.complaintBtn.layer.cornerRadius = 13;
    [self.complaintBtn setTitleColor:[UIColor colorTextForA9B0BF] forState:UIControlStateNormal];
    self.complaintBtn.layer.borderColor = [UIColor colorTextForA9B0BF].CGColor;
    self.complaintBtn.layer.borderWidth = 1;
    self.complaintBtn.backgroundColor = [UIColor whiteColor];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

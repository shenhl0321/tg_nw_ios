//
//  GC_MySetButtonCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_MySetButtonCell.h"

@implementation GC_MySetButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.eventBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

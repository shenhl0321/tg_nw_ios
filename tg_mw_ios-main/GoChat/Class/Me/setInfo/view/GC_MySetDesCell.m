//
//  GC_MySetDesCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_MySetDesCell.h"

@implementation GC_MySetDesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.desLab.numberOfLines = 2;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

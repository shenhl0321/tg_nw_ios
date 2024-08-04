//
//  GC_CircleCommentCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_CircleCommentCell.h"

@implementation GC_CircleCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.parsieBtn setTitle:@"" forState:UIControlStateNormal];
    [self.replyBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
    [self.replyBtn setTintColor:[UIColor colorMain]];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

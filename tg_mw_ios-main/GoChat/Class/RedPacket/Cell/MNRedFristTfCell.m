//
//  MNRedFristTfCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNRedFristTfCell.h"

@implementation MNRedFristTfCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initUI{
    [super initUI];
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
    }];
    self.leftLabel.text = @"红包个数".lv_localized;
    self.rightLabel.text = @"个".lv_localized;
    self.tf.placeholder = @"填写个数".lv_localized;
}

@end

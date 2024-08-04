//
//  GC_CommonInputCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_CommonInputCell.h"

@implementation GC_CommonInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    self.titleLab.text = [dataDic stringValueForKey:@"title" defaultValue:@""];
    self.input.placeholder = [dataDic stringValueForKey:@"place" defaultValue:@""];
}
@end

//
//  GC_CashAccountCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_CashAccountCell.h"

@implementation GC_CashAccountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.reBindLab.textColor = [UIColor colorMain];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    self.titleLab.text = [dataDic stringValueForKey:@"title" defaultValue:@""];
    self.imageV.image = [UIImage imageNamed:[dataDic stringValueForKey:@"image" defaultValue:@""]];
}

@end

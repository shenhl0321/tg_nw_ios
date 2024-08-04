//
//  GC_MyWalletCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/5.
//

#import "GC_MyWalletCell.h"

@implementation GC_MyWalletCell

- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    
    self.imageV.image = [UIImage imageNamed:[dataDic stringValueForKey:@"image" defaultValue:@""].lv_Style];
    self.titleLab.text = [dataDic stringValueForKey:@"title" defaultValue:@""];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLab.textColor = [UIColor colorTextFor23272A];
    self.titleLab.font = [UIFont regularCustomFontOfSize:16];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

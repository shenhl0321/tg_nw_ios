//
//  GC_MinePakgeCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import "GC_MinePakgeCell.h"

@implementation GC_MinePakgeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundImageV.image = [UIImage imageNamed:@"icon_mine_myPakge".lv_Style];
    self.backgroundImageV.contentMode = UIViewContentModeScaleToFill;
    self.maPakgeImageV.image = [UIImage imageNamed:@"icon_mine_myPakge_p".lv_Style];
    self.arrowImageV.image = [UIImage imageNamed:@"icon_mine_myPakge_arrow".lv_Style];
    
    self.wtLab.textColor = [UIColor colorTextForFFFFFF];
    self.wtLab.font = [UIFont semiBoldCustomFontOfSize:14];
    
    self.priceLab.textColor = [UIColor colorTextForFFFFFF];
    self.priceLab.font = [UIFont semiBoldCustomFontOfSize:24];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

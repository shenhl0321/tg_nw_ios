//
//  GC_CollectionRecordCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/13.
//

#import "GC_CollectionRecordCell.h"

@implementation GC_CollectionRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentV.clipsToBounds = YES;
    self.contentV.layer.cornerRadius = 13;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
}

@end

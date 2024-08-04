//
//  CZGroupInvitationTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/9.
//

#import "CZGroupInvitationTableViewCell.h"

@interface CZGroupInvitationTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@end

@implementation CZGroupInvitationTableViewCell

- (void)setCellModel:(CZGroupInvitatioModel *)cellModel{
    _cellModel = cellModel;
    if (cellModel) {
        _mainLabel.text = cellModel.tipsStr;
        _mainLabel.font = [UIFont systemFontOfSize:cellModel.fontSize];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  CZRegisterTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "CZRegisterTableViewCell.h"

@interface CZRegisterTableViewCell ()
@property (weak, nonatomic) IBOutlet UITextField *mainTextField;

@end

@implementation CZRegisterTableViewCell

- (void)setCellModel:(CZRegisterInputModel *)cellModel{
    _cellModel = cellModel;
    if (cellModel) {
        _mainTextField.placeholder = cellModel.placeStr;
        self.tag = cellModel.fieldCellTag;
    }
}

- (NSString *)inputString{
    return _mainTextField.text;;
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

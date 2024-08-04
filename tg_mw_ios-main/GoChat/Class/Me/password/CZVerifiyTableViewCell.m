//
//  CZChoiceCountyTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "CZVerifiyTableViewCell.h"

@interface CZVerifiyTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIView *lineLab;
@end

@implementation CZVerifiyTableViewCell

- (void)setCellModel:(CZRegisterInputModel *)cellModel{
    _cellModel = cellModel;
    if (cellModel) {
        _inputField.placeholder = cellModel.placeStr;
        self.tag = cellModel.fieldCellTag;
        _titleLabel.text = cellModel.titleStr;
    }
}

- (NSString *)inputString{
    return _inputField.text;;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.inputField.keyboardType = UIKeyboardTypeASCIICapable;
    self.lineLab.backgroundColor = [UIColor colorMain];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

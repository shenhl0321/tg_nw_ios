//
//  CZChoiceCountyTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "CZChoiceCountyTableViewCell.h"

@interface CZChoiceCountyTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *areaCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;

@end

@implementation CZChoiceCountyTableViewCell

- (void)setCellModel:(CZRegisterInputModel *)cellModel{
    _cellModel = cellModel;
    if (cellModel) {
        _inputField.placeholder = cellModel.placeStr;
        self.tag = cellModel.fieldCellTag;
    }
}

- (void)setCountrycode:(NSString *)countrycode{
    _countrycode = countrycode;
    if (countrycode) {
        _countryLabel.text = countrycode;
    }
}

- (NSString *)inputString{
    return _inputField.text;;
}

//地区区号选择
- (IBAction)countryChoiceClick:(UIButton *)sender {
    if (_block) {
        _block();
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

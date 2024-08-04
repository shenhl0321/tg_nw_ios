//
//  CZChoiceCountyTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "QTChangeLoginPasswordCell.h"

@interface QTChangeLoginPasswordCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation QTChangeLoginPasswordCell

- (void)setCellModel:(CZRegisterInputModel *)cellModel{
    _cellModel = cellModel;
    if (cellModel) {
        self.inputField.placeholder = cellModel.placeStr;
        self.tag = cellModel.fieldCellTag;
        self.titleLabel.text = cellModel.titleStr;
        
        if ([self.titleLabel.text isEqualToString:@"原密码".lv_localized]){
            self.statusBtn.hidden = NO;
            self.inputField.secureTextEntry = YES;
        }else{
            self.statusBtn.hidden = YES;
            self.inputField.secureTextEntry = NO;
        }
    }
}

- (NSString *)inputString{
    return _inputField.text;;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.inputField.keyboardType = UIKeyboardTypeASCIICapable;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buttonClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    self.inputField.secureTextEntry = !sender.selected;
}


@end

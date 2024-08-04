//
//  CZEditThridTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import "CZEditThridTableViewCell.h"

@interface CZEditThridTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *aLabel;

@end
@implementation CZEditThridTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.aLabel.font = fontRegular(16);
    self.aLabel.textColor = [UIColor colorTextFor23272A];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

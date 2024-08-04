//
//  CZGroupNameTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import "CZGroupNameTableViewCell.h"

@interface CZGroupNameTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *groupImageview;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupMembersLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupIntroduceLabel;

@end

@implementation CZGroupNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)settingGropuHeaderImageClick:(UIButton *)sender {
    
}

- (IBAction)settingGroupIntroduceClick:(UIButton *)sender {
    
}

@end

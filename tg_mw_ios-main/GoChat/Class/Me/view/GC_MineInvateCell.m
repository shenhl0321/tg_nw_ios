//
//  GC_MineInvateCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import "GC_MineInvateCell.h"

@implementation GC_MineInvateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.inviteImageV.image = [UIImage imageNamed:@"icon_mine_addFriend".lv_Style];
    self.inviteLab.textColor = [UIColor colorTextFor23272A];
    self.inviteLab.font = [UIFont regularCustomFontOfSize:14];
    
    self.nearImageV.image = [UIImage imageNamed:@"icon_mine_near".lv_Style];
    self.nearLab.textColor = [UIColor colorTextFor23272A];
    self.nearLab.font = [UIFont regularCustomFontOfSize:14];
    
    self.groupImageV.image = [UIImage imageNamed:@"icon_mine_group".lv_Style];
    self.groupLab.textColor = [UIColor colorTextFor23272A];
    self.groupLab.font = [UIFont regularCustomFontOfSize:14];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.inviteView.tag = 0;
    UITapGestureRecognizer *inviteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [self.inviteView addGestureRecognizer:inviteTap];
    
    self.nearView.tag = 1;
    UITapGestureRecognizer *nearTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [self.nearView addGestureRecognizer:nearTap];
    
    self.groupView.tag = 2;
    UITapGestureRecognizer *groupTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [self.groupView addGestureRecognizer:groupTap];
    
    // Initialization code
}
- (void)tapGes:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    
    if(self.menuBlock){
        self.menuBlock(tag);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (UIView *)contentVV{
//    if (!_contentVV) {
//        _contentVV = [UIView new];
//        _contentVV.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
//        _contentVV.layer.cornerRadius = 13;
//        _contentVV.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
//        _contentVV.layer.shadowOffset = CGSizeMake(0,0);
//        _contentVV.layer.shadowOpacity = 1;
//        _contentVV.layer.shadowRadius = 7;
//    }
//    return _contentVV;
//}

@end

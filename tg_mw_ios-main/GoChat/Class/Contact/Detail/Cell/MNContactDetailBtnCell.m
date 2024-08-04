//
//  MNContactDetailBtnCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNContactDetailBtnCell.h"

@implementation MNContactDetailBtnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillDataWithUser:(UserInfo *)user chat:(ChatInfo *)chat{
    if (chat.is_blocked) {
        [self.bottomBtn setTitle:@"取消屏蔽".lv_localized forState:UIControlStateNormal];
    }else{
        [self.bottomBtn setTitle:@"屏蔽此人".lv_localized forState:UIControlStateNormal];
    }
}
- (void)initUI{
    [super initUI];
    self.needLine = YES;
    [self.contentView addSubview:self.topBtn];
    [self.contentView addSubview:self.bottomBtn];
    [self.topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(25);
    }];
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topBtn);
        make.right.equalTo(self.topBtn);
        make.height.equalTo(self.topBtn);
        make.top.equalTo(self.topBtn.mas_bottom).with.offset(15);
    }];
}
-(UIButton *)topBtn{
    if (!_topBtn) {
        _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topBtn mn_loginStyle];
        [_topBtn setTitle:@"加为好友".lv_localized forState:UIControlStateNormal];
        [_topBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBtn;
}

-(UIButton *)bottomBtn{
    if (!_bottomBtn) {
        _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomBtn setTitle:@"屏蔽此人/取消屏蔽".lv_localized forState:UIControlStateNormal];
        [_bottomBtn mn_registerStyle];
        [_bottomBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBtn;
}

- (void)btnAction:(UIButton *)btn{
    if (self.clickBtnBlock) {
        self.clickBtnBlock(btn);
    }
}
@end

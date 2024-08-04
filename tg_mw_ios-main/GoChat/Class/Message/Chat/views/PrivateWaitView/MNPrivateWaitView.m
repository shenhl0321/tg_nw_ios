//
//  MNPrivateWaitView.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/8.
//

#import "MNPrivateWaitView.h"

@implementation MNPrivateWaitView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self initUI];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreenWidth(), 60);
        [self initUI];
    }
    return self;
}

- (void)initUI{
//    self.backgroundColor = [UIColor colorForF5F9FA];
    self.backgroundColor = HEXCOLOR(0xF5F9FA);
    [self addSubview:self.btn];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.hidden = YES;
}

- (void)setUserInfo:(UserInfo *)userInfo{
    _userInfo = userInfo;
    [_btn setTitle:[NSString stringWithFormat:@"等待 %@上线...".lv_localized, userInfo.displayName] forState:UIControlStateNormal];
}


-(UIButton *)btn{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *imgN = [NSString stringWithFormat:@"private_wait_%ld", MNThemeMgr().themeStyle];
        [_btn setImage:[UIImage imageNamed:imgN] forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor colorTextFor0DBFC0] forState:UIControlStateNormal];
        _btn.titleLabel.font = fontRegular(15);
        [_btn setTitle:@"等待 用户昵称上线...".lv_localized forState:UIControlStateNormal];
        [_btn setBackgroundColor:[UIColor colorForF5F9FA]];
        [_btn setImage:[UIImage imageNamed:@"private_wait"] forState:UIControlStateNormal];
        [_btn setImagePosition:LXMImagePositionLeft spacing:7];
        _btn.enabled = NO;
    }
    return _btn;
}

@end

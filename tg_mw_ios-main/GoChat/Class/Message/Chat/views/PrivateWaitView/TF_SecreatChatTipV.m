//
//  TF_SecreatChatTipV.m
//  GoChat
//
//  Created by apple on 2022/2/25.
//

#import "TF_SecreatChatTipV.h"

@interface TF_SecreatChatTipV()
/// <#code#>
@property (nonatomic,strong) UIView *contentV;
/// <#code#>
@property (nonatomic,strong) UILabel *titleL;


@end

@implementation TF_SecreatChatTipV

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentV];
        [self.contentV addSubview:self.titleL];
        [self layoutUI];
        
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        self.backgroundColor = XHQRGBA(0, 0, 0, 0.3);
    }
    return self;
}

- (void)layoutUI{
    [self.contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    UILabel *tip1 = [self creatTipLableWithText:@"加密对话:".lv_localized];
    [self.contentV addSubview:tip1];
    
    [tip1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(self.titleL.mas_bottom).mas_offset(8);
    }];
    
    UIImageView *tipImg2 = [self lockImageV];
    UILabel *tip2 = [self creatTipLableWithText:@"使用端到端加密".lv_localized];
    [self.contentV addSubview:tipImg2];
    [self.contentV addSubview:tip2];
    [tipImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tip1);
        make.width.height.mas_equalTo(15);
        make.top.mas_equalTo(tip1.mas_bottom).offset(10);
    }];
    [tip2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(tipImg2);
        make.left.mas_equalTo(tipImg2.mas_right).offset(5);
    }];
    
    UIImageView *tipImg3 = [self lockImageV];
    UILabel *tip3 = [self creatTipLableWithText:@"不会在我们的服务器上留下任何痕迹".lv_localized];
    [self.contentV addSubview:tipImg3];
    [self.contentV addSubview:tip3];
    
    [tipImg3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipImg2);
        make.width.height.mas_equalTo(15);
        make.top.mas_equalTo(tip2.mas_bottom).offset(10);
    }];
    [tip3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(tipImg3);
        make.left.mas_equalTo(tipImg3.mas_right).offset(5);
    }];
    
    UIImageView *tipImg4 = [self lockImageV];
    UILabel *tip4 = [self creatTipLableWithText:@"支持阅后即焚".lv_localized];
    [self.contentV addSubview:tipImg4];
    [self.contentV addSubview:tip4];
    
    [tipImg4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipImg2);
        make.width.height.mas_equalTo(15);
        make.top.mas_equalTo(tip3.mas_bottom).offset(10);
    }];
    [tip4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(tipImg4);
        make.left.mas_equalTo(tipImg4.mas_right).offset(5);
    }];
    
    
    UIImageView *tipImg5 = [self lockImageV];
    UILabel *tip5 = [self creatTipLableWithText:@"不允许转发消息".lv_localized];
    [self.contentV addSubview:tipImg5];
    [self.contentV addSubview:tip5];
    
    [tipImg5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipImg2);
        make.width.height.mas_equalTo(15);
        make.top.mas_equalTo(tip4.mas_bottom).offset(10);
    }];
    [tip5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(tipImg5);
        make.left.mas_equalTo(tipImg5.mas_right).offset(5);
    }];
}

- (void)setUserInfo:(UserInfo *)userInfo{
    _userInfo = userInfo;
    if (self.chatInfo.secretChatInfo.is_outbound) {
        self.titleL.text = [NSString stringWithFormat:@"您已邀请%@加入私密聊天".lv_localized, userInfo.displayName];
        
    } else {
        self.titleL.text = [NSString stringWithFormat:@"%@邀请您加入私密聊天".lv_localized, userInfo.displayName];
    }
}

- (UILabel *)creatTipLableWithText:(NSString *)text{
    UILabel *tipL = [[UILabel alloc] init];
    tipL.textColor = [UIColor whiteColor];
    tipL.font = XHQFont(14);
    tipL.text = text;
    tipL.textAlignment = NSTextAlignmentLeft;
    return tipL;
}

- (UIImageView *)lockImageV{
    UIImageView *lock = [[UIImageView alloc] init];
    lock.image = [UIImage imageNamed:@"secreat_tip_lock"];
    
    return lock;
}

- (UILabel *)titleL{
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.textColor = [UIColor whiteColor];
        _titleL.font = XHQFont(16);
        _titleL.text = @"您已邀请顾客加入私密聊天".lv_localized;
        _titleL.textAlignment = NSTextAlignmentCenter;
    }
    return _titleL;
}

- (UIView *)contentV{
    if (!_contentV) {
        _contentV = [[UIView alloc] init];
        _contentV.layer.cornerRadius = 10;
        _contentV.clipsToBounds = YES;
    }
    return _contentV;
}

@end

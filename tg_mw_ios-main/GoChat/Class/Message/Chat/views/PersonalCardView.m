//
//  PersonalCardView.m
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import "PersonalCardView.h"

@interface PersonalCardView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nicknameLab;
@property (nonatomic, strong) UILabel *cardNicknameLab;
@property (nonatomic, strong) UITextField *leaveWordTF;
@property (nonatomic, strong) UIView *lineV;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation PersonalCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews{
    [self addSubview:self.bgView];
    [self addSubview:self.whiteView];
    [self.whiteView addSubview:self.titleLab];
    [self.whiteView addSubview:self.iconImgV];
    [self.whiteView addSubview:self.nicknameLab];
    [self.whiteView addSubview:self.cardNicknameLab];
    [self.whiteView addSubview:self.leaveWordTF];
    [self.whiteView addSubview:self.lineV];
    [self.whiteView addSubview:self.cancelBtn];
    [self.whiteView addSubview:self.sendBtn];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.mas_equalTo(0);
    }];
    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(284);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(22);
        make.left.mas_equalTo(25);
        make.height.mas_equalTo(27);
    }];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLab.mas_left);
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(10);
        make.width.height.mas_equalTo(42);
    }];
    [self.nicknameLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.iconImgV.mas_top).offset(12);
        make.centerY.equalTo(self.iconImgV);
        make.left.mas_equalTo(self.iconImgV.mas_right).offset(10);
        make.right.mas_equalTo(-25);
        make.height.mas_equalTo(24);
    }];
    [self.cardNicknameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImgV.mas_bottom).offset(22);
        make.left.mas_equalTo(self.iconImgV.mas_left);
        make.right.mas_equalTo(-25);
        make.height.mas_equalTo(24);
    }];
    [self.leaveWordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cardNicknameLab.mas_left);
        make.top.mas_equalTo(self.cardNicknameLab.mas_bottom).offset(20);
        make.right.mas_equalTo(-25);
        make.height.mas_equalTo(42);
    }];
    [self.lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leaveWordTF.mas_bottom).offset(20);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineV.mas_bottom).mas_offset(14);
        make.left.mas_equalTo(54);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(24);
    }];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineV.mas_bottom).mas_offset(14);
        make.right.mas_equalTo(-54);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(24);
    }];
    
}


- (void)resetChatInfo:(id)chat sendChatInfo:(ChatInfo *)sendChatInfo
{
    
    //    只显示个人名片那的备注
    if ([chat isKindOfClass:[ChatInfo class]]) {
        ChatInfo *chatInfo = (ChatInfo *)chat;
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:chatInfo.userId];
        if(user != nil)
        {
            self.cardNicknameLab.text = [NSString stringWithFormat:@"[个人名片] %@".lv_localized,user.displayName];
        }
        else
        {
            self.cardNicknameLab.text = [NSString stringWithFormat:@"[个人名片] %@".lv_localized,chatInfo.title];
        }
    } else if ([chat isKindOfClass:[UserInfo class]]){
        UserInfo *userInfo = (UserInfo *)chat;
        self.cardNicknameLab.text = [NSString stringWithFormat:@"[个人名片] %@".lv_localized,userInfo.displayName];
    }
    
    //    显示头像、昵称
    if ([sendChatInfo isKindOfClass:[ChatInfo class]]) {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:sendChatInfo.userId];
        if(user != nil)
        {
            if(user.profile_photo != nil)
            {
                if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
                {
                    [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                    //本地头像
                    self.iconImgV.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
                }
                else
                {
                    [UserInfo cleanColorBackgroundWithView:self.iconImgV];
                    self.iconImgV.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }
            else
            {
                //本地头像
                self.iconImgV.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
            }
            self.nicknameLab.text = user.displayName;
        }
        else
        {
            //本地头像
            self.iconImgV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(sendChatInfo.title.length>0)
            {
                text = [[sendChatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
            self.nicknameLab.text = sendChatInfo.title;
        }
    }
    
}

- (void)cardShareCancelEvent:(UIButton *)button {
    if (self.personalCardCancelBlock) {
        self.personalCardCancelBlock(button);
    }
}

- (void)cardShareSendEvent:(UIButton *)button {
    if (self.personalCardSendBlock) {
        self.personalCardSendBlock(button);
    }
}

#pragma mark - UITextFieldDidChange
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textField %@",textField.text);
}


- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = RGBA(0, 0, 0, 0.67);
    }
    return _bgView;
}

- (UIView *)whiteView {
    if (!_whiteView) {
        _whiteView = [[UIView alloc] init];
        _whiteView.layer.cornerRadius = 10;
        _whiteView.layer.masksToBounds = YES;
        _whiteView.backgroundColor = UIColor.whiteColor;
    }
    return _whiteView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = fontRegular(19);
        _titleLab.textColor = [UIColor colorTextFor23272A];
        _titleLab.text = @"发送给:".lv_localized;
    }
    return _titleLab;
}

- (UIImageView *)iconImgV {
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_default_header"]];
        _iconImgV.layer.cornerRadius = 21;
        _iconImgV.layer.masksToBounds=YES;
    }
    return _iconImgV;
}

- (UILabel *)nicknameLab {
    if (!_nicknameLab) {
        _nicknameLab = [[UILabel alloc] init];
        _nicknameLab.font = fontRegular(17);
        _nicknameLab.textColor = [UIColor colorTextFor23272A];
        _nicknameLab.text = @"昵称".lv_localized;
    }
    return _nicknameLab;
}

- (UILabel *)cardNicknameLab {
    if (!_cardNicknameLab) {
        _cardNicknameLab = [[UILabel alloc] init];
        _cardNicknameLab.font = fontRegular(17);
        _cardNicknameLab.textColor = [UIColor colorFor878D9A];
        _cardNicknameLab.text = @"[个人名片] a003小红帽".lv_localized;
    }
    return _cardNicknameLab;
}

- (UITextField *)leaveWordTF {
    if (!_leaveWordTF) {
        _leaveWordTF = [[UITextField alloc] init];
        _leaveWordTF.delegate = self;
        [_leaveWordTF mn_defalutStyleWithFont:fontRegular(15) leftMargin:12];
        _leaveWordTF.placeholder = @"给朋友留言".lv_localized;
        
//        _leaveWordTF.textColor = HEX_COLOR(@"#010009");
//        _leaveWordTF.backgroundColor = HEX_COLOR(@"#f5f5f5");
        _leaveWordTF.backgroundColor = [UIColor colorForF5F9FA];
        _leaveWordTF.layer.cornerRadius = 8;
        _leaveWordTF.layer.masksToBounds = YES;
    }
    return _leaveWordTF;
}

- (UIView *)lineV {
    if (!_lineV) {
        _lineV = [[UIView alloc] init];
        _lineV.backgroundColor = [UIColor colorTextForE5EAF0];
    }
    return _lineV;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitleColor:[UIColor colorTextForA9B0BF] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = fontRegular(17);
        [_cancelBtn setTitle:@"取消".lv_localized forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cardShareCancelEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = fontRegular(17);
        [_sendBtn setTitle:@"发送".lv_localized forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(cardShareSendEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}


@end

//
//  CloseAccountVC.m
//  GoChat
//
//  Created by Autumn on 2022/2/15.
//

#import "CloseAccountVC.h"

@interface CloseAccountVC ()<TimerCounterDelegate>

@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UITextField *codeTF;

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *codeButton;
@property (strong, nonatomic) IBOutlet UIView *codeButtonLeftLine;
@property (strong, nonatomic) IBOutlet UILabel *verityTipLabel;

@property (nonatomic, assign) BOOL isGotSmsCode;
@property (nonatomic, assign) int Counter;
@property (nonatomic, strong) TimerCounter *tmCounter;

/// 使用密码验证，针对没有用手机号注册的用户
@property (nonatomic, assign, getter=isPwdVerify) BOOL pwdVerify;

@end

@implementation CloseAccountVC

- (void)dealloc {
    [self.tmCounter stopCountProcess];
    self.tmCounter = nil;
}

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"注销账号".lv_localized];
    
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.contentView.hidden = YES;
    NSString *phone = UserInfo.shareInstance.phone_number;
    if (phone && phone.length > 0) {
        if ([phone hasPrefix:@"86"]) {
            phone = [phone substringWithRange:NSMakeRange(2, phone.length - 2)];
            _phoneTF.text = [NSString stringWithFormat:@"  +86  %@", phone];
        } else {
            _phoneTF.text = [NSString stringWithFormat:@"  +%@", phone];
        }
        self.codeTF.keyboardType = UIKeyboardTypeNumberPad;
        self.pwdVerify = NO;
        self.verityTipLabel.text = @"我们将通过验证码验证您的账号，请输入您的验证码".lv_localized;
    } else {
        _phoneTF.text = [NSString stringWithFormat:@"  %@", UserInfo.shareInstance.username];
        self.pwdVerify = YES;
        self.verityTipLabel.text = @"我们将通过密码验证您的账号，请输入您的密码".lv_localized;
        self.codeButton.hidden = YES;
        self.codeButtonLeftLine.hidden = YES;
        self.codeTF.secureTextEntry = YES;
        self.codeTF.keyboardType = UIKeyboardTypeDefault;
        self.codeTF.placeholder = @"请输入登录密码".lv_localized;
    }
    [_codeTF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.submitButton xhq_cornerRadius:13];
    
    [self textFieldDidChanged:_codeTF];
    
    self.tmCounter = [TimerCounter new];
    self.tmCounter.delegate = self;
}

- (IBAction)submitAction:(id)sender {
    if (self.isPwdVerify) {
        [self submitPwdAction];
        return;
    }
    [self submitCodeAction];
}

- (void)submitCodeAction {
    if (!self.isGotSmsCode) {
        [UserInfo showTips:self.view des:@"请先获取短信验证码".lv_localized];
        return;
    }
    
    NSString *smsCode = self.codeTF.text;
    smsCode = [smsCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(smsCode.length<=0) {
        [UserInfo showTips:self.view des:@"请输入短信验证码".lv_localized];
        return;
    }
    if (smsCode.length!=5) {
        [UserInfo showTips:self.view des:@"请输入正确的短信验证码".lv_localized];
        return;
    }
    [self verityAlertShow:smsCode];
}

- (void)submitPwdAction {
    NSString *pwd = self.codeTF.text;
    if(pwd.length<=0) {
        [UserInfo showTips:self.view des:@"请输入登录密码".lv_localized];
        return;
    }
    if (pwd.length < 6) {
        [UserInfo showTips:self.view des:@"请输入正确的登录密码".lv_localized];
        return;
    }
    [self verityAlertShow:pwd];
}

- (void)verityAlertShow:(NSString *)number {
    [self.view endEditing:YES];
    //提示用户
    MMPopupItemHandler block = ^(NSInteger index) {
        if (index != 0) {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isPwdVerify) {
                [self verifyPassword:number];
            } else {
                [self verifyCode:number];
            }
        });
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, nil)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"注销账号将删除所有数据，永久注销，不可恢复。确定要注销当前账号？".lv_localized items:items];
    [view show];
}

- (void)verifyCode:(NSString *)code {
    [UserInfo show];
    [TelegramManager.shareInstance verifySmsCode:code type:SmsCodeType_CloseAccount resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if (![obj boolValue]) {
            [UserInfo showTips:self.view des:@"验证码检验失败".lv_localized];
            return;
        }
        [TelegramManager.shareInstance deleteAccount];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:self.view des:@"验证码检验失败".lv_localized];
    }];
}

- (void)verifyPassword:(NSString *)pwd {
    [UserInfo show];
    NSDictionary *parameters = @{
        @"@type": @"checkPassword",
        @"password": pwd
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if (![TelegramManager isResultOk:response]) {
            [UserInfo showTips:self.view des:@"密码检验失败".lv_localized];
            return;
        }
        [TelegramManager.shareInstance deleteAccount];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:self.view des:@"密码检验失败".lv_localized];
    }];
}


- (IBAction)codeAction:(id)sender {
    if (!UserInfo.shareInstance.phone_number || UserInfo.shareInstance.phone_number.length == 0) {
        [UserInfo showTips:nil des:@"获取手机手机号失败".lv_localized];
        return;
    }
    [UserInfo show];
    [TelegramManager.shareInstance gotSmsCode:SmsCodeType_CloseAccount resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if ([obj boolValue]) {
            self.isGotSmsCode = YES;
            [UserInfo showTips:nil des:@"验证码已发送，请查收".lv_localized];
            [self startCounter];
        } else {
            [UserInfo showTips:nil des:@"验证码获取失败，请稍后重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"验证码获取失败，请稍后重试".lv_localized];
    }];
}

- (void)startCounter {
    self.Counter = 60*5;
    self.codeButton.enabled = NO;
    [self.tmCounter stopCountProcess];
    [self.tmCounter startCountProcess:1 repeat:YES];
    NSLog(@"添加好友 - dddddddddd");
}

- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm {
    self.Counter--;
    if (self.Counter<=0) {
        self.codeButton.enabled = YES;
        [self.codeButton setTitle:@"获取验证码".lv_localized forState:UIControlStateNormal];
        [self.tmCounter stopCountProcess];
    } else {
        [self.codeButton setTitle:[Common timeFormattedForRp:self.Counter] forState:UIControlStateNormal];
    }
}

- (void)textFieldDidChanged:(UITextField *)textField {
    BOOL notEmpty = [NSString xhq_notEmpty:textField.text];
    _submitButton.enabled = notEmpty;
    _submitButton.backgroundColor = notEmpty ? UIColor.colorMain : UIColor.lightGrayColor;
}

@end

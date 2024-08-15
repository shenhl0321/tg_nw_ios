//
//  MNRegisterVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNRegisterVC.h"
#import "MNPhoneNumRow.h"
#import "MNPhoneVerCodeRow.h"
#import "TfRow.h"
#import "MNNickNameVC.h"
#import "CountryCodeViewController.h"
#import "MNMsgCodeVC.h"
#import "XinstallSDK.h"

@interface MNRegisterVC ()
<UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *rowsArray;
@property (nonatomic, strong) UITextField *phoneNumTf;
@property (nonatomic, strong) UITextField *countryCodeTf;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UITextField *userNameTf;
@property (nonatomic, strong) UITextField *msgCodeTf;
@property (nonatomic, strong) UITextField *inviteTf;
@property (nonatomic, strong) UITextField *pwdTf;
@property (nonatomic, strong) UITextField *surePwdTf;
@property (nonatomic, strong) UITextField *invitePwdTf;

@property (nonatomic, strong) NSString *channelStr;
@property (nonatomic, strong) NSString *invitedStr;

//@property (nonatomic, strong) UITextField *ret
@end

@implementation MNRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:LocalString(localRegisterAccount)];
    [self getChannalData];
    
    [self.view insertSubview:self.customNavBar atIndex:100];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    [self showLogoUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)initUI{
    _rowsArray = [[NSMutableArray alloc] init];
    AppConfigInfo *info = [AppConfigInfo sharedInstance];
    if (info.register_need_phone_code) {
        MNPhoneNumRow *phoneNumRow = [[MNPhoneNumRow alloc] init];
        phoneNumRow.onlyPhoneNumTF = NO;
        self.phoneNumTf = phoneNumRow.phoneNumTf;
        [self.phoneNumTf addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
        self.countryCodeTf = phoneNumRow.countryTf;
        self.countryCodeTf.delegate= self;
        self.phoneNumTf.placeholder = LocalString(localPlsEnterPhoneNum);
        self.countryCodeTf.placeholder = LocalString(localCountryCode);
        self.countryCodeTf.text = [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
//        [self.countryCodeTf addTarget:self action:@selector(touchUpInSideCountryCodeTf:) forControlEvents:UIControlEventEditingDidBegin];

        [self.rowsArray addObject:phoneNumRow];
//        ////    请输入手机号码
//        MNPhoneVerCodeRow *verCodeRow = [[MNPhoneVerCodeRow alloc] init];
//        self.msgCodeTf = verCodeRow.tf;
//        self.msgCodeTf.placeholder = LocalString(localPlsEnterVerificationCode);
//
//        [verCodeRow.retCodeBtn addTarget:self action:@selector(retCodeSendAction) forControlEvents:UIControlEventTouchUpInside];
//        [self.rowsArray addObject:verCodeRow];
    }
    
    TfRow *userNameRow = [[TfRow alloc] init];
    self.userNameTf = userNameRow.tf;
    [self.userNameTf addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    self.userNameTf.placeholder = LocalString(localPlsEnterUserNameLimit);
    [self.rowsArray addObject:userNameRow];
    
   
    TfRow *pwdRow = [[TfRow alloc] init];
    self.pwdTf = pwdRow.tf;
    [self.pwdTf addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    self.pwdTf.placeholder = LocalString(localPlsSetLimitLoginPwd);
    self.pwdTf.secureTextEntry = YES;
    [self.rowsArray addObject:pwdRow];
    TfRow *surePwdRow = [[TfRow alloc] init];
    self.surePwdTf = surePwdRow.tf;
    [self.surePwdTf addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    self.surePwdTf.secureTextEntry = YES;
    self.surePwdTf.placeholder = LocalString(localPlsReEnterNewPwd);
    [self.rowsArray addObject:surePwdRow];
    
    if (info.register_need_inviter) {
        TfRow *inviteRow = [[TfRow alloc] init];
        self.inviteTf = inviteRow.tf;
        self.inviteTf.placeholder = LocalString(localPlsEnterInviteCode);
        [self.rowsArray addObject:inviteRow];
        
        if(self.invitedStr && self.invitedStr.length > 0){
            self.inviteTf.text = self.invitedStr;
        }
    }
    
    for (int i = 0; i < self.rowsArray.count; i++) {
        MNRow *row = self.rowsArray[i];
        row.frame = CGRectMake(left_margin30(), 50 + i*56, APP_SCREEN_WIDTH-2*left_margin30(), 56);
        [self.contentView addSubview:row];
    }
    [self.contentView addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.left.mas_equalTo(left_margin30());
        make.height.mas_equalTo(55);
        make.top.equalTo(surePwdRow.mas_bottom).offset(80);
    }];
    
}

-(UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [UIButton mn_loginStyleWithTitle:LocalString(localNextStep)];
        _nextBtn.enabled = NO;
        [_nextBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (void)getChannalData{
    [[XinstallSDK defaultManager] getInstallParamsWithCompletion:^(XinstallData * _Nullable installData, XinstallError * _Nullable error) {
        if (error == nil) {
            // error 为 nil 时代表获取安装参数成功
                if (installData.data) { // 安装参数
                    // e.g. 如免填邀请码绑定邀请关系、自动加好友、自动进入某个群组或房间等
                    // uo 为H5网址后拼接的参数，如下载地址 https://app.xinstall.com/app/8l4hkz1?channelCode=zhihu&key1=value1&key2=value2，则uo为{channelCode=zhihu;key1=value1;key2=value2};
                    NSDictionary *uo = [installData.data objectForKey:@"uo"];
                    self.channelStr = [uo objectForKey:@"channel"];
                    self.invitedStr = [uo objectForKey:@"invite"];
//                    // co 通过H5按钮点击事件传递参数， Xinstall 支持单页面传递多事件参数。
//                    id co = [installData.data objectForKey:@"co"];
                    
                }
                if (installData.channelCode) {// 通过渠道链接或二维码唤醒会返回渠道编号
                    // e.g.可自己统计渠道相关数据等
                }
                if (installData.timeSpan > 20 ) {
                    // e.g. 超过20s不处理
                }
                NSLog(@"安装数据获取方法xinstall_getInstallParams:被调用");
                NSLog(@"XinstallSDK:\n动态参数：%@;\n渠道编号：%@", installData.data, installData.channelCode);
        } else {
            // 获取安装参数时发生错误，具体可根据 error.type 和 error.errorMsg 的值进行下一步处理
            NSLog(@"安装数据获取方法xinstall_getInstallParams:被调用");
            NSLog(@"%@",error.errorMsg);
        }
        [self initUI];
    }];
}

- (void)nextAction{
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[NSNumber numberWithBool:YES] forKey:@"isSignup"];
    AppConfigInfo *info = [AppConfigInfo sharedInstance];
    [UserInfo shareInstance].isPasswordLoginType = !info.register_need_phone_code;
    if (info.register_need_phone_code) {
        NSString *phonenumer = self.phoneNumTf.text;
        if (!phonenumer || phonenumer.length < 1) {
            [UserInfo showTips:self.view des:LocalString(localPlsEnterCorrectPhoneNum)];
            return;
        }else{
            [paramsDic setObject:[NSString stringWithFormat:@"%@%@", [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""], phonenumer] forKey:@"phoneNumber"];
            
        }
//        NSString *msgCode = self.msgCodeTf.text;
//        if(!msgCode || msgCode.length < 1){
//            [UserInfo showTips:self.view des:LocalString(localEnterSmsCode)];
//            return;
//        }else{
//            [paramsDic setObject:self.msgCodeTf.text forKey:@"code"];
//        }
    }
    
    NSString *useraccount = self.userNameTf.text;
    if (!useraccount || useraccount.length < 1) {
        [UserInfo showTips:self.view des:LocalString(localPlsEnterCorrectUserName)];
        return;
    }else{
        [paramsDic setObject:useraccount forKey:@"userName"];
    }
    
    NSString *userpwd1 = self.pwdTf.text;
    NSString *userpwd2 = self.surePwdTf.text;
    if (userpwd1 && userpwd2 &&  userpwd1.length > 5 && userpwd2.length > 5 && [userpwd1 isEqualToString:userpwd2]) {
//        [paramsDic setObject:[Common md5:userpwd1] forKey:@"password"];
        [paramsDic setObject:userpwd1 forKey:@"password"];
    }else{
        [UserInfo showTips:self.view des:LocalString(localPlsEnterCorrectLoginPwd)];
        return;
    }
    
    if (info.register_need_inviter) {
        NSString *invitationStr = self.inviteTf.text;
        if (!invitationStr || invitationStr.length < 1) {
            [UserInfo showTips:self.view des:LocalString(localPlsEnterCorrectInviteCode)];
            return;
        }else{
            [paramsDic setObject:@([invitationStr longLongValue]) forKey:@"inviteCode"];
        }
    }else{
        if(self.invitedStr && self.invitedStr.length > 0){
            [paramsDic setObject:@([self.invitedStr longLongValue]) forKey:@"inviteCode"];
        }
    }
    
    if(self.channelStr && self.channelStr.length > 0){
        [paramsDic setObject:@([self.channelStr longLongValue]) forKey:@"channelId"];
    }
    
    [UserInfo show];
    [[TelegramManager shareInstance] setAuthenticationPhoneNumber:[CZCommonTool dictionaryToJson:paramsDic] result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if(![TelegramManager isResultOk:response])
        {
            NSString *errorMsg = [TelegramManager errorMsg:response];
            if([@"400_IP_ADDRESS_BANNED" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"登录ip被禁用".lv_localized];
                return;
            }
            if([@"400_USER_BINDED_IP_ADDRESS" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"登录用户已经绑定ip".lv_localized];
                return;
            }
            if([@"400_USERNAME_INVALID" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"用户名无效".lv_localized];
                return;
            }
            if([@"400_INVITE_CODE_INVALID" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"邀请码无效".lv_localized];
                return;
            }
            if([@"400_PASSWORD_VERIFY_INVALID" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"密码无效".lv_localized];
                return;
            }
            if([@"400_PHONE_NUMBER_UNOCCUPIED" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"手机号被占用".lv_localized];
                return;
            }
            if([@"400_USERNAME_OCCUPIED" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"用户名被占用".lv_localized];
                return;
            }
            if([@"400_PHONE_NUMBER_APP_SIGNUP_FORBIDDEN" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"禁止注册新用户".lv_localized];
                return;
            }
            [UserInfo showTips:self.view des:@"无效手机号码".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"sendCode timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}


- (void)retCodeSendAction{
    NSString *phonenumer = self.phoneNumTf.text;
    if (!phonenumer || phonenumer.length < 1) {
        [UserInfo showTips:self.view des:LocalString(localPlsEnterCorrectPhoneNum)];
        return;
    }
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[NSNumber numberWithBool:YES] forKey:@"isSignup"];
    [paramsDic setObject:[NSString stringWithFormat:@"%@%@", [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""], phonenumer] forKey:@"phoneNumber"];
    
//    return;
//    NSString *newPhoneNumber = [NSString stringWithFormat:@"%@%@",self.countryCode,phonenumer];
//    newPhoneNumber = [newPhoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [UserInfo show];
    [[TelegramManager shareInstance] setAuthenticationPhoneNumber:[CZCommonTool dictionaryToJson:paramsDic] result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        
        [[TelegramManager shareInstance] setOnlineState:@"true" result:^(NSDictionary *request, NSDictionary *response) {
        } timeout:^(NSDictionary *request) {
            
        }];
        if(![TelegramManager isResultOk:response])
        {
            //{"@type":"error","code":400,"message":"PASSWORD_VERIFY_INVALID","@extra":4}
            //USER_PASSWORD_NEEDED 必须输入密码
//                        USERNAME_NOT_EXIST 用户名不存在
//                        USER_PASSWORD_NOT_SET 用户未设置密码
//                        PASSWORD_VERIFY_INVALID 密码校验错误
//                        IP_ADDRESS_BANNED 登录ip被禁用
//                        USER_BINDED_IP_ADDRESS 登录用户已经绑定ip
            NSString *errorMsg = [TelegramManager errorMsg:response];
            if([@"400_IP_ADDRESS_BANNED" isEqualToString:errorMsg])
            {
                [UserInfo showTips:self.view des:@"登录ip被禁用".lv_localized];
                return;
            }
            if([@"400_USER_BINDED_IP_ADDRESS" isEqualToString:errorMsg])
            {
                [UserInfo showTips:self.view des:@"登录用户已经绑定ip".lv_localized];
                return;
            }
            if([@"400_PASSWORD_VERIFY_INVALID" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"密码无效".lv_localized];
                return;
            }
            if([@"400_INVITE_CODE_INVALID" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"账号未注册".lv_localized];
                return;
            }
            if([@"400_PHONE_NUMBER_BANNED" isEqualToString:errorMsg]){
                [UserInfo showTips:self.view des:@"账号已封禁，请联系客服".lv_localized];
                return;
            }
            if([@"406_PHONE_PASSWORD_FLOOD" isEqualToString:errorMsg])
            {
                AppConfigInfo *config = [AppConfigInfo sharedInstance];
                NSInteger time = config.password_flood_interval;
                NSInteger hour = time/3600;
                NSInteger min = time/60;
                NSString *timeStr;
                if (hour > 0) {
                    min = (time % 3600)/60;
                    timeStr = [NSString stringWithFormat:@"%ld%@%ld%@", hour,@"小时".lv_localized, min, @"分钟".lv_localized];
                } else if (min > 0){
                    timeStr = [NSString stringWithFormat:@"%ld%@", min, @"分钟".lv_localized];
                } else {
                    timeStr = [NSString stringWithFormat:@"%ld%@", time, @"秒钟".lv_localized];
                }
                
                [UserInfo showTips:self.view des:[NSString stringWithFormat:@"密码错误次数过多，请%@后再试".lv_localized, timeStr]];
                return;
            }
            [UserInfo showTips:self.view des:@"登录账号或密码错误".lv_localized];
            return;
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"sendCode timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}
#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Input_Code_ByPasswordWay): /// 通过用户注册
        {
            [self sendDefaultCode];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Register):
        {
            //直接跳过来的
           
        }
        case MakeID(EUserManager, EUser_Td_Input_Code):
        {
            [XinstallSDK reportRegister];//注册量统计
            if (AppConfigInfo.sharedInstance.register_need_phone_code) {
                MNMsgCodeVC *vc = [[MNMsgCodeVC alloc] init];
                vc.curCountryCode = self.countryCode;
                vc.curPhone = self.phoneNumTf.text;
                vc.curUsername = self.userNameTf.text;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                MNNickNameVC *vc = [[MNNickNameVC alloc] init];
                vc.curCountryCode = self.countryCode;
                vc.curPhone = self.phoneNumTf.text;
                vc.curUsername = self.userNameTf.text;
                [self.navigationController pushViewController:vc animated:YES];
            }
            //会跳转这个页面
//            break;
//            //手机验证码登录的
            //输入验证码的。。。现在页面分离了。。暂时不知道这边会不会用的上
//            UIStoryboard *rpSb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//            InputSmsVerificationCodeViewController *vc = [rpSb instantiateViewControllerWithIdentifier:@"InputSmsVerificationCodeViewController"];
//            vc.curCountryCode = [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
//            vc.curPhone = [self getFieldStrWithTag:100];
//            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //清理数据
            [AuthUserManager cleanDestroyFolder];
            
            AppConfigInfo *info = [AppConfigInfo sharedInstance];
            if (info.register_need_phone_code) {
                NSString *phonenumer = self.phoneNumTf.text;
                [[AuthUserManager shareInstance] login:phonenumer data_directory:[UserInfo shareInstance].data_directory];
            }else{
                NSString *useraccount = self.userNameTf.text;
                [[AuthUserManager shareInstance] login:useraccount data_directory:[UserInfo shareInstance].data_directory];
            }
            //goto home view
            [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
            //更新手机号
            if(!IsStrEmpty([UserInfo shareInstance].phone_number))
            {
                [[AuthUserManager shareInstance] updateCurrentUserPhone:[UserInfo shareInstance].phone_number];
            }
            break;
        }
        default:
            break;
    }
}

- (void)sendDefaultCode
{
    [UserInfo show];
    [[TelegramManager shareInstance] checkAuthenticationCode:@"88888" result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if(![TelegramManager isResultOk:response])
        {
            // errorMsg:[TelegramManager errorMsg:response]
            [UserInfo showTips:self.view des:@"注册失败".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}

- (void)touchUpInSideCountryCodeTf:(UITextField *)tf{
    CountryCodeViewController *countryCodeVC = [[CountryCodeViewController alloc] init];
    countryCodeVC.sortedNameDict = self.sortedNameDict;
    __weak __typeof(self)weakSelf = self;
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        NSLog(@"%@",[NSString stringWithFormat:@"国家: %@  代码: %@".lv_localized,countryName,code]);
        weakSelf.countryCode = code;
        weakSelf.countryCodeTf.text = code;
    };
    [self.navigationController pushViewController:countryCodeVC animated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.countryCodeTf) {
        [self touchUpInSideCountryCodeTf:textField];
        return NO;
    }
    return YES;
}

- (void)textChange{
    AppConfigInfo *info = [AppConfigInfo sharedInstance];
    if (info.register_need_phone_code) {
        if (self.phoneNumTf.text.length >= 1 &&
            !IsStrEmpty(self.userNameTf.text) &&
            !IsStrEmpty(self.pwdTf.text) &&
            !IsStrEmpty(self.surePwdTf.text)){
            self.nextBtn.enabled = YES;
        }else{
            self.nextBtn.enabled = NO;
        }
    }else{
        if (!IsStrEmpty(self.userNameTf.text) &&
            !IsStrEmpty(self.pwdTf.text) &&
            !IsStrEmpty(self.surePwdTf.text)){
            self.nextBtn.enabled = YES;
        }else{
            self.nextBtn.enabled = NO;
        }
    }
    
}


@end

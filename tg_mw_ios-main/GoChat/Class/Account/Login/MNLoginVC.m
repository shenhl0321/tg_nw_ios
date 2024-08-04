//
//  MNLoginVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "MNLoginVC.h"
#import "WHPingTester.h"
#import "LabArrowRow.h"
#import "MNPhoneNumRow.h"
#import "MNPhoneVerCodeRow.h"
#import "MNRegisterVC.h"
#import "CountryCodeViewController.h"
#import "PwdTfRow.h"
#import "MNNickNameVC.h"

@interface MNLoginVC ()
<UITextFieldDelegate>
@property (nonatomic, strong) WHPingTester* pingTester;
@property (nonatomic, assign) int pingIndex;
@property (nonatomic, assign) BOOL goNext;
@property (nonatomic, assign) BOOL islogin;

@property (nonatomic, strong) NSMutableArray *rowsArray;
@property (nonatomic, strong) UILabel *countryLabel;
@property (nonatomic, strong) UITextField *countryTf;
@property (nonatomic, strong) UITextField *userTf;
@property (nonatomic, strong) UITextField *pwdTf;//
@property (nonatomic, strong) UIButton *registerBtn;
@property (nonatomic, strong) UIButton *loginTypeChangeBtn;
@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, strong) NSString *curCountryCode;
@property (nonatomic, strong) NSString *curCountryName;
@property (nonatomic, strong) NSString *curPhone;
@property (nonatomic, strong) NSDictionary *sortedNameDict;

@property (nonatomic, strong) UIButton *agreeSelectedButton;
@property (nonatomic, strong) UIButton *agreementButton;
@property (nonatomic, strong) UIButton *policyButton;
@property (nonatomic, strong) UILabel *andLabel;
@property (nonatomic, strong) UILabel *versionLabel;

@property (nonatomic, assign) BOOL isPasswordLogin;

@end

@implementation MNLoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar style_GoChatLogin];
    [self.customNavBar setTitleIVWithImageName:@"NavLogo"];
    [self initData];
    [self initUI];

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

- (void)initData{
    //判断当前系统语言
    if (LanguageIsEnglish)
    {
        NSString *plistPathEN = [[NSBundle mainBundle] pathForResource:@"sortedNameEN" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathEN];
        self.curCountryName = @"China";
    }
    else
    {
        NSString *plistPathCH = [[NSBundle mainBundle] pathForResource:@"sortedNameCH" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathCH];
        self.curCountryName = @"中国".lv_localized;
    }
    //首次进来默认是账号密码登录
    self.isPasswordLogin = YES;
    self.curCountryCode = @"86";
}

#pragma mark - 业务相关
- (void)login:(NSString *)phone
{
    UserInfo.shareInstance.isPasswordLoginType = self.isPasswordLogin;
    [UserInfo show];
    [[TelegramManager shareInstance] setAuthenticationPhoneNumber:phone result:^(NSDictionary *request, NSDictionary *response) {
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
        case MakeID(EUserManager, EUser_Td_Input_Code):
        {
            //发送验证码的回调，可以给个提示
            
            [UserInfo showTips:self.view des:LocalString(localVerificationCodeSended) duration:1];
//            [self performSegueWithIdentifier:@"InputSmsVerificationCodeView" sender:nil];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Input_Code_ByPasswordWay):
        {
            
            [self checkCode:@"88888"];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //验证码已经发送，并且验证了返回是正确的
            //清理数据
            [AuthUserManager cleanDestroyFolder];
            //登录
            [[AuthUserManager shareInstance] login:[NSString stringWithFormat:@"%@%@", self.curCountryCode, self.curPhone] data_directory:[UserInfo shareInstance].data_directory];
            //goto home view
            [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Register): {
            MNNickNameVC *vc = [[MNNickNameVC alloc] init];
            vc.curCountryCode = self.curCountryCode;
            vc.curPhone = self.curPhone;
            vc.curUsername = @"";
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - action
//登录动作
- (void)loginAction{
    UserInfo.shareInstance.isPasswordLoginType = self.isPasswordLogin;
    if (!self.agreeSelectedButton.isSelected) {
        XHQAlertText(@"请仔细阅读并同意《用户协议》和《隐私政策》".lv_localized);
        return;
    }
    //登录动作
    NSString *countryCode = [NSString stringWithFormat:@"+%@",self.countryTf.text];
    countryCode = [countryCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *phone = self.userTf.text;
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *smsCode  = self.pwdTf.text;
    smsCode = [smsCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    第一步判断是哪种登录方式
    if (!self.isPasswordLogin) {//手机号登录的
       
        if(countryCode.length<=0)
        {
            [UserInfo showTips:self.view des:@"请选择国家或者输入国家码".lv_localized];
            return;
        }
        //phone
        
        if(phone.length<=0)
        {
            [UserInfo showTips:self.view des:@"请输入手机号码".lv_localized];
            return;
        }
        
        
        if(smsCode.length<=0)
        {
            [UserInfo showTips:self.view des:@"请输入短信验证码".lv_localized];
            return;
        }
        if(smsCode.length!=5)
        {
            [UserInfo showTips:self.view des:@"请输入正确的短信验证码".lv_localized];
            return;
        }
        self.curCountryCode = countryCode;
        self.curPhone = phone;
        [self checkCode:self.pwdTf.text];
        //校验验证码正确以后在进行下一步
        
        
        
        
    }else{//用户名密码登录的
        if (!countryCode || phone.length< 5) {
            [UserInfo showTips:self.view des:@"请输入正确的账号".lv_localized];
            return;
        }
        if (!smsCode || smsCode.length<6) {
            [UserInfo showTips:self.view des:@"请输入正确的密码".lv_localized];
            return;
        }
        NSDictionary *paramsdic = nil;
        
        
        if ([CZCommonTool isEnglishFirst:phone]) {
            paramsdic = @{
                @"isSignup" :   [NSNumber numberWithBool:NO],
                @"userName" :   phone,
                @"password" :   [Common md5:smsCode]
//                @"password" :   smsCode
            };
        }else{
            paramsdic = @{
                @"isSignup" :   [NSNumber numberWithBool:NO],
                @"phoneNumber" :   [NSString stringWithFormat:@"%@%@",self.curCountryCode,phone],
                @"password" :    [Common md5:smsCode]
//                @"password" :   smsCode
            };
        }
        
        [self login:[CZCommonTool dictionaryToJson:paramsdic]];
    }
}


- (void)checkCode:(NSString *)codeStr
{
    [UserInfo show];
    [[TelegramManager shareInstance] checkAuthenticationCode:codeStr result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if(![TelegramManager isResultOk:response])
        {
            if ([UserInfo shareInstance].isPasswordLoginType) {
                [UserInfo showTips:self.view des:@"登录失败".lv_localized];
            }else{
                int code = [response[@"code"] intValue];
                if(code == 420)
                {
                    [UserInfo showTips:self.view des:@"验证码错误次数过多，请5分钟后重新登录".lv_localized];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [UserInfo showTips:self.view des:@"验证码错误".lv_localized];
                }
                //{"@type":"error","code":400,"message":"PHONE_CODE_INVALID","@extra":8}
                //{"@type":"error","code":8,"message":"Call to checkAuthenticationCode unexpected","@extra":6}
                NSLog(@"checkCode fail......");
            }
            
            
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"checkCode timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}

//注册动作
- (void)registerAction{
    MNRegisterVC *vc = [[MNRegisterVC alloc] init];
    vc.sortedNameDict = self.sortedNameDict;
    vc.countryCode = self.curCountryCode;
    [self.navigationController pushViewController:vc animated:YES];
}
//切换登录方式的动作
- (void)loginTypeChangeAction{
    self.isPasswordLogin = !self.isPasswordLogin;
    [self refreshUI];
}

//发送验证码的动作
- (void)sendMsgCodeAction:(MNRetCodeBtn*)btn{
   
    NSString *countryCode = [NSString stringWithFormat:@"+%@",self.countryTf.text];
    countryCode = [countryCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(countryCode.length<=0)
    {
        [UserInfo showTips:self.view des:@"请选择国家或者输入国家码".lv_localized];
        return;
    }
    
    //phone
    NSString *phone = self.userTf.text;
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(phone.length<=0)
    {
        [UserInfo showTips:self.view des:@"请输入手机号码".lv_localized];
        return;
    }
    [self login:[NSString stringWithFormat:@"%@%@",countryCode,phone]];
    [btn timer];
    self.curCountryCode = countryCode;
    self.curPhone = phone;
    [UserInfo show];
    
}


- (void)chooseCountryRec{
    CountryCodeViewController *countryCodeVC = [[CountryCodeViewController alloc] init];
    countryCodeVC.sortedNameDict = self.sortedNameDict;
    __weak __typeof(self)weakSelf = self;
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        NSLog(@"%@",[NSString stringWithFormat:@"国家: %@  代码: %@".lv_localized,countryName,code]);
        weakSelf.curCountryName = countryName;
        NSString *str = [code stringByReplacingOccurrencesOfString:@"+" withString:@""];
        weakSelf.curCountryCode = str;
//        weakSelf.countryLabel.text = countryName;
//        weakSelf.countryTf.text = code;
    };
    [self.navigationController pushViewController:countryCodeVC animated:YES];
}

-(void)setCurCountryName:(NSString *)curCountryName{
    _curCountryName = curCountryName;
   
   
}

-(void)setCurCountryCode:(NSString *)curCountryCode{
    _curCountryCode = curCountryCode;
    if ([curCountryCode containsString:@"+"]) {
        self.countryTf.text = [curCountryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }else{
        self.countryTf.text = curCountryCode;
    }
    
}

#pragma mark - UITextFieldDelegate
- (void)textContentChanged:(UITextField*)textFiled
{
    NSString *inputText = textFiled.text;
    __weak __typeof(self)weakSelf = self;
    [self.sortedNameDict.allValues enumerateObjectsUsingBlock:^(NSArray * obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [obj enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            NSArray  *array = [obj componentsSeparatedByString:@"+"];
            NSString *code = array.lastObject;
            if ([code isEqualToString:inputText])
            {
                NSString * countryName = [array.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                weakSelf.countryLabel.text = countryName;
//                weakSelf.countryTf.text = code;
                weakSelf.curCountryName = countryName;
                weakSelf.curCountryCode = code;
            }
        }];
    }];
}

#pragma mark - 隐私政策 + 用户协议
- (void)agreementAction:(UIButton *)sender {
    if ([localAppName isEqualToString:@"涨聊"]) {
        return;
    }
    BaseWebViewController *web = [[BaseWebViewController alloc] init];
    web.titleString = sender.titleLabel.text;
    web.urlStr = KHostUserAgreementAddress;
    web.type = WEB_LOAD_TYPE_URL;
    [self.navigationController pushViewController:web animated:YES];
}

- (void)policyAction:(UIButton *)sender {
    if ([localAppName isEqualToString:@"涨聊"]) {
        return;
    }
    BaseWebViewController *web = [[BaseWebViewController alloc] init];
    web.titleString = sender.titleLabel.text;
    web.urlStr = KHostPrivacyAddress;
    web.type = WEB_LOAD_TYPE_URL;
    [self.navigationController pushViewController:web animated:YES];
}

- (void)agree:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}


#pragma mark - UI布局
- (void)initUI{
    
    _rowsArray  = [[NSMutableArray alloc] init];
   
   
    [self.contentView addSubview:self.loginBtn];
    [self.contentView addSubview:self.registerBtn];
    [self.contentView addSubview:self.loginTypeChangeBtn];
    [self.contentView addSubview:self.agreeSelectedButton];
    [self.contentView addSubview:self.agreementButton];
    [self.contentView addSubview:self.policyButton];
    [self.contentView addSubview:self.andLabel];
    [self.contentView addSubview:self.versionLabel];
    [self refreshUI];
    
    //默认值
//    self.countryTf.text = @"86";
   
   
}

- (void)refreshUI{//刷新UI的
    for (MNRow *row in self.rowsArray) {
        [row removeFromSuperview];
    }
    [self.rowsArray removeAllObjects];
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (!config.phone_code_login) {
        self.loginTypeChangeBtn.hidden = YES;
    }
    
    if (!self.isPasswordLogin) {//手机号登录
        LabArrowRow *countryRow = [[LabArrowRow alloc] initWithFrame:CGRectMake(left_margin40(), 100, APP_SCREEN_WIDTH-2*left_margin40(), 62)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCountryRec)];
        [countryRow addGestureRecognizer:tap];
        [self.rowsArray addObject:countryRow];
        [self.contentView addSubview:countryRow];
        self.countryLabel = countryRow.lcLabel;
        MNPhoneNumRow *phoneRow = [[MNPhoneNumRow alloc] initWithFrame:CGRectMake(CGRectGetMinX(countryRow.frame), 100+62, CGRectGetWidth(countryRow.frame), 62)];
        [self.contentView addSubview:phoneRow];
        self.countryTf = phoneRow.countryTf;
        self.userTf = phoneRow.phoneNumTf;
        [self.rowsArray addObject:phoneRow];
        MNPhoneVerCodeRow *verCodeRow = [[MNPhoneVerCodeRow alloc] initWithFrame:CGRectMake(CGRectGetMinX(countryRow.frame), 100+62*2, CGRectGetWidth(countryRow.frame), 62)];
        [self.contentView addSubview:verCodeRow];
        [self.rowsArray addObject:verCodeRow];
        self.pwdTf = verCodeRow.tf;
        [verCodeRow.retCodeBtn addTarget:self
                                  action:@selector(sendMsgCodeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.loginTypeChangeBtn setTitle:LocalString(localAccountLogin) forState:UIControlStateNormal];
       
        self.countryLabel.text =self.curCountryName;
        self.countryTf.text = self.curCountryCode;
        
        self.countryTf.delegate = self;
        [self.countryTf addTarget:self action:@selector(textContentChanged:) forControlEvents:UIControlEventEditingChanged];
    }else{//用户名的登录方式
        LabArrowRow *countryRow = [[LabArrowRow alloc] initWithFrame:CGRectMake(left_margin40(), 100, APP_SCREEN_WIDTH-2*left_margin40(), 62)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCountryRec)];
        [countryRow addGestureRecognizer:tap];
        [self.contentView addSubview:countryRow];
        [self.rowsArray addObject:countryRow];
        self.countryLabel = countryRow.lcLabel;
        self.countryLabel.text = self.curCountryName;
        
        TfRow *userRow = [[TfRow alloc] initWithFrame:CGRectMake(left_margin40(), 100+62, APP_SCREEN_WIDTH-2*left_margin40(), 62)];
        self.userTf = userRow.tf;
        [self.contentView addSubview:userRow];
        [self.rowsArray addObject:userRow];
        
        PwdTfRow *pwdRow = [[PwdTfRow alloc] initWithFrame:CGRectMake(CGRectGetMinX(userRow.frame), 100+62*2, CGRectGetWidth(userRow.frame), 62)];
        self.pwdTf = pwdRow.tf;
        [self.contentView addSubview:pwdRow];
        [self.rowsArray addObject:pwdRow];
        
        self.userTf.placeholder = LocalString(localPlsEnterLoginAccount);
        self.pwdTf.placeholder = LocalString(localPlsEnterLoginPwd);
        [self.loginTypeChangeBtn setTitle:LocalString(localVerificationCodeLogin) forState:UIControlStateNormal];
        
#if DEBUG
        self.userTf.text = @"17600800152";
        self.pwdTf.text = @"123456";
#endif
       
    }
    
    UIView *lastRow = self.rowsArray[self.rowsArray.count-1];
    [self.loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin30());
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(55);
        make.top.equalTo(lastRow.mas_bottom).with.offset(94);
    }];
    
    [self.registerBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 54));
//        make.right.mas_equalTo(-left_margin30());
        make.top.equalTo(self.loginBtn.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(0);
    }];
    [self.loginTypeChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.size.equalTo(self.registerBtn);
//        make.centerY.equalTo(self.registerBtn);
        make.top.equalTo(lastRow.mas_bottom).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(130, 44));
        make.left.mas_equalTo(left_margin30());
    }];
    [self.agreeSelectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loginBtn);
        make.top.equalTo(self.registerBtn.mas_bottom).offset(15);
        make.height.mas_equalTo(20);
    }];
    [self.agreeSelectedButton sizeToFit];
    [self.agreementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.agreeSelectedButton.mas_right);
        make.centerY.equalTo(self.agreeSelectedButton);
        make.size.mas_equalTo(CGSizeMake(80, 20));
    }];
    [self.andLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.agreementButton);
        make.left.equalTo(self.agreementButton.mas_right);
    }];
    [self.policyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.andLabel.mas_right);
        make.size.bottom.equalTo(self.agreementButton);
    }];
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.agreeSelectedButton.mas_bottom).offset(15);
        make.centerX.equalTo(self.registerBtn);
    }];
}

- (UIButton *)agreeSelectedButton {
    if (!_agreeSelectedButton) {
        _agreeSelectedButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"  阅读并同意".lv_localized forState:UIControlStateNormal];
            [btn setTitleColor:UIColor.colorTextFor999999 forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont regularCustomFontOfSize:12];
            [btn setImage:[UIImage imageNamed:@"UnSelect"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"Select"] forState:UIControlStateSelected];
            [btn xhq_addTarget:self action:@selector(agree:)];
            btn.hidden = YES;
            btn.selected = YES;
            btn;
        });
    }
    return _agreeSelectedButton;
}

- (UILabel *)andLabel {
    if (!_andLabel) {
        _andLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = UIColor.colorTextFor999999;
            label.font = [UIFont regularCustomFontOfSize:12];
            label.text = @"和".lv_localized;
            label.hidden = YES;
            label;
        });
    }
    return _andLabel;
}

- (UILabel *)versionLabel{
    if(!_versionLabel){
        _versionLabel = [[UILabel alloc]init];
        _versionLabel.textColor = [UIColor colorTextFor878D9A];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _versionLabel.text = [NSString stringWithFormat:@"version %@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    }
    return _versionLabel;
}

- (UIButton *)agreementButton {
    if (!_agreementButton) {
        _agreementButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"《用户协议》".lv_localized forState:UIControlStateNormal];
            [btn setTitleColor:UIColor.colorMain forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont regularCustomFontOfSize:12];
            [btn xhq_addTarget:self action:@selector(agreementAction:)];
            btn.hidden = YES;
            btn;
        });
    }
    return _agreementButton;
}

- (UIButton *)policyButton {
    if (!_policyButton) {
        _policyButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"《隐私政策》".lv_localized forState:UIControlStateNormal];
            [btn setTitleColor:UIColor.colorMain forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont regularCustomFontOfSize:12];
            [btn xhq_addTarget:self action:@selector(policyAction:)];
            btn.hidden = YES;
            btn;
        });
    }
    return _policyButton;
}

-(UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton mn_loginStyleWithTitle:LocalString(localLogin)];
        [_loginBtn addTarget:self
                      action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}
-(UIButton *)registerBtn{
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:LocalString(localRegisterAccount) forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor colorTextFor878D9A] forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = fontRegular(17);
        _registerBtn.frame = CGRectMake( APP_SCREEN_WIDTH- left_margin30()-100, ContentHeight-102-44, 100, 44);
        [_registerBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}

- (UIButton *)loginTypeChangeBtn{
    if (!_loginTypeChangeBtn) {
        _loginTypeChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginTypeChangeBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _loginTypeChangeBtn.titleLabel.font = fontRegular(17);
        _loginTypeChangeBtn.frame = CGRectMake(left_margin30(), ContentHeight-102-44, 80, 44);
        _loginTypeChangeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_loginTypeChangeBtn  addTarget:self action:@selector(loginTypeChangeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginTypeChangeBtn;
}




@end

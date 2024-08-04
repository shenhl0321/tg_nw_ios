//
//  CZRegisterViewController.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "CZRegisterViewController.h"
#import "CZSedRegisterViewController.h"
#import "CountryCodeViewController.h"

@interface CZRegisterViewController ()<BusinessListenerProtocol>
@property (weak, nonatomic) IBOutlet UILabel *appnameLabel;
@property (weak, nonatomic) IBOutlet UITextField *accountFiele;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifiyBtn;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (nonatomic, strong) NSDictionary *sortedNameDict;
@property (nonatomic,strong)    NSString *countryNumer;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollview;

@end

@implementation CZRegisterViewController

/**
 *  将状态栏和导航条设置成透明
 当translucent = YES，controller中self.view的原点是从导航栏左上角开始计算
 当translucent = NO，controller中self.view的原点是从导航栏左下角开始计算
 */
- (void)showNavigationWithClearBG{
    
    //导航栏随着滚动 变得不透明
    self.navigationController.navigationBar.translucent = YES;
    UIImage *image = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //全屏模式
    if (@available(iOS 11,*))
    {
        if ([self.mainScrollview respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)])
        {
            self.mainScrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录".lv_localized;
    self.appnameLabel.text = localAppName.lv_localized;
    self.countryNumer = @"86";
    //判断当前系统语言
    if (LanguageIsEnglish)
    {
        NSString *plistPathEN = [[NSBundle mainBundle] pathForResource:@"sortedNameEN" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathEN];
    }
    else
    {
        NSString *plistPathCH = [[NSBundle mainBundle] pathForResource:@"sortedNameCH" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathCH];
    }
    // Do any additional setup after loading the view from its nib.
    
//    self.accountFiele.text = @"gogo2";
//    self.pwdField.text = @"123456";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showNavigationWithClearBG];
    //隐藏导航栏
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //白色标题
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self setLoginButtonUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //隐藏导航栏
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    //白色标题
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
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

- (void)setLoginButtonUI
{
    self.loginBtn.layer.cornerRadius = 7;
    self.loginBtn.layer.masksToBounds = YES;
    
    AppConfigInfo *info = [AppConfigInfo sharedInstance];
    self.verifiyBtn.hidden = !info.phone_code_login;
}

- (IBAction)eyeBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    _pwdField.secureTextEntry = !_pwdField.secureTextEntry;
}
- (IBAction)loginBtnClick:(UIButton *)sender {
    NSDictionary *paramsdic = nil;
    if (!_accountFiele.text || _accountFiele.text.length < 5) {
        [UserInfo showTips:self.view des:@"请输入正确的账号".lv_localized];
        return;
    }
    if (!_pwdField.text || _pwdField.text.length < 6) {
        [UserInfo showTips:self.view des:@"请输入正确的密码".lv_localized];
        return;
    }
    if ([CZCommonTool isEnglishFirst:_accountFiele.text]) {
        paramsdic = @{
            @"isSignup" :   [NSNumber numberWithBool:NO],
            @"userName" :   _accountFiele.text,
            @"password" :   [Common md5:_pwdField.text]
        };
    }else{
        paramsdic = @{
            @"isSignup" :   [NSNumber numberWithBool:NO],
            @"phoneNumber" :   [NSString stringWithFormat:@"%@%@",self.countryNumer,_accountFiele.text],
            @"password" :   [Common md5:_pwdField.text]
        };
    }
    
    
    [UserInfo shareInstance].isPasswordLoginType = YES;
    [UserInfo show];
    [[TelegramManager shareInstance] setAuthenticationPhoneNumber:[CZCommonTool dictionaryToJson:paramsdic] result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
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
            if([@"400_ErrPhonePasswordFlood" isEqualToString:errorMsg])
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
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"sendCode timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}

- (IBAction)vertyBtnClick:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    [self.navigationController pushViewController:[sb instantiateInitialViewController] animated:YES];
}

- (IBAction)registerBtnClick:(UIButton *)sender {
    CZSedRegisterViewController *registerVC = [CZSedRegisterViewController new];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Input_Code_ByPasswordWay):
        {
            [self sendDefaultCode];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Register):
        {
//            [self performSegueWithIdentifier:@"InputNicknameView" sender:nil];
//            break;
        }
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //清理数据
            [AuthUserManager cleanDestroyFolder];
            //登录
            [[AuthUserManager shareInstance] login:self.accountFiele.text data_directory:[UserInfo shareInstance].data_directory];
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
            [UserInfo showTips:self.view des:@"登录失败".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}

//选择国家
- (IBAction)choiceCountryClick:(UIButton *)sender {
    CountryCodeViewController *countryCodeVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"CountryCodeViewController"];
    countryCodeVC.sortedNameDict = self.sortedNameDict;
    __weak __typeof(self)weakSelf = self;
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        NSLog(@"%@",[NSString stringWithFormat:@"国家: %@  代码: %@".lv_localized,countryName,code]);
        weakSelf.countryLabel.text = countryName;
        weakSelf.countryNumer = code;
    };
    [self.navigationController pushViewController:countryCodeVC animated:YES];
}

//用户协议
- (IBAction)userProtocalBtnClick:(UIButton *)sender {
    BaseWebViewController *v = [BaseWebViewController new];
    v.hidesBottomBarWhenPushed = YES;
    v.titleString = @"用户协议".lv_localized;
    v.urlStr = KHostUserAgreementAddress;
    v.type = WEB_LOAD_TYPE_URL;
    [self.navigationController pushViewController:v animated:YES];
}
//隐私政策
- (IBAction)privacyBtnClick:(UIButton *)sender {
    BaseWebViewController *v = [BaseWebViewController new];
    v.hidesBottomBarWhenPushed = YES;
    v.titleString = @"隐私政策".lv_localized;
    v.urlStr = KHostPrivacyAddress;
    v.type = WEB_LOAD_TYPE_URL;
    [self.navigationController pushViewController:v animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

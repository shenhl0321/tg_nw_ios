//
//  InputSmsVerificationCodeViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/10/27.
//

#import "InputSmsVerificationCodeViewController.h"
#import "InputNicknameViewController.h"

@interface InputSmsVerificationCodeViewController ()<BusinessListenerProtocol>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTextBottom;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet CRBoxInputView *codeInputView;

@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@end

@implementation InputSmsVerificationCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //国际化
    self.titleLabel.text = @"输入短信验证码".lv_localized;
    self.tipLabel.text = [NSString stringWithFormat:@"短信验证码已经发送至%@ %@".lv_localized, self.curCountryCode, self.curPhone];
    self.appNameLabel.text = localAppName.lv_localized;
    
    //全屏模式
    if (@available(iOS 11,*))
    {
        if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)])
        {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    //视图位置调整
    self.titleTop.constant = StateBarHeight;
    if(Is_iPhoneX)
    {
        self.topTextBottom.constant = 50;
    }
    else
    {
        self.topTextBottom.constant = 64;
    }
    //验证码视图样式
    [self setCodeInputUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //白色标题
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)setCodeInputUI
{
    CRBoxInputCellProperty *cellProperty = [CRBoxInputCellProperty new];
    cellProperty.showLine = YES;
    cellProperty.borderWidth = 0;
    cellProperty.cellCursorColor = COLOR_CG1;
    cellProperty.customLineViewBlock = ^CRLineView * _Nonnull{
        CRLineView *lineView = [CRLineView new];
        lineView.underlineColorNormal = HEX_COLOR(@"#717682");
        lineView.underlineColorSelected = HEX_COLOR(@"#04020C");
        lineView.underlineColorFilled = HEX_COLOR(@"#717682");
        [lineView.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.left.right.bottom.offset(0);
        }];
        lineView.selectChangeBlock = ^(CRLineView * _Nonnull lineView, BOOL selected) {
            if (selected) {
                [lineView.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(2);
                }];
            } else {
                [lineView.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(2);
                }];
            }
        };
        return lineView;
    };
    self.codeInputView.inputType = CRInputType_Number;
    [self.codeInputView resetCodeLength:5 beginEdit:NO];
    self.codeInputView.customCellProperty = cellProperty;
    [self.codeInputView loadAndPrepareViewWithBeginEdit:YES];
    self.codeInputView.textDidChangeblock = ^(NSString *text, BOOL isFinished) {
        if(isFinished)
        {
            [self checkCode:text];
        }
    };
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

#pragma mark - click
- (IBAction)click_back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkCode:(NSString *)codeStr
{
    [UserInfo show];
    [[TelegramManager shareInstance] checkAuthenticationCode:codeStr result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if(![TelegramManager isResultOk:response])
        {
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
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"checkCode timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Register):
        {
            [self performSegueWithIdentifier:@"InputNicknameView" sender:nil];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //清理数据
            [AuthUserManager cleanDestroyFolder];
            //登录
            [[AuthUserManager shareInstance] login:[NSString stringWithFormat:@"%@%@", self.curCountryCode, self.curPhone] data_directory:[UserInfo shareInstance].data_directory];
            //goto home view
            [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
            break;
        }
        default:
            break;
    }
}

//next segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([@"InputNicknameView" isEqualToString:segue.identifier])
    {
        InputNicknameViewController *v = segue.destinationViewController;
        v.curCountryCode = self.curCountryCode;
        v.curPhone = self.curPhone;
    }
}

@end

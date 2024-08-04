//
//  QTCodeVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/28.
//

#import "QTCodeVC.h"
#import "MNNickNameVC.h"
#import "MNRetCodeBtn.h"

@interface QTCodeVC ()

@property (strong, nonatomic) CRBoxInputView *codeInputView;

@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UILabel *contentLab;

@property (strong, nonatomic) MNRetCodeBtn *codeBtn;

@end

@implementation QTCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.customNavBar setTitle:@"输入验证码".lv_localized];
    [self.customNavBar setTitle:@""];
    
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

- (void)initUI{
    
    [self.view insertSubview:self.customNavBar atIndex:100];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    [self showLogoUI];
    
    [self.view addSubview:self.titleLab];
    [self.view addSubview:self.contentLab];
//    [self.view addSubview:self.codeBtn];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(140);
    }];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.titleLab);
        make.top.equalTo(self.titleLab.mas_bottom).offset(5);
    }];
    
    
    
    UILabel *aLabel = [[UILabel alloc] init];
    aLabel.font = fontMedium(19);
    aLabel.textColor = [UIColor colorTextFor23272A];
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.frame = CGRectMake(40, 40, APP_SCREEN_WIDTH-80, 27);
    aLabel.text = @"输入验证码".lv_localized;
    aLabel.hidden = YES;
    [self.contentView addSubview:aLabel];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(left_margin(), 81, APP_SCREEN_WIDTH-2*left_margin(), 30)];
    tipLabel.numberOfLines = 0;
    tipLabel.text = [NSString stringWithFormat:@"%@ +%@ %@",@"短信验证码已发送至".lv_localized,self.curCountryCode,self.curPhone];
    tipLabel.font = fontRegular(15);
    tipLabel.textColor = [UIColor colorTextFor878D9A];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.hidden = YES;
    [self.contentView addSubview:tipLabel];
    
    CRBoxInputCellProperty *cellProperty = [CRBoxInputCellProperty new];
    cellProperty.showLine = YES;
    cellProperty.borderWidth = 0;
    cellProperty.cellCursorColor = COLOR_CG1;

    cellProperty.customLineViewBlock = ^CRLineView * _Nonnull{
        CRLineView *lineView = [CRLineView new];
        lineView.underlineColorNormal = HEX_COLOR(@"#878D9A");
        lineView.underlineColorSelected = HEX_COLOR(@"#0DBFC0");
        lineView.underlineColorFilled = HEX_COLOR(@"#878D9A");
        [lineView.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.left.right.bottom.offset(0);
        }];
        lineView.selectChangeBlock = ^(CRLineView * _Nonnull lineView, BOOL selected) {
            if (selected) {
                [lineView.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(1);
                }];
            } else {
                [lineView.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(1);
                }];
            }
        };
        return lineView;
    };
    _codeInputView = [[CRBoxInputView alloc] initWithFrame:CGRectMake(35, 130, APP_SCREEN_WIDTH-70, 80)];
    self.codeInputView.inputType = CRInputType_Number;
    [self.codeInputView resetCodeLength:5 beginEdit:NO];
    self.codeInputView.customCellProperty = cellProperty;
    [self.codeInputView loadAndPrepareViewWithBeginEdit:YES];
    [self.contentView addSubview:self.codeInputView];
    WS(weakSelf)
    self.codeInputView.textDidChangeblock = ^(NSString *text, BOOL isFinished) {
        if(isFinished)
        {
            [weakSelf checkCode:text];
        }
    };
    
//    [self.codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        //
//        make.centerX.equalTo(self);
//        make.top.equalTo(self.codeInputView.mas_bottom).offset(30);
//    }];
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
            MNNickNameVC *vc = [[MNNickNameVC alloc] init];
            vc.curCountryCode = self.curCountryCode;
            vc.curPhone = self.curPhone;
            vc.curUsername = self.curUsername;
            [self.navigationController pushViewController:vc animated:YES];
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


- (UILabel *)titleLab{
    if (!_titleLab){
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"验证码已发送至";
        _titleLab.textColor = HEXCOLOR(0x000000);
        _titleLab.font = [UIFont boldCustomFontOfSize:25];
    }
    return _titleLab;
}
- (UILabel *)contentLab{
    if (!_contentLab){
        _contentLab = [[UILabel alloc] init];
        _contentLab.font = [UIFont systemFontOfSize:15];
        _contentLab.textColor = HEXCOLOR(0x999999);
        _contentLab.text = [NSString stringWithFormat:@"%@ %@", self.curCountryCode, self.curPhone];
    }
    return _contentLab;
}

-(MNRetCodeBtn *)codeBtn{
    if (!_codeBtn) {
        _codeBtn = [[MNRetCodeBtn alloc] init];
        _codeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_codeBtn addTarget:self action:@selector(sendCodeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _codeBtn;
}
- (void)sendCodeButtonClick:(MNRetCodeBtn *)sender{
    [sender timer];
}

@end

//
//  CZSedRegisterViewController.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "CZSedRegisterViewController.h"
#import "CZRegisterTableViewCell.h"
#import "CZRegisterBtnView.h"
#import "CZChoiceCountyTableViewCell.h"
#import "CZVerifiyTableViewCell.h"
#import "CZRegisterInputModel.h"
#import "CountryCodeViewController.h"
#import "InputSmsVerificationCodeViewController.h"
#import "InputNicknameViewController.h"

@interface CZSedRegisterViewController ()<BusinessListenerProtocol>
@property   (weak, nonatomic) IBOutlet UITableView *mainTableview;
@property (nonatomic, strong) NSDictionary *sortedNameDict;
@property   (nonatomic,strong) NSMutableArray *placeHodlerArray;
@property (nonatomic,strong)    NSString    *countryCode;
@end

@implementation CZSedRegisterViewController

- (NSMutableArray *)placeHodlerArray{
    if (!_placeHodlerArray) {
        _placeHodlerArray = [NSMutableArray array];
        AppConfigInfo *info = [AppConfigInfo sharedInstance];
        if (info.register_need_phone_code) {
            [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请输入手机号码".lv_localized withFieldTag:100]];
        }
        [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请输入用户名(5位以上字母数字组合)".lv_localized withFieldTag:101]];
//        [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请输入昵称" withFieldTag:102]];
        [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请设置6-20位新的登录密码".lv_localized withFieldTag:103]];
        [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请再次输入新的登录密码".lv_localized withFieldTag:104]];
        if (info.register_need_inviter) {
            [_placeHodlerArray addObject:[CZRegisterInputModel initWithPlaceHodlerStr:@"请输入邀请码".lv_localized withFieldTag:105]];
        }
    }
    return _placeHodlerArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册账号".lv_localized;
    self.countryCode = @"+86";
    //判断当前系统语言
    if (LanguageIsEnglish)
    {
        NSString *plistPathEN = [[NSBundle mainBundle] pathForResource:@"sortedNameEN" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathEN];
    }else
    {
        NSString *plistPathCH = [[NSBundle mainBundle] pathForResource:@"sortedNameCH" ofType:@"plist"];
        self.sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathCH];
    }
    self.mainTableview.tableFooterView = [CZRegisterBtnView instanceViewWithBtnTitle:@"注册".lv_localized WithClick:^{
        [self registerBtnClick];
    }];
    // Do any additional setup after loading the view from its nib.
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

//注册
- (void)registerBtnClick{
    [UserInfo shareInstance].isPasswordLoginType = YES;
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[NSNumber numberWithBool:YES] forKey:@"isSignup"];
    AppConfigInfo *info = [AppConfigInfo sharedInstance];
    if (info.register_need_phone_code) {
        NSString *phonenumer = [self getFieldStrWithTag:100];
        if (!phonenumer || phonenumer.length < 1) {
            [UserInfo showTips:self.view des:@"请输入正确的手机号码".lv_localized];
            return;
        }else{
            [UserInfo shareInstance].isPasswordLoginType = NO;
            [paramsDic setObject:[NSString stringWithFormat:@"%@%@", [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""], phonenumer] forKey:@"phoneNumber"];
        }
    }
    
    NSString *useraccount = [self getFieldStrWithTag:101];
    if (!useraccount || useraccount.length < 1) {
        [UserInfo showTips:self.view des:@"请输入正确的用户名".lv_localized];
        return;
    }else{
        [paramsDic setObject:useraccount forKey:@"userName"];
    }
    
    NSString *userpwd1 = [self getFieldStrWithTag:103];
    NSString *userpwd2 = [self getFieldStrWithTag:104];
    if (userpwd1 && userpwd2 &&  userpwd1.length > 5 && userpwd2.length > 5 && [userpwd1 isEqualToString:userpwd2]) {
        [paramsDic setObject:[Common md5:userpwd1] forKey:@"password"];
    }else{
        [UserInfo showTips:self.view des:@"请输入正确的登录密码".lv_localized];
        return;
    }
    
    if (info.register_need_inviter) {
        NSString *invitationStr = [self getFieldStrWithTag:105];
        if (!invitationStr || invitationStr.length < 1) {
            [UserInfo showTips:self.view des:@"请输入正确的邀请码".lv_localized];
            return;
        }else{
            [paramsDic setObject:@([[self getFieldStrWithTag:105] longLongValue]) forKey:@"inviteCode"];
        }
    }
    
    [UserInfo show];
    [[TelegramManager shareInstance] setAuthenticationPhoneNumber:[CZCommonTool dictionaryToJson:paramsDic] result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if(![TelegramManager isResultOk:response])
        {
            if([@"400_IP_ADDRESS_BANNED" isEqualToString:[TelegramManager errorMsg:response]]){
                [UserInfo showTips:self.view des:@"登录ip被禁用".lv_localized];
                return;
            }
            if([@"400_USER_BINDED_IP_ADDRESS" isEqualToString:[TelegramManager errorMsg:response]]){
                [UserInfo showTips:self.view des:@"登录用户已经绑定ip".lv_localized];
                return;
            }
            if([@"400_USERNAME_INVALID" isEqualToString:[TelegramManager errorMsg:response]]){
                [UserInfo showTips:self.view des:@"用户名无效".lv_localized];
                return;
            }
            if([@"400_INVITE_CODE_INVALID" isEqualToString:[TelegramManager errorMsg:response]]){
                [UserInfo showTips:self.view des:@"邀请码无效".lv_localized];
                return;
            }
            if([@"400_PASSWORD_VERIFY_INVALID" isEqualToString:[TelegramManager errorMsg:response]]){
                [UserInfo showTips:self.view des:@"密码无效".lv_localized];
                return;
            }
            if([@"400_PHONE_NUMBER_UNOCCUPIED" isEqualToString:[TelegramManager errorMsg:response]]){
                [UserInfo showTips:self.view des:@"手机号被占用".lv_localized];
                return;
            }
            if([@"400_USERNAME_OCCUPIED" isEqualToString:[TelegramManager errorMsg:response]]){
                [UserInfo showTips:self.view des:@"用户名被占用".lv_localized];
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

- (NSString *)getFieldStrWithTag:(NSInteger)tag{
    for (UITableViewCell *cell in self.mainTableview.visibleCells) {
        if (cell.tag == tag) {
            if ([cell isMemberOfClass:[CZChoiceCountyTableViewCell class]]) {
                CZChoiceCountyTableViewCell *cellLim = (CZChoiceCountyTableViewCell *)cell;
                return cellLim.inputString;
            }
            if ([cell isMemberOfClass:[CZRegisterTableViewCell class]]) {
                CZRegisterTableViewCell *cellLim = (CZRegisterTableViewCell *)cell;
                return cellLim.inputString;
            }
        }
    }
    return nil;
}

//设置TablerView显示几组数据，默认分一组；
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//设置UITabView每组显示几行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.placeHodlerArray.count;
}
//设置每一行的每一组显示单元格的什么内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CZRegisterInputModel *cellModel = [self.placeHodlerArray objectAtIndex:indexPath.row];
    AppConfigInfo *info = [AppConfigInfo sharedInstance];
    if (info.register_need_phone_code) {
        if (indexPath.row == 0) {
            NSString *ID = @"CZChoiceCountyTableViewCell";
            CZChoiceCountyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZChoiceCountyTableViewCell" owner:nil options:nil] firstObject];
            }
            cell.cellModel = cellModel;
            cell.countrycode = self.countryCode;
            cell.block = ^{
                CountryCodeViewController *countryCodeVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"CountryCodeViewController"];
                countryCodeVC.sortedNameDict = self.sortedNameDict;
                __weak __typeof(self)weakSelf = self;
                countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
                    NSLog(@"%@",[NSString stringWithFormat:@"国家: %@  代码: %@".lv_localized,countryName,code]);
                    weakSelf.countryCode = [NSString stringWithFormat:@"+%@",code];
                    [weakSelf.mainTableview reloadData];
                };
                [self.navigationController pushViewController:countryCodeVC animated:YES];
            };
            return cell;
        }
    }
    NSString *ID = @"CZRegisterTableViewCell";
    CZRegisterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CZRegisterTableViewCell" owner:nil options:nil] firstObject];
    }
    cell.cellModel = cellModel;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 116;
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

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Input_Code_ByPasswordWay)://密码登录
        {
            [self sendDefaultCode];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Register):
        {
            UIStoryboard *rpSb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            InputNicknameViewController *vc = [rpSb instantiateViewControllerWithIdentifier:@"InputNicknameViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Input_Code):
        {
            UIStoryboard *rpSb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            InputSmsVerificationCodeViewController *vc = [rpSb instantiateViewControllerWithIdentifier:@"InputSmsVerificationCodeViewController"];
            vc.curCountryCode = [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
            vc.curPhone = [self getFieldStrWithTag:100];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //清理数据
            [AuthUserManager cleanDestroyFolder];
            
            AppConfigInfo *info = [AppConfigInfo sharedInstance];
            if (info.register_need_phone_code) {
                NSString *phonenumer = [self getFieldStrWithTag:100];
                [[AuthUserManager shareInstance] login:phonenumer data_directory:[UserInfo shareInstance].data_directory];
            }else{
                NSString *useraccount = [self getFieldStrWithTag:101];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

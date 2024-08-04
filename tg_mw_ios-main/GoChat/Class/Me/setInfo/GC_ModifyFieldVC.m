//
//  GC_ModifyFieldVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/5.
//

#import "GC_ModifyFieldVC.h"

@interface GC_ModifyFieldVC ()<UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *inputTf;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (nonatomic, strong)UIButton *saveBtn;

@end

@implementation GC_ModifyFieldVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inputTf.delegate = self;
    [self resetUI];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.inputTf];
    self.view.backgroundColor = [UIColor colorForF5F9FA];
}

- (void)resetUI
{
    self.contentView.hidden = YES;
    switch (self.fieldType)
    {
        case ModifyFieldType_Set_My_Nickname:
           
            [self.customNavBar setTitle:@"设置昵称".lv_localized];
            self.titleLabel.text = @"昵称".lv_localized;
            self.inputTf.placeholder = @"  填写您的昵称".lv_localized;
            //输入框最大字符数-12字符
            [self.inputTf setMylimitCount:@12];
            self.inputTf.text = [UserInfo shareInstance].displayName;
            break;
        case ModifyFieldType_Set_My_Username:
            
            [self.customNavBar setTitle:@"设置用户名".lv_localized];
            self.titleLabel.text = @"用户名".lv_localized;
            self.inputTf.placeholder = @"  填写您的用户名".lv_localized;
            self.inputTf.keyboardType = UIKeyboardTypeASCIICapable;
            self.inputTf.text = [UserInfo shareInstance].username;
            self.tipsLabel.text = @"1.最小长度为5个字符。\n2.只能使用字母、数字、下划线。\n3.不能以数字开头，不能以下划线开头与结尾。".lv_localized;
            break;
        case ModifyFieldType_Set_Group_Name:
            self.title = @"";
            [self.customNavBar setTitle:@"设置群组名称".lv_localized];
            self.titleLabel.text = @"群组名称".lv_localized;
            self.inputTf.placeholder = @"填写群组名称".lv_localized;
            //输入框最大字符数-12字符
            [self.inputTf setMylimitCount:@12];
            self.inputTf.text = self.prevValueString;
            break;
        case ModifyFieldType_Set_Group_Nickname:
            self.title = @"";
            [self.customNavBar setTitle:@"我在群里的昵称".lv_localized];
            self.titleLabel.text = @"昵称";
            self.inputTf.placeholder = @"填写您在群里的昵称".lv_localized;
            self.tipsLabel.text = @"昵称修改后，只会在此群内显示，群里成员都可以看见".lv_localized;
            //输入框最大字符数-12字符
            [self.inputTf setMylimitCount:@10];
            self.inputTf.text = self.prevValueString;
            break;
        case ModifyFieldType_Set_User_NickName:
            
            [self.customNavBar setTitle:@"设置备注".lv_localized];
            self.titleLabel.text = @"备注".lv_localized;
            self.inputTf.placeholder = @"  填写备注".lv_localized;
            //输入框最大字符数-12字符
            [self.inputTf setMylimitCount:@12];
            self.inputTf.text = self.prevValueString;
            break;
        default:
            break;
    }
    
    [self.customNavBar addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(0);
    }];
}

- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_saveBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (void)click_ok
{
    NSString *keyword = self.inputTf.text;
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    switch (self.fieldType)
    {
        case ModifyFieldType_Set_My_Nickname:
            [self saveMyNickName:keyword];
            break;
        case ModifyFieldType_Set_My_Username:
        {
            NSString *nameRegex = @"(^[a-zA-Z][a-zA-Z0-9_]{3,30}[a-zA-Z0-9]$)";
            NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
            BOOL isok = [nameTest evaluateWithObject:keyword];
            if (!isok)
            {
                [UserInfo showTips:nil des:@"用户名不合规，请您重新输入".lv_localized];
                return;
            }
            [self saveMyUsername:keyword];
        }
            break;
        case ModifyFieldType_Set_Group_Name:
            [self saveGroupName:keyword];
            break;
        case ModifyFieldType_Set_User_NickName:
            [self saveUserNickname:keyword];
            break;
        case ModifyFieldType_Set_Group_Nickname:
            [self setGroupNickname:keyword];
            break;
        default:
            break;
    }
}

- (void)saveMyNickName:(NSString *)nickName
{
    if(!IsStrEmpty(nickName))
    {
        [UserInfo show];
        [[TelegramManager shareInstance] setMyNickName:nickName resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"昵称设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"昵称设置失败，请稍后重试".lv_localized];
        }];
    }
    else
    {
        [UserInfo showTips:nil des:@"请填写您的昵称".lv_localized];
    }
}

- (void)saveMyUsername:(NSString *)userName
{
    [UserInfo show];
    [[TelegramManager shareInstance] setMyUserName:userName resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            int code = [response[@"code"] intValue];
            if(code == 429)
            {
                [UserInfo showTips:nil des:@"用户名设置失败，请更换用户名或者稍后重试".lv_localized];
            }
            else if(code == 400)
            {
                [UserInfo showTips:nil des:@"用户名已被占用，请换一个".lv_localized];
            }
            else
            {
                [UserInfo showTips:nil des:@"用户名设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"用户名设置失败，请稍后重试".lv_localized];
    }];
}

- (void)saveGroupName:(NSString *)name
{
    if(!IsStrEmpty(name))
    {
        [UserInfo show];
        [[TelegramManager shareInstance] setGroupName:self.chatId groupName:name resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized];
        }];
    }
    else
    {
        [UserInfo showTips:nil des:@"请填写群组名称".lv_localized];
    }
}

- (void)saveUserNickname:(NSString *)name
{
    [UserInfo show];
    [[TelegramManager shareInstance] setContactNickName:self.toBeModifyUser nickName:name resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized];
    }];
}

- (void)setGroupNickname:(NSString *)name {
    if(IsStrEmpty(name)) {
        [UserInfo showTips:nil des:@"请填写昵称".lv_localized];
        return;
    }
    [UserInfo show];
    NSDictionary *param = @{
        @"@type": @"sendCustomRequest",
        @"method": @"chats.setNickname",
        @"parameters": @{
            @"chatId": @(self.chatId),
            @"nickname": name
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:param result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            if ([resp[@"code"] integerValue] == 200) {
                [UserInfo showTips:nil des:@"设置昵称成功".lv_localized];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"昵称设置失败，请稍后重试".lv_localized];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self click_ok];
    return YES;
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

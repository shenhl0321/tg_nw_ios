//
//  ModifyFieldViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/12/4.
//

#import "ModifyFieldViewController.h"

@interface ModifyFieldViewController ()<UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *inputTf;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@end

@implementation ModifyFieldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inputTf.delegate = self;
    [self resetUI];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.inputTf];
}

- (void)resetUI
{
    switch (self.fieldType)
    {
        case ModifyFieldType_Set_My_Nickname:
            self.title = @"设置昵称".lv_localized;
            self.titleLabel.text = @"昵称".lv_localized;
            self.inputTf.placeholder = @"填写您的昵称".lv_localized;
            //输入框最大字符数-12字符
            [self.inputTf setMylimitCount:@12];
            self.inputTf.text = [UserInfo shareInstance].displayName;
            break;
        case ModifyFieldType_Set_My_Username:
            self.title = @"设置用户名".lv_localized;
            self.titleLabel.text = @"用户名".lv_localized;
            self.inputTf.placeholder = @"填写您的用户名".lv_localized;
            self.inputTf.keyboardType = UIKeyboardTypeASCIICapable;
            self.inputTf.text = [UserInfo shareInstance].username;
            self.tipsLabel.text = @"1.最小长度为5个字符。\n2.只能使用字母、数字、下划线。\n3.不能以数字开头，不能以下划线开头与结尾。".lv_localized;
            break;
        case ModifyFieldType_Set_Group_Name:
            self.title = @"设置群组名称".lv_localized;
            self.titleLabel.text = @"群组名称".lv_localized;
            self.inputTf.placeholder = @"填写群组名称".lv_localized;
            //输入框最大字符数-12字符
            [self.inputTf setMylimitCount:@12];
            self.inputTf.text = self.prevValueString;
            break;
        case ModifyFieldType_Set_User_NickName:
            self.title = @"设置备注".lv_localized;
            self.titleLabel.text = @"备注".lv_localized;
            self.inputTf.placeholder = @"填写备注".lv_localized;
            //输入框最大字符数-12字符
            [self.inputTf setMylimitCount:@12];
            self.inputTf.text = self.prevValueString;
            break;
        default:
            break;
    }
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(0, 0, 55, 29);
    [okBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
    if(Is_Special_Theme)
    {
        [okBtn setBackgroundColor:COLOR_NAV_TINT_COLOR];
        [okBtn setTitleColor:COLOR_CG1 forState:UIControlStateNormal];
    }
    else
    {
        [okBtn setBackgroundColor:COLOR_CG1];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [okBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    okBtn.layer.masksToBounds = YES;
    okBtn.layer.cornerRadius = 4;
    [okBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:okBtn];
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self click_ok];
    return YES;
}

//- (void)textFiledEditChanged:(NSNotification*)notification
//{
//    if (ModifyFieldType_Set_My_Username == self.fieldType)
//    {
//        UITextField *textField = notification.object;
//        NSString *str = textField.text;
//        for (int i = 0; i<str.length; i++)
//        {
//            NSString *string = [str substringFromIndex:i];
//            NSString *regex = @"[\u4e00-\u9fa5]{0,}$"; // 中文
//            NSPredicate *predicateRe1 = [NSPredicate predicateWithFormat:@"self matches %@", regex];
//            //匹配字符串
//            BOOL resualt = [predicateRe1 evaluateWithObject:string];
//            if (resualt)
//            {
//                //是中文替换为空字符串
//                str =  [str stringByReplacingOccurrencesOfString:[str substringFromIndex:i] withString:@""];
//            }
//        }
//        textField.text = str;
//    }
//}

@end

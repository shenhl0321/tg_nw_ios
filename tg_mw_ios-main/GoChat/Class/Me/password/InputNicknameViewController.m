//
//  InputNicknameViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/10/27.
//

#import "InputNicknameViewController.h"

@interface InputNicknameViewController ()<BusinessListenerProtocol>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTf;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTf;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@end

@implementation InputNicknameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //国际化
    self.title = @"设置昵称".lv_localized;
    //设置按钮样式
    [self setCommitBtnUI];
}

- (void)setCommitBtnUI
{
    self.commitBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:30/255.0 blue:0/255.0 alpha:1.0];
    self.commitBtn.layer.cornerRadius = 7;
    self.commitBtn.layer.masksToBounds = YES;
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
- (IBAction)click_commit:(id)sender
{
    //phone
    NSString *firstName = self.firstNameTf.text;
    firstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(firstName.length<=0)
    {
        [UserInfo showTips:self.view des:@"请输入您的昵称".lv_localized];
        return;
    }
    
    //phone
//    NSString *lastName = self.lastNameTf.text;
//    lastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if(lastName.length<=0)
//    {
//        [UserInfo showTips:self.view des:@"请输入您的姓氏"];
//        return;
//    }
    
    [UserInfo show];
    [[TelegramManager shareInstance] registerUser:firstName lastName:@"" result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if(![TelegramManager isResultOk:response])
        {
            NSLog(@"registerUser fail......");
            [UserInfo showTips:self.view des:@"设置昵称失败".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        NSLog(@"registerUser timeout......");
        [UserInfo showTips:self.view des:@"请求超时，请检查网络是否正常".lv_localized];
    }];
}

- (void)setUserPassword
{
    [[TelegramManager shareInstance] checkAuthenticationPassword:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultOk:response])
        {
            NSLog(@"setUserPassword fail......");
        }
    } timeout:^(NSDictionary *request) {
        NSLog(@"setUserPassword timeout......");
    }];
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Input_Password):
        {
            [self setUserPassword];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //清理数据
            [AuthUserManager cleanDestroyFolder];
            //登录
            if([UserInfo shareInstance].isPasswordLoginType)
            {
                if(!IsStrEmpty([UserInfo shareInstance].phone_number))
                {
                    [[AuthUserManager shareInstance] login:[UserInfo shareInstance].phone_number data_directory:[UserInfo shareInstance].data_directory];
                }
                else
                {
                    [[AuthUserManager shareInstance] login:self.curUsername data_directory:[UserInfo shareInstance].data_directory];
                }
            }
            else
            {
                [[AuthUserManager shareInstance] login:[NSString stringWithFormat:@"%@%@", self.curCountryCode, self.curPhone] data_directory:[UserInfo shareInstance].data_directory];
            }
            //goto home view
            [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
            break;
        }
        default:
            break;
    }
}

@end

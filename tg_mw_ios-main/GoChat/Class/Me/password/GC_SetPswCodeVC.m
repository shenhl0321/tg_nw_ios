//
//  GC_SetPswCodeVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/5.
//

#import "GC_SetPswCodeVC.h"
#import "GC_SetPwInputNewPwVC.h"

@interface GC_SetPswCodeVC ()<TimerCounterDelegate>

@property (nonatomic, weak) IBOutlet UITextField *smsTf;
@property (nonatomic, weak) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic) BOOL isGotSmsCode;
@property (nonatomic) int Counter;
@property (nonatomic, strong) TimerCounter *tmCounter;

@end

@implementation GC_SetPswCodeVC

- (void)dealloc
{
    [self.tmCounter stopCountProcess];
    self.tmCounter = nil;
}

- (void)closeView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"支付密码".lv_localized];
    NSString *phone_number = [UserInfo shareInstance].phone_number;
    if ([phone_number hasPrefix:@"86"]) {
        self.phoneTF.text = [[UserInfo shareInstance].phone_number substringWithRange:NSMakeRange(2, phone_number.length - 2)];
    }else{
        self.phoneTF.text = [UserInfo shareInstance].phone_number;
    }
    
    self.phoneTF.userInteractionEnabled = NO;
    self.phoneTF.textColor = [UIColor colorTextFor23272A];
    [self.smsTf setMylimitCount:@5];
    self.smsTf.keyboardType = UIKeyboardTypeNumberPad;
    [self.smsTf becomeFirstResponder];
    self.tmCounter = [TimerCounter new];
    self.tmCounter.delegate = self;
    self.contentView.hidden = YES;
    self.nextBtn.clipsToBounds = YES;
    self.nextBtn.layer.cornerRadius = 13;
    self.nextBtn.backgroundColor = [UIColor colorMain];
}

- (IBAction)click_next:(id)sender
{
    if(!self.isGotSmsCode)
    {
        [UserInfo showTips:self.view des:@"请先获取短信验证码".lv_localized];
        return;
    }
    
    NSString *smsCode = self.smsTf.text;
    smsCode = [smsCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    
    GC_SetPwInputNewPwVC *vc = [[GC_SetPwInputNewPwVC alloc] init];
    vc.smsCode = smsCode;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)click_sendCode:(id)sender
{
    [UserInfo show];
    [[TelegramManager shareInstance] gotSmsCode:SmsCodeType_SetWalletPassword resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if([obj boolValue])
        {
            self.isGotSmsCode = YES;
            [UserInfo showTips:nil des:@"验证码已发送，请查收".lv_localized];
            [self startCounter];
        }
        else
        {
            [UserInfo showTips:nil des:@"验证码获取失败，请稍后重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"验证码获取失败，请稍后重试".lv_localized];
    }];
}

- (void)startCounter
{
    self.Counter = 60*5;
    self.sendCodeBtn.enabled = NO;
    [self.tmCounter stopCountProcess];
    [self.tmCounter startCountProcess:1 repeat:YES];
    NSLog(@"添加好友 - dddddddddd");
}

- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm
{
    self.Counter--;
    if(self.Counter<=0)
    {
        self.sendCodeBtn.enabled = YES;
        [self.sendCodeBtn setTitle:@"获取验证码".lv_localized forState:UIControlStateNormal];
        [self.tmCounter stopCountProcess];
    }
    else
    {
        [self.sendCodeBtn setTitle:[Common timeFormattedForRp:self.Counter] forState:UIControlStateNormal];
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

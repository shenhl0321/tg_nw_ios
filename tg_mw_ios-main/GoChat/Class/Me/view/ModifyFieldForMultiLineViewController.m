//
//  ModifyFieldForMultiLineViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/12/4.
//

#import "ModifyFieldForMultiLineViewController.h"
#import "UITextView+Placeholder.h"

@interface ModifyFieldForMultiLineViewController ()<BusinessListenerProtocol>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextView *inputText;
@property (nonatomic, strong) MessageInfo *sendingMsg;
@property (nonatomic,strong) NSArray *keysWords;
@property (nonatomic,strong) UIButton *okBtn;
@end

@implementation ModifyFieldForMultiLineViewController

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    if (self.fieldType == Group_ShieldSensitiveWordsManagerStyle) {
        [self queryGroupShieldWordsWithchtid];
    }
    [self resetUI];
}

- (void)setKeysWords:(NSArray *)keysWords{
    if (keysWords) {
        _keysWords = keysWords;
        //UI
        self.inputText.text = [keysWords componentsJoinedByString:@","];
    }
}

- (void)resetUI
{
    switch (self.fieldType)
    {
        case ModifyFieldForMultiLineType_Set_Group_Pinned_Message:
        {
            self.title = @"设置群公告".lv_localized;
            self.titleLabel.text = @"群公告".lv_localized;
            self.inputText.placeholder = @"填写群公告".lv_localized;
            //输入框最大字符数-4000字符
            [self.inputText setMylimitCount:@4000];
            if(![@"未设置".lv_localized isEqualToString:self.prevValueString])
                self.inputText.text = self.prevValueString;
            else
                self.inputText.text = nil;
        }
            break;
        case Group_ShieldSensitiveWordsManagerStyle:
        {
            self.title = @"设置屏蔽敏感词".lv_localized;
            self.titleLabel.text = @"屏蔽敏感词".lv_localized;
            self.inputText.placeholder = @"填写需要屏蔽的敏感词,多个词用逗号分开".lv_localized;
            //输入框最大字符数-4000字符
            [self.inputText setMylimitCount:@4000];
        }
            break;
        default:
            break;
    }
    
    self.okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okBtn.frame = CGRectMake(0, 0, 55, 29);
    [self.okBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
    if(Is_Special_Theme)
    {
        [self.okBtn setBackgroundColor:COLOR_NAV_TINT_COLOR];
        [self.okBtn setTitleColor:COLOR_CG1 forState:UIControlStateNormal];
    }
    else
    {
        [self.okBtn setBackgroundColor:COLOR_CG1];
        [self.okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [self.okBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    self.okBtn.layer.masksToBounds = YES;
    self.okBtn.layer.cornerRadius = 4;
    [self.okBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.okBtn];
}

- (void)click_ok
{
    NSString *keyword = self.inputText.text;
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    switch (self.fieldType)
    {
        case ModifyFieldForMultiLineType_Set_Group_Pinned_Message:
        {
            [self setGroupPinnedMessage_step1:keyword];
        }
            break;
        case Group_ShieldSensitiveWordsManagerStyle:
        {
            keyword = [keyword stringByReplacingOccurrencesOfString:@"，" withString:@","];
            keyword = [keyword stringByReplacingOccurrencesOfString:@"。" withString:@","];
            keyword = [keyword stringByReplacingOccurrencesOfString:@"、" withString:@","];
            [self settingGroupShieldWords:keyword];
        }
            break;
        default:
            break;
    }
}

//查询
- (void)queryGroupShieldWordsWithchtid{
    [UserInfo show];
    [[TelegramManager shareInstance] queryGroupShieldWordsWithchtid:[ChatInfo toServerPeerId:self.chatId] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response]){
            //获取数据失败
        }else{
            NSArray *keys = [response objectForKey:@"data"];
            self.keysWords = keys;
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
    }];
}

//设置
- (void)settingGroupShieldWords:(NSString *)keywords{
    NSMutableArray *keys = [[keywords componentsSeparatedByString:@","] mutableCopy];
    for (NSString *itemstr in [keys copy]) {
        if (itemstr.length < 1) {
            [keys removeObject:itemstr];
        }
    }
    //发起请求
    [UserInfo show];
    [[TelegramManager shareInstance] settingGroupShieldWords:keys withchtid:[ChatInfo toServerPeerId:self.chatId] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response]){
            [UserInfo showTips:nil des:@"敏感词设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }else{
            [UserInfo showTips:nil des:@"敏感词设置成功".lv_localized];
            [self.navigationController popViewControllerAnimated:YES];
        //成功  等待状态更新
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"敏感词设置失败，请稍后重试".lv_localized];
    }];
}

- (void)setGroupPinnedMessage_step1:(NSString *)content
{
    //第一步，发送文本消息
    //第二步，设置为pinned消息
    if(!IsStrEmpty(content))
    {
        content = [NSString stringWithFormat:@"%@%@", GROUP_NOTICE_PREFIX, content];
        [UserInfo show];
        self.okBtn.enabled = NO;
        [[TelegramManager shareInstance] sendTextMessage:self.chatId replyid:0 text:content withUserInfoArr:nil replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            self.okBtn.enabled = YES;
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else
            {
                MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:response];
                if(msg.sendState == MessageSendState_Success)
                {//发送成功
                    [self setGroupPinnedMessage_step2:msg._id];
                }
                else if(msg.sendState == MessageSendState_Pending)
                {//等待回调结果
                    self.sendingMsg = msg;
                }
                else
                {
                    [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
                }
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            self.okBtn.enabled = YES;
            [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
        }];
    }
    else
    {
        [UserInfo showTips:nil des:@"请填写群公告".lv_localized];
    }
}

- (void)setGroupPinnedMessage_step2:(long)msgId
{
    [UserInfo show];
    self.okBtn.enabled = NO;
    [[TelegramManager shareInstance] setPinMessage:self.chatId long:msgId resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        self.okBtn.enabled = YES;
        if([TelegramManager isResultOk:response])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        self.okBtn.enabled = YES;
        [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
    }];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Success):
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Fail):
        {
            //@{@"msg":msg, @"old_message_id":[dic objectForKey:@"old_message_id"]}
            NSDictionary *params = inParam;
            if(params != nil && [params isKindOfClass:[NSDictionary class]])
            {
                MessageInfo *msg = [params objectForKey:@"msg"];
                if(msg != nil && [msg isKindOfClass:[MessageInfo class]])
                {
                    if(msg.chat_id == self.chatId)
                    {//当前会话
                        long oldMsgId = -1;
                        NSNumber *old_message_id = [params objectForKey:@"old_message_id"];
                        if(old_message_id != nil && [old_message_id isKindOfClass:[NSNumber class]])
                        {
                            oldMsgId = [old_message_id longValue];
                        }
                        if(self.sendingMsg._id == oldMsgId)
                        {
                            if(msg.sendState == MessageSendState_Success)
                            {//发送成功
                                [UserInfo show];
                                [self setGroupPinnedMessage_step2:msg._id];
                            }
                            else
                            {
                                [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
                            }
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Keys_Change):
        {
            NSArray *keys = inParam;
            if (keys) {
                self.keysWords = keys;
            }
        }
            break;
        default:
            break;
    }
}

@end

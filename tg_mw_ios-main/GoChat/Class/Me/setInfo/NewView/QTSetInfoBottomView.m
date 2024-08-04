//
//  QTSetInfoBottomView.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/3/23.
//

#import "QTSetInfoBottomView.h"
#import <IQKeyboardManager.h>
#import "UIView+QT.h"

@interface QTSetInfoBottomView ()

@property (assign, nonatomic) QTSetInfoBottomType type;
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSString *contentStr;
@property (strong, nonatomic) NSString *placeStr;

@property (weak, nonatomic) IBOutlet YCShadowView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (strong, nonatomic) NSString *chatId;


@end

#define viewHei 260
@implementation QTSetInfoBottomView

static QTSetInfoBottomView *currentView = nil;

+(QTSetInfoBottomView *)sharedInstance {
    @synchronized(self) {
        if(!currentView) {
            currentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QTSetInfoBottomView class]) owner:nil options:nil] firstObject];
            currentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
    }
    return currentView;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.detailView yc_cornerRadius:15 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}
/// 设置
/// - Parameters:
///   - type: 类型
///   - chatId: 聊天ID
///   - titleStr: 标题
///   - contentStr: 内容
///   - placeStr: 占位符
///   - successBlock: 成功回调
- (void)alertViewType:(QTSetInfoBottomType)type ChatId:(NSString *)chatId TitleStr:(NSString *)titleStr ContentStr:(NSString *)contentStr PlaceStr:(NSString *)placeStr{
    self.chatId = chatId;
    [self alertViewType:type TitleStr:titleStr ContentStr:contentStr PlaceStr:placeStr];
}
/// 设置
/// - Parameters:
///   - type: 类型
///   - titleStr: 标题
///   - contentStr: 内容
///   - placeStr: 占位符
///   - successBlock: 成功回调
- (void)alertViewType:(QTSetInfoBottomType)type TitleStr:(NSString *)titleStr ContentStr:(NSString *)contentStr PlaceStr:(NSString *)placeStr{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:currentView];
    
    self.type = type;
    self.titleStr = titleStr;
    self.contentStr = contentStr;
    self.placeStr = placeStr;
    
    self.titleLab.text = titleStr;
    self.textField.text = contentStr;
    self.textField.placeholder = placeStr;
    [self textFieldChange];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    // UIKeyboardWillShowNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.textField addTarget:self action:@selector(textFieldChange) forControlEvents:UIControlEventEditingChanged];
}
- (void)textFieldChange{
    self.cancelBtn.hidden = IsStrEmpty(self.textField.text);
}

- (void)keyBoardWillShow:(NSNotification *)note{
    if ([IQKeyboardManager sharedManager].isEnabled == YES) {
        return;
    }
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    MJWeakSelf
    [UIView animateWithDuration:animationTime animations:^{
        //
        weakSelf.detailView.bottom = SCREEN_HEIGHT-keyBoardBounds.size.height+(viewHei-120);
    }];
}
- (void)keyBoardWillHide:(NSNotification *)note{
    if ([IQKeyboardManager sharedManager].isEnabled == YES) {
        return;
    }
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    MJWeakSelf
    [UIView animateWithDuration:animationTime animations:^{
        //
        weakSelf.detailView.bottom = SCREEN_HEIGHT;
    }];
}

- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 1){ // 取消
        [self dismiss];
    }else if (sender.tag == 2){ // 取消
        [self dismiss];
    }else if (sender.tag == 3){ // 完成
        if (IsStrEmpty(self.textField.text)){
            [UserInfo showTips:self des:self.textField.placeholder];
            return;
        }
        
//        if (self.successBlock){
//            self.successBlock(self.textField.text);
//        }else{
            [self editUserInfo];
//        }
    }else if (sender.tag == 4){ // 清空
        self.textField.text = @"";
        [self textFieldChange];
    }
}
- (void)editUserInfo{
    NSString *keyword = self.textField.text;
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.type == QT_Set_My_Nickname){ // 昵称
        [self saveMyNickName:keyword];
    }else if (self.type == QT_Set_My_Group_Nickname){ // 我在本群群昵称
        [self saveMyGroupname:keyword];
    }else if (self.type == QT_Set_Group_Nickname){ // 群昵称
        [self saveGroupName:keyword];
    }
}

// 群昵称
- (void)saveGroupName:(NSString *)name{
    MJWeakSelf
    if(!IsStrEmpty(name)){
        [UserInfo show];
        [[TelegramManager shareInstance] setGroupName:[self.chatId longLongValue] groupName:name resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response]){
                [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }else{
                [UserInfo showTips:nil des:@"群组名称设置成功".lv_localized];
                if (weakSelf.successBlock){
                    weakSelf.successBlock(name);
                }
                [weakSelf dismiss];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized];
        }];
    }else{
        [UserInfo showTips:nil des:@"请填写群组名称".lv_localized];
    }
}


// 我在本群昵称
- (void)saveMyGroupname:(NSString *)name {
    MJWeakSelf
    if(IsStrEmpty(name)) {
        [UserInfo showTips:nil des:@"请填写昵称".lv_localized];
        return;
    }
    [UserInfo show];
    
    long chatId = [self.chatId longLongValue];
    NSDictionary *param = @{
        @"@type": @"sendCustomRequest",
        @"method": @"chats.setNickname",
        @"parameters": @{
            @"chatId": @(chatId),
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
                if (weakSelf.successBlock){
                    weakSelf.successBlock(name);
                }
                [weakSelf dismiss];
            }
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"昵称设置失败，请稍后重试".lv_localized];
    }];
}

// 我的昵称
- (void)saveMyNickName:(NSString *)nickName{
    MJWeakSelf
    if(!IsStrEmpty(nickName)){
        [UserInfo show];
        [self.textField endEditing:YES];
        [[TelegramManager shareInstance] setMyNickName:nickName resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response]){
                [UserInfo showTips:nil des:@"昵称设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else{
                if (weakSelf.successBlock){
                    weakSelf.successBlock(nickName);
                }
                [weakSelf dismiss];
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

- (void)dismiss{
    [[IQKeyboardManager sharedManager] setEnable:YES];
    self.textField.text = @"";
    [self endEditing:YES];
    [self removeFromSuperview];
}

@end
